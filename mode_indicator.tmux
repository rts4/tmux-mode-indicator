#!/usr/bin/env bash

set -e

declare -r mode_indicator_placeholder="\#{tmux_mode_indicator}"

declare -r prefix_prompt_config='@mode_indicator_prefix_prompt'
declare -r copy_prompt_config='@mode_indicator_copy_prompt'
declare -r sync_prompt_config='@mode_indicator_sync_prompt'
declare -r empty_prompt_config='@mode_indicator_empty_prompt'
declare -r custom_prompt_config="@mode_indicator_custom_prompt"
declare -r prefix_mode_style_config='@mode_indicator_prefix_mode_style'
declare -r copy_mode_style_config='@mode_indicator_copy_mode_style'
declare -r sync_mode_style_config='@mode_indicator_sync_mode_style'
declare -r empty_mode_style_config='@mode_indicator_empty_mode_style'
declare -r custom_mode_style_config="@mode_indicator_custom_mode_style"

declare -r copy_prompt_config_fg='@mi_copy_fg'
declare -r copy_prompt_config_bg='@mi_copy_bg'

declare -r sync_prompt_config_fg='@mi_sync_fg'
declare -r sync_prompt_config_bg='@mi_sync_bg'

declare -r prefix_prompt_config_fg='@mi_prefix_fg'
declare -r prefix_prompt_config_bg='@mi_prefix_bg'

declare -r empty_prompt_config_fg='@mi_empty_fg'
declare -r empty_prompt_config_bg='@mi_empty_bg'

tmux_option() {
    local -r option=$(tmux show-option -gqv "$1")
    local -r fallback="$2"
    echo "${option:-$fallback}"
}

indicator_style() {
    local -r style=$(tmux_option "$1" "$2")
    echo "${style:+#[${style//,/]#[}]}"
}

init_tmux_mode_indicator() {
    local -r \
        prefix_prompt=$(tmux_option "$prefix_prompt_config" " WAIT ") \
        copy_prompt=$(tmux_option "$copy_prompt_config" " COPY ") \
        sync_prompt=$(tmux_option "$sync_prompt_config" " SYNC ") \
        empty_prompt=$(tmux_option "$empty_prompt_config" " TMUX ") \
        prefix_style=$(indicator_style "$prefix_mode_style_config" "bg=blue,fg=black") \
        copy_style=$(indicator_style "$copy_mode_style_config" "bg=yellow,fg=black") \
        sync_style=$(indicator_style "$sync_mode_style_config" "bg=red,fg=black") \
        empty_style=$(indicator_style "$empty_mode_style_config" "bg=cyan,fg=black") \
        prefix_fg=$(indicator_style "$prefix_prompt_config_fg", "fg=blue") \
        copy_fg=$(indicator_style "$copy_prompt_config_fg", "fg=yellow") \
        sync_fg=$(indicator_style "$sync_prompt_config_fg", "fg=red") \
        empty_fg=$(indicator_style "$empty_prompt_config_fg", "fg=cyan") \
        prefix_bg=$(indicator_style "$prefix_prompt_config_bg", "bg=black") \
        copy_bg=$(indicator_style "$copy_prompt_config_bg", "bg=black") \
        sync_bg=$(indicator_style "$sync_prompt_config_bg", "bg=black") \
        empty_bg=$(indicator_style "$empty_prompt_config_bg", "bg=black")

    local -r \
        custom_prompt="#(tmux show-option -qv $custom_prompt_config)" \
        custom_style="#(tmux show-option -qv $custom_mode_style_config)"

    local -r \
        mode_prompt="#{?#{!=:$custom_prompt,},$custom_prompt,#{?client_prefix,$prefix_prompt,#{?pane_in_mode,$copy_prompt,#{?pane_synchronized,$sync_prompt,$empty_prompt}}}}" \
        mode_style="#{?#{!=:$custom_style,},#[$custom_style],#{?client_prefix,$prefix_style,#{?pane_in_mode,$copy_style,#{?pane_synchronized,$sync_style,$empty_style}}}}" \
        mode_fg="#{?#{!=:$custom_style,},#[$custom_style],#{?client_prefix,$prefix_fg,#{?pane_in_mode,$copy_fg,#{?pane_synchronized,$sync_fg,$empty_fg}}}}" \
        mode_bg="#{?#{!=:$custom_style,},#[$custom_style],#{?client_prefix,$prefix_bg,#{?pane_in_mode,$copy_bg,#{?pane_synchronized,$sync_bg,$empty_bg}}}}"

    local -r mode_indicator="$mode_fg#[default]$mode_style$mode_prompt#[default]$mode_style#[default]"

    local -r status_left_value="$(tmux_option "status-left")"
    tmux set-option -gq "status-left" "${status_left_value/$mode_indicator_placeholder/$mode_indicator}"

    local -r status_right_value="$(tmux_option "status-right")"
    tmux set-option -gq "status-right" "${status_right_value/$mode_indicator_placeholder/$mode_indicator}"
}

init_tmux_mode_indicator
