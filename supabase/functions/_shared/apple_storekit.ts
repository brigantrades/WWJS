import { Buffer } from "node:buffer";
import {
  AppStoreServerAPIClient,
  Environment,
  SignedDataVerifier,
  type JWSTransactionDecodedPayload,
  type ResponseBodyV2DecodedPayload,
} from "npm:@apple/app-store-server-library@3.1.0";

export const APPLE_PRODUCT_IDS = new Set([
  "wwjs_full_access_monthly",
  "wwjs_full_access_yearly",
]);

const APPLE_ROOT_CA_G3_BASE64 =
  "MIICQzCCAcmgAwIBAgIILcX8iNLFS5UwCgYIKoZIzj0EAwMwZzEbMBkGA1UEAwwSQXBwbGUgUm9vdCBDQSAtIEczMSYwJAYDVQQLDB1BcHBsZSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTETMBEGA1UECgwKQXBwbGUgSW5jLjELMAkGA1UEBhMCVVMwHhcNMTQwNDMwMTgxOTA2WhcNMzkwNDMwMTgxOTA2WjBnMRswGQYDVQQDDBJBcHBsZSBSb290IENBIC0gRzMxJjAkBgNVBAsMHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzB2MBAGByqGSM49AgEGBSuBBAAiA2IABJjpLz1AcqTtkyJygRMc3RCV8cWjTnHcFBbZDuWmBSp3ZHtfTjjTuxxEtX/1H7YyYl3J6YRbTzBPEVoA/VhYDKX1DyxNB0cTddqXl5dvMVztK517IDvYuVTZXpmkOlEKMaNCMEAwHQYDVR0OBBYEFLuw3qFYM4iapIqZ3r6966/ayySrMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMAoGCCqGSM49BAMDA2gAMGUCMQCD6cHEFl4aXTQY2e3v9GwOAEZLuN+yRhHFD/3meoyhpmvOwgPUnPWTxnS4at+qIxUCMG1mihDK1A3UT82NQz60imOlM27jbdoXt2QfyFMm+YhidDkLF1vLUagM6BgD56KyKA==";

type LastTransaction = {
  status?: number;
  originalTransactionId?: string;
  signedTransactionInfo?: string;
};

type StatusResponse = {
  data?: Array<{ lastTransactions?: LastTransaction[] }>;
};

