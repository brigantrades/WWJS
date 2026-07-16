import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2.110.5";
import {
  APPLE_PRODUCT_IDS,
  entitlementJson,
  entitlementRow,
  fetchAppleEntitlement,
  verifyTransaction,
} from "../_shared/apple_storekit.ts";

function json(body: unknown, status = 200): Response {
  return Response.json(body, { status });
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

    const admin = createClient(supabaseUrl, adminKey(), {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const body = await request.json() as {
      action?: string;
      productId?: string;
      signedTransaction?: string;
      restored?: boolean;
    };

    let transactionId: string;
    let environment: string;
    let expectedOriginalTransactionId: string | undefined;

    if (body.action === "status") {
      const { data, error } = await admin
        .from("apple_storekit_entitlements")
        .select("original_transaction_id, latest_transaction_id, environment")
        .eq("user_id", user.id)
        .order("updated_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      if (error) throw error;
      if (!data) return json({ isEntitled: false });
      transactionId = data.latest_transaction_id as string;
      environment = data.environment as string;
      expectedOriginalTransactionId = data.original_transaction_id as string;
    } else if (body.action === "verify") {
      if (
        !body.productId ||
        !APPLE_PRODUCT_IDS.has(body.productId) ||
        !body.signedTransaction
      ) {
        return json({ error: "Invalid purchase details." }, 400);
      }
      const transaction = await verifyTransaction(body.signedTransaction);
      if (
        transaction.productId !== body.productId ||
        !transaction.transactionId ||
        !transaction.originalTransactionId ||
        !transaction.environment
      ) {
        return json({ error: "The App Store transaction does not match this purchase." }, 400);
      }
      if (!body.restored && transaction.appAccountToken !== user.id) {
        return json({ error: "The App Store purchase belongs to another app account." }, 403);
      }
      transactionId = transaction.transactionId;
      environment = transaction.environment as string;
      expectedOriginalTransactionId = transaction.originalTransactionId;
    } else {
      return json({ error: "Invalid action." }, 400);
    }

    const entitlement = await fetchAppleEntitlement(
      transactionId,
      environment,
      expectedOriginalTransactionId,
    );
    if (!entitlement) return json({ isEntitled: false });

    const { data: existing, error: existingError } = await admin
      .from("apple_storekit_entitlements")
      .select("user_id")
      .eq("original_transaction_id", entitlement.originalTransactionId)
      .maybeSingle();
    if (existingError) throw existingError;
    if (
      existing &&
      existing.user_id !== user.id &&
      !(body.action === "verify" && body.restored === true)
    ) {
      return json({ error: "This subscription is linked to another app account." }, 403);
    }

    const { error: upsertError } = await admin
      .from("apple_storekit_entitlements")
      .upsert(entitlementRow(entitlement, user.id), {
        onConflict: "original_transaction_id",
      });
    if (upsertError) throw upsertError;

    return json(entitlementJson(entitlement));
  } catch (error) {
    console.error(error);
    return json({
      error: error instanceof Error
        ? error.message
        : "App Store billing verification failed.",
    }, 500);
  }
});
