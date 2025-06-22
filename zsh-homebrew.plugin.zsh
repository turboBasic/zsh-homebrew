0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

typeset -gA PLUGIN_ZSH_HOMEBREW
PLUGIN_ZSH_HOMEBREW[dir]=${0:h}
PLUGIN_ZSH_HOMEBREW[function_files]=''
PLUGIN_ZSH_HOMEBREW[functions]=''

() {
    emulate -LR zsh

    # capture all files in functions/ dir including those starting with dot
    typeset -a function_files=( ${PLUGIN_ZSH_HOMEBREW[dir]}/functions/*(D) )
    PLUGIN_ZSH_HOMEBREW[function_files]=${(F)function_files}

    # Leave only basenames
    typeset -a function_names=( ${^function_files:t} )
    PLUGIN_ZSH_HOMEBREW[functions]=${(F)function_names}

    # Remove existing functions which conflict with our function_names
    typeset -a existing_functions=( ${${(k)functions}:*function_names} )
    (( $#existing_functions )) && unfunction $existing_functions

    # Now when all conflicting functiones are removed we can autoload our functions
    builtin autoload -Uz $function_files
}

function homebrew_prefix() {
    # Find Homebrew prefix without executing Homebrew, empty if not found

    # Standard header of Zsh plugin function.
    # - https://zdharma-continuum.github.io/zinit/wiki/zsh-plugin-standard/#standard_recommended_options
    # - https://zdharma-continuum.github.io/zinit/wiki/zsh-plugin-standard/#standard_recommended_variables
    emulate -L zsh
    setopt \
        extended_glob \
        no_auto_pushd \
        no_short_loops \
        rc_quotes \
        typeset_silent \
        warn_create_global

    local MATCH REPLY
    integer MBEGIN MEND
    local -a match mbegin mend reply

    # End of standard header of Zsh plugin function


    if [[ -n "$HOMEBREW_PREFIX" ]]; then
        echo $HOMEBREW_PREFIX
    elif (( $+commands[brew] )); then
        echo ${commands[brew]:h:h}  # /opt/homebrew/bin/brew → /opt/homebrew
    else
        echo ${$(.homebrew_path_to_homebrew):h:h}
    fi
}

function homebrew_path_to_gnu_utils() {
    # Find path to Homebrew's GNU Coreutils package, empty if not found

    # Standard header of Zsh plugin function.
    # - https://zdharma-continuum.github.io/zinit/wiki/zsh-plugin-standard/#standard_recommended_options
    # - https://zdharma-continuum.github.io/zinit/wiki/zsh-plugin-standard/#standard_recommended_variables

    emulate -L zsh
    setopt \
        extended_glob \
        no_auto_pushd \
        no_short_loops \
        rc_quotes \
        typeset_silent \
        warn_create_global

    local MATCH REPLY
    integer MBEGIN MEND
    local -a match mbegin mend reply

    # End of standard header of Zsh plugin function


    local homebrew_prefix=$(homebrew_prefix)
    # only directories and symlinks to directories  
    echo ${homebrew_prefix:+$homebrew_prefix/opt/coreutils/libexec/gnubin}(-N/)
}

function .homebrew_path_to_homebrew() {
    # Find path to Homebrew binary, empty if not found
    
    typeset -aU homebrew=(
        $commands[brew]
        $HOMEBREW_PREFIX/bin/brew
        /home/linuxbrew/.linuxbrew/bin/brew
        /opt/homebrew/bin/brew
        /usr/local/bin/brew
    )
    reply=( ${^homebrew}(-*N) )  # only executable files, including symlinks to them
    echo ${(F)reply}
}