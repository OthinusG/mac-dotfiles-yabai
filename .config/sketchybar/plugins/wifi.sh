#!/bin/bash

CLASH_SOCKET="${CLASH_SOCKET:-/tmp/verge/verge-mihomo.sock}"
CLASH_TEST_URL="${CLASH_TEST_URL:-https://www.gstatic.com/generate_204}"
CONNECTED_ICON="󰖩"
DISCONNECTED_ICON="󰖪"

set_status() {
  color="${ACCENT_COLOR:-0xffffffff}"
  [[ "$1" == "$DISCONNECTED_ICON" ]] && color=0xffff2453
  sketchybar --set "$NAME" icon="$1" icon.color="$color" label="$2"
}

urlencode() {
  jq -nr --arg value "$1" '$value | @uri'
}

api_get() {
  /usr/bin/curl --fail --silent --show-error --max-time 3 \
    --unix-socket "$CLASH_SOCKET" "http://localhost$1" 2>/dev/null
}

resolve_proxy() {
  [[ -n "$CLASH_PROXY_GROUP" ]] && {
    printf '%s\n' "$CLASH_PROXY_GROUP"
    return
  }

  config_response=$(api_get "/configs") || return 1
  mode=$(jq -r '.mode // "rule" | ascii_downcase' <<<"$config_response") || return 1

  case "$mode" in
    global) printf '%s\n' "GLOBAL" ;;
    direct) printf '%s\n' "DIRECT" ;;
    rule)
      rules_response=$(api_get "/rules") || return 1
      jq -er '[.rules[] | select(((.type // "") | ascii_downcase) == "match") | .proxy][-1]
        | select(type == "string" and length > 0)' <<<"$rules_response"
      ;;
    *) return 1 ;;
  esac
}

if [[ ! -S "$CLASH_SOCKET" ]]; then
  set_status "$DISCONNECTED_ICON" "Offline"
  exit 0
fi

proxy=$(resolve_proxy) || {
  set_status "$DISCONNECTED_ICON" "Offline"
  exit 0
}
for _ in {1..8}; do
  response=$(api_get "/proxies/$(urlencode "$proxy")") || {
    set_status "$DISCONNECTED_ICON" "Offline"
    exit 0
  }
  next=$(jq -r '.now // empty' <<<"$response")
  [[ -z "$next" || "$next" == "$proxy" ]] && break
  proxy="$next"
done

delay_response=$(/usr/bin/curl --fail --silent --show-error --max-time 4 \
  --unix-socket "$CLASH_SOCKET" --get \
  "http://localhost/proxies/$(urlencode "$proxy")/delay" \
  --data-urlencode "url=$CLASH_TEST_URL" \
  --data-urlencode "timeout=3000" 2>/dev/null) || {
  set_status "$DISCONNECTED_ICON" "Offline"
  exit 0
}

delay=$(jq -er '.delay | select(type == "number" and . > 0)' \
  <<<"$delay_response" 2>/dev/null) || {
  set_status "$DISCONNECTED_ICON" "Offline"
  exit 0
}

set_status "$CONNECTED_ICON" "${delay}ms"
