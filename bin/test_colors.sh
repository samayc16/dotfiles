#!/usr/bin/env bash
# Comprehensive terminal color test script
#
# Portable: printf escapes and C-style loops only, so it also runs on macOS's
# /bin/bash 3.2 (no `echo -e "\e"`, no stepped {a..b..c} ranges there).

ESC=$'\033'
R="${ESC}[0m"

echo "=== Terminal Color Support Test ==="
echo ""

# Test 1: Basic 16 colors
echo "1. Basic 16 Colors (ANSI):"
echo "   Foreground colors:"
for ((i = 0; i < 8; i++)); do printf '  %s[3%dm Color %d %s' "$ESC" "$i" "$i" "$R"; done
echo ""
for ((i = 0; i < 8; i++)); do printf '  %s[9%dm Bright %d %s' "$ESC" "$i" "$i" "$R"; done
echo ""
echo ""

echo "   Background colors:"
for ((i = 0; i < 8; i++)); do printf '  %s[4%dm Color %d %s' "$ESC" "$i" "$i" "$R"; done
echo ""
for ((i = 0; i < 8; i++)); do printf '  %s[10%dm Bright %d %s' "$ESC" "$i" "$i" "$R"; done
echo ""
echo ""

# Test 2: 256 color palette
echo "2. 256 Color Palette:"
echo "   System colors (0-15):"
for ((i = 0; i <= 15; i++)); do
    printf '%s[48;5;%dm %3d %s' "$ESC" "$i" "$i" "$R"
    if (( (i + 1) % 8 == 0 )); then echo ""; fi
done
echo ""

echo "   216 color cube (16-231):"
for ((i = 16; i <= 231; i++)); do
    printf '%s[48;5;%dm %3d %s' "$ESC" "$i" "$i" "$R"
    if (( (i - 15) % 6 == 0 )); then printf ' '; fi
    if (( (i - 15) % 36 == 0 )); then echo ""; fi
done
echo ""

echo "   Grayscale ramp (232-255):"
for ((i = 232; i <= 255; i++)); do
    printf '%s[48;5;%dm %3d %s' "$ESC" "$i" "$i" "$R"
    if (( (i - 231) % 12 == 0 )); then echo ""; fi
done
echo ""
echo ""

# Test 3: True Color (24-bit RGB)
echo "3. True Color (24-bit RGB) Test:"
echo "   RGB Gradient:"
for ((r = 0; r <= 255; r += 32)); do
    for ((g = 0; g <= 255; g += 32)); do
        for ((b = 0; b <= 255; b += 32)); do
            printf '%s[48;2;%d;%d;%dm  %s' "$ESC" "$r" "$g" "$b" "$R"
        done
        printf ' '
    done
    echo ""
done
echo ""

# Test 4: Color gradient bars
echo "4. Smooth Gradients (True Color):"
echo "   Red gradient:"
for ((i = 0; i <= 255; i += 4)); do printf '%s[48;2;%d;0;0m %s' "$ESC" "$i" "$R"; done
echo ""

echo "   Green gradient:"
for ((i = 0; i <= 255; i += 4)); do printf '%s[48;2;0;%d;0m %s' "$ESC" "$i" "$R"; done
echo ""

echo "   Blue gradient:"
for ((i = 0; i <= 255; i += 4)); do printf '%s[48;2;0;0;%dm %s' "$ESC" "$i" "$R"; done
echo ""
echo ""

# Test 5: Text styles
echo "5. Text Styles:"
printf '   %s[1mBold%s\n' "$ESC" "$R"
printf '   %s[2mDim%s\n' "$ESC" "$R"
printf '   %s[3mItalic%s\n' "$ESC" "$R"
printf '   %s[4mUnderline%s\n' "$ESC" "$R"
printf '   %s[5mBlink%s\n' "$ESC" "$R"
printf '   %s[7mReverse%s\n' "$ESC" "$R"
printf '   %s[8mHidden%s (hidden text)\n' "$ESC" "$R"
printf '   %s[9mStrikethrough%s\n' "$ESC" "$R"
echo ""

# Test 6: Combined styles and colors
echo "6. Combined Styles:"
printf '   %s[1;31mBold Red%s\n' "$ESC" "$R"
printf '   %s[4;32mUnderlined Green%s\n' "$ESC" "$R"
printf '   %s[3;34mItalic Blue%s\n' "$ESC" "$R"
printf '   %s[1;4;35mBold Underlined Magenta%s\n' "$ESC" "$R"
printf '   %s[7;33mReverse Yellow%s\n' "$ESC" "$R"
echo ""

# Test 7: Terminal capabilities
echo "7. Terminal Capabilities:"
echo "   TERM: $TERM"
echo "   COLORTERM: ${COLORTERM:-}"
if colors=$(tput colors 2>/dev/null); then
    echo "   Colors supported (tput): $colors"
else
    echo "   tput: not available"
fi
echo ""

# Test 8: Color cube visualization
echo "8. Color Cube (6x6x6):"
for ((level = 0; level <= 5; level++)); do
    echo "   Level $level:"
    for ((g = 0; g <= 5; g++)); do
        printf '   '
        for ((r = 0; r <= 5; r++)); do
            color=$((16 + 36 * r + 6 * g + level))
            printf '%s[48;5;%dm  %s' "$ESC" "$color" "$R"
        done
        echo ""
    done
done
echo ""

echo "=== Test Complete ==="
echo ""
echo "If you can see:"
echo "  ✓ 16 different basic colors"
echo "  ✓ A full 256-color palette"
echo "  ✓ Smooth RGB gradients in red, green, and blue"
echo "  ✓ Bold, italic, and underlined text"
echo ""
echo "Then your terminal has full color support!"
