#!/bin/bash

# Service URL
URL="http://workshop:80/logs"

MAX_ATTEMPTS=5
WAIT_TIME=5

attempt=1
while ((attempt <= MAX_ATTEMPTS)); do
    echo "Attempt $attempt of $MAX_ATTEMPTS: checking URL $URL"
    response=$(curl -s -o /dev/null -w "%{http_code}" $URL)
    if [ "$response" -eq 200 ]; then
        echo "Host available."
        echo "HOST_AVAILABLE=true" >>$GITHUB_ENV
        exit 0
    fi
    echo "Host not available. Waiting $WAIT_TIME seconds before retry..."
    sleep $WAIT_TIME
    ((attempt++))
done

echo "Host not available after $MAX_ATTEMPTS attempts."
echo "HOST_AVAILABLE=false" >>$GITHUB_ENV
exit 0
