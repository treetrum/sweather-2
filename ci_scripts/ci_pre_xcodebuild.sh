#!/bin/sh

# Load .env from source if it exists
if [ -f ${CI_WORKSPACE}/.env ]
then
    export $(grep -v '^#' $CI_WORKSPACE/.env | xargs)
fi

# Add env vars to config.xcconfig
echo "WILLY_WEATHER_API_KEY = $WILLY_WEATHER_API_KEY" > $CI_WORKSPACE/sweather-2/Build\ Config/config.xcconfig

exit 0