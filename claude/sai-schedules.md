# Sai's Scheduled Triggers

Source of truth for personal cron entries managed via Claude Code's `/schedule` skill. Re-arm any entry here if `/schedule` doesn't survive an Ona environment restart.

## Active triggers

### sai-weakness-friday

- **Cron:** `0 16 * * FRI` (4:00 PM local, every Friday)
- **Command:** `/sai-weakness synthesize --days 7`
- **Created:** 2026-04-26
- **Purpose:** Weekly roll-up of `sai-weakness-register.md` entries into themes with routed follow-ups. Reduces BCR: forgetting to synthesize.
- **Re-arm command (if the trigger is missing):**

  ```
  /schedule add --name sai-weakness-friday --cron "0 16 * * FRI" --command "/sai-weakness synthesize --days 7"
  ```

  (Adjust syntax to match the actual `/schedule` skill interface — see `/schedule --help`.)

## Verification

After every Ona environment start:

1. Run `/schedule list`
2. Confirm `sai-weakness-friday` is present and active
3. If missing, re-arm using the command above

## Retired triggers

(none)
