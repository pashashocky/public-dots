# prevent mac /etc/profile screwing with the path
# https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if [ -f /etc/profile ]; then
  PATH=""
  source /etc/profile
fi

# Needs to be on top otherwise it messes with the PROMPT
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


case $TERM in
  (*xterm* | *rxvt* | *alacritty* | tmux*)

    # Write some info to terminal title.
    # This is seen when the shell prompts for input.
    function precmd {
      # Semantic prompts
      # allow scrolling in wezterm to the previous prompt
      #
      # https://gitlab.freedesktop.org/Per_Bothner/specifications/blob/master/proposals/semantic-prompts.md
      # https://gitlab.freedesktop.org/Per_Bothner/specifications/-/blob/master/proposals/prompts-data/shell-integration.zsh
      local ret="$?"
      if test "$_prompt_executing" != "0"
      then
        _PROMPT_SAVE_PS1="$PS1"
        _PROMPT_SAVE_PS2="$PS2"
        PS1=$'%{\e]133;P;k=i\a%}'$PS1$'%{\e]133;B\a\e]122;> \a%}'
        PS2=$'%{\e]133;P;k=s\a%}'$PS2$'%{\e]133;B\a%}'
      fi
      if test "$_prompt_executing" != ""
      then
         printf "\033]133;D;%s;aid=%s\007" "$ret" "$$"
      fi
      printf "\033]133;A;cl=m;aid=%s\007" "$$"
      _prompt_executing=0

        
      vcs_info
      print -Pn "\e]0;zsh %(1j,%j job%(2j|s|); ,)%~\a"

      # Parse timer
      if [ $timer ]; then
        timer_show=$(($SECONDS - $timer))
        PRERPROMPT=""
        if (($timer_show > 60)); then
            min=$(($timer_show / 60))
            sec=$(($timer_show - $min * 60))
            PRERPROMPT="%F{yellow}${min}m ${sec}s %{$reset_color%} "
        elif (($timer_show > 10)); then
            PRERPROMPT="%F{yellow}${timer_show}s %{$reset_color%} "
        fi
        unset timer
      fi
      
      # Conda Environment name in prompt
      CONDA_ENV_NAME=""
      if [ $CONDA_DEFAULT_ENV ]; then
        CONDA_ENV_NAME="%F{yellow}$(echo $CONDA_DEFAULT_ENV)%{$reset_color%} "
      fi

      if [ $PROMPT ]; then
          export PROMPT="$(echo "${PROMPT/$CONDA_PROMPT_MODIFIER/}")"
      fi
    }
    # Write command and args to terminal title.
    # This is seen while the shell waits for a command to complete.
    function preexec {
      # Semantic prompts
      PS1="$_PROMPT_SAVE_PS1"
      PS2="$_PROMPT_SAVE_PS2"
      printf "\033]133;C;\007"
      _prompt_executing=1

      printf "\033]0;%s\a" "$1"
      timer=${timer:-$SECONDS}
    }

  ;;
esac

# ZPLUG
source ~/.zplug/init.zsh || \
    curl -sL --proto-redir -all,https \
    https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
zplug "zplug/zplug"  # Actual plugin manager
# zplug "zdharma-continuum/history-search-multi-word"  # better CTRL+R Suggestion aka fzf
zplug "changyuheng/zsh-interactive-cd"  # Interactive cd with fzf suggestions
zplug "zsh-users/zsh-history-substring-search"  # search from history by substring
# bindkey "^P" history-substring-search-up
# bindkey "^N" history-substring-search-down
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
zplug "MichaelAquilina/zsh-you-should-use"  # forces you to use your aliases
zplug "zsh-users/zsh-completions", as:plugin, use:"src"  # gathers completions not part of zsh
# zplug "rupa/z", use:z.sh  # jump around to the most frecent directory `z config` based on fasd
zplug "zsh-users/zsh-autosuggestions"  # grey auto-complete in zsh, ctrl+space to accept
    export ZSH_AUTOSUGGEST_USE_ASYNC=true
    bindkey '^ ' autosuggest-accept
