wdate() {
# Show date and time in other time zones

search=$1

format='%a %F --- %T ---  %z'
zoneinfo=/usr/share/zoneinfo/

if command -v timedatectl >/dev/null; then
    tzlist=$(timedatectl list-timezones)
else
    tzlist=$(find -L $zoneinfo -type f -print)
fi

grep -i "$search" <<< "$tzlist" \
| while read z
  do
      d=$(TZ=$z date +"$format")
      printf "%-32s %s\n" "$z" "$d"
  done
}

timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

parse_url() {
  local encoded_url="$1"
  node -e "
    const url = new URL(decodeURIComponent('$encoded_url'));
    const queryParams = Object.fromEntries(url.searchParams);
    console.log(queryParams);
  "
}

function prev() {
  PREV=$(fc -lrn | head -n 1)
  sh -c "pet new `printf %q "$PREV"`"
}
