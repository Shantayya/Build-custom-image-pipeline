FROM alpine/helm
RUN curl -LO https://dl.k8s.io/release/v1.25.0/bin/linux/amd64/kubectl \
    && mv kubectl /bin/kubectl \
    && chmod a+x /bin/kubectl