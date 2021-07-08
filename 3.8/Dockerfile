FROM registry.centos.org/centos/centos:7

MAINTAINER Jean-Francois Chevrette <jfchevrette@gmail.com>

# Labels consumed by the build service
LABEL Component="mattermost" \
      Name="mattermost/mattermost-team-3.8.2-centos7" \
      Version="3.8.2" \
      Release="1"

# Openshift/Kubernetes labels
LABEL io.k8s.description="Mattermost is an open source, self-hosted Slack-alternative" \
      io.k8s.display-name="Mattermost 3.8.2" \
      io.openshift.expose-services="8065/tcp:mattermost" \
      io.openshift.non-scalable="true" \
      io.openshift.tags="mattermost,slack" \
      io.openshift.min-memory="128Mi"

RUN set -x && \
  yum -y install epel-release && \
  yum -y install python-dpath nc tar && \
  yum clean all

ENV MATTERMOST_VERSION 3.8.2

RUN set -x && \
  curl -sLO https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
  tar -xf mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz -C /opt && \
  rm -f mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \

  mkdir -p /opt/mattermost/data /opt/mattermost/logs && \

  chmod 777 /opt/mattermost/data /opt/mattermost/logs /opt/mattermost/config/config.json

COPY rootfs/ /
COPY docker-entrypoint.sh /

USER 1001

EXPOSE 8065

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["mattermost"]
