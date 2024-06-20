# Installation:

Clone this repo into your home directory
```bash
git clone git@github.com:matthew-hagemann/dotfiles.git
git submodule update --init --recursive
```

Install GNU stow
```bash
sudo apt install stow
```

Move all these up a level as symlink's
```bash
stow .
```
