#!/usr/bin/env bash
# See http://kvz.io/blog/2013/11/21/bash-best-practices/
set -o errexit
set -o pipefail
set -o nounset
set -o allexport
# set -o xtrace


# Some colors, per http://stackoverflow.com/a/5947802/223225
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color


#
# Prepare the container
#

printf "${GREEN}Configuring Solr...${NC}\n"

# If the Docker volume doesn’t already have a Solr core, copy in the empty default OTMM one
if [ ! -d /opt/solr-index/otmmcore ] && [ -d /opt/default-otmmcore/solr-index/otmmcore ]; then
	printf "${GREEN}Adding default empty OpenText Media Management core...${NC}\n"
	cp --preserve=mode,ownership,timestamps --recursive /opt/default-otmmcore/solr-index/otmmcore /opt/solr-index/
fi


# If a lockfile exists (and therefore Solr did not stop gracefully) delete it so that Solr can start
if [ -f /opt/solr-index/otmmcore/data/index/write.lock ]; then
	rm /opt/solr-index/otmmcore/data/index/write.lock
fi
