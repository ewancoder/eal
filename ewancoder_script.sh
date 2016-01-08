mess "Configure git for $main"
mess "Configure git user.name as $main"
git config --global user.name "$main"
mess "Configure git user.email as $main@gmail.com"
git config --global user.email "$main@gmail.com"
mess "Configure git merge.tool as vimdiff"
git config --global merge.tool vimdiff
mess "Configure git core.editor as vim"
git config --global core.editor vim
mess "Adopt new push behaviour (simple)"
git config --global push.default simple
mess "Configure newlines instead of carriage returns"
git config --global core.autocrlf input
mess "Setup git to remember password for current session"
git config --global credential.helper cache

mess 'Link ewancoder oh-my-zsh theme'
ln -s "$HOME/.dotfiles/.ewancoder.zsh-theme" "$HOME/.oh-my-zsh/themes/ewancoder.zsh-theme"
mess 'Make vim swap&backup dirs'
mkdir -p ~/.vim/{swap,backup}
mess 'Install minted (latex)'
mkdir -p ~/texmf/tex/latex/minted
curl -o ~/texmf/tex/latex/minted/minted.sty https://raw.githubusercontent.com/gpoore/minted/master/source/minted.sty
mess 'Setup initial RPI ip address'
echo 192.168.100.110 > ~/.rpi
mess 'Setup vlc playback speed to 1.2'
mkdir ~/.config/vlc
echo 'rate=1.2' > ~/.config/vlc/vlcrc
mess 'Setup Qt style equal to GTK+'
echo -e "[Qt]\nstyle=GTK+" > ~/.config/Trolltech.conf
mess 'Install vim plugins'
#vim -E +PluginInstall +qall
vim +PluginInstall +qall
