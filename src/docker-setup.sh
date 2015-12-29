#!/bin/bash

if ! test -e $LC_HOME/buildout.cfg; then
    python /configure.py
fi

if test -e $LC_HOME/buildout.cfg; then
    $LC_HOME/bin/buildout -c $LC_HOME/buildout.cfg
fi
