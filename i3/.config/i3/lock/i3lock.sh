#!/bin/sh

BLANK='#00000000'
CLEAR='#ffffff22'
DEFAULT='#13131a'
TEXT='#7aa2f7'
WRONG='#db4b4b'
VERIFYING='#414868'

i3lock \
  --insidever-color=$CLEAR     \
  --ringver-color=$VERIFYING   \
  --insidewrong-color=$CLEAR   \
  --ringwrong-color=$WRONG     \
  --inside-color=$BLANK        \
  --ring-color=$TEXT           \
  --line-color=$BLANK          \
  --separator-color=$DEFAULT   \
  --verif-color=$VERIFYING     \
  --wrong-color=$TEXT          \
  --time-color=$TEXT           \
  --date-color=$TEXT           \
  --keyhl-color=$VERIFYING     \
  --bshl-color=$VERIFYING      \
  --blur 5                     \
  --clock                      \
  --indicator                  \
  --time-str="%H:%M:%S"        \
  --date-str="%A, %Y-%m-%d"    \

# Turn off the screen after 1 minute
xset dpms 0 0 60

