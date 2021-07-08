#!/bin/bash
MM_HOME=/opt/mattermost
MM_CONFIG=${MM_HOME}/config/config.json
MM_SECRETS_DIR=${MM_HOME}/secrets/

# Verify presence of required database environment variables
if [[ -z $MM_DB_HOST ]]; then echo "MM_DB_HOST not set."; exit 1; fi
if [[ -z $MM_DB_PORT ]]; then echo "MM_DB_PORT not set."; exit 1; fi
if [[ -z $MM_DB_USER ]]; then echo "MM_DB_USER not set."; exit 1; fi
if [[ -z $MM_DB_PASS ]]; then echo "MM_DB_PASS not set."; exit 1; fi
if [[ -z $MM_DB_NAME ]]; then echo "MM_DB_NAME not set."; exit 1; fi

echo "Updating mattermost database config from environment variables ..."
json-set "${MM_CONFIG}" "SqlSettings.DriverName" "postgres"
json-set "${MM_CONFIG}" "SqlSettings.DataSource" "postgres://${MM_DB_USER}:${MM_DB_PASS}@${MM_DB_HOST}:${MM_DB_PORT}/${MM_DB_NAME}?sslmode=disable&connect_timeout=10"

echo "Updating mattermost config from mounted secrets ..."
SECRETS=$(find "${MM_SECRETS_DIR}" -maxdepth 1 -type l -not -path '*/\.*')
for secret in $SECRETS; do
  jsonkey=$(basename "${secret}")
  jsonvalue=$(cat "${secret}")

  # Try to set the desired json key from the secret name
  if json-set "${MM_CONFIG}" "${jsonkey}" "${jsonvalue}"; then
    echo "Updated ${jsonkey}"
  else
    echo "Invalid json key ${jsonkey}"
  fi
done

# Create a copy of the mattermost config.json file as it was at container startup
/bin/cp -af "${MM_CONFIG}" /tmp/

# Start mattermost if first parameter is "mattermost"
if [[ "$1" == "mattermost" ]]; then
  echo "Starting platform"
  cd ${MM_HOME} || exit 1
  ./bin/platform
else
  exec "$@"
fi
