FROM alpine:3.8

WORKDIR /home

RUN echo "installing dependencys..." && \
    apk --update \
        add \
            curl \
            openssh \
            python \
            tini \
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
