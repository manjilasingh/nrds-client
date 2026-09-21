#!/bin/bash
# The base image's own ALLOWED_HOSTS/CSRF_TRUSTED_ORIGINS env-var support does not override a
# value already baked into portal_config.yml at build time, so patch the file ourselves from the
# runtime env vars (JSON list strings, e.g. '["nrds.ciroh.org","localhost"]') before handing off.
set -euo pipefail

CONFIG_FILE="/config/portal_config.yml"

set_yaml_list() {
    local key="$1" value="$2"
    [ -n "$value" ] || return 0
    if grep -qE "^[[:space:]]*${key}:" "$CONFIG_FILE"; then
        sed -i -E "s|^([[:space:]]*)${key}:.*|\1${key}: ${value}|" "$CONFIG_FILE"
    else
        sed -i -E "/^settings:/a\\  ${key}: ${value}" "$CONFIG_FILE"
    fi
}

set_yaml_list ALLOWED_HOSTS "${ALLOWED_HOSTS:-}"
set_yaml_list CSRF_TRUSTED_ORIGINS "${CSRF_TRUSTED_ORIGINS:-}"

exec /usr/local/bin/serve.sh "$@"
