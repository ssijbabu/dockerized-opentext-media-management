# See https://hub.docker.com/_/solr/
FROM solr:5.3
MAINTAINER Geoffrey Booth <geoffrey.booth@disney.com>

USER root
ENV TERM xterm

RUN apt-get update \
	&& apt-get install --yes bsdtar \
	&& apt-get clean

# See https://knowledge.opentext.com/knowledge/piroot/medmgt/v160000/medmgt-igd/en/html/jsframe.htm?inst-solr-sep-srv-unix
# Add folder created via `ant create-solr-index` in step 3
# Save it to a test data folder so that we don’t overwrite an index which may already be in the Docker volume mounted on /opt/solr-index
ARG OBJECTS_ROOT_URL
RUN mkdir --parents /opt/solr-index/ /opt/default-otmmcore/solr-index/ /opt/opentext-media-management-installer/ \
	&& curl --location $OBJECTS_ROOT_URL/opentext-media-management-16.2/mediamgmt_16.2_linux.iso \
		| bsdtar --extract --preserve-permissions --file - --directory /opt/opentext-media-management-installer/ \
	&& unzip -j /opt/opentext-media-management-installer/OTMM/Disk1/InstData/Resource1.zip '$IA_PROJECT_DIR$/delivery/installservers.zip' -d /opt/opentext-media-management-installer/ \
	&& unzip -j /opt/opentext-media-management-installer/installservers.zip indexer/solr_otmm_531.zip -d /opt/opentext-media-management-installer/ \
	&& unzip /opt/opentext-media-management-installer/solr_otmm_531.zip -d /opt/opentext-media-management-installer/ \
	&& mv /opt/opentext-media-management-installer/solr5_otmm/otmmcore /opt/default-otmmcore/solr-index/ \
	&& rm -rf /opt/opentext-media-management-installer/

# Set the lock type, mimicking `ant edit-solr-config-unix` (see OTMM $TEAMS_HOME/install/ant/index.xml)
RUN sed --in-place 's/@@LockType@@/simple/' /opt/default-otmmcore/solr-index/otmmcore/conf/solrconfig.xml

# Copy config file that points to that index folder, via instructions step 6
COPY solr.xml /opt/solr/server/solr/solr.xml

# Forward log to Docker log collector, based on https://github.com/nginxinc/docker-nginx/blob/master/mainline/jessie/Dockerfile
RUN mkdir --parents /opt/solr/server/logs \
	&& ln --symbolic --force /dev/stdout /opt/solr/server/logs/solr.log

# Fix permissions
RUN if [ -f /opt/solr-index ]; then chown -R solr:solr /opt/solr-index/; fi
RUN if [ -f /opt/default-otmmcore/solr-index/ ]; then chown -R solr:solr /opt/default-otmmcore/solr-index/; fi
RUN chown -R solr:solr /opt/solr/server/solr/solr.xml

USER solr

COPY configure.sh /docker-entrypoint-initdb.d/configure.sh
