now_playing=(
    icon.padding_left=6
    icon.padding_right=5
    label.padding_left=0
    label.padding_right=6
    background.padding_right=2
    #background.padding_left=0
    update_freq=3
    updates=on
    label.font.style="Bold Italic"
    script="$PLUGIN_DIR/now_playing.sh"
    background.drawing=on
    background.color=$ACCENT_COLOR
    label.color=$BAR_COLOR
    drawing=off
    display=1
)

now_playing_like=(
    icon="♡"
    icon.font="SF Pro:Regular:14.0"
    icon.color=0xffff2453
    icon.padding_left=6
    icon.padding_right=6
    label.drawing=off
    background.drawing=on
    background.color=$WHITE
    background.height=20
    background.corner_radius=7
    padding_left=3
    padding_right=0
    script="$PLUGIN_DIR/now_playing.sh"
    drawing=off
    display=1
)

# Now Playing
sketchybar --add item now_playing.like right \
    --set now_playing.like "${now_playing_like[@]}" \
    --subscribe now_playing.like mouse.clicked \
    --add item now_playing right \
    --set now_playing "${now_playing[@]}" \
    --subscribe now_playing mouse.clicked

# click_script="mpc toggle ; echo $SENDER > /tmp/logs.txt" \
    #click_script="mpc toggle" \
    # icon.font="SF Pro:Semibold:15.0" \
    # label.font="SF Pro:Medium:12.0" \
    # background.color=$BACKGROUND_1 \
