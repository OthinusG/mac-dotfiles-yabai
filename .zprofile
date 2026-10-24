# >>> AI api-key >>>
if [ -f ~/.ai_keys ]; then
    source ~/.ai_keys
fi
# <<< AI ai_key <<<

# Setting PATH for Python 3.12
export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:${PATH}"
export PATH="/opt/homebrew/anaconda3/bin:$PATH"
export PATH="/opt/anaconda3/bin:$PATH"
export CONDA_CHANGEPS1=false


# npm
PATH=~/.local/bin:$PATH


# >>> brew >>>
  export HOMEBREW_PIP_INDEX_URL=https://pypi.mirrors.ustc.edu.cn/simple #ckbrew
  export HOMEBREW_API_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles/api  #ckbrew
  export HOMEBREW_BOTTLE_DOMAIN=''
  eval $(/opt/homebrew/bin/brew shellenv) #ckbrew
# <<< brew <<<


# >>> macports >>>
	export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# <<< macports <<<


# >>> curl >>>
	export PATH="/opt/homebrew/opt/curl/bin:$PATH"
	export LDFLAGS="-L/opt/homebrew/opt/curl/lib"
	export CPPFLAGS="-I/opt/homebrew/opt/curl/include"
	PATH=~/.local/bin/:$PATH
# <<< curl initialize <<<

# QODERCN_DISPATCHER_PATH v1
path=("$HOME/.qoder-cn/entry" ${path:#"$HOME/.qoder-cn/entry"})
export PATH
# END QODERCN_DISPATCHER_PATH v1
