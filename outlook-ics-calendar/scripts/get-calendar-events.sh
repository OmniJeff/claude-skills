#!/bin/bash
# Fetch calendar events for a given date from an Outlook ICS feed.
# Handles recurring events, all-day events, and timezone conversion to Pacific.
#
# Usage: get-calendar-events.sh YYYYMMDD [ICS_URL_OR_FILE]
# - YYYYMMDD: date to fetch events for (defaults to today)
# - ICS_URL_OR_FILE: URL or file path to ICS (defaults to ~/.openclaw/workspace/calendar-ics.txt)
#
# Requirements: python3 with icalendar and recurring-ical-events packages
#   pip3 install icalendar recurring-ical-events
#
# Excluded events (personal logistics): "Kid dropoff", "Drive to work"
# To customize, edit the EXCLUDE list in the Python block below.

DATE=${1:-$(date +%Y%m%d)}
ICS_SOURCE=${2:-"$(cat ~/.openclaw/workspace/calendar-ics.txt 2>/dev/null)"}

if [ -z "$ICS_SOURCE" ]; then
  echo "ERROR: No ICS URL or file provided. Set one in ~/.openclaw/workspace/calendar-ics.txt" >&2
  exit 1
fi

# Fetch ICS content
if [[ "$ICS_SOURCE" == http* ]]; then
  ICS_CONTENT=$(curl -s "$ICS_SOURCE")
else
  ICS_CONTENT=$(cat "$ICS_SOURCE")
fi

echo "$ICS_CONTENT" | python3 -c "
import sys
import datetime

EXCLUDE = ['kid dropoff', 'drive to work']

try:
    import icalendar
    import recurring_ical_events

    date_str = '$DATE'
    year, month, day = int(date_str[:4]), int(date_str[4:6]), int(date_str[6:8])
    target_date = datetime.date(year, month, day)

    cal = icalendar.Calendar.from_ical(sys.stdin.buffer.read())
    events = recurring_ical_events.of(cal).at(target_date)

    def sort_key(e):
        dt = e.get('DTSTART').dt
        if isinstance(dt, datetime.datetime):
            if dt.tzinfo:
                return dt.astimezone(datetime.timezone.utc).replace(tzinfo=None)
            return dt
        return datetime.datetime.combine(dt, datetime.time.min)

    for event in sorted(events, key=sort_key):
        summary = str(event.get('SUMMARY', '')).strip()
        if summary.lower() in EXCLUDE:
            continue

        dtstart = event.get('DTSTART').dt
        dtend = event.get('DTEND').dt
        location = str(event.get('LOCATION', '')).strip()

        if isinstance(dtstart, datetime.datetime):
            pacific = datetime.timezone(datetime.timedelta(hours=-7))  # PDT (UTC-7)
            if dtstart.tzinfo:
                dtstart_pt = dtstart.astimezone(pacific)
                dtend_pt = dtend.astimezone(pacific)
            else:
                dtstart_pt = dtstart.replace(tzinfo=pacific)
                dtend_pt = dtend.replace(tzinfo=pacific)
            start_str = dtstart_pt.strftime('%I:%M %p').lstrip('0')
            end_str = dtend_pt.strftime('%I:%M %p').lstrip('0')
            print(f'TIME: {start_str} - {end_str}')
        else:
            print('TIME: All day')

        print(f'SUMMARY: {summary}')
        if location and location != 'None':
            print(f'LOCATION: {location}')
        print('---')

except ImportError as e:
    print(f'ERROR: Missing dependency: {e}', file=sys.stderr)
    print('Run: pip3 install icalendar recurring-ical-events', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
"