zplug "mafredri/zsh-async", from:github  # allow zsh to run asynchronous tasks
# defer:3 needed to load after compinit
zplug "zsh-users/zsh-syntax-highlighting", defer:3  # syntax highlighting for commands
# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
zplug load

# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

## init mcfly
# eval "$(mcfly init zsh)"

# Setopts
setopt correct_all      # spelling correction for all arguments
setopt autocd           # autocd just by typing directory
setopt extended_glob    # allows printing extended glob with print -l **/*
setopt autopushd        # auto push directory to use with popd
setopt auto_list        # automatically list choices on ambiguous completion
setopt auto_menu        # automatically use menu completion
setopt always_to_end    # move cursor to end if word had one match
setopt interactivecomments  # Allow comments in the command line
# Report the status of background jobs immediately,
# rather than waiting until just before printing a prompt.
setopt notify
# Automatically list choices on an ambiguous completion.
setopt auto_list
# confirm execution of command from history
setopt hist_verify
setopt prompt_subst     # allow prompt substitution for vcs_info

# Zcompletion
zstyle ':completion:*' menu select   # select completions with arrow keys

# group results by category
zstyle ':completion:*' matcher-list	'' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion
zstyle ':zplug:tag' depth 1
bindkey '^[[Z' reverse-menu-complete

# zoxide
eval "$(zoxide init zsh)"
cl () { 
    zi; 
    zle accept-line; 
}
zle     -N   cl
bindkey '^F' cl


eee () { 
    e; 
    zle accept-line; 
}
zle     -N   eee
bindkey '^E' eee


# FZF
source <(fzf --zsh)
# eval "$(fasd --init auto)"
export FZF_DEFAULT_COMMAND='fd -t f --hidden --follow -E .git -E node_modules -E target'
export FZF_DEFAULT_OPTS="--preview 'bat -n --color=always {}' --height 40% --reverse --border=sharp"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --header '[Enter] edit; [^e] accept; [^h] expand'
  --bind 'ctrl-h:reload(fd -t f . $HOME --hidden --follow -E .git -E node_modules -E target),ctrl-/:change-preview-window(down|hidden|),enter:execute(hx {})+abort,ctrl-e:accept'
  "

export FZF_ALT_C_COMMAND="fd -t d --hidden --follow -E .git -E node_modules -E target"
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree --gitignore -C {}'
  --header '[^e] accept; [^h] include $HOME; [^r] restart'
  --bind 'ctrl-h:reload(fd -t d . $HOME --hidden --follow -E .git -E node_modules -E target),ctrl-r:reload(fd -t d . --hidden --follow -E .git -E node_modules -E target),ctrl-e:accept'
  "
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header '[CTRL-Y] copy to clipboard'
  --preview 'echo {2..} | bat --color=always -pl sh'
  --preview-window 'down:20%'
  "

fzf-git-branch() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    git branch --color=always --all --sort=-committerdate |
        grep -v HEAD |
        fzf --height 50% --ansi --no-multi --preview-window right:65% \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
        sed "s/.* //"
}

fzf-git-checkout() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    local branch

    branch=$(fzf-git-branch)
    if [[ "$branch" = "" ]]; then
        echo "No branch selected."
        return
    fi

    # If branch name starts with 'remotes/' then it is a remote branch. By
    # using --track and a remote branch name, it is the same as:
    # git checkout -b branchName --track origin/branchName
    if [[ "$branch" = 'remotes/'* ]]; then
        # gt co --track $branch
        gt co $branch;
    else
        gt co $branch;
    fi
}

alias gb='fzf-git-branch'
alias gco='fzf-git-checkout'

# FASD
# eval "$(fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install)"
eval "$(fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install)"

# Direnv
eval "$(direnv hook zsh)"

# felix
# eval "$($HOME/.cargo/bin/fx --init)"

# sesh tmux
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(seshmux)
    [[ -z "$session" ]] && return
    z $session;
    zle accept-line;
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

