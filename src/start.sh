#!/bin/bash

_terminate() {
  $LC_HOME/bin/reportek_converters stop
  kill -TERM $child 2>/dev/null
}

trap _terminate SIGTERM SIGINT

LAST_CFG=`bin/develop rb -n`
echo $LAST_CFG

# Avoid running buildout on docker start
if [[ "$LAST_CFG" == *base.cfg ]]; then
  if ! test -e $LC_HOME/buildout.cfg; then
      python /configure.py
  fi

  if test -e $LC_HOME/buildout.cfg; then
      $LC_HOME/bin/buildout -c $LC_HOME/buildout.cfg
  fi
fi

chown -R 500:500 $LC_HOME/var $LC_HOME/parts

$LC_HOME/bin/reportek_converters start

child=$!
wait "$child"
