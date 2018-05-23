FROM library/alpine

MAINTAINER Andy Savage <andy@savage.hk>

LABEL org.label-schema.name="docker-gitwatch" \
      org.label-schema.description="Watch a directory and add any changes to a git repo" \
      org.label-schema.vcs-url="https://github.com/hongkongkiwi/docker-gitwatch" \
      org.label-schema.license="MIT"

ARG S6_VERSION="1.21.4.0"
ARG S6_ARCH="amd64"
ARG S6_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.gz"
ARG GITWATCH_URL="https://raw.githubusercontent.com/gitwatch/gitwatch/master/gitwatch.sh"
ARG PACKAGES="bash git ca-certificates inotify-tools gettext"

ENV CHANGE_WAIT_SECS=10 \
    DATE_FORMAT="+%Y-%m-%d %H:%M:%S" \
    REMOTE_REPO="" \
    REMOTE_BRANCH="" \
    GIT_COMMIT_MSG="Scripted auto-commit on change (%d) by gitwatch.sh" \
    DIR_TO_WATCH="/watchdir"

ENV GIT_NAME="Automatic Script" \
		GIT_EMAIL="auto@auto.com"

VOLUME ["/watchdir"]

RUN echo "Installing Packages" \
 && apk update \
 && apk add --no-cache \
      $PACKAGES \
 && mkdir -p "/root" "/tmp" "/usr/local/share" "/usr/local/bin"

ADD "$GITWATCH_URL" /usr/local/bin/gitwatch
ADD "$S6_URL" /tmp/
ADD /root/ /
ADD gitconfig.template "/usr/local/share/gitconfig.template"

RUN echo "Installing S6 Overlay" \
  && tar xzf "/tmp/s6-overlay-amd64.tar.gz" -C /

RUN echo "Cleaning Up" \
 && rm -rf /var/cache/apk/* \
 && rm -rf /tmp/*

ENTRYPOINT ["/init"]
