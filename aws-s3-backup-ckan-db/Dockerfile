# Pulled Dec 20, 2021
FROM postgres:9.6@sha256:63f752ed01a989d0b20be000743b9425069e35277523120cee077bee79931048
RUN apt-get update && apt-get install -y curl unzip
RUN curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&\
    unzip -q awscliv2.zip &&\
    ./aws/install &&\
    aws --version
WORKDIR /srv
COPY entrypoint.sh ./
ENTRYPOINT ["/srv/entrypoint.sh"]
