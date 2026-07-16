import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2.110.5";
import {
  entitlementRow,
  fetchAppleEntitlement,
  verifyNotification,
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
    const body = await request.json() as { signedPayload?: string };
    if (!body.signedPayload) return json({ error: "Missing signed payload." }, 400);

    const notification = await verifyNotification(body.signedPayload);
    const signedTransaction = notification.data?.signedTransactionInfo;
    if (!signedTransaction) return json({ received: true });

    const transaction = await verifyTransaction(signedTransaction);
    if (
      !transaction.transactionId ||
      !transaction.originalTransactionId ||
      !transaction.environment
    ) {
      return json({ error: "Incomplete App Store transaction." }, 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const admin = createClient(supabaseUrl, adminKey(), {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: existing, error: existingError } = await admin
      .from("apple_storekit_entitlements")
      .select("user_id")
      .eq("original_transaction_id", transaction.originalTransactionId)
      .maybeSingle();
    if (existingError) throw existingError;
    if (!existing) return json({ received: true });

    const entitlement = await fetchAppleEntitlement(
      transaction.transactionId,
      transaction.environment,
      transaction.originalTransactionId,
    );
    if (!entitlement) return json({ received: true });

    const { error: upsertError } = await admin
      .from("apple_storekit_entitlements")
      .upsert(entitlementRow(entitlement, existing.user_id as string), {
        onConflict: "original_transaction_id",
      });
    if (upsertError) throw upsertError;
    return json({ received: true });
  } catch (error) {
    console.error(error);
    return json({ error: "Invalid App Store notification." }, 400);
  }
});
