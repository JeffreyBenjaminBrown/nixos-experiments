# Use diff-so-fancy for Git diffs
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"
git config --global user.email "jeffbrown.the@gmail.com"
git config --global user.name "Jeffrey Benjamin Brown"
git config --global core.editor "emacs -nw --no-init-file"
git config --global status.showUntrackedFiles all

# Things I build in nixpkgs by hand
cd /nix/nixpkgs

magically_update_the_nixpkgs_repo to match whatever channel I am on.

git checkout master
git fetch upstream
git merge upstream/master
git checkout jbb-oddities
git merge master

# So far I can't build sc3-plugins.
# Once I can, uncomment the sc3-plugins lines below.
nix-build -A     libmonome
nix-build -A     serialosc
# nix-build -A     sc3-plugins
nix-env -f . -iA libmonome serialosc # sc3-plugins

# Haskell
cabal update
cabal install vivid vivid-osc vivid-supercollider
  # This line failed, but maybe it's important.
# Then I rebooted, and the following worked:
cd ~/mtv/mtv
cabal repl

# # UNTESTED: Configure Konsole
# profile=~/.local/share/konsole/jbb.profile # Write a profile here
# echo [Appearance]                         > $profile
# echo ColorScheme=WhiteOnBlack		  > $profile
# echo Font=Monospace,24,-1,5,50,0,0,0,0,0  > $profile
# echo ""					  > $profile
# echo [General]				  > $profile
# echo Name=Profile 1			  > $profile
# echo Parent=FALLBACK/                     > $profile
# config=~/.config/konsolerc # Specify that profile here
# profileSpecifier="DefaultProfile=$profile" # A line to put into $config
#     # TODO: Will the $profile be substituted in the string above?
#     # Maybe I need to use '' instead of "".
# if grep -q "DefaultProfile" $config; then
#     # Replace the default profile with $profile
#     sed -i "s/.*DefaultProfile.*/$profileSpecifier/g" $config
#       # TODO: Will $profileSpecifier be substituted in the string above?
#       # Maybe I need to use '' instead of "".
# else
#     if grep -q "[Desktop Entry]" $config; then
# 	# Insert $profileSpecifier the line with "[Desktop Entry]".
# 	sed -i "/\[Desktop Entry\]/a $profileSpecifier" $config
#           # TODO: Will $profileSpecifier be substituted in the string above?
#           # Maybe I need to use '' instead of "".
#     else
# 	# There's no line with "[Desktop Entry]", so write one,
# 	# and specify the profile after it.
# 	echo [Desktop Entry]    > $config
# 	echo $profileSpecifier  > $config
# 	echo ""			> $config
#     fi
# fi

# Manual KDE config. Search terms are in quotation marks.
In_kde settings: search for "search", disable content indexing.
In_kde settings: set a keyboard shortcut to "invert" the color of a window.
In_kde settings: add Spanish as a second "language", configure "keyboard" shortcuts.
In_kde settings: use 16 "Virtual Desktops", 2 "Activities", set "KWin" shortcuts to move between them and move windows between them.
In_kde settings: set shortcuts to "zoom", and to view all desktops.
