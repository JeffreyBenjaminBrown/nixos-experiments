# Use diff-so-fancy for Git diffs
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"
git config --global user.email "jeffbrown.the@gmail.com"
git config --global user.name "Jeffrey Benjamin Brown"
git config --global core.editor "emacs -nw"
