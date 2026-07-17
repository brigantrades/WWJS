import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const PACKAGE_NAME = "com.wwjs.wwjs";
const PRODUCT_ID = "wwjs_full_access";
const GOOGLE_SCOPE = "https://www.googleapis.com/auth/androidpublisher";

type ServiceAccount = {
  client_email: string;
  private_key: string;
  token_uri?: string;
};

type SubscriptionLineItem = {
  productId?: string;
  expiryTime?: string;
  offerDetails?: { basePlanId?: string };
};

type SubscriptionPurchase = {
  subscriptionState?: string;
  linkedPurchaseToken?: string;
  lineItems?: SubscriptionLineItem[];
};

let cachedGoogleToken: { value: string; expiresAt: number } | null = null;

function json(body: unknown, status = 200): Response {
  return Response.json(body, { status });
}

function base64Url(value: Uint8Array | string): string {
  const bytes = typeof value === "string" ? new TextEncoder().encode(value) : value;
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replace(/=+$/, "");
}

function decodeServiceAccount(): ServiceAccount {
  const encoded = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64");
  if (!encoded) throw new Error("Google Play credentials are not configured.");
  return JSON.parse(atob(encoded)) as ServiceAccount;
}

function pemBytes(pem: string): Uint8Array {
  const encoded = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replaceAll(/\s/g, "");
  return Uint8Array.from(atob(encoded), (character) => character.charCodeAt(0));
}

async function googleAccessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedGoogleToken && cachedGoogleToken.expiresAt > now + 60) {
    return cachedGoogleToken.value;
  }

  const serviceAccount = decodeServiceAccount();
  const tokenUri = serviceAccount.token_uri ?? "https://oauth2.googleapis.com/token";
  const header = base64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = base64Url(
    JSON.stringify({
      iss: serviceAccount.client_email,
      scope: GOOGLE_SCOPE,
      aud: tokenUri,
      iat: now,
      exp: now + 3600,
    }),
  );
  const unsigned = `${header}.${claims}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemBytes(serviceAccount.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const assertion = `${unsigned}.${base64Url(new Uint8Array(signature))}`;
  const response = await fetch(tokenUri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!response.ok) {
    console.error("Google OAuth failed", response.status, await response.text());
    throw new Error("Unable to authenticate with Google Play.");
  }
  const payload = await response.json() as { access_token: string; expires_in?: number };
  cachedGoogleToken = {
    value: payload.access_token,
    expiresAt: now + (payload.expires_in ?? 3600),
  };
  return payload.access_token;
}

async function fetchSubscription(
  purchaseToken: string,
  allowNotFound = false,
): Promise<SubscriptionPurchase | null> {
  const accessToken = await googleAccessToken();
  const endpoint =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}` +
    `/purchases/subscriptionsv2/tokens/${encodeURIComponent(purchaseToken)}`;
  const response = await fetch(endpoint, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (!response.ok) {
    console.error("Google Play verification failed", response.status, await response.text());
    if (allowNotFound && (response.status === 404 || response.status === 410)) {
      return null;
    }
    if (response.status === 401 || response.status === 403) {
      throw new Error("Google Play API access is not authorized.");
    }
    throw new Error(
      response.status === 404 || response.status === 410
        ? "Google Play could not find this purchase."
        : "Google Play could not verify this purchase.",
    );
  }
  return await response.json() as SubscriptionPurchase;
}

async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value));
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

function entitlementFrom(subscription: SubscriptionPurchase) {
  const matchingItems = (subscription.lineItems ?? []).filter(
    (item) => item.productId === PRODUCT_ID,
  );
  const expiryTimes = matchingItems
    .map((item) => item.expiryTime)
    .filter((value): value is string => Boolean(value))
    .map((value) => new Date(value));
  const expiresAt = expiryTimes.sort((a, b) => b.getTime() - a.getTime())[0] ?? null;
  const state = subscription.subscriptionState ?? "SUBSCRIPTION_STATE_UNSPECIFIED";
  const accessStates = new Set([
    "SUBSCRIPTION_STATE_ACTIVE",
    "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
    "SUBSCRIPTION_STATE_CANCELED",
  ]);
  const isEntitled = matchingItems.length > 0 &&
    accessStates.has(state) &&
    expiresAt != null &&
    expiresAt.getTime() > Date.now();

  return {
    isEntitled,
    state,
    expiresAt: expiresAt?.toISOString() ?? null,
    basePlanId: matchingItems[0]?.offerDetails?.basePlanId ?? null,
  };
}

