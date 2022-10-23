#!/bin/sh

SWEATHER_REPO_ROOT="$(dirname "$BASH_SOURCE")"/..
CONFIG_FILE=$SWEATHER_REPO_ROOT/sweather-2/Build\ Config/config.xcconfig

# Load .env from source if it exists
if [ -f ${SWEATHER_REPO_ROOT}/.env ]
then
    export $(grep -v '^#' $SWEATHER_REPO_ROOT/.env | xargs)
fi

# Add env vars to config.xcconfig
echo "WILLY_WEATHER_API_KEY = $WILLY_WEATHER_API_KEY" > $CONFIG_FILE

exit 0