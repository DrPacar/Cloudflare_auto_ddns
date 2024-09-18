#!/bin/bash

# author: Luka Pacar 18.09.2024

# Get the current public IP
PUBLIC_IP=$(curl -s ifconfig.me)

# Domain array with multiple domains
DOMAINS=(
  "YOUR DOMAIN"
)

# Associative array for API tokens
# IMPORTANT TOKEN HAS TO GRANT READ AND WRITE TO DNS
declare -A API_TOKENS=(
  ["YOUR DOMAIN"]="YOURTOKEN"
)

# Loop over each domain
for DOMAIN in "${DOMAINS[@]}"; do

  # Get the correct API token for the current domain
  API_TOKEN="${API_TOKENS[$DOMAIN]}"

  # Check if API token is available for the domain
  if [ -z "$API_TOKEN" ]; then
    echo "Error: No API token available for $DOMAIN"
    continue
  fi

  # Fetch Zone ID for each domain
  ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')

  # Check if the Zone ID was retrieved
  if [ "$ZONE_ID" == "null" ] || [ -z "$ZONE_ID" ]; then
    echo "Error: Could not get Zone ID for $DOMAIN"
    continue
  fi

  echo "Updating records for domain: $DOMAIN (ZONE_ID: $ZONE_ID)"

  # Fetch DNS record IDs and names
  DOMAIN_RECORDS_IDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result[].id')

  DOMAIN_RECORDS_NAMES=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result[].name')

  # Convert fetched IDs and names into arrays
  IFS=$'\n' read -r -d '' -a DOMAIN_RECORDS_IDS_ARRAY <<< "$DOMAIN_RECORDS_IDS"
  IFS=$'\n' read -r -d '' -a DOMAIN_RECORDS_NAMES_ARRAY <<< "$DOMAIN_RECORDS_NAMES"

  # Loop over each DNS record for the current domain
  for i in "${!DOMAIN_RECORDS_IDS_ARRAY[@]}"; do
    ID="${DOMAIN_RECORDS_IDS_ARRAY[$i]}"
    NAME="${DOMAIN_RECORDS_NAMES_ARRAY[$i]}"

    # Fetch the current record's IP and proxied status
    RECORD_DATA=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$ID" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json")

    RECORD_IP=$(echo "$RECORD_DATA" | jq -r '.result.content')
    PROXIED=$(echo "$RECORD_DATA" | jq -r '.result.proxied')
    
    # If the current record IP doesn't match the public IP, update it
    if [ "$PUBLIC_IP" != "$RECORD_IP" ]; then
      curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$ID" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$NAME\",\"content\":\"$PUBLIC_IP\",\"ttl\":1,\"proxied\":$PROXIED}" | jq > /dev/null
      echo "Updated DNS record for $NAME to $PUBLIC_IP"
    else
      echo "DNS record for $NAME is up-to-date"
    fi
  done
done

