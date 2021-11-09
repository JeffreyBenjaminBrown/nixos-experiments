# Use diff-so-fancy for Git diffs
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"
git config --global user.email "jeffbrown.the@gmail.com"
git config --global user.name "Jeffrey Benjamin Brown"
git config --global core.editor "emacs -nw --no-init-file"

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
