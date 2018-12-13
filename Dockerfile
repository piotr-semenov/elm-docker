FROM node:alpine as builder
LABEL stage=intermediate

ARG elmpackages="elm"

SHELL ["ash", "-o", "pipefail", "-c"]
RUN echo $elmpackages |\
    xargs -n1 echo |\
    xargs -n1 -I{} npm install --only=production --unsafe-perm=true --allow-root -g {}@latest &&\
    npm cache clean --force

# hadolint ignore=SC2086,SC2046
RUN apk add --no-cache rsync &&\
    mkdir /target &&\
    DEPS=$(which env node busybox ash sh |\
           xargs -n1 ldd |\
           awk '/statically/{next;} /=>/ { print $3; next; } { print $1 }' |\
           sort | uniq) &&\
    rsync -R --links /bin/busybox\
                     /bin/ash /bin/sh\
                     /usr/bin/env\
                     /usr/local/bin/node\
                     $DEPS\
                     $(echo $DEPS | xargs -n1 readlink -f)\
                     /usr/local/bin/elm*\
                     /target &&\
    rsync -Rr --links /etc/ssl\
             /usr/local/lib/node_modules/elm*\
             /target &&\
    apk del rsync


FROM scratch

ARG vcsref
LABEL \
    stage=final \
    org.label-schema.name="tiny-elm" \
    org.label-schema.description="Ultra-slim dockerized Elm compiler and tools." \
    org.label-schema.url="https://hub.docker.com/r/semenovp/tiny-elm/" \
    org.label-schema.vcs-ref="$vcsref" \
    org.label-schema.vcs-url="https://github.com/piotr-semenov/elm-docker.git" \
    maintainer='Piotr Semenov <piotr.k.semenov@gmail.com>'

ENV PATH=/bin:/usr/bin:/usr/local/bin
COPY --from=builder /target /

ENTRYPOINT ["elm"]