# NVIM
# NVIM_LISTEN_ADDRESS=/tmp/nvimsocket

# TimeZone
export TZ=Europe/London

# Locale
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Colored ManPages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# history
HISTFILE=$HOME/.zsh-history
HISTSIZE=3000
SAVEHIST=10000 # nice for logging
setopt extended_history
setopt share_history
function history-all { history -E 1 }

# bindkey "^R" history-incremental-search-backward

# Term variable
# export TERM=xterm-256color
# [ "$TMUX" ] && export TERM=tmux-256color
export ZSH=$HOME/.zsh

# path
export GOPATH="$HOME/.go"
export PATH="$HOME/.local/bin:$GOPATH/bin:$HOME/.cargo/bin:$(brew --prefix)/opt/llvm/bin:$PATH"
export PATH="/Users/pash/.local/share/solana/install/active_release/bin:$PATH"  # solana

# abbreviation for later use
#export EDITOR="nvr -s"
export EDITOR="hx"
export PAGER=less

# Prompt + Git info
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' actionformats '%m%F{72}%b%f %c%u'
zstyle ':vcs_info:*' formats '%m%F{72}%b%f% %c%u'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{40} ●%f'
zstyle ':vcs_info:*' unstagedstr '%F{214} ●%f'
zstyle ':vcs_info:git+set-message:*' hooks check-untracked check-upstream

+vi-check-untracked() {
    [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]] &&
    hook_com[unstaged]+='%F{red} ●%f'
    return 0
}

+vi-check-upstream() {
    local ours theirs
    git rev-list --count --left-right 'HEAD...@{u}' 2>/dev/null | read ours theirs
    ((ours)) && hook_com[misc]="%F{green}$ours▲%f"
    ((theirs)) && hook_com[misc]+="%F{yellow}$theirs▼%f"
    hook_com[misc]+=${hook_com[misc]:+ }
    return 0
}

PROMPT='
${CONDA_ENV_NAME}%F{1}------------- %F{yellow}%T%f %F{255}${vcs_info_msg_0_}
> '
RPROMPT='${PRERPROMPT}%B%F{6}%~%f%b'

# Poetry prompt completion
fpath+=~/.zfunc
autoload -Uz compinit && compinit

###
#
# Shell aliases.
#
###

# cd
alias sb='cd "/Users/pash/Library/Mobile Documents/iCloud~md~obsidian/Documents/Ideaverse"'

## Git
alias cfg='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias cfgst='cfg status'
alias cfga='cfg add -u'
alias gr='git restore'
alias grs='git restore --staged'
alias gst='g st'
alias pn='pnpm'
alias cargo='nocorrect cargo'
alias brew='nocorrect brew'
alias conda='nocorrect conda'
alias anchor='nocorrect anchor'

## Apps
alias lf='lfcd'
alias ll='cdu -dh -s'
alias sll='sudo cdu -dh -s'
alias rs='ranger'
alias cdu='cdu -dh -s'
alias rgd='rip_grep_delta'

# mac
alias restartaudio='sudo launchctl kickstart -kp system/com.apple.audio.coreaudiod'

alias wakeph='wolcmd B06EBFCD5954 188.172.156.18 255.255.255.255 4343'
alias wakephl='wakeonlan -i 192.168.0.255 -p 4343 B0:6E:BF:CD:59:54'    

# dev
alias jc='jupyter qtconsole &'

#Other
alias myip='curl ipecho.net/plain ; echo'
alias pg='ping google.com'
alias clk='tty-clock -c -b -C 5'
alias arec='asciinema rec'
alias castme='ffcast -s recordmydesktop --width %w --height %h -x %x -y %y --fps 30 --v_bitrate 2000000 -o'
alias encode='mencoder -ovc lavc -oac mp3lame '

# Utils
alias conns='watch -n1 netstat -nputw'
alias top='top -s1'
alias grep='grep -i --color'
alias g='git'
alias lg='lazygit'
alias ls='eza -h'
alias l='ls -lah'
alias cpp='rsync -aP'
alias sauce='source ~/.zshrc'
alias sres='xrdb -load ~/.Xresources'

