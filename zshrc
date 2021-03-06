# environment {{{
# not using .zshenv, because it runs before /etc/profile, and /etc/profile
# tends to hard-set $PATH and such
[ -f "$HOME/.env" ] && source $HOME/.env
# }}}
# Change the window title of X terminals {{{
function term_title_precmd () {
    echo -ne "\033]0;${USER}@${HOST}:${PWD/$HOME/~}\007"
}
case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome|screen*)
        precmd_functions+=(term_title_precmd)
        ;;
esac # }}}
# aliases {{{
[ -f "$HOME/.aliases" ] && source $HOME/.aliases
mkdir -p $HOME/.vim/data/hist
function vim {
    local zsh_hist_fname
    zsh_hist_fname=$HOME/.vim/data/hist/$$
    command vim --cmd "let g:_zsh_hist_fname = '$zsh_hist_fname'" "$@"
    if [[ -r $zsh_hist_fname ]]; then
        while read line; do
            if echo $line | grep -q "[[:space:]']"; then
                line=${line/\'/\'\\\\\'\'}
                line="'$line'"
            fi
            print -s "vim $line"
        done < $zsh_hist_fname
        fc -AI
        rm -f $zsh_hist_fname
    fi
}
# }}}
# completion {{{
source ~/.zshcomplete
# }}}
# zsh configuration {{{
source ~/.zshinput
autoload -U colors
colors
setopt incappendhistory
setopt extendedhistory
setopt histignoredups
setopt noclobber
setopt nobeep
setopt completeinword
setopt correct
export REPORTTIME=120
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=1000000000
export SAVEHIST=1000000000
export SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [ynae] "
export KEYTIMEOUT=5
# plugins {{{
# cdhist {{{
source ~/.sh/cdhist.sh
# }}}
# zsh-syntax-highlighting {{{
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=green'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
ZSH_HIGHLIGHT_STYLES[function]='fg=green'
ZSH_HIGHLIGHT_STYLES[command]='fg=green'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=green'
ZSH_HIGHLIGHT_STYLES[path]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=blue,underline'
ZSH_HIGHLIGHT_STYLES[path_approx]='underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[history-expansion]='none'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[assign]='fg=cyan'
# }}}
# opp {{{
source ~/.zsh/opp/opp.zsh
opp_operators+=("e" opp-vi-change)
bindkey -M vicmd "e" opp
{ bindkey -M afu-vicmd "e" opp } > /dev/null 2>&1
# }}}
# }}}
# prompt {{{
function shell_prompt_precmd () {
    PROMPT=`fancy-prompt --prompt-escape zsh $?`
    RPS1=''
}
precmd_functions+=(shell_prompt_precmd)
function zle-keymap-select () {
    setopt localoptions no_ksharrays
    { [[ "${@[2]-main}" == opp ]] } && return
    if [[ "x$KEYMAP" == 'xmain' ]]; then
        RPS1=''
    else
        RPS1="%{$fg_bold[yellow]%}[${KEYMAP/vicmd/NORMAL}]%{$reset_color%}"
    fi
    zle reset-prompt
}
zle -N zle-keymap-select
# }}}
# }}}
# fortune {{{
fortune -n600 -s ~/.fortune | grep -v -E "^$"
# }}}
