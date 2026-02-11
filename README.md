# dotfiles

zsh configuration files for macOS
New Setup Steps

Video Tutorial: https://www.youtube.com/watch?v=y6XCebnB9gs&t=284s
Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" Run these commands in your terminal to add Homebrew to your PATH:
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/moebis/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

zsh Customizations

brew install zsh-autosuggestions zsh-syntax-highlighting
edit .zshrc
add:
alias ls="eza --icons --group-directories-first"
alias cat="bat -pp"

#Oh My Posh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
#  eval "$(oh-my-posh init zsh)"
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/moebis.toml)"
fi

#Zoxide
eval "$(zoxide init zsh)"

fastfetch

Starship

brew install starship nano ~/.zshrc add:
# ~/.zshrc
eval "$(starship init zsh)"

starship preset catppuccin-powerline -o ~/.config/starship.toml
Install Misc. Packages:

brew install yazi ffmpeg 7-Zip jq poppler fd rg fzf zoxide ImageMagick bat eza stow btop fastfetch pastel navi atuin
brew install gromgit/brewtils/taproom

add to .zshrc:
#atuin
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"
bindkey '^r' atuin-up-search-viins

stow command

nano ~/.stow-global-ignore

add to ignore:
RCS
.+,v

CVS
\.\#.+       # CVS conflict files / emacs lock files
\.cvsignore

\.svn
_darcs
\.hg

\.git
\.gitignore
\.gitmodules

.+~          # emacs backup files
\#.*\#       # emacs autosave files

^/README.*
^/LICENSE.*
^/COPYING

\.DS_Store

create dotfiles and .gitignore
mkdir ~/dotfiles
cd ~/dotfiles
echo .DS_Store >> .gitignore
stow .

git .zshrc initial commit and author settings

git init .
git add .zshrc
git commit -m "Initial commit"
git commit --amend --author="moebis <carl@moebis>" --no-edit
git config --global --edit
git config --global user.name "moebis"
git config --global user.email carl@moebis.com
git commit --amend --reset-author
git config --list

git .config commit

git add .config/
git commit -m "added .config"

check diff git diff .
revert changes git checkout .zshrc
git status
git status

roll back changes
git restore .

DS_Stores:
git add .gitignore
git commit -m '.DS_Store banished!'

Initial git sync:
git remote add origin git@github.com:moebis/dotfiles.git
git push origin main

Remove an origin:
git remote rm origin

GIT Key Creation:
1. Generate SSH key using ssh-keygen -t rsa -b 4096 -C "your email".
2. Copy the output of cat ~/.ssh/id_rsa.pub to your clipboard
3. Paste the above-copied output to the form at https://github.com/settings/ssh/new
4. Then go ahead to retry the operation that generated the initial fatal error.
To Pull Down Git Initially
git clone git@github.com:moebis/dotfiles.git

To Pull Down Changes
git pull

To Add Changes:
git commit -a
git push origin main

Oh-my-posh and Catputcin Theme

Install MesloLGS Nerd Font Mono
About
zsh configuration
Resources
 Readme

 Activity
Stars
 0 stars
Watchers
 1 watching
Forks
 0 forks
Releases
No releases published
Create a new release
Packages
No packages published
Publish your first package
Languages



	•	 GLSL 91.3%   Go 6.9%   Shell 1.8%
Suggested workflows
Based on your tech stack
	1	
	2	Go  Build a Go project.
	3	
	4	SLSA Generic generator  Generate SLSA3 provenance for your existing release workflows
	5	
	6	SLSA Go releaser  Compile your Go project using a SLSA3 compliant builder
More workflows
Footer

© 2026 GitHub, Inc.
Footer navigation
* Terms
* Privacy