# misc.
alias ..="cd ../"
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias ........="cd ../../../../../../.."
alias .........="cd ../../../../../../../.."
alias ..........="cd ../../../../../../../../.."
alias ...........="cd ../../../../../../../../../.."
alias ............="cd ../../../../../../../../../../.."
alias .............="cd ../../../../../../../../../../../.."
alias ..............="cd ../../../../../../../../../../../../.."
alias ...............="cd ../../../../../../../../../../../../../.."
alias ................="cd ../../../../../../../../../../../../../../.."
alias .................="cd ../../../../../../../../../../../../../../../.."
alias ..................="cd ../../../../../../../../../../../../../../../../.."
alias ...................="cd ../../../../../../../../../../../../../../../../../.."
alias ....................="cd ../../../../../../../../../../../../../../../../../../.."
alias .....................="cd ../../../../../../../../../../../../../../../../../../../.."
alias ......................="cd ../../../../../../../../../../../../../../../../../../../../.."
alias .......................="cd ../../../../../../../../../../../../../../../../../../../../../.."
alias ........................="cd ../../../../../../../../../../../../../../../../../../../../../../.."
alias .........................="cd ../../../../../../../../../../../../../../../../../../../../../../../.."
alias ..........................="cd ../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ...........................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ............................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias .............................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ..............................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ...............................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias .................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ..................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ...................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ....................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias .....................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ......................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias .......................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ........................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias .........................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ..........................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ...........................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."
alias ............................................="cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../.."

###
#
# Shell functions.
#
###

# rg with delta
rip_grep_delta() {
    rg --json -C 2 "$1" | delta
}

# ix io pastie
ix() {
    local opts
    local OPTIND
    [ -f "$HOME/var/.netrc" ] && opts='-n'
    while getopts ":hd:i:n:" x; do
        case $x in
            h) echo "ix [-d ID] [-i ID] [-n N] [opts]"; return;;
            d) $echo curl $opts -X DELETE ix.io/$OPTARG; return;;
            i) opts="$opts -X PUT"; local id="$OPTARG";;
            n) opts="$opts -F read:1=$OPTARG";;
        esac
    done
    shift $(($OPTIND - 1))
    [ -t 0 ] && {
        local filename="$1"
        shift
        [ "$filename" ] && {
            curl $opts -F f:1=@"$filename" $* ix.io/$id
            return
        }
        echo "^C to cancel, ^D to send."
    }
    curl $opts -F f:1='<-' $* ix.io/$id
}

###
#
# Key setup for Colemak on an HHKB.
#
###
bindkey '^N' forward-word
bindkey '^P' backward-word
bindkey "^A" beginning-of-line
bindkey "^O" end-of-line

