# emacs-pgtk - Building Emacs 30 Debian package with pure GTK support

## Purpose

Pure GTK Emacs runs better on Wayland.
This project builds an *Emacs* package from the latest git emacs-30 branch with support to *pure GTK* and native compilation, for *Bookworm* systems.

## Caveats

* The resulting package isn't *lintian* clean, it doesn't have a man page and a changelog, I put a copyright file but I briskly assumed all files under *GPL 3.0* — the proper *Debian Emacs* package is more thorough —, also it lacks a proper cryptographic signature, anywho as it's not supposed to be officially distributed it's good enough for my purpose.
* The native compilation is done at build time: `make NATIVE_FULL_AOT=1`
* It's assumed the presence of an apt cache on the *LAN*, but it should be transparently bypassed it if not available: `apt-get install --yes --no-install-recommends auto-apt-proxy`


## Prerequisites

- git
- make
- docker


## Build on Premise

Type `make` will fetch latest commit and build it for your host Debian version.

```shell
$ git clone https://github.com/ndrvtl/emacs-pgtk
$ cd emacs-pgtk
$ make
```


## Build using GitHub Actions

Manually launching the workflow using the *actions* menu or pushing a change on the repository.


## Acknowledgments

Big thanks to Étienne Bersac (https://github.com/bersace) who has basically rewritten all the build infrastructure.


