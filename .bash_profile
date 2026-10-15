# macOS terminals start bash as a login shell, which reads ~/.bash_profile instead of ~/.bashrc
if [[ -f "$HOME"/.bashrc ]]
then
    source "$HOME"/.bashrc
fi
