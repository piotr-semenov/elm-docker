FROM node:alpine as builder

SHELL ["ash", "-o", "pipefail", "-c"]
RUN npm install --only=production --unsafe-perm=true --allow-root\
                -g elm@latest &&\
    npm cache clean --force

# hadolint ignore=SC2086,SC2046
RUN apk add --no-cache rsync &&\
    mkdir /target &&\
    DEPS=$(which env node busybox |\
           xargs -n1 ldd |\
           awk '/statically/{next;} /=>/ { print $3; next; } { print $1 }' |\
           sort | uniq) &&\
    rsync -R --links /bin/busybox\
                     /usr/bin/env\
                     /usr/local/bin/node\
                     $DEPS\
                     $(echo $DEPS | xargs -n1 readlink -f)\
                     /usr/local/bin/elm\
                     /target &&\
    rsync -Rr --links /etc/ssl\
             /usr/local/lib/node_modules/elm\
             /target &&\
    apk del rsync


FROM scratch

LABEL tag='elm:latest'\
      maintainer='Piotr Semenov <piotr.k.semenov@gmail.com>'

ENV PATH=/bin:/usr/bin:/usr/local/bin
COPY --from=builder /target /

ENTRYPOINT ["elm"]
