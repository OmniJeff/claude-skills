---
name: outlook-ics-calendar
description: Fetch and display calendar events from an Outlook ICS feed. Handles recurring events, all-day events, and timezone conversion to Pacific time. Use when fetching today's or any day's calendar events from an Outlook/Office 365 calendar via a published ICS URL. Requires the ICS URL stored in ~/.openclaw/workspace/calendar-ics.txt.
---

# Outlook ICS Calendar

Reads events from an Outlook ICS feed using a script that properly handles recurring events (via `recurring-ical-events`), all-day events, and timezone conversion to Pacific time.

## Setup

1. Store the ICS URL in `~/.openclaw/workspace/calendar-ics.txt`:
   ```bash
   echo "https://outlook.office365.com/owa/calendar/..." > ~/.openclaw/workspace/calendar-ics.txt
   chmod 600 ~/.openclaw/workspace/calendar-ics.txt
   ```

2. Get the URL from Outlook Web: **Settings → Calendar → Shared calendars → Publish a calendar** → copy the ICS link.

3. Install dependencies (one-time):
   ```bash
   pip3 install icalendar recurring-ical-events
   ```

## Usage

```bash
# Today's events
~/.openclaw/workspace/skills/outlook-ics-calendar/scripts/get-calendar-events.sh

# Specific date
~/.openclaw/workspace/skills/outlook-ics-calendar/scripts/get-calendar-events.sh 20260330

# Custom ICS source (URL or file path)
~/.openclaw/workspace/skills/outlook-ics-calendar/scripts/get-calendar-events.sh 20260330 /path/to/calendar.ics
```

## Output format

```
TIME: 9:00 AM - 9:30 AM
SUMMARY: Team Standup
LOCATION: Microsoft Teams Meeting
---
TIME: All day
SUMMARY: Nati OOO - Reserve Duty
---
```

Times are always in **Pacific time** (PDT, UTC-7). All-day events show `TIME: All day`.

## Excluding events

Edit the `EXCLUDE` list near the top of the script to filter out personal/noise events:

```python
EXCLUDE = ['kid dropoff', 'drive to work']
```

Matching is case-insensitive and exact.

## Notes

- Recurring events are fully expanded — the script uses `recurring-ical-events` to handle RRULE/EXDATE correctly. This is the key difference from naive awk/grep approaches which only match the original DTSTART date.
- Outlook ICS feeds may only contain a rolling window of events (typically 1 year back, 1 year forward). If events are missing, check the publishing range in Outlook Web.
- Times are hardcoded to PDT (UTC-7). Update the `pacific` offset in the script to UTC-8 during standard time (November–March) if precision matters.
- The ICS URL contains an auth token — treat it like a password. Store it in the workspace file (mode 600), never paste it in chat.