function adminKey(): string {
  const legacy = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (legacy) return legacy;
  const keys = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (!keys) throw new Error("Supabase server credentials are not configured.");
  return (JSON.parse(keys) as Record<string, string>).default;
}

Deno.serve(async (request: Request) => {
  if (request.method !== "POST") return json({ error: "Method not allowed." }, 405);

  try {
    const authorization = request.headers.get("Authorization");
    if (!authorization) return json({ error: "Authentication required." }, 401);

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const userClient = createClient(
      supabaseUrl,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authorization } } },
    );
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) return json({ error: "Authentication required." }, 401);
    if (user.app_metadata?.wwjs_premium_override === true) {
      return json({
        isEntitled: true,
        expiresAt: null,
        productId: "admin_override",
      });
    }

    const admin = createClient(supabaseUrl, adminKey(), {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const body = await request.json() as {
      action?: string;
      productId?: string;
      purchaseToken?: string;
    };

    let purchaseToken: string;
    if (body.action === "status") {
      const { data, error } = await admin
        .from("google_play_entitlements")
        .select("purchase_token")
        .eq("user_id", user.id)
        .order("updated_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      if (error) throw error;
      if (!data) return json({ isEntitled: false });
      purchaseToken = data.purchase_token as string;
    } else if (body.action === "verify") {
      if (body.productId !== PRODUCT_ID || !body.purchaseToken) {
        return json({ error: "Invalid purchase details." }, 400);
      }
      purchaseToken = body.purchaseToken;
    } else {
      return json({ error: "Invalid action." }, 400);
    }

    const tokenHash = await sha256(purchaseToken);
    const subscription = await fetchSubscription(
      purchaseToken,
      body.action === "status",
    );
    if (!subscription) {
      const now = new Date().toISOString();
      const { error } = await admin
        .from("google_play_entitlements")
        .update({
          subscription_state: "SUBSCRIPTION_STATE_EXPIRED",
          is_entitled: false,
          last_verified_at: now,
          updated_at: now,
        })
        .eq("purchase_token_hash", tokenHash);
      if (error) throw error;
      return json({ isEntitled: false });
    }
    const entitlement = entitlementFrom(subscription);
    const linkedTokenHash = subscription.linkedPurchaseToken
      ? await sha256(subscription.linkedPurchaseToken)
      : null;

    if (linkedTokenHash) {
      const { error } = await admin
        .from("google_play_entitlements")
        .update({ is_entitled: false, updated_at: new Date().toISOString() })
        .eq("purchase_token_hash", linkedTokenHash);
      if (error) throw error;
    }

    const now = new Date().toISOString();
    const { error: upsertError } = await admin
      .from("google_play_entitlements")
      .upsert({
        purchase_token_hash: tokenHash,
        purchase_token: purchaseToken,
        user_id: user.id,
        product_id: PRODUCT_ID,
        base_plan_id: entitlement.basePlanId,
        subscription_state: entitlement.state,
        expires_at: entitlement.expiresAt,
        is_entitled: entitlement.isEntitled,
        linked_purchase_token_hash: linkedTokenHash,
        last_verified_at: now,
        updated_at: now,
      }, { onConflict: "purchase_token_hash" });
    if (upsertError) throw upsertError;

    return json(entitlement);
  } catch (error) {
    console.error(error);
    return json({ error: error instanceof Error ? error.message : "Billing verification failed." }, 500);
  }
});
