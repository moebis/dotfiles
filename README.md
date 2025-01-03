# dotfiles
zsh configuration files for macOS 

## New Setup Steps

### Homebrew

> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /Users/moebis/.zprofile
> echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >› /Users/moebis/.zprofile
> eval "$(/opt/homebrew/bin/brew shellenv)"

### Oh-My-Zsh

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
or
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
brew install yazi ffmpeg 7-Zip jq poppler fd rg fzf zoxide ImageMagick bat eza dotfiles
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

