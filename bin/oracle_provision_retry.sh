#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -f .env.oracle ]; then
  set -a
  source .env.oracle
  set +a
fi

: "${COMPARTMENT_ID:?Set COMPARTMENT_ID in .env.oracle}"
: "${SUBNET_ID:?Set SUBNET_ID in .env.oracle}"
: "${IMAGE_ID:?Set IMAGE_ID in .env.oracle}"
: "${SSH_PUBLIC_KEY_FILE:?Set SSH_PUBLIC_KEY_FILE in .env.oracle}"
: "${INSTANCE_DISPLAY_NAME:=snack-rating-box}"

read -ra AVAILABILITY_DOMAINS <<< "${AVAILABILITY_DOMAINS:?Set AVAILABILITY_DOMAINS in .env.oracle}"

# Attempts one launch in the given AD. Echoes the OCI CLI's combined output
# (includes the instance OCID under "id" on success). Caller inspects the
# output for known error strings to decide whether to retry.
attempt_launch() {
  local ad="$1"
  oci compute instance launch \
    --compartment-id "$COMPARTMENT_ID" \
    --availability-domain "$ad" \
    --shape "VM.Standard.A1.Flex" \
    --shape-config '{"ocpus": 1, "memoryInGBs": 6}' \
    --subnet-id "$SUBNET_ID" \
    --image-id "$IMAGE_ID" \
    --ssh-authorized-keys-file "$SSH_PUBLIC_KEY_FILE" \
    --display-name "$INSTANCE_DISPLAY_NAME" \
    --no-retry \
    2>&1
}

# Polls list-vnics for a public IP, since the VNIC attaches slightly after
# instance creation and won't have one on the very first check.
fetch_public_ip() {
  local instance_id="$1"
  local ip=""
  for _ in $(seq 1 6); do
    ip=$(oci compute instance list-vnics \
      --instance-id "$instance_id" \
      --compartment-id "$COMPARTMENT_ID" \
      --query 'data[0]."public-ip"' --raw-output)
    [ "$ip" != "null" ] && [ -n "$ip" ] && break
    sleep 5
  done
  echo "$ip"
}

sleep_time=30
while true; do
  for ad in "${AVAILABILITY_DOMAINS[@]}"; do
    echo "Attempting launch in $ad..."

    if output=$(attempt_launch "$ad"); then
      echo "$output"
      echo "Launched successfully in $ad!"

      instance_id=$(echo "$output" | jq -r '.data.id')
      public_ip=$(fetch_public_ip "$instance_id")
      echo "Public IP: ${public_ip:-unavailable yet — check the console}"

      exit 0
    fi

    if [[ $output == *"TooManyRequests"* ]]; then
      sleep_time=$((sleep_time * 2))
      echo "Too many requests, backing off to ${sleep_time}s interval..."
      break
    elif [[ $output == *"Out of host capacity"* ]]; then
      echo "No capacity in $ad..."
    else
      echo "Non-retryable error: $output"
      exit 1
    fi

    echo "Retrying in ${sleep_time}s..."
    sleep "$sleep_time"
  done
done
