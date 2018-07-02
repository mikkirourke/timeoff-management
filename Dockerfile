FROM phusion/baseimage:0.9.22

#install required packages
ENV DEBIAN_FRONTEND noninteractive
RUN  sed -i 's/deb-src/#deb-src/g' /etc/apt/sources.list
RUN apt-get update && apt-get install -yq git xz-utils

#install nodejs
ENV NPM_CONFIG_LOGLEVEL=info
ENV NODE_VERSION=6.11.1

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

#install timeoff-application
WORKDIR /opt
RUN git clone https://github.com/timeoff-management/application.git timeoff-management 
WORKDIR /opt/timeoff-management
RUN npm install mysql && npm install
VOLUME /opt/timeoff-management/config
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY localisation.sh /localisation.sh
EXPOSE 3000

##Add restic client 
COPY restic/restic /usr/bin
COPY backup /usr/bin

##Add mysqlclient
RUN apt-get install -y mysql-client=5.7.22-0ubuntu0.16.04.1

##Add scripts to configure cron and to backup
COPY configure_cron /etc/my_init.d
RUN chmod +x /usr/bin/backup /etc/my_init.d/configure_cron

ENTRYPOINT [ "/sbin/my_init","--","/docker-entrypoint.sh"]
