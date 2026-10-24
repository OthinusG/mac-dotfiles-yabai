#!/usr/bin/env bash

# Focused to support players: spotify_player, Spotifast, MPD, Apple Music, Spotify.
# spotify_player, Spotifast, Apple Music & Spotify have basic support without volume scroll control.
# MPD have full functionality (As it's my primary (platform independed) players between linux and macos)

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"
PLAYER_LABEL_COLOR=$BAR_COLOR
PLAYER_PLAY_ICON_COLOR=$BAR_COLOR
PLAYER_PAUSE_ICON_COLOR=$BAR_COLOR
PLAYER_STOP_ICON_COLOR=$BAR_COLOR
CACHE_DIR="$HOME/dotfiles/temp"
CACHE_FILE="$CACHE_DIR/cache.now_playing.envs"
FASTPOTIFY_BIN="${FASTPOTIFY_BIN:-/Applications/Spotifast.app/Contents/MacOS/Spotifast}"
SPOTIFY_PLAYER_BIN="${SPOTIFY_PLAYER_BIN:-/opt/homebrew/bin/spotify_player}"
SPOTIFY_PLAYER_CACHE_DIR="${SPOTIFY_PLAYER_CACHE_DIR:-$HOME/.cache/spotify-player}"
SP_LIKED_CACHE="$SPOTIFY_PLAYER_CACHE_DIR/SavedTracks_cache.json"
SP_LIKED_BELIEF="$CACHE_DIR/cache.now_playing.liked"

function build_mpd_player_name() {
    local vol=$(~/.cargo/bin/rmpc volume)
    PLAYER="MPD [ ${vol}%]"
}
function __write_tmp_envs_file() {
    mkdir -p "$CACHE_DIR"
    printf 'PLAYER=%q\nTRACK=%q\nARTIST=%q\n' "$PLAYER" "$TRACK" "$ARTIST" > "$CACHE_FILE"
}
function __read_tmp_envs_file() {
    if [ ! -f "$CACHE_FILE" ]; then
        return
    fi
    . "$CACHE_FILE"
}
function build_music_label() {
    # echo "${TRACK} • ${ARTIST}"
    echo "${TRACK}"
}
if [ -f "$CACHE_FILE" ]; then
    # LAST_PLAYING_LABEL=$(bat -pp "$CACHE_FILE")
    __read_tmp_envs_file
    LAST_PLAYING_LABEL=$(build_music_label)
else
    LAST_PLAYING_LABEL="Paused"
fi

# Spotifast exposes the fastpotify CLI for metadata and controls.
function get_fastpotify_info() {
    PLAYER="Spotifast"
    local info
    info=$("$FASTPOTIFY_BIN" now-playing --raw 2>/dev/null) || {
        STATUS="stopped"
        return
    }
    IFS=$'\034' read -r STATUS TRACK ARTIST SAVED < <(
        awk -F '\t' 'BEGIN { OFS = "\034" } { print $1, $2, $3, $11 }' <<< "$info"
    )
    if [[ "$STATUS" != "playing" && "$STATUS" != "paused" ]]; then
        STATUS="stopped"
    fi
}

# spotify_player exposes the CLI for metadata and controls. While the TUI runs,
# playback state is served from its local state (no Web API call), so polling
# here is cheap. If the app is not running, skip the query entirely: the CLI
# would fall back to a Web API client (prone to rate limiting / long retries).
function get_spotify_player_info() {
    PLAYER="spotify_player"
    STATUS=""
    TRACK=""
    ARTIST=""
    TRACK_ID=""
    IS_EPISODE=""
    SAVED="no"
    if ! pgrep -x spotify_player >/dev/null 2>&1; then
        STATUS="stopped"
        return
    fi
    local info
    info=$("$SPOTIFY_PLAYER_BIN" get key playback 2>/dev/null) || {
        STATUS="stopped"
        return
    }
    IFS=$'\034' read -r STATUS TRACK ARTIST TRACK_ID IS_EPISODE < <(
        jq -r '
            if (. == null) or (.item == null) then ["stopped", "", "", "", ""]
            else . as $p |
                (if $p.is_playing then "playing" else "paused" end) as $st |
                (([$p.item.artists[]?.name] | join(", ")) as $a |
                    [$st, ($p.item.name // ""),
                     (if $a == "" then ($p.item.show.name // "") else $a end),
                     ($p.item.id // ""),
                     (if $p.item.show == null then "" else "episode" end)])
            end | join("\u001c")' <<< "$info"
    )
    case "$STATUS" in
        playing|paused) ;;
        *) STATUS="stopped" ;;
    esac
    if [ -n "$TRACK_ID" ]; then
        SAVED=$(liked_belief "$TRACK_ID")
    fi
}

# Liked state is tracked locally: Web API reads (`get key user-liked-tracks`)
# crawl every saved track and hit rate limits, so the plugin keeps a local
# belief per track, seeded from the app's SavedTracks_cache.json (written when
# the TUI loads the Liked Songs page) and updated on toggle.
function liked_belief() {
    local id="$1" belief
    [ -z "$id" ] && { echo "no"; return; }
    belief=$(grep -m1 "^${id} " "$SP_LIKED_BELIEF" 2>/dev/null | awk '{print $2}')
    if [ -n "$belief" ]; then
        echo "$belief"
        return
    fi
    belief="no"
    if [ -f "$SP_LIKED_CACHE" ] && grep -qF "\"spotify:track:${id}\":" "$SP_LIKED_CACHE" 2>/dev/null; then
        belief="yes"
    fi
    mkdir -p "$CACHE_DIR"
    printf '%s %s\n' "$id" "$belief" >> "$SP_LIKED_BELIEF"
    echo "$belief"
}

function set_liked_belief() {
    local id="$1" value="$2"
    mkdir -p "$CACHE_DIR"
    if [ -f "$SP_LIKED_BELIEF" ]; then
        grep -v "^${id} " "$SP_LIKED_BELIEF" > "${SP_LIKED_BELIEF}.$$" 2>/dev/null
        mv "${SP_LIKED_BELIEF}.$$" "$SP_LIKED_BELIEF"
    fi
    printf '%s %s\n' "$id" "$value" >> "$SP_LIKED_BELIEF"
}

function toggle_spotify_player_like() {
    [[ -z "$TRACK_ID" || -n "$IS_EPISODE" ]] && return
    if [[ "$SAVED" == "yes" ]]; then
        "$SPOTIFY_PLAYER_BIN" like --unlike && set_liked_belief "$TRACK_ID" "no"
    else
        "$SPOTIFY_PLAYER_BIN" like && set_liked_belief "$TRACK_ID" "yes"
    fi
}

function update_like_item() {
    local icon="♡"
    [[ "$SAVED" == "yes" ]] && icon="♥"
    sketchybar --set now_playing.like \
        icon="$icon" \
        icon.color=0xffff2453 \
        background.color="$WHITE" \
        drawing=on
}

# Mouse control: 
if [[ "$SENDER" == "mouse."* ]]; then
    get_spotify_player_info
    [[ "$STATUS" == "stopped" ]] && exit 0
    if [[ "$NAME" == "now_playing.like" ]]; then
        [[ "$BUTTON" == "left" ]] && toggle_spotify_player_like
        get_spotify_player_info
        update_like_item
        exit 0
    fi
    # echo "sender: $SENDER, button: $BUTTON, modifier: $MODIFIER, scroll_delta: $SCROLL_DELTA" > /tmp/logs.txt
    case "$SENDER" in
        "mouse.clicked")
            case "$BUTTON" in
                "left")
                    "$SPOTIFY_PLAYER_BIN" playback play-pause
                    ;;
                "right")
                    if [ "$MODIFIER" = "ctrl" ]; then
                        "$SPOTIFY_PLAYER_BIN" playback previous
                    else
                        "$SPOTIFY_PLAYER_BIN" playback next
                    fi
            esac
            ;;
    esac