###
#
# LS colors for gnu ls and gnu dircolors.
#
# ##
LS_COLORS='bd=38;5;68:ca=38;5;17:cd=38;5;113;1:di=38;5;30:do=38;5;127:ex=38;5;166;1:pi=38;5;126:fi=38;5;253:ln=target:mh=38;5;220;1:or=48;5;196;38;5;232;1:ow=38;5;220;1:sg=48;5;234;38;5;100;1:su=38;5;137:so=38;5;197:st=38;5;86;48;5;234:tw=48;5;235;38;5;139;3:*LS_COLORS=48;5;89;38;5;197;1;3;4;7:*.BAT=38;5;108:*.PL=38;5;160:*.asm=38;5;240;1:*.awk=38;5;148;1:*.bash=38;5;173:*.bat=38;5;108:*.c=38;5;110:*.cc=38;5;24;1:*.ii=38;5;24;1:*.cfg=1:*.cl=38;5;204;1:*.coffee=38;5;94;1:*.conf=1:*.C=38;5;24;1:*.cp=38;5;24;1:*.cpp=38;5;24;1:*.cxx=38;5;24;1:*.c++=38;5;24;1:*.ii=38;5;24;1:*.cs=38;5;74;1:*.css=38;5;91:*.csv=38;5;78:*.ctp=38;5;95:*.diff=48;5;197;38;5;232:*.enc=38;5;192;3:*.eps=38;5;192:*.etx=38;5;172:*.ex=38;5;148;1:*.example=38;5;225;1:*.git=38;5;197:*.gitignore=38;5;240:*.go=38;5;36;1:*.h=38;5;81:*.H=38;5;81:*.hpp=38;5;81:*.hxx=38;5;81:*.h++=38;5;81:*.tcc=38;5;81:*.f=38;5;81:*.for=38;5;81:*.ftn=38;5;81:*.s=38;5;81:*.S=38;5;81:*.sx=38;5;81:*.hi=38;5;240:*.hs=38;5;155;1:*.htm=38;5;125;1:*.html=38;5;125;1:*.info=38;5;101:*.ini=38;5;122:*.java=38;5;142;1:*.jhtm=38;5;125;1:*.js=38;5;42:*.jsm=38;5;42:*.jsm=38;5;42:*.json=38;5;199:*.jsp=38;5;45:*.lisp=38;5;204;1:*.log=38;5;190:*.lua=38;5;34;1:*.m=38;5;130;3:*.mht=38;5;129:*.mm=38;5;130;3:*.M=38;5;130;3:*.map=38;5;58;3:*.markdown=38;5;184:*.md=38;5;184:*.mf=38;5;220;3:*.mfasl=38;5;73:*.mi=38;5;124:*.mkd=38;5;184:*.mtx=38;5;36;3:*.nfo=38;5;220:*.o=38;5;240:*.pacnew=38;5;33:*.patch=48;5;197;38;5;232;1:*.pc=38;5;100:*.pfa=38;5;43:*.php=38;5;93:*.pl=38;5;214:*.plt=38;5;204;1:*.pm=38;5;197;1:*.pod=38;5;172;1:*.py=38;5;41:*.pyc=38;5;240:*.rb=38;5;192:*.rdf=38;5;144:*.rst=38;5;67:*.ru=38;5;142:*.scm=38;5;204;1:*.sed=38;5;130;1:*.sfv=38;5;197:*.sh=38;5;113:*.signature=38;5;206:*.sql=38;5;222:*.srt=38;5;116:*.sty=38;5;58:*.sug=38;5;44:*.t=38;5;28;1:*.tcl=38;5;64;1:*.tdy=38;5;214:*.tex=38;5;172:*.textile=38;5;106:*.tfm=38;5;64:*.tfnt=38;5;140:*.theme=38;5;109:*.txt=38;5;192:*.urlview=38;5;85:*.vim=1:*.viminfo=38;5;240;1:*.xml=38;5;199:*.yml=38;5;208:*.zsh=38;5;173:*README=38;5;220;1:*Makefile=38;5;196:*MANIFEST=38;5;243:*pm_to_blib=38;5;240:*.1=38;5;196;1:*.3=38;5;196;1:*.7=38;5;196;1:*.1p=38;5;160:*.3p=38;5;160:*.am=38;5;242:*.in=38;5;242:*.old=38;5;242:*.out=38;5;46;1:*.bmp=38;5;62:*.cdr=38;5;59:*.gif=38;5;72:*.ico=38;5;73:*.jpeg=38;5;66:*.jpg=38;5;66:*.JPG=38;5;66:*.png=38;5;68;1:*.svg=38;5;24;1:*.xpm=38;5;36:*.32x=38;5;137:*.A64=38;5;82:*.a00=38;5;11:*.a52=38;5;112:*.a64=38;5;82:*.a78=38;5;112:*.adf=38;5;35:*.atr=38;5;213:*.cdi=38;5;124:*.fm2=38;5;35:*.gb=38;5;203:*.gba=38;5;205:*.gbc=38;5;204:*.gel=38;5;83:*.gg=38;5;138:*.ggl=38;5;83:*.j64=38;5;102:*.nds=38;5;193:*.nes=38;5;160:*.rom=38;5;59;1:*.sav=38;5;220:*.sms=38;5;33:*.st=38;5;208;1:*.iso=38;5;124:*.nrg=38;5;124:*.qcow=38;5;141:*.VOB=38;5;137:*.IFO=38;5;240:*.BUP=38;5;241:*.MOV=38;5;42:*.3gp=38;5;134:*.3g2=38;5;133:*.asf=38;5;25:*.avi=38;5;114:*.divx=38;5;112:*.f4v=38;5;125:*.flv=38;5;131:*.m2v=38;5;166:*.mkv=38;5;202:*.mov=38;5;42:*.mp4=38;5;124:*.mpg=38;5;38:*.mpeg=38;5;38:*.ogm=38;5;97:*.ogv=38;5;94:*.rmvb=38;5;112:*.sample=38;5;130;1:*.ts=38;5;39:*.vob=38;5;137:*.webm=38;5;109:*.wmv=38;5;113:*.S3M=38;5;71;1:*.aac=38;5;137:*.cue=38;5;112:*.dat=38;5;165:*.dts=38;5;100;1:*.fcm=38;5;41:*.flac=38;5;166;1:*.m3u=38;5;172:*.m4=38;5;196;3:*.m4a=38;5;137;1:*.mid=38;5;102:*.midi=38;5;102:*.mod=38;5;72:*.mp3=38;5;191:*.oga=38;5;95:*.ogg=38;5;96:*.s3m=38;5;71;1:*.sid=38;5;69;1:*.spl=38;5;173:*.wv=38;5;149:*.wvc=38;5;149:*.afm=38;5;58:*.pfb=38;5;58:*.pfm=38;5;58:*.ttf=38;5;66:*.pcf=38;5;65:*.psf=38;5;64:*.bak=38;5;41;1:*.bin=38;5;249:*.pid=38;5;160:*.state=38;5;124:*.swo=38;5;236:*.swp=38;5;241:*.tmp=38;5;244:*.un~=38;5;240:*.zcompdump=38;5;240:*.zwc=38;5;240:*.db=38;5;60:*.dump=38;5;119:*.sqlite=38;5;60:*.typelib=38;5;60:*.7z=38;5;40:*.a=38;5;46:*.apk=38;5;172;3:*.arj=38;5;41:*.bz2=38;5;44:*.deb=38;5;215:*.ipk=38;5;117:*.jad=38;5;50:*.jar=38;5;51:*.nth=38;5;40:*.sis=38;5;39:*.part=38;5;239;1:*.r00=38;5;239:*.r01=38;5;239:*.r02=38;5;239:*.r03=38;5;239:*.r04=38;5;239:*.r05=38;5;239:*.r06=38;5;239:*.r07=38;5;239:*.r08=38;5;239:*.r09=38;5;239:*.r10=38;5;239:*.r100=38;5;239:*.r101=38;5;239:*.r102=38;5;239:*.r103=38;5;239:*.r104=38;5;239:*.r105=38;5;239:*.r106=38;5;239:*.r107=38;5;239:*.r108=38;5;239:*.r109=38;5;239:*.r11=38;5;239:*.r110=38;5;239:*.r111=38;5;239:*.r112=38;5;239:*.r113=38;5;239:*.r114=38;5;239:*.r115=38;5;239:*.r116=38;5;239:*.r12=38;5;239:*.r13=38;5;239:*.r14=38;5;239:*.r15=38;5;239:*.r16=38;5;239:*.r17=38;5;239:*.r18=38;5;239:*.r19=38;5;239:*.r20=38;5;239:*.r21=38;5;239:*.r22=38;5;239:*.r25=38;5;239:*.r26=38;5;239:*.r27=38;5;239:*.r28=38;5;239:*.r29=38;5;239:*.r30=38;5;239:*.r31=38;5;239:*.r32=38;5;239:*.r33=38;5;239:*.r34=38;5;239:*.r35=38;5;239:*.r36=38;5;239:*.r37=38;5;239:*.r38=38;5;239:*.r39=38;5;239:*.r40=38;5;239:*.r41=38;5;239:*.r42=38;5;239:*.r43=38;5;239:*.r44=38;5;239:*.r45=38;5;239:*.r46=38;5;239:*.r47=38;5;239:*.r48=38;5;239:*.r49=38;5;239:*.r50=38;5;239:*.r51=38;5;239:*.r52=38;5;239:*.r53=38;5;239:*.r54=38;5;239:*.r55=38;5;239:*.r56=38;5;239:*.r57=38;5;239:*.r58=38;5;239:*.r59=38;5;239:*.r60=38;5;239:*.r61=38;5;239:*.r62=38;5;239:*.r63=38;5;239:*.r64=38;5;239:*.r65=38;5;239:*.r66=38;5;239:*.r67=38;5;239:*.r68=38;5;239:*.r69=38;5;239:*.r69=38;5;239:*.r70=38;5;239:*.r71=38;5;239:*.r72=38;5;239:*.r73=38;5;239:*.r74=38;5;239:*.r75=38;5;239:*.r76=38;5;239:*.r77=38;5;239:*.r78=38;5;239:*.r79=38;5;239:*.r80=38;5;239:*.r81=38;5;239:*.r82=38;5;239:*.r83=38;5;239:*.r84=38;5;239:*.r85=38;5;239:*.r86=38;5;239:*.r87=38;5;239:*.r88=38;5;239:*.r89=38;5;239:*.r90=38;5;239:*.r91=38;5;239:*.r92=38;5;239:*.r93=38;5;239:*.r94=38;5;239:*.r95=38;5;239:*.r96=38;5;239:*.r97=38;5;239:*.r98=38;5;239:*.r99=38;5;239:*.rar=38;5;106;1:*.tar=38;5;118:*.tar.gz=38;5;34:*.tgz=38;5;35;1:*.xz=38;5;118:*.zip=38;5;41:*.pdf=38;5;203:*.djvu=38;5;141:*.cbr=38;5;140:*.cbz=38;5;140:*.chm=38;5;144:*.odt=38;5;111:*.ods=38;5;112:*.odp=38;5;166:*.odb=38;5;161:*.allow=38;5;112:*.deny=38;5;196:*.SKIP=38;5;244:*.def=38;5;136:*.directory=38;5;83:*.err=38;5;160;1:*.error=38;5;160;1:*.pi=38;5;126:*.properties=38;5;197;1:*.torrent=38;5;58:*.gp3=38;5;114:*.gp4=38;5;115:*.tg=38;5;99:*.pcap=38;5;29:*.cap=38;5;29:*.dmp=38;5;29:*.service=38;5;81:*@.service=38;5;45:*.socket=38;5;75:*.device=38;5;24:*.mount=38;5;115:*.automount=38;5;114:*.swap=38;5;113:*.target=38;5;73:*.path=38;5;116:*.timer=38;5;111:*.snapshot=38;5;139:';
export LS_COLORS


## Terraform completion: terraform -install-autocomplete
PATH="/usr/local/Cellar/perl/5.34.0/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/usr/local/Cellar/perl/5.34.0/lib/perl5/site_perl/5.34.0${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/usr/local/Cellar/perl/5.34.0/lib/perl5/site_perl/5.34.0${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/usr/local/Cellar/perl/5.34.0/lib/perl5/site_perl/5.34.0\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/usr/local/Cellar/perl/5.34.0/lib/perl5/site_perl/5.34.0"; export PERL_MM_OPT;


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# mac warpify zsh - not sure what this does but breaks tmux
# printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh" }}\x9c'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

LFCD="/Users/pash/.config/lf/lfcd.sh"                                #  pre-built binary, make sure to use absolute path
if [ -f "$LFCD" ]; then
    source "$LFCD"
fi
source /Users/pash/.config/broot/launcher/bash/br

# attach to tmux
# if [ -z "$TMUX" ] && [ "$TERM" = "xterm-256color" ]; then
#   tmux new-session -A -s root
# fi