export type AppleEntitlement = {
  originalTransactionId: string;
  latestTransactionId: string;
  productId: string;
  environment: "Production" | "Sandbox";
  subscriptionStatus: number;
  appAccountToken: string | null;
  expiresAt: string | null;
  revocationDate: string | null;
  isEntitled: boolean;
};

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not configured.`);
  return value;
}

function appAppleId(): number {
  const value = Number(requiredEnv("APPLE_IAP_APP_ID"));
  if (!Number.isSafeInteger(value)) throw new Error("APPLE_IAP_APP_ID is invalid.");
  return value;
}

function privateKey(): string {
  return atob(requiredEnv("APPLE_IAP_PRIVATE_KEY_BASE64"));
}

function verifier(environment: Environment): SignedDataVerifier {
  return new SignedDataVerifier(
    [Buffer.from(APPLE_ROOT_CA_G3_BASE64, "base64")],
    false,
    environment,
    requiredEnv("APPLE_IAP_BUNDLE_ID"),
    environment === Environment.PRODUCTION ? appAppleId() : undefined,
  );
}

function apiClient(environment: Environment): AppStoreServerAPIClient {
  return new AppStoreServerAPIClient(
    privateKey(),
    requiredEnv("APPLE_IAP_KEY_ID"),
    requiredEnv("APPLE_IAP_ISSUER_ID"),
    requiredEnv("APPLE_IAP_BUNDLE_ID"),
    environment,
  );
}

function decodeUnverifiedPayload(jws: string): Record<string, unknown> {
  const part = jws.split(".")[1];
  if (!part) throw new Error("Malformed Apple signed payload.");
  const normalized = part.replaceAll("-", "+").replaceAll("_", "/");
  const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, "=");
  return JSON.parse(atob(padded)) as Record<string, unknown>;
}

function environmentFromValue(value: unknown): Environment {
  if (value === Environment.PRODUCTION || value === "Production") {
    return Environment.PRODUCTION;
  }
  if (value === Environment.SANDBOX || value === "Sandbox") {
    return Environment.SANDBOX;
  }
  throw new Error("Unsupported App Store environment.");
}

export function environmentName(
  environment: Environment | string | undefined,
): "Production" | "Sandbox" {
  return environmentFromValue(environment) === Environment.PRODUCTION
    ? "Production"
    : "Sandbox";
}

export async function verifyTransaction(
  signedTransaction: string,
): Promise<JWSTransactionDecodedPayload> {
  const unverified = decodeUnverifiedPayload(signedTransaction);
  return await verifier(environmentFromValue(unverified.environment))
    .verifyAndDecodeTransaction(signedTransaction);
}

export async function verifyNotification(
  signedPayload: string,
): Promise<ResponseBodyV2DecodedPayload> {
  const unverified = decodeUnverifiedPayload(signedPayload);
  const data = unverified.data as Record<string, unknown> | undefined;
  return await verifier(environmentFromValue(data?.environment))
    .verifyAndDecodeNotification(signedPayload);
}

function iso(milliseconds: number | undefined): string | null {
  return milliseconds == null ? null : new Date(milliseconds).toISOString();
}

export async function fetchAppleEntitlement(
  transactionId: string,
  environment: Environment | string,
  expectedOriginalTransactionId?: string,
): Promise<AppleEntitlement | null> {
  const normalizedEnvironment = environmentFromValue(environment);
  const response = await apiClient(normalizedEnvironment)
    .getAllSubscriptionStatuses(transactionId) as StatusResponse;
  const candidates: Array<{
    status: number;
    transaction: JWSTransactionDecodedPayload;
  }> = [];

  for (const group of response.data ?? []) {
    for (const item of group.lastTransactions ?? []) {
      if (!item.signedTransactionInfo || item.status == null) continue;
      const transaction = await verifier(normalizedEnvironment)
        .verifyAndDecodeTransaction(item.signedTransactionInfo);
      if (!transaction.productId || !APPLE_PRODUCT_IDS.has(transaction.productId)) {
        continue;
      }
      if (
        expectedOriginalTransactionId &&
        transaction.originalTransactionId !== expectedOriginalTransactionId
      ) {
        continue;
      }
      candidates.push({ status: Number(item.status), transaction });
    }
  }

  candidates.sort((left, right) => {
    const leftActive = left.status === 1 || left.status === 4 ? 1 : 0;
    const rightActive = right.status === 1 || right.status === 4 ? 1 : 0;
    return rightActive - leftActive ||
      (right.transaction.expiresDate ?? 0) - (left.transaction.expiresDate ?? 0);
  });
  const selected = candidates[0];
  if (!selected) return null;

  const transaction = selected.transaction;
  if (
    !transaction.originalTransactionId ||
    !transaction.transactionId ||
    !transaction.productId
  ) {
    throw new Error("Apple returned incomplete transaction data.");
  }
  const hasAccessStatus = selected.status === 1 || selected.status === 4;
  const isEntitled = hasAccessStatus &&
    transaction.revocationDate == null &&
    (transaction.expiresDate ?? 0) > Date.now();

  return {
    originalTransactionId: transaction.originalTransactionId,
    latestTransactionId: transaction.transactionId,
    productId: transaction.productId,
    environment: environmentName(transaction.environment),
    subscriptionStatus: selected.status,
    appAccountToken: transaction.appAccountToken ?? null,
    expiresAt: iso(transaction.expiresDate),
    revocationDate: iso(transaction.revocationDate),
    isEntitled,
  };
}

export function entitlementRow(entitlement: AppleEntitlement, userId: string) {
  const now = new Date().toISOString();
  return {
    original_transaction_id: entitlement.originalTransactionId,
    latest_transaction_id: entitlement.latestTransactionId,
    user_id: userId,
    product_id: entitlement.productId,
    environment: entitlement.environment,
    subscription_status: entitlement.subscriptionStatus,
    app_account_token: entitlement.appAccountToken,
    expires_at: entitlement.expiresAt,
    revocation_date: entitlement.revocationDate,
    is_entitled: entitlement.isEntitled,
    last_verified_at: now,
    updated_at: now,
  };
}

export function entitlementJson(entitlement: AppleEntitlement) {
  return {
    isEntitled: entitlement.isEntitled,
    expiresAt: entitlement.expiresAt,
    productId: entitlement.productId,
  };
}
