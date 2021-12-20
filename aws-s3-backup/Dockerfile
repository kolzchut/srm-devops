# Pulled Dec 20, 2021
FROM amazon/aws-cli@sha256:d123012561ce8a323782d891d79ef81791f49f964692e42b4e00e89d2c5669a3
RUN yum install -y gzip tar
WORKDIR /srv
COPY entrypoint.sh ./
ENTRYPOINT ["/srv/entrypoint.sh"]
