# Baby Log MVP Implementation Plan

## Final Pre-Implementation Decisions

- Profiles are created by a database trigger on `auth.users`.
- The app does not manually insert `profiles` during signup.
- `updated_at` is maintained by database triggers on every mutable app table.
- Open sleep duplication is blocked by the required partial unique index `one_open_sleep_per_child`.
- Record storage uses type-specific tables: `feeding_records`, `sleep_records`, and `diaper_records`.

Type-specific tables are the chosen option because each record type has different required fields and validation rules. This keeps forms, RLS, and update paths clear while still being fast enough for the MVP.

## 2-Week Schedule

### Week 1

- [ ] Day 1: Project scaffold
  - Done when Next.js App Router files, TypeScript, Tailwind, PWA manifest, and Supabase client helpers exist.
- [ ] Day 2: Database and RLS
  - Done when migration creates tables, indexes, triggers, and policies, including ownership checks for `child_id`.
- [ ] Day 3: Auth flow
  - Done when signup, login, logout, and protected redirects work.
- [ ] Day 4: Child onboarding
  - Done when one child can be created per user and users without a child are redirected to onboarding.
- [ ] Day 5: Today records home
  - Done when today's feeding, sleep, and diaper records are displayed in one sorted list.

### Week 2

- [ ] Day 6: Feeding CRUD
  - Done when feeding records can be created, updated, deleted, and shown on the home screen.
- [ ] Day 7: Diaper CRUD
  - Done when diaper records can be created, updated, deleted, and shown on the home screen.
- [ ] Day 8: Sleep CRUD
  - Done when sleep can be started, ended, updated, deleted, and open sleep duplication is blocked.
- [ ] Day 9: Mobile PWA polish
  - Done when mobile layout, touch targets, loading states, and manifest basics are ready.
- [ ] Day 10: QA and deploy readiness
  - Done when core flows pass on local and production-like environments.

## Today Home Query Definition

The home screen queries the three record tables separately, maps each row to `TodayRecordItem`, merges the arrays, then sorts them.

Date range is based on the user's local day:

- `todayStart`: local start of day converted to ISO.
- `tomorrowStart`: next local day start converted to ISO.

Query filters:

- Feeding: `fed_at >= todayStart` and `fed_at < tomorrowStart`
- Diaper: `changed_at >= todayStart` and `changed_at < tomorrowStart`
- Sleep: `started_at < tomorrowStart` and (`ended_at is null` or `ended_at >= todayStart`)

Sort rule:

- Descending by `sortTime`
- Feeding `sortTime = fed_at`
- Diaper `sortTime = changed_at`
- Sleep `sortTime = ended_at ?? started_at`

## Functional TODO

- [ ] Auth
  - Completion: authenticated users can enter the app and unauthenticated users are redirected to login.
- [ ] Child onboarding
  - Completion: each user has at most one child, enforced by the database.
- [ ] Today records home
  - Completion: all three record types appear in one list with a stable descending order.
- [ ] Feeding records
  - Completion: create, edit, delete, validation, and home refresh work.
- [ ] Sleep records
  - Completion: start, end, edit, delete, validation, and single-open-sleep constraint work.
- [ ] Diaper records
  - Completion: create, edit, delete, validation, and home refresh work.

## Test Scenarios

- New user signs up and a profile row is created automatically.
- User without a child is redirected to child onboarding.
- User can create exactly one child.
- Record insert fails when `child_id` does not belong to the authenticated user.
- Record select, update, and delete fail for another user's records.
- Updating a record changes `updated_at` automatically.
- Creating a second open sleep for the same child fails.
- Today's home shows feeding, sleep, and diaper records in one descending list.
- Sleep crossing midnight appears on the correct day.

## Risks And Responses

- Risk: local day range can be wrong around midnight.
  - Response: centralize date range calculation and test sleep crossing midnight.
- Risk: RLS can pass `user_id` but miss `child_id` ownership.
  - Response: every record policy includes an `exists` check against `children`.
- Risk: open sleep can duplicate under fast repeated clicks.
  - Response: enforce `one_open_sleep_per_child` in the database.
- Risk: generated profile creation can drift from signup behavior.
  - Response: use the `auth.users` trigger as the single creation path.
