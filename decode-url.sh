#!/bin/bash

# Use the first argument as the URL
url="$1"

# Decode the entire URL (main URL decoding)
decoded_url=$(echo "$url" | sed 's/+/ /g; s/%\(..\)/\\x\1/g' | xargs -0 printf "%b")

# Extract query parameters
query_params=$(echo "$decoded_url" | sed -n 's/.*?\(.*\)/\1/p')

# Output decoded URL
echo "Decoded URL: $decoded_url"

# Parse and process query parameters
echo "Query Parameters:"
echo "$query_params" | tr '&' '\n' | while IFS='=' read -r key value; do
    # URL decode for keys containing 'url' or 'uri'
    if [[ "$key" == *"url"* || "$key" == *"uri"* ]]; then
        # First decode the URL (in case it's URL-encoded)
        value_decoded_once=$(echo "$value" | sed 's/+/ /g; s/%\(..\)/\\x\1/g' | xargs -0 printf "%b")

        # Check if further decoding is needed
        # If the decoded value still contains encoded characters, decode it again
        value_decoded_twice=$(echo "$value_decoded_once" | sed 's/+/ /g; s/%\(..\)/\\x\1/g' | xargs -0 printf "%b")

        # Print the final decoded URL
        echo "  $key: $value_decoded_twice (decoded URL)"
    elif [[ "$key" == *"token"* || "$key" == *"state"* ]]; then
        # Decode Base64-encoded values (like token or state)
        decoded_value=$(echo "$value" | base64 --decode 2>/dev/null || echo "$value")
        if [[ "$decoded_value" != "$value" ]]; then
            echo "  $key: $decoded_value (decoded Base64)"
        else
            echo "  $key: $value"
        fi
    else
        # Leave other parameters as-is
        echo "  $key: $value"
    fi
done

