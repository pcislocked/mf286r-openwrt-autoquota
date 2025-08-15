#!/bin/sh

MODEM_DEVICE="/dev/ttyACM0"
ISP_NUMBER="5555"
QUOTA_KEYWORD="KALAN"
BUY_KEYWORD="MOBIL EK 10GB"
TELEGRAM_BOT_TOKEN="31"
TELEGRAM_CHAT_ID="3"
LOW_DATA_THRESHOLD=5120
MAX_RETRIES=10
RETRY_INTERVAL=5

url_encode() {
    printf %s "$1" | sed 's/ /%20/g; s/!/%21/g; s/'"'"'/%27/g; s/🚨/%F0%9F%9A%A8/g; s/✅/%E2%9C%85/g'
}

echo "kotasiken"
sms_tool -d "$MODEM_DEVICE" delete all > /dev/null 2>&1
sleep 1
sms_tool -d "$MODEM_DEVICE" send "$ISP_NUMBER" "$QUOTA_KEYWORD"
sleep 1
echo "mesaj bekleniyor"
remaining_mb=0
i=0
sleep $RETRY_INTERVAL
while [ $i -lt $MAX_RETRIES ]; do
    echo "--> sms bekliyom($((i+1))/$MAX_RETRIES)..."
	sms_responses=$(sms_tool -d "$MODEM_DEVICE" recv 2>&1)
    quota_messages=$(echo "$sms_responses" | grep 'internet hakkiniz')
	if [ -n "$quota_messages" ]; then
        remaining_mb=$(echo "$quota_messages" | awk '{ for(i=1; i<=NF; i++) if($i == "MB") print $(i-1) }' | awk '{s+=$1} END {print s}')
        case $remaining_mb in
            ''|*[!0-9]*) remaining_mb=0 ;;
        esac
        break
    else
        sleep $RETRY_INTERVAL
    fi
    i=$((i+1))
done
if [ "$remaining_mb" -le 0 ]; then
    echo "akça naptın aq"
    exit 1
fi

echo "kalan int $remaining_mb MB, sınır $LOW_DATA_THRESHOLD MB"

MESSAGE_TEXT=""
SILENT_MODE=""

if [ "$remaining_mb" -le "$LOW_DATA_THRESHOLD" ]; then
    MESSAGE_TEXT="🚨 internet bitiyo knk $remaining_mb mb kaldı."
    SILENT_MODE="" # Not silent
else
    MESSAGE_TEXT="✅ sikinti yok daha $remaining_mb mb var."
    SILENT_MODE="&disable_notification=true"
fi

ENCODED_MESSAGE=$(url_encode "$MESSAGE_TEXT")
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$TELEGRAM_CHAT_ID&text=$ENCODED_MESSAGE$SILENT_MODE")

if [ "$response" = "200" ]; then
    echo "telegrama mesaj atıldı"
else
    echo "telegram yine donuna sıçtı: $response"
fi