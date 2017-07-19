#!/bin/bash
# Author: Olimpiu Rob olimpiu.rob@gmail.com

RETVAL=0
if [ -z "$$PYTHON" ]; then
  PYTHON="/usr/bin/env python2.7"
fi

PREFIX=${parts.buildout.directory}

PID_CONVERTERS=$( cat "$$PREFIX/var/converters.pid" 2>/dev/null )

pid_exists() {
    ps -p $1  &>/dev/null
}

start_all() {
    if pid_exists $$PID_CONVERTERS; then
        echo "Converters not started"
    else
        $$PREFIX/bin/gunicorn -b ${parts.gunicorn['address']}:${parts.gunicorn['port']} ${parts.gunicorn['app_module']} --timeout 300 -p $$PREFIX/var/converters.pid --chdir=${parts.buildout.directory}/src/reportek.converters/Products/reportek.converters/
        echo "Converters started"
    fi
}

stop_all() {
    if pid_exists $$PID_CONVERTERS; then
        kill -s TERM $$PID_CONVERTERS
        echo "Converters stopped"
    else
        echo "Converters not stopped"
    fi
}

status_all() {
    if pid_exists $$PID_CONVERTERS; then
        echo "Converters seem to be running pid=$$PID_CONVERTERS"
    else
        echo "Converters not running"
    fi
}

case "$$1" in
  start)
        start_all
        ;;
  stop)
        stop_all
        ;;
  status)
        status_all
        ;;
  restart)
        stop_all
        start_all
        ;;
  *)
        echo "Usage: $$0 {start|stop|status|restart}"
        RETVAL=1
esac
exit $$RETVAL
