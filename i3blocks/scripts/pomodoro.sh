#!/bin/bash

# Pomodoro Timer for i3blocks
# Save state in /tmp to persist across script runs
STATE_FILE="/tmp/pomodoro_state"
WORK_TIME=1500    # 25 minutes in seconds
BREAK_TIME=300    # 5 minutes in seconds

# Initialize state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "stopped" > "$STATE_FILE"
    echo "0" >> "$STATE_FILE"
    echo "work" >> "$STATE_FILE"
fi

# Read current state
readarray -t STATE < "$STATE_FILE"
STATUS="${STATE[0]}"
ELAPSED="${STATE[1]}"
MODE="${STATE[2]}"

# Handle command line arguments for keybindings
case "$1" in
    start)
        if [ "$STATUS" = "stopped" ] || [ "$STATUS" = "paused" ]; then
            echo "running" > "$STATE_FILE"
            echo "$ELAPSED" >> "$STATE_FILE"
            echo "$MODE" >> "$STATE_FILE"
        fi
        pkill -RTMIN+10 i3blocks
        exit 0
        ;;
    pause)
        if [ "$STATUS" = "running" ]; then
            echo "paused" > "$STATE_FILE"
            echo "$ELAPSED" >> "$STATE_FILE"
            echo "$MODE" >> "$STATE_FILE"
        fi
        pkill -RTMIN+10 i3blocks
        exit 0
        ;;
    reset)
        echo "stopped" > "$STATE_FILE"
        echo "0" >> "$STATE_FILE"
        echo "work" >> "$STATE_FILE"
        pkill -RTMIN+10 i3blocks
        exit 0
        ;;
    toggle)
        if [ "$MODE" = "work" ]; then
            echo "stopped" > "$STATE_FILE"
            echo "0" >> "$STATE_FILE"
            echo "break" >> "$STATE_FILE"
        else
            echo "stopped" > "$STATE_FILE"
            echo "0" >> "$STATE_FILE"
            echo "work" >> "$STATE_FILE"
        fi
        pkill -RTMIN+10 i3blocks
        exit 0
        ;;
esac

# Handle button clicks (i3blocks passes button number)
case $BUTTON in
    1) # Left click - start/pause
        if [ "$STATUS" = "stopped" ] || [ "$STATUS" = "paused" ]; then
            echo "running" > "$STATE_FILE"
            echo "$ELAPSED" >> "$STATE_FILE"
            echo "$MODE" >> "$STATE_FILE"
        elif [ "$STATUS" = "running" ]; then
            echo "paused" > "$STATE_FILE"
            echo "$ELAPSED" >> "$STATE_FILE"
            echo "$MODE" >> "$STATE_FILE"
        fi
        ;;
    2) # Middle click - reset
        echo "stopped" > "$STATE_FILE"
        echo "0" >> "$STATE_FILE"
        echo "work" >> "$STATE_FILE"
        ;;
    3) # Right click - skip to break/work
        if [ "$MODE" = "work" ]; then
            echo "stopped" > "$STATE_FILE"
            echo "0" >> "$STATE_FILE"
            echo "break" >> "$STATE_FILE"
        else
            echo "stopped" > "$STATE_FILE"
            echo "0" >> "$STATE_FILE"
            echo "work" >> "$STATE_FILE"
        fi
        ;;
esac

# Re-read state after potential update
readarray -t STATE < "$STATE_FILE"
STATUS="${STATE[0]}"
ELAPSED="${STATE[1]}"
MODE="${STATE[2]}"

# Update timer if running
if [ "$STATUS" = "running" ]; then
    ELAPSED=$((ELAPSED + 1))
    
    # Determine duration based on mode
    if [ "$MODE" = "work" ]; then
        DURATION=$WORK_TIME
    else
        DURATION=$BREAK_TIME
    fi
    
    # Check if time is up
    if [ "$ELAPSED" -ge "$DURATION" ]; then
        # Switch modes
        if [ "$MODE" = "work" ]; then
            notify-send "Pomodoro" "Work session complete! Time for a break." -u critical
            echo "stopped" > "$STATE_FILE"
            echo "0" >> "$STATE_FILE"
            echo "break" >> "$STATE_FILE"
        else
            notify-send "Pomodoro" "Break over! Ready for work?" -u critical
            echo "stopped" > "$STATE_FILE"
            echo "0" >> "$STATE_FILE"
            echo "work" >> "$STATE_FILE"
        fi
    else
        echo "$STATUS" > "$STATE_FILE"
        echo "$ELAPSED" >> "$STATE_FILE"
        echo "$MODE" >> "$STATE_FILE"
    fi
fi

# Calculate remaining time
if [ "$MODE" = "work" ]; then
    REMAINING=$((WORK_TIME - ELAPSED))
else
    REMAINING=$((BREAK_TIME - ELAPSED))
fi

# Format time display
MINS=$((REMAINING / 60))
SECS=$((REMAINING % 60))

# Choose prefix based on mode and status
if [ "$STATUS" = "paused" ]; then
    PREFIX="[P]"
elif [ "$STATUS" = "stopped" ]; then
    PREFIX="[S]"
elif [ "$MODE" = "work" ]; then
    PREFIX="[W]"
else
    PREFIX="[B]"
fi

# Output for i3blocks (full text, short text, color)
printf "%s %02d:%02d\n" "$PREFIX" "$MINS" "$SECS"
printf "%s %02d:%02d\n" "$PREFIX" "$MINS" "$SECS"

# Set color based on status
if [ "$STATUS" = "running" ] && [ "$MODE" = "work" ]; then
    echo "#FF6347"  # Tomato red for work
elif [ "$STATUS" = "running" ] && [ "$MODE" = "break" ]; then
    echo "#00FF00"  # Green for break
else
    echo "#888888"  # Gray for stopped/paused
fi
