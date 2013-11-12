#!/bin/bash

set -e

PROJECT_VERSION=$1

printf 'deb.version='

case $PROJECT_VERSION in
	*-SNAPSHOT)
		printf ${PROJECT_VERSION%-SNAPSHOT}~$( date +"%Y%m%d.%H%M%S" )-$( git describe --tags --always --dirty )
		;;
	*)
		printf $PROJECT_VERSION
		;;
esac

printf '\n'