fi

if [[ "$NAME" == "now_playing.like" ]]; then
    get_spotify_player_info
    if [[ "$STATUS" == "stopped" ]]; then
        sketchybar --set now_playing.like drawing=off
    else
        update_like_item
    fi
    exit 0
fi

# Function to get Spotify info
function get_spotify_info() {
    local state=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)
    PLAYER="Spotify"
    if [[ "$state" == "playing" ]]; then
        STATUS="playing"
        ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
        TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
    elif [[ "$state" == "paused" ]]; then
        STATUS="paused"
    else
        STATUS="stopped"
    fi
}

# Function to get Apple Music info
function get_apple_music_info() {
    local state=$(osascript -e 'tell application "Music" to player state as string' 2>/dev/null)
    PLAYER="Music"
    if [[ "$state" == "playing" ]]; then
        STATUS="playing"
        ARTIST=$(osascript -e 'tell application "Music" to artist of current track as string' 2>/dev/null)
        TRACK=$(osascript -e 'tell application "Music" to name of current track as string' 2>/dev/null)
    elif [[ "$state" == "paused" ]]; then
        STATUS="paused"
    else
        STATUS="stopped"
    fi
}

# Function to get MPD info
function get_mpd_info() {
    local state=$(~/.cargo/bin/rmpc status | jq -r '.state')
    build_mpd_player_name
    if [[ "$state" == "Play" ]]; then
        STATUS="playing"
        local song_json=$(~/.cargo/bin/rmpc song)
        ARTIST=$(echo $song_json | jq -r '.metadata.artist')
        TRACK=$(echo $song_json | jq -r '.metadata.title')
    elif [[ "$state" == "Pause" ]]; then
        STATUS="paused"
    else
        STATUS="stopped"
    fi
}

function update_music_item() {
    # Update the Now Playing item (only if we're showing it)
    sketchybar --set "$NAME" \
        icon="$ICON" \
        icon.color="$ICON_COLOR" \
        label="$LABEL" \
        label.color="$PLAYER_LABEL_COLOR"
}

function process_player_info() {
    if [[ "$STATUS" == "playing" ]]; then
        sketchybar --set "$NAME" drawing=on
        full_lable=$(build_music_label)
        if [[ ${#full_lable} -gt 60 ]]; then
            LABEL="${full_lable:0:60}..."
        else
            LABEL="$full_lable"
        fi
        ICON_COLOR="$PLAYER_PLAY_ICON_COLOR"
        ICON="$PLAYER_PLAY"
        # echo -e "$full_lable" > "${CACHE_FILE}"
        __write_tmp_envs_file
        update_music_item
        update_like_item
        exit 0
    fi
}

# echo "STATUS: $STATUS" >/tmp/logs.txt

#get_apple_music_info
#process_player_info

#get_mpd_info
#process_player_info

#get_spotify_info
#process_player_info

get_spotify_player_info
process_player_info

# in case no any player in status - playing
if [[ "$STATUS" == "paused" ]]; then
    sketchybar --set "$NAME" drawing=on
    ICON="$PLAYER_PAUSE"
    ICON_COLOR="$PLAYER_PAUSE_ICON_COLOR"
    LABEL=$(build_music_label)
    update_music_item
    update_like_item
else
    # No music playing - hide the item completely
    ICON_COLOR="$PLAYER_STOP_ICON_COLOR"
    ICON="$PLAYER_STOP"
    sketchybar --set "$NAME" drawing=off \
        --set now_playing.like drawing=off
fi
