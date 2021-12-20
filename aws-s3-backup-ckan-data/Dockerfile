# Pulled Dec 20, 2021
FROM python:3.8@sha256:881e0df149c29af8b29a973a9e80814dae6cddf123fe38a0bcac71864c85fb8a
RUN curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&\
    unzip -q awscliv2.zip &&\
    ./aws/install &&\
    aws --version
WORKDIR /srv
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY entrypoint.py ./
ENTRYPOINT ["/usr/local/bin/python", "/srv/entrypoint.py"]
