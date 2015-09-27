mess "Adopt new push behaviour (simple)"
git config --global push.default simple
mess "Configure newlines instead of carriage returns"
git config --global core.autocrlf input
mess "Setup git to remember password for current session"
git config --global credential.helper cache

mess 'Make vim swap&backup dirs'
mkdir -p ~/.vim/{swap,backup}
mess 'Install minted (latex)'
mkdir -p ~/texmf/tex/latex/minted
curl -o ~/texmf/tex/latex/minted/minted.sty https://raw.githubusercontent.com/gpoore/minted/master/source/minted.sty
mess 'Install vim plugins'
vim -E +PluginInstall +qall
mess 'Setup initial RPI ip address'
echo 192.168.100.110 > ~/.rpi
mess 'Setup vlc playback speed to 1.2'
mkdir ~/.config/vlc
echo 'rate=1.2' > ~/.config/vlc/vlcrc
mess 'Setup Qt style equal to GTK+'
echo -e "[Qt]\nstyle=GTK+" > ~/.config/Trolltech.conf
