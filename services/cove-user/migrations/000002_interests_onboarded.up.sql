-- Generic per-user flags table. Each row records that a named flag was set for
-- a user, along with when. Presence of a row is the flag — no value column needed.
-- Adding new flags requires no schema changes, only a new string constant in the service.
--
-- Current flags:
--   interests_onboarded — set when PUT /users/me/interests is called (even with an empty array)

CREATE TABLE profile.user_flags (
    user_id    uuid        NOT NULL REFERENCES profile.users(id) ON DELETE CASCADE,
    flag       text        NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, flag)
);

GRANT SELECT, INSERT, DELETE ON profile.user_flags TO cove_user;
