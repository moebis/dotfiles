# dotfiles
zsh configuration files for macOS 

## New Setup Steps

Video Tutorial: https://www.youtube.com/watch?v=y6XCebnB9gs&t=284s

### Homebrew

> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
 Run these commands in your terminal to add Homebrew to your PATH:
```    echo >> /Users/moebis/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/moebis/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Oh-My-Zsh

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
or FOR INFO ONLY DO NOT USE
```brew install zsh-autosuggestions zsh-syntax-highlighting```

> edit .zshrc

add:
```
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)
```
add:
```
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
```

### Oh-My-Posh

```brew install oh-my-posh```

### Install Misc. Packages:

```
brew install yazi ffmpeg 7-Zip jq poppler fd rg fzf zoxide ImageMagick bat eza stow btop fastfetch
```
### stow command
```
nano ~/.stow-global-ignore
```
add to ignore:
```
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
```
create dotfiles and .gitignore
```
mkdir ~/dotfiles
cd ~/dotfiles
echo .DS_Store >> .gitignore
stow .
```

### git .zshrc initial commit and author settings
```
git init .
git add .zshrc
git commit -m "Initial commit"
git commit --amend --author="moebis <carl@moebis>" --no-edit
git config --global --edit
git config --global user.name "moebis"
git config --global user.email carl@moebis.com
git commit --amend --reset-author
git config --list
```

### git .config commit
```
git add .config/
git commit -m "added .config"
```

check diff
```git diff .```

revert changes
```git checkout .zshrc```

git status
```
git status
```

roll back changes
```
git restore .
```

DS_Stores:
```
git add .gitignore
git commit -m '.DS_Store banished!'
```
Initial git sync:
```
git remote add origin git@github.com:moebis/dotfiles.git
git push origin main
```

Remove an origin:
```
git remote rm origin
```

GIT Key Creation:

1. Generate SSH key using ssh-keygen -t rsa -b 4096 -C "your email".
2. Copy the output of cat ~/.ssh/id_rsa.pub to your clipboard
3. Paste the above-copied output to the form at https://github.com/settings/ssh/new
4. Then go ahead to retry the operation that generated the initial fatal error.


To Pull Down Git Initially
```
git clone git@github.com:moebis/dotfiles.git
```

To Pull Down Changes
```
git pull
```
To Add Changes:
```
git commit -a
git push origin main
```

