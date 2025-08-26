# 2. Choose URL shortening algorithm

Date: 2025-08-26

## Status

Accepted

## Context

Business drivers and quality attributes:
- Throughput: ~100M new short links per year, retained for 3 years (≈300M total). Reads dominate (≈10 visits/link/day). Redirect latency target ≤ 0.2s.
- Availability and scalability: tolerate failure of any two nodes with ≤ 0.1s added latency, seamless releases.
- Security/abuse resistance: slugs should be hard to guess to reduce enumeration and abuse.
- Operability: simple, horizontally scalable, even key distribution to avoid hotspots.
- Usability: short, human-friendly slugs; allow custom aliases separately.

Tactics considered: unique identifier generation strategies that balance short length, low collision probability at 300M scale, unpredictability, and even partition distribution. Options compared below.

| Alternative / Criteria | Collision risk @300M | Predictability / guessability | Hotspot / partition distribution | Read cache friendliness | Determinism (same long→same short) | Complexity / ops | Slug length | Multi-region suitability | Abuse resistance | Overall fit |
|------------------------|----------------------|-------------------------------|----------------------------------|------------------------|-------------------------------------|------------------|-------------|--------------------------|------------------|-------------|
| Global counter + Base62 (numeric ID → Base62 conversion) | ★★ Requires strong uniqueness infra; no collisions if atomic | ★ Predictable, easily enumerable | ★ Hotspots on counter owner unless sharded | ★★★ Good locality | ★★★ Deterministic | ★ Needs global lock/txn or sharded counters | ★★★ 6–8+ possible | ★ Sharded counters hard cross-region | ★ Weak (enumerable) | ★ |
| Random Base62 token (7–8) + unique index | ★★ Expected rare retries; manageable at 300M | ★★★ Unpredictable, hard to enumerate | ★★★ Uniform distribution by hash | ★★ No time order | ★ Non-deterministic | ★★★ Simple, no central coordinator | ★★★ 7–8 chars | ★★★ Works with multi-writer, per-region | ★★★ Strong | ★★★ |
| Hash(long URL)+salt truncated (Base62) | ★★ Low but non-zero; depends on truncation | ★★★ With secret salt, hard to guess | ★★ Depends on hash; uniform | ★★ No time order | ★★★ Deterministic (per salt) | ★★ Need salt mgmt; collision handling path | ★★ Length tied to truncation | ★★★ Good; no coordinator | ★★★ Strong | ★★ |
| Snowflake/KSUID time-based ID + Base62 | ★★★ No collisions by design | ★★ Partly predictable (time-ordered) | ★★ Can hotspot by time; k-sorted | ★★★ Good locality in caches | ★ Non-deterministic | ★★ Requires clock/worker config | ★★ Typically 10–12+ chars | ★★ Requires careful clock/IDs cross-region | ★★ Medium | ★★ |

Legend: ★ weak, ★★ medium, ★★★ strong.

Note: “Global counter + Base62” explicitly means generating a monotonic numeric ID (e.g., DB sequence, sharded counters, or Snowflake-like numeric form) and converting it to a short Base62 string by repeated division/mod or table lookup. This yields the shortest slugs for a given numeric range but is predictable and enumerable.

## Decision

Use a random Base62 slug of length 7 (expandable to 8) generated with a high-quality RNG (e.g., NanoID) and enforced uniqueness via a datastore unique index. On conflict, retry generation (bounded attempts, then escalate). Reserve support for user-defined custom aliases out-of-band.

Rationale:
- Unpredictable slugs reduce enumeration and abuse while providing even key distribution across partitions.
- For ~300M slugs, 7 chars (62^7 ≈ 3.52e12) yields an expected collision retry rate well under 0.01%; operationally negligible. If growth exceeds projections or collision rate rises, increase length to 8 without breaking existing links.
- No global coordinator or clock sync is required; works well with multi-writer, multi-region setups using per-region databases or a globally distributed store.

Key parameters:
- Alphabet: [0-9A-Za-z] (62 symbols). Length: 7 (feature-flag to 8).
- Generator: cryptographically secure or high-quality PRNG (e.g., NanoID). Retry on unique constraint violation.
- DB: unique index on slug; optional namespace/account prefix only for multi-tenant isolation when needed.

## Consequences

Positive:
- Short, human-friendly, unguessable slugs; even distribution avoids hotspots and supports horizontal scaling.
- Simple implementation and operations; no central ID service.
- Collision handling is trivial with retries; length can be increased without migration.

Negative:
- Mapping is not deterministic; identical long URLs may produce different slugs (unless dedup is implemented separately).
- Requires a uniqueness check on write (slight write amplification under rare collisions).
- Slugs carry no temporal information, so time-based analytics require separate metadata.
