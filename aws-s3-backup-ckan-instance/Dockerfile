# Pulled Dec 21, 2021
FROM ubuntu@sha256:626ffe58f6e7566e00254b638eb7e0f3b11d4da9675088f4781a50ae288f3322
RUN apt-get update && apt-get install -y unzip wget
RUN wget https://dl.k8s.io/release/v1.19.14/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl &&\
    chmod +x /usr/local/bin/kubectl
RUN wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip" &&\
    unzip -q awscliv2.zip &&\
    ./aws/install &&\
    aws --version
WORKDIR /srv
COPY entrypoint.sh ./
ENTRYPOINT ["/srv/entrypoint.sh"]
