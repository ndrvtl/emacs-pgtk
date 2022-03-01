#!/usr/bin/env sh
docker build -t ndrvtl/emacs-pgtk .
container=$(docker create ndrvtl/emacs-pgtk)
docker cp $container:/opt/packages .
