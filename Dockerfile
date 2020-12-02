FROM node:alpine as builder
LABEL stage=intermediate

ARG elmpackages="elm-analyse elm-test"

SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN apk update &&\
    apk --no-cache add curl &&\
    curl -sL https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz -o /tmp/elm.gz &&\
    gunzip /tmp/elm.gz &&\
    mv /tmp/elm /usr/local/bin/elm &&\
    chmod +x /usr/local/bin/elm &&\
    apk del curl

COPY ./dockerfile-commons/reduce_alpine.sh /tmp/reduce_alpine.sh

# hadolint ignore=SC2046
RUN chmod +x /tmp/reduce_alpine.sh &&\
    \
    # First off, reduce Alpine to already installed elm compiler.\
    /tmp/reduce_alpine.sh -v /target sh env busybox /usr/local/bin/elm\
                                     \
                                     /etc/ssl;\
    \
    # If it provides the list of elm tools then install as well.\
    if [ "$elmpackages" ]; then\
        echo $elmpackages |\
        xargs -n1 echo |\
        xargs -n1 -I{} npm install --only=production --unsafe-perm=true --allow-root -g {}@latest &&\
        npm cache clean --force &&\
        \
        /tmp/reduce_alpine.sh -v /target node $(echo $elmpackages | xargs -n1 -I@ echo /usr/local/bin/@)\
                                         \
                                         /usr/local/lib/node_modules/elm*;\
    fi


FROM scratch

ARG vcsref
LABEL \
    stage=final \
    org.label-schema.name="tiny-elm" \
    org.label-schema.description="Elm compiler and tools." \
    org.label-schema.url="https://hub.docker.com/r/semenovp/tiny-elm/" \
    org.label-schema.vcs-ref="$vcsref" \
    org.label-schema.vcs-url="https://github.com/piotr-semenov/elm-docker.git" \
    maintainer='Piotr Semenov <piotr.k.semenov@gmail.com>'

COPY --from=builder /target /

ENTRYPOINT ["elm"]
