#!/bin/sh
set -eu

usage() {
  echo "usage: detached-reviewer.sh {launch|retry} ROUND -- COMMAND [ARG ...]" >&2
  echo "       detached-reviewer.sh {status|wait} ROUND" >&2
  exit 64
}

[ "$#" -ge 2 ] || usage
mode=$1
round=$2
shift 2

[ -d "$round" ] || {
  echo "round directory does not exist: $round" >&2
  exit 66
}
round=$(cd "$round" && pwd -P)

pid_file=$round/reviewer.pid
done_file=$round/reviewer.done
log_file=$round/codex.log

read_state() {
  state=idle
  detail=

  if [ -e "$done_file" ]; then
    status=$(tr -d '\r\n' <"$done_file")
    case "$status" in
      ''|*[!0-9]*) state=failed; detail="sentinel:$status" ;;
      *) state=complete; detail=$status ;;
    esac
    return
  fi

  if [ ! -e "$pid_file" ]; then
    for orphan in "$log_file" "$round/findings.json" "$round/thread-id"; do
      [ ! -e "$orphan" ] || {
        state=lost
        detail=missing-pid
        return
      }
    done
    return
  fi

  IFS=' ' read -r pid identity extra <"$pid_file" || true
  case ${pid:-} in
    ''|*[!0-9]*) state=unverifiable; detail=pid; return ;;
  esac
  [ -z "${extra:-}" ] || {
    state=unverifiable
    detail=pid-record
    return
  }

  if process=$(ps -ww -p "$pid" -o command= 2>&1); then
    case ${identity:-} in
      review-loop-detached.*)
        case "$process" in
          *"$identity"*) state=running; detail=$pid ;;
          *) state=lost; detail=$pid ;;
        esac
        ;;
      '')
        case "$process" in
          *review-loop-detached*) state=running; detail=$pid ;;
          *) state=unverifiable; detail=legacy-identity ;;
        esac
        ;;
      *) state=unverifiable; detail=identity ;;
    esac
  elif [ -n "$process" ]; then
    state=unverifiable
    detail=process-inspection
  else
    state=lost
    detail=$pid
  fi
}

print_state() {
  read_state
  print_loaded_state
}

print_loaded_state() {
  case "$detail" in
    '') printf '%s\n' "$state" ;;
    *) printf '%s %s\n' "$state" "$detail" ;;
  esac
}

wait_for_terminal() {
  while :; do
    read_state
    case "$state" in
      running|unverifiable) sleep 2 ;;
      lost)
        sleep 1
        read_state
        case "$state" in
          running|unverifiable) continue ;;
          *) print_loaded_state; return ;;
        esac
        ;;
      *) print_loaded_state; return ;;
    esac
  done
}

archive_state() {
  attempts=$round/reviewer-attempts
  mkdir -p "$attempts"
  attempt=1
  archive=$attempts/$(printf '%02d' "$attempt")
  while [ -e "$archive" ]; do
    attempt=$((attempt + 1))
    archive=$attempts/$(printf '%02d' "$attempt")
  done
  mkdir "$archive"

  for artifact in reviewer.pid reviewer.done codex.log findings.json thread-id; do
    [ ! -e "$round/$artifact" ] || mv "$round/$artifact" "$archive/$artifact"
  done
}

launch() {
  identity=review-loop-detached.$$.$(date +%s)

  nohup sh -c '
round=$1
shift
done_file=$round/reviewer.done
done_tmp=$round/.reviewer.done.$$

publish_status() {
  status=$?
  trap - 0 1 2 15
  printf "%s\n" "$status" >"$done_tmp" && mv "$done_tmp" "$done_file"
  exit "$status"
}

trap publish_status 0
trap "exit 129" 1
trap "exit 130" 2
trap "exit 143" 15

"$@" </dev/null >"$round/codex.log" 2>&1
' "$identity" "$round" "$@" </dev/null >/dev/null 2>&1 &

  worker_pid=$!
  pid_tmp=$round/.reviewer.pid.$$
  printf '%s %s\n' "$worker_pid" "$identity" >"$pid_tmp"
  mv "$pid_tmp" "$pid_file"
  printf 'started reviewer pid %s\n' "$worker_pid"
}

case "$mode" in
  status|wait)
    [ "$#" -eq 0 ] || usage
    if [ "$mode" = wait ]; then
      wait_for_terminal
    else
      print_state
    fi
    ;;
  launch|retry)
    [ "$#" -ge 2 ] || usage
    [ "$1" = "--" ] || usage
    shift

    read_state
    if [ "$mode" = retry ]; then
      case "$state" in
        running) echo "reviewer is still running: $detail" >&2; exit 75 ;;
        unverifiable) echo "reviewer identity is unverifiable: $detail" >&2; exit 69 ;;
        idle) echo "no reviewer state exists to retry" >&2; exit 66 ;;
        *) archive_state ;;
      esac
    else
      [ "$state" = idle ] || {
        echo "reviewer state already exists: $state ${detail:-}" >&2
        exit 73
      }
    fi

    launch "$@"
    ;;
  *) usage ;;
esac
