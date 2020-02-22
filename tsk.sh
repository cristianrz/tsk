#!/bin/sh

set -eu

BKP="$HOME"/.cache/tsk/backup.csv
DONE="$HOME"/.cache/tsk/done.log
MAIN="$HOME"/.cache/tsk/pending.csv
TMP="$HOME"/.cache/tsk/tmp.csv

help() {
	cat >&2 <<'EOF'
Available commands:
	a  add task
	d  do task
	e  manually edit file
	p  print task list
	q  quit
EOF
}

# Backs up MAIN
backup() {
	cp "$MAIN" "$BKP"
}

# Orders MAIN
tsktidy() {
	backup
	cp "$MAIN" "$TMP"
	sort -t, -k 4 "$MAIN" >"$TMP"
	mv "$TMP" "$MAIN"
}

# Prints list of tasks
tskp() {
	tsktidy

	{
		cat <<'EOF'
ID,ASSIGNEE,TASK NAME,PRIORITY,DUE,CREATED
EOF
		cat "$MAIN"
	} | column -s, -t
}

tska() {
	backup
	cp "$MAIN" "$TMP"

	_date="$(date +%y%m%d%H%M%S)"

	_id="$(printf '%s' "$_date" | md5sum | head -c 5)"
	_middle="$*"
	_created="$_date"

	printf '%s,%s,%s\n' "$_id" "$_middle" "$_created" >>"$TMP"

	mv "$TMP" "$MAIN"
}

tskd() {
	if test "$#" -eq 0; then
		return 0
	fi

	backup
	# MAIN is not copied to TMP as we will overwrite TMP
	true >"$TMP"

	filter="$1" && shift

	while read -r line; do
		# Get the hash
		id="$(printf '%s' "$line" | cut -d',' -f 1)"
		case "$id" in
		"$filter")
			# If it matches the filter print and append to DONE
			printf "[%s]: %s\n" "$(date)" "$line" | tee "$DONE"
			;;
		*)
			# If it does not, append to TMP
			printf '%s\n' "$line" >>"$TMP"
			;;
		esac
	done <"$MAIN"

	mv "$TMP" "$MAIN"
}

tskq() { exit 0; }

tski() {
	tska "$USER","$(cat)",-,888888
}

tske() {
	backup
	cp "$MAIN" "$TMP"
	${EDITOR-vi} "$TMP"
	mv "$TMP" "$MAIN"
}

parse() {
	cmd="$1" && shift
	case "x$cmd" in
	xa)
		printf 'Assignee [-]: ' && read -r assignee
		: "${assignee:=-}"

		while [ -z "${name:-}" ]; do
			printf 'Task name: ' && read -r name
		done

		printf 'Priority [-]: ' && read -r priority
		: "${priority:=-}"

		printf 'Due date [888888]: ' && read -r due
		: "${due:=888888}"

		set -- "$(printf '%s,%s,%s,%s' "$assignee" "$name" "$priority" "$due")"
		unset assignee name priority due
		;;
	xd | xe | xq | xp | xi ) ;;
	*)
		help
		return 1
		;;
	esac

	if ! eval "tsk$cmd" "$@"; then
		printf '%s: command "%s" failed\n' "$(basename "$0")" "$cmd" >&2
	fi
}

# We don't want Ctrl+C to work
trap '' 2
trap 'rm -f "$TMP"' EXIT

# Initialise dir and file if they don't exist
if [ ! -f "$MAIN" ]; then
	DIR="$(dirname "$MAIN")"
	if [ ! -d "$DIR" ]; then
		mkdir -p "$DIR"
	fi

	touch "$MAIN"
fi

case "$#" in
# If no args are given open interactive mode
0)
	while true; do
		printf '? ' && read -r args
		eval "set -- ${args:-p}"
		parse "$@"
	done
	;;
# Handles commands given from command line args
*) parse "$@" ;;
esac

trap 2
