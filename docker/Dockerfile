FROM alpine:3.7

WORKDIR /home

ENV OPENSSH_VERSION 7.5_p1-r8
ENV PYTHON_VERSION 2.7.14-r2
ENV TINI_VERSION 0.16.1-r0
ENV CURL_VERSION 7.60.0-r1

RUN true && \
    echo "installing dependencys..." && \
    apk --update \
        add \
            curl=${CURL_VERSION} \
            openssh=${OPENSSH_VERSION} \
            python=${PYTHON_VERSION} \
            tini=${TINI_VERSION} \
    && \
    echo "installing aws cli" && \
    wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip && \
    unzip awscli-bundle.zip && \
    rm awscli-bundle.zip && \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    rm -R awscli-bundle && \
    /usr/local/bin/aws --version && \
    \
    echo "creating ops user..." && \ 
    adduser -D -s /bin/sh ops && \
    passwd ops -d '*' && \
    mkdir -p /home/ops/.ssh/ && \
    chown -R ops /home/ops/.ssh/

ADD entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "/bin/sh", "/usr/local/bin/entrypoint.sh" ]
