#!/bin/sh

set -e

js="main.js"

../node_modules/elm/bin/elm make --optimize --output=$js src/Leader.elm src/Follower.elm

echo "Compiled size:$(cat $js | wc -c) bytes  ($js)"

../node_modules/uglify-es/bin/uglifyjs $js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | ../node_modules/uglify-es/bin/uglifyjs --mangle --output=$js

echo "Minified size:$(cat $js | wc -c) bytes  ($js)"
