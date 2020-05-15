#!/bin/sh
#
# Copyright (c) 2020, Cristian Ariza
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# a command-line task manager

set -eu

TSK_PATH="$HOME/.cache.tsk"
BKP="$TSK_PATH/backup.csv"
DONE="$TSK_PATH/done.log"
TMP="$(mktemp)"
TODO="$TSK_PATH/pending.csv"

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

# Backs up TODO
backup() { cp "$TODO" "$BKP"; }

# Orders TODO
tsktidy() {
	backup
	cp "$TODO" "$TMP"
	sort -t, -k 4 "$TODO" >"$TMP"
	mv "$TMP" "$TODO"
}

# Prints list of tasks
tskp() {
	tsktidy

	{
		echo 'ID,ASSIGNEE,TASK NAME,PRIORITY,DUE'
		cat "$TODO"
	} | awk -F ',' '{ printf "%-7s%-10s%-40s%-15s%s\n",$1,$2,$3,$4,$5 }'
}

tska() {
	backup
	cp "$TODO" "$TMP"

	date="$(date +%y%m%d%H%M%S)"

	id="$(printf '%s' "$date" | md5sum | head -c 5)"

	printf '%s,%s,%s\n' "$id" "$*" "$date" >>"$TMP"

	mv "$TMP" "$TODO"
}

tskd() {
	[ "$#" -eq 0 ] && return

	backup

	# TODO is not copied to TMP as we will overwrite TMP
	true >"$TMP"

	filter="$1" && shift

	# if id matches filter goes to DONE, otherwise goes to TMP
	awk -F',' -v filter="$filter" -v date="$(date)" -v DONE="$DONE" \
		-v TMP="$TMP" '
			$1 == filter {
				printf "[%s]: %s\n", date, $0 >> DONE
				next
			}
			{ print >> TMP; }
		' "$TODO"

	mv "$TMP" "$TODO"
}

tskq() { exit 0; }

tske() {
	backup
	"${EDITOR-vi}" "$TODO"
}

parse() {
	cmd="$1" && shift
	case "x$cmd" in
	xa)
		printf 'Assignee [-]: ' && read -r assignee

		while [ -z "${name:-}" ]; do
			printf 'Task name: ' && read -r name
		done

		printf 'Priority [-]: ' && read -r priority

		printf 'Due date [888888]: ' && read -r due

		set -- "$(printf '%s,%s,%s,%s' "${assignee--}" "$name" \
			"${priority--}" "${due-888888}")"
		;;
	xd | xe | xq | xp | xi) ;;
	*)
		help
		return 1
		;;
	esac

	eval "tsk$cmd" "$@" || printf 'tsk: command "%s" failed\n' "$cmd" >&2
}

# We don't want Ctrl+C to work
trap '' 2
trap 'rm -f "$TMP"' EXIT

mkdir -p "$TSK_PATH"
touch "$TODO"

case "$#" in
# If no args are given open interactive mode
0)
	while :; do
		printf '? ' && read -r args
		eval "set -- ${args:-p}"
		parse "$@" || true
	done
	;;
# Handles commands given from command line args
*) parse "$@" ;;
esac

trap 2
