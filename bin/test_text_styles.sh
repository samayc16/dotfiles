#!/usr/bin/env bash
# Text style test. printf escapes (not `echo -e "\e"`) so it also works on
# macOS's /bin/bash 3.2.

ESC=$'\033'
R="${ESC}[0m"

echo "Testing text styles in terminal:"
echo ""
echo "Normal text"
printf '%s[1mBold text%s\n' "$ESC" "$R"
printf '%s[3mItalic text%s\n' "$ESC" "$R"
printf '%s[4mUnderlined text%s\n' "$ESC" "$R"
printf '%s[1;3mBold italic text%s\n' "$ESC" "$R"
printf '%s[1;4mBold underlined text%s\n' "$ESC" "$R"
printf '%s[3;4mItalic underlined text%s\n' "$ESC" "$R"
printf '%s[1;3;4mBold italic underlined text%s\n' "$ESC" "$R"
printf '%s[4:3mUndercurl text%s (needs a terminal with styled underlines)\n' "$ESC" "$R"
echo ""
echo "If you can see differences in the text above, styling works!"
