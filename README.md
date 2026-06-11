# OpenAI — User Data (GTM Variable Template)

Builds and validates the OpenAI **user data object** (`email_sha256`, `external_id_sha256`, `country`, `city`, `zip_code`) for identity matching with the [OpenAI Measurement Pixel](https://developers.openai.com/ads/measurement-pixel) and [Conversions API](https://developers.openai.com/ads/conversions-api).

## PII Guard

OpenAI's spec forbids sending raw emails or IDs. This variable enforces that:

- Email and External ID values must be **valid 64-character SHA-256 hex hashes**
- Anything else (e.g., a raw email accidentally wired in) is **dropped, never forwarded**
- Uppercase hashes are normalized to lowercase

## Normalization

| Field | Treatment |
|-------|-----------|
| `email_sha256` / `external_id_sha256` | trimmed, lowercased, hex-validated |
| `country` | trimmed, uppercased, must be exactly 2 letters |
| `city` | trimmed, lowercased, truncated to 128 chars |
| `zip_code` | trimmed, truncated to 32 chars |

Returns `undefined` when no valid fields remain.

## Hashing Note

GTM web variables are synchronous, so this template **cannot hash raw emails itself** (the sandbox `sha256` API is async). Provide pre-hashed values — or enter the raw email directly in the OpenAI Measurement Pixel tag, which hashes automatically.

## License

Apache 2.0 — see [LICENSE](LICENSE).
