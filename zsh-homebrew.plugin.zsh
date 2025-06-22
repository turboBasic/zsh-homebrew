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
