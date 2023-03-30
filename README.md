# emacs-pgtk - Building Emacs Debian package with pure GTK support using Docker

#### Purpose
* This script will build an *Emacs* package from the latest git main branch with support to pure *GTK* — this is desired when running *Wayland* — and native compilation, using a *Debian's "Bullseye"* environment.

#### Caveats:
* The resulting package isn't *lintian* clean, it doesn't have a man page and a changelog, I put a copyright file but I briskly assumed all files under *GPL 3.0* — the proper *Debian Emacs* package is more thorough —, also it lacks a proper cryptographic signature, anywho as it's not supposed to be officially distributed it's good enough for my purpose
* The native compilation is done at build time: `make NATIVE_FULL_AOT=1`
* It's assumed the presence of an apt cache on the *LAN*, but it should be transparently bypassed it if not available: `apt-get install --yes --no-install-recommends auto-apt-proxy`

#### Instruction
How to build the package:
* On premise  
*Docker* is a prerequisite:
```shell
$ git clone https://github.com/ndrvtl/emacs-pgtk
$ cd emacs-pgtk
$ make
```

* On *GitHub* with *"GitHub Actions"*  
Manually launching the workflow using the *"actions"* menu or pushing a change on the repository


