#!/bin/bash

OPT="i"

case "$1" in
  -h | --help | h | help)
    echo "Usage: `basename $0` [option]

options:
    -i, --install     install all of execuable file in jdk bin path and setup to use, this option is default
    -r, --remove      remove the alternatives"
    exit 0
  ;;
  *                     )
    OPT="$1"
  ;;
esac

if [ "$EUID" -ne 0 ]; then
  echo "Permission denied"
  exit 1
fi

__STRING=`sudo -Hiu $SUDO_USER env | grep JAVA_HOME`
__ARRAY=(${__STRING//=/ })
JAVA_HOME=${__ARRAY[1]}

if [ -z $JAVA_HOME ]; then
  echo "Please setup JAVA_HOME environment variable"
  exit 1
fi

f_install() {
    for __file in $JAVA_HOME/bin/*; do
      if [ -x $__file ]; then
        __BASENAME=`basename $__file`
        update-alternatives --install /usr/bin/$__BASENAME $__BASENAME $__file 500
        update-alternatives --set $__BASENAME $__file
      fi
    done
}

f_remove() {
    for __file in $JAVA_HOME/bin/*; do
      if [ -x $__file ]; then
        __BASENAME=`basename $__file`
        update-alternatives --remove $__BASENAME $__file
      fi
    done
}

case "$OPT" in
  r | -r | remove | --remove)
    f_remove
    ;;
  *     )
    f_install
    ;;
esac
