## vim:ft=zsh
if [[ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" == 'true' ]] ; then
    # Default: off - these are potentially expensive on big repositories
    git diff --no-ext-diff --ignore-submodules=dirty --quiet --exit-code 2> /dev/null ||
        gitunstaged=1
    if git rev-parse --quiet --verify HEAD &> /dev/null ; then
        git diff-index --cached --quiet --ignore-submodules=dirty HEAD 2> /dev/null
        (( $? && $? != 128 )) && gitstaged=1
    else
        # empty repository (no commits yet)
        # 4b825dc642cb6eb9a060e54bf8d69288fbee4904 is the git empty tree.
        git diff-index --cached --quiet --ignore-submodules=dirty 4b825dc642cb6eb9a060e54bf8d69288fbee4904 2>/dev/null
        (( $? && $? != 128 )) && gitstaged=1
    fi
fi
