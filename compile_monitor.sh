#!/bin/bash

# Install telegram-send
if ! command -v telegram-send &> /dev/null; then
    # Check the Python version
    if command -v python3 &> /dev/null; then
        pip_cmd="pip3"
    elif command -v python &> /dev/null; then
        pip_cmd="pip"
    else
        echo "Error: Python not found. Please install Python."
        exit 1
    fi

    $pip_cmd install telegram-send
else
    echo "telegram-send is already installed."
fi

TELEGRAM_BOT_TOKEN="1822006486:AAGX5JWqloJdIin7XbhjtVSsFWb06B3Uk1w"
CHAT_ID="-1001379101256"
ANDROID_SOURCE_DIR="~/iamtttt55/sw/"

# Send a Telegram message with the log file
send_telegram_document() {
    document_path="$1"
    message="$2"
    telegram-send --config /dev/null --token $TELEGRAM_BOT_TOKEN --chat_id $CHAT_ID --document "$document_path" "$message"
}

# Main compilation monitoring loop
while true; do
    export USE_CCACHE=1
    ccache -M 150G
    export CCACHE_COMPRESS=1
    . build/envsetup.sh
    lunch lineage_veux-userdebug
    m bacon --j$(nproc --all) > compilation_log.txt 2>&1

    # Check if the compilation was successful
    if [ $? -eq 0 ]; then
        send_telegram_document "compilation_log.txt" "Android compilation completed successfully!"
    else
        send_telegram_document "compilation_log.txt" "Android compilation failed! Check compilation_log.txt for details."
    fi

    # Check back at an interval of 5 minutes
    sleep 300
done &
