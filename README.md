# emacs-pgtk - Building an Emacs 31 Debian package with pure GTK support

## Purpose

Pure GTK Emacs runs better on Wayland.
This project builds an *Emacs Debian* package from the latest emacs-31 git branch, with support for *pure GTK* and native compilation, targeting *Trixie* and *Bookworm* systems.

## Caveats

* The resulting package isn't *lintian* clean: it doesn't have a man page and a changelog, I included a copyright file, but I assumed all files are under *GPL 3.0*, the official *Debian Emacs* package is more thorough, additionally, it lacks a proper cryptographic signature. Anywho, since it's not supposed to be officially distributed, it's good enough for my purpose.
* The native compilation is done at build time using: `make NATIVE_FULL_AOT=1`


## Prerequisites

- git
- make
- docker


## Build on Premise

Typing `make` will fetch the latest commit and build it for your host *Debian* version.

```shell
$ git clone https://github.com/ndrvtl/emacs-pgtk
$ cd emacs-pgtk
$ make
```

The Trixie build also produces `libtree-sitter0.26` and `libtree-sitter-dev` packages in `packages/treesitter/` (built from the sid source). Install the runtime package alongside Emacs, since the package depends on it and it's not available in Trixie.


## Build using GitHub Actions

Launching manually the workflow using the *actions* menu or pushing a change on the repository.


## Acknowledgments

Big thanks to Étienne Bersac (https://github.com/bersace) who has basically rewritten all the build infrastructure.
