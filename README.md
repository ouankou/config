# vimrc
My bash and vim configuration.

# Guide
Put the SSH key in `.ssh` folder.
Append `bashrc` to the end of `.bashrc`. 

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

## Git Configuration

Import a key:

```bash
gpg2 --import FILENAME
```

List all secret keys:

```bash
gpg2 --list-secret-keys --keyid-format LONG
```

Edit key setting:

```bash
gpg2 --edit-key KEYCODE
```

#### Global

```bash
git config --global user.name ""
git config --global user.email ""
git config --global user.signingkey
git config --global commit.gpgsign true
git config --global gpg.program gpg2

```

#### Local

```bash
git config user.name ""
git config user.email ""
git config user.signingkey
```
