# 8. Choose frontend technology

Date: 2025-08-26

## Status

Accepted

## Context

Business drivers and quality attributes:
- Build interactive analytics dashboards, charts, and segment explorers with fast perceived performance.
- Support SEO for public docs/marketing pages and authenticated app for tenants; internationalization later.
- Strong type-safety and maintainability, large ecosystem for charting and data grid components.
- Easy deployment on Kubernetes/CDN per ADR-0005; prefer portability and low lock-in.

Architectural tactics influencing the choice:
- Server-side rendering (SSR)/static generation (SSG) for SEO and fast first paint; incremental static regen (ISR) for low-cost freshness on docs.
- Client-side interactivity and streaming for dashboard pages; efficient data fetching and caching.
- TypeScript for end-to-end type-safety; shared types with Web API SDKs.
- Component library and utility CSS for consistent, accessible UI with rapid iteration.

Comparison of alternatives (higher is better):

| Stack / Criteria                        | Performance (TTFB/FP/TBT) | SSR/SSG/ISR & SEO | DX & productivity | Type-safety & tooling | Charting & ecosystem | Routing/data & caching | Deployability (CDN/K8s) | Portability & lock-in |
|-----------------------------------------|---------------------------|-------------------|-------------------|-----------------------|----------------------|------------------------|-------------------------|----------------------|
| React + Next.js (App Router) + TS       | ★★★                       | ★★★               | ★★★               | ★★★                   | ★★★                  | ★★★                    | ★★★                     | ★★                   |
| React + Remix + TS                      | ★★                        | ★★                | ★★                | ★★★                   | ★★★                  | ★★★                    | ★★★                     | ★★                   |
| Svelte + SvelteKit + TS                 | ★★★                       | ★★★               | ★★                | ★★                    | ★★                   | ★★                     | ★★★                     | ★★★                  |
| Vue + Nuxt + TS                         | ★★                        | ★★★               | ★★                | ★★                    | ★★                   | ★★                     | ★★★                     | ★★                   |
| Angular                                 | ★★                        | ★★                | ★★                | ★★                    | ★★                   | ★★                     | ★★★                     | ★★                   |
| React SPA (Vite) + TS (CSR only)        | ★★                        | ★                 | ★★                | ★★★                   | ★★★                  | ★★                     | ★★★                     | ★★★                  |

Notes:
- Next.js offers mature SSR/SSG/ISR, RSC, streaming, route handlers, and built-in image/font optimizations, with a large React ecosystem (charts, grids, SDKs). Remix is strong for web fundamentals but less standard at scale; SvelteKit is efficient but with a smaller ecosystem.

## Decision

Adopt React with Next.js (App Router) and TypeScript for the frontend application. Use server components and SSR/SSG/ISR where appropriate: static/ISR for public docs/marketing, SSR/streaming for authenticated dashboards, and client components for interactive charts. Use a mainstream component system (e.g., Radix UI + Tailwind CSS) and a proven charting library (e.g., Apache ECharts or Recharts) based on use case fit. Co-generate API types from the Web API schemas to ensure type-safe clients.

## Consequences

Positive:
- Excellent performance and UX via SSR/SSG/ISR and streaming; vast ecosystem for charts, tables, and auth/integrations.
- Strong TypeScript support and tooling; easy deployment on CDN/K8s; aligns with team skills and hiring market.
- Flexibility to optimize per page (RSC, edge/server runtimes) and share types with backend SDKs.

Negative / risks:
- React/Next.js adds complexity (RSC boundaries, data fetching patterns); requires conventions and linting.
- Potential framework churn; keep dependencies minimal and avoid deep vendor lock-in features.
- Tailwind + component libs require design discipline to avoid inconsistency; enforce design tokens and linting.

