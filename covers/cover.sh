# Shared cover helpers, sourced by make-covers.sh and sunshine-add. Output: 600x800 PNG.
FONT=$(fc-match -f '%{file}' 'sans:bold')

# cover <out-path-without-.png> <label> <icon> [icon-size] [tint-override]
# Icon centered, label below, dark gradient tinted by the icon's average colour.
cover() {
    local out=$1 label=$2 icon=$3 size=${4:-380} tint=${5:-}
    if [ -z "$tint" ]; then
        tint=$(magick -background none -density 96 "$icon" -resize 64x64 -alpha set \
            -channel A -threshold 50% +channel -trim +repage \
            -scale 1x1! -alpha off -modulate 100,180 -depth 8 -format '#%[hex:p{0,0}]' info:)
    fi
    local top bot
    top=$(magick xc:"$tint" -fill black -colorize 58% -format '#%[hex:p{0,0}]' info:)
    bot=$(magick xc:"$tint" -fill black -colorize 88% -format '#%[hex:p{0,0}]' info:)
    magick -size 600x800 gradient:"$top"-"$bot" \
        \( -background none -density 384 "$icon" -resize "${size}x${size}" \) \
        -gravity center -geometry +0-60 -composite \
        -density 72 -gravity south -fill white -font "$FONT" -pointsize 62 -annotate +0+110 "$label" \
        -depth 8 "$out.png"
    echo "$out.png  tint=$tint"
}

# steamcover <out-path-without-.png> <portrait art, e.g. 600x900>
# Fills 600x800 by cropping from the bottom (titles usually sit near the top).
steamcover() {
    local out=$1 art=$2
    magick "$art" -resize '600x800^' -gravity north -extent 600x800 -depth 8 "$out.png"
    echo "$out.png"
}
