#!/usr/bin/env bash

# Shared dmenu backend helpers (rofi/fuzzel).
# Intended to be sourced by scripts living next to this file.

# Public API:
# - use_dmenu_backend <auto|rofi|fuzzel>
# - dmenu_list <prompt> [matching] [insensitive] [selected_index]
# - dmenu_prompt <prompt> [prefill] [insensitive]
# - dmenu_password <prompt>
#
# Notes:
# - matching: rofi supports fuzzy|prefix|normal; fuzzel supports fuzzy|fzf|exact.
#   For matching=prefix on fuzzel, we fall back to exact as best-effort.

_dmenu_have_cmd() {
	command -v "$1" >/dev/null 2>&1
}

_dmenu_detect_backend() {
	local requested="${1:-auto}"

	case "$requested" in
	auto)
		if [[ -n "${WAYLAND_DISPLAY:-}" ]] && _dmenu_have_cmd fuzzel; then
			echo "fuzzel"
			return 0
		fi
		if _dmenu_have_cmd rofi; then
			echo "rofi"
			return 0
		fi
		if _dmenu_have_cmd fuzzel; then
			echo "fuzzel"
			return 0
		fi
		echo "Error: neither 'rofi' nor 'fuzzel' found in PATH" >&2
		return 127
		;;
	rofi | fuzzel)
		echo "$requested"
		return 0
		;;
	*)
		echo "Error: invalid backend '$requested' (expected auto|rofi|fuzzel)" >&2
		return 2
		;;
	esac
}

use_dmenu_backend() {
	DMENU_BACKEND="$(_dmenu_detect_backend "${1:-auto}")" || return $?
	export DMENU_BACKEND
}

_one_trailing_space() {
	local prompt="${1:-}"
	# Trim trailing whitespace, then add exactly one space.
	prompt="${prompt%"${prompt##*[![:space:]]}"}"
	printf '%s ' "$prompt"
}

dmenu_list() {
	local prompt="$1"
	local matching="${2:-fuzzy}"
	local insensitive="${3:-false}"
	local selected_index="${4:-}"

	case "${DMENU_BACKEND:-auto}" in
	rofi)
		local -a args=(-dmenu -p "$prompt")
		if [[ "$insensitive" == "true" ]]; then
			args+=(-i)
		fi
		if [[ -n "$matching" ]]; then
			args+=(-matching "$matching")
		fi
		if [[ -n "$selected_index" ]]; then
			args+=(-selected-row "$selected_index")
		fi
		rofi "${args[@]}"
		;;
	fuzzel)
		local -a args=(--dmenu --prompt "$(_one_trailing_space "$prompt")")
		case "$matching" in
		fuzzy | fzf | exact)
			args+=(--match-mode="$matching")
			;;
		prefix)
			args+=(--match-mode=exact)
			;;
		*)
			args+=(--match-mode=fuzzy)
			;;
		esac
		if [[ -n "$selected_index" ]]; then
			args+=(--select-index="$selected_index")
		fi
		fuzzel "${args[@]}"
		;;
	*)
		use_dmenu_backend "${DMENU_BACKEND:-auto}" || return $?
		dmenu_list "$prompt" "$matching" "$insensitive" "$selected_index"
		;;
	esac
}

# Free-form input.
dmenu_prompt() {
	local prompt="$1"
	local prefill="${2:-}"
	local insensitive="${3:-false}"

	case "${DMENU_BACKEND:-auto}" in
	rofi)
		local -a args=(-dmenu -p "$prompt" -l 0)
		if [[ "$insensitive" == "true" ]]; then
			args+=(-i)
		fi
		if [[ -n "$prefill" ]]; then
			args+=(-filter "$prefill")
		fi
		printf '' | rofi "${args[@]}"
		;;
	fuzzel)
		local -a args=(--dmenu --prompt-only "$(_one_trailing_space "$prompt")" --match-mode=fuzzy)
		if [[ -n "$prefill" ]]; then
			args+=(--search "$prefill")
		fi
		fuzzel "${args[@]}"
		;;
	*)
		use_dmenu_backend "${DMENU_BACKEND:-auto}" || return $?
		dmenu_prompt "$prompt" "$prefill" "$insensitive"
		;;
	esac
}

dmenu_password() {
	local prompt="$1"

	case "${DMENU_BACKEND:-auto}" in
	rofi)
		printf '' | rofi -dmenu -password -p "$prompt" -l 0
		;;
	fuzzel)
		fuzzel --dmenu --prompt-only "$(_one_trailing_space "$prompt")" --password
		;;
	*)
		use_dmenu_backend "${DMENU_BACKEND:-auto}" || return $?
		dmenu_password "$prompt"
		;;
	esac
}
