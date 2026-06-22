# Vajra Gym ERP deployment

## Quick setup

1. Open the Supabase SQL editor.
2. Run `SQL 1.sql`. It contains the complete idempotent schema, indexes, seed accounts, workout templates, curated videos, and announcements table.
3. Serve this folder through HTTPS. Do not deploy by opening the HTML through `file://` because installability and the service worker require HTTP/HTTPS.
4. Open `vajra_gym_erp.html`, sign in, and publish a test member announcement.
5. Install the app from the browser menu on member and staff devices.

`SQL 2 - users workouts attendance.sql` is retained as a focused upgrade script for older databases. New installations only need `SQL 1.sql`.

## Updating

The SQL scripts use `if not exists`, upserts, and policy replacement, so they can be run again. Existing custom workout video URLs are preserved unless they are blank or an old generic Muscle & Strength search link.

After updating frontend files, reload the page once while online. The service worker will replace its previous application-shell cache.

## Production security warning

The current frontend-only username/PIN system and permissive anonymous Supabase policies are suitable for a private prototype, not a public production deployment. The publishable Supabase key is expected to be visible in browser code; the problem is the open policies and plaintext PIN table.

Before a public launch:

- migrate users to Supabase Auth or a trusted server/Edge Function;
- remove plaintext passwords from `gym_users`;
- replace every `Allow all` policy with authenticated, role-aware RLS;
- restrict owner-only exports, deletion, and financial data at the database layer;
- add backups, audit logs, rate limits, and error monitoring;
- use a separate staging Supabase project for testing migrations.

Frontend role checks improve the interface but are not a security boundary. Database policies must enforce the same permissions.

## Operations checklist

- Change the seeded `OWNER / 1234` and `STAFF / 5678` credentials before real use.
- New member login IDs use `NAME_LAST4`, where `LAST4` is taken from the member phone number. This prevents members with identical names from overwriting each other.
- Test owner, staff, active-member, and expired-member accounts after every release.
- Verify membership renewal, payment entry, attendance, workout logging, videos, timer audio, exports, announcements, and offline recovery.
- Confirm YouTube is available on the gym network; direct custom MP4/WebM URLs remain supported for restricted networks.
- Export member data regularly and maintain an independent encrypted backup.
