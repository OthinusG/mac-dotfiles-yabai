# >>> AI api-key >>>
if [ -f ~/.ai_keys ]; then
    source ~/.ai_keys
fi
# <<< AI ai_key <<<


# >>> proxy >>>
proxy() {
    export HTTP_PROXY="http://127.0.0.1:7897"
    export HTTPS_PROXY="http://127.0.0.1:7897"
    export ALL_PROXY="socks5h://127.0.0.1:7897"

    export http_proxy="$HTTP_PROXY"
    export https_proxy="$HTTPS_PROXY"
    export all_proxy="$ALL_PROXY"

    echo "Proxy ON → 127.0.0.1:7897"
}

unproxy() {
    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY
    unset http_proxy https_proxy all_proxy

    echo "Proxy OFF"
}
# <<< proxy <<<


# >>> starship >>>
	source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
	ZSH_HIGHLIGHT_STYLES[path]="fg=#a6e3a1"
 	ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=#89dceb"
	
 	source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=245"
	
	fpath=("$(brew --prefix)/share/zsh/site-functions" "$(brew --prefix)/share/zsh-completions" $fpath)
	autoload -Uz compinit && compinit -u
	zstyle ':completion:*' menu select
	
	eval "$(starship init zsh)"
# <<< starship <<<





# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/wqin/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/wqin/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/wqin/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/wqin/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

