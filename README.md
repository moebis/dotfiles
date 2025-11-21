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
### Oh-my-posh and Catputcin Theme

.config/ohmyposh/default.toml <--- create and add:

console_title_template = '{{ .Shell }} in {{ .Folder }}'
version = 3
final_space = true

[palette]
  black = '#262B44'
  blue = '#4B95E9'
  green = '#59C9A5'
  orange = '#F07623'
  red = '#D81E5B'
  white = '#E0DEF4'
  yellow = '#F3AE35'

[secondary_prompt]
  template = '<p:yellow,transparent></><,p:yellow> > </><p:yellow,transparent></> '
  foreground = 'p:black'
  background = 'transparent'

[transient_prompt]
  template = '<p:yellow,transparent></><,p:yellow> {{ .Folder }} </><p:yellow,transparent></> '
  foreground = 'p:black'
  background = 'transparent'

[upgrade]
  source = 'cdn'
  interval = '168h'
  auto = false
  notice = false

[[blocks]]
  type = 'prompt'
  alignment = 'left'

  [[blocks.segments]]
    leading_diamond = ''
    trailing_diamond = ''
    template = ' {{ if .SSHSession }} {{ end }}{{ .UserName }} '
    foreground = 'p:black'
    background = 'p:yellow'
    type = 'session'
    style = 'diamond'

  [[blocks.segments]]
    template = '  {{ path .Path .Location }} '
    foreground = 'p:white'
    powerline_symbol = ''
    background = 'p:orange'
    type = 'path'
    style = 'powerline'

    [blocks.segments.properties]
      style = 'folder'

  [[blocks.segments]]
    template = ' {{ if .UpstreamURL }}{{ url .UpstreamIcon .UpstreamURL }} {{ end }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }} '
    foreground = 'p:black'
    powerline_symbol = ''
    background = 'p:green'
    type = 'git'
    style = 'powerline'
    foreground_templates = ['{{ if or (.Working.Changed) (.Staging.Changed) }}p:black{{ end }}', '{{ if and (gt .Ahead 0) (gt .Behind 0) }}p:white{{ end }}', '{{ if gt .Ahead 0 }}p:white{{ end }}']
    background_templates = ['{{ if or (.Working.Changed) (.Staging.Changed) }}p:yellow{{ end }}', '{{ if and (gt .Ahead 0) (gt .Behind 0) }}p:red{{ end }}', '{{ if gt .Ahead 0 }}#49416D{{ end }}', '{{ if gt .Behind 0 }}#7A306C{{ end }}']

    [blocks.segments.properties]
      branch_max_length = 25
      fetch_status = true
      fetch_upstream_icon = true

  [[blocks.segments]]
    template = '  '
    foreground = 'p:white'
    powerline_symbol = ''
    background = 'p:yellow'
    type = 'root'
    style = 'powerline'

  [[blocks.segments]]
    leading_diamond = '<transparent,background></>'
    trailing_diamond = ''
    template = ' {{ if gt .Code 0 }}{{ else }}{{ end }} '
    foreground = 'p:white'
    background = 'p:blue'
    type = 'status'
    style = 'diamond'
    background_templates = ['{{ if gt .Code 0 }}p:red{{ end }}']

    [blocks.segments.properties]
      always_enabled = true

[[blocks]]
  type = 'rprompt'

  [[blocks.segments]]
    template = ' '
    foreground = 'p:green'
    background = 'transparent'
    type = 'node'
    style = 'plain'

    [blocks.segments.properties]
      display_mode = 'files'
      fetch_package_manager = false
      home_enabled = false

  [[blocks.segments]]
    template = ' '
    foreground = 'p:blue'
    background = 'transparent'
    type = 'go'
    style = 'plain'

    [blocks.segments.properties]
      fetch_version = false

  [[blocks.segments]]
    template = ' '
    foreground = 'p:yellow'
    background = 'transparent'
    type = 'python'
    style = 'plain'

    [blocks.segments.properties]
      display_mode = 'files'
      fetch_version = false
      fetch_virtual_env = false

  [[blocks.segments]]
    template = 'in <p:blue><b>{{ .Name }}</b></> '
    foreground = 'p:white'
    background = 'transparent'
    type = 'shell'
    style = 'plain'

  [[blocks.segments]]
    template = 'at <p:blue><b>{{ .CurrentDate | date "15:04:05" }}</b></>'
    foreground = 'p:white'
    background = 'transparent'
    type = 'time'
    style = 'plain'

[[tooltips]]
  leading_diamond = ''
  trailing_diamond = ''
  template = '  {{ .Profile }}{{ if .Region }}@{{ .Region }}{{ end }} '
  foreground = 'p:white'
  background = 'p:orange'
  type = 'aws'
  style = 'diamond'
  tips = ['aws']

  [tooltips.properties]
    display_default = true

[[tooltips]]
  leading_diamond = ''
  trailing_diamond = ''
  template = '  {{ .Name }} '
  foreground = 'p:white'
  background = 'p:blue'
  type = 'az'
  style = 'diamond'
  tips = ['az']

  [tooltips.properties]
    display_default = true
