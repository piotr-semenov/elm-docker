FROM node:alpine as builder

RUN npm install --only=production --unsafe-perm=true --allow-root\
                -g elm@latest &&\
    npm cache clean --force

RUN apk add rsync &&\
    mkdir /target &&\
    export DEPS=$(which env node busybox |\
           xargs -n1 ldd |\
           awk '/statically/{next;} /=>/ { print $3; next; } { print $1 }' |\
           sort | uniq) &&\
    rsync -R --links /bin/busybox\
                     /usr/bin/env\
                     /usr/local/bin/node\
                     $DEPS\
                     $(echo $DEPS | xargs -n1 readlink -f)\
                     /usr/local/bin/elm*\
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
