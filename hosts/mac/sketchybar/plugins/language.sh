#!/usr/bin/env bash

language=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID)

case "$language" in
    com.apple.keylayout.US)
        name="EN";;
    com.apple.keylayout.Lithuanian)
        name="LT";;
    "org.sil.ukelele.keyboardlayout.lithuanian(sk_eiles).lithuanian(sk_eiles)")
        name="LT";;
    *)
        name="${language##*.}";;
esac

sketchybar --set "$NAME" icon="󰌌" label="$name"
