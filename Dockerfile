FROM maven:3.10.0-eclipse-temurin-8-noble

RUN apt-get update && apt-get install -y jq && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

USER ubuntu

RUN cd /home/ubuntu
RUN git clone https://github.com/UT-SE-Research/iDFlakies.git
RUN cd iDFlakies
RUN mvn clean install -U

RUN cd /home/ubuntu
RUN git clone https://github.com/TestingResearchIllinois/NonDex.git
RUN cd NonDex
RUN mvn clean install -U

RUN cd /home/ubuntu
RUN git clone https://github.com/UT-SE-Research/FlakeSync.git
RUN cd FlakeSync
RUN mvn clean install -U

RUN cd /home/ubuntu
RUN rm -rf iDFlakies NonDex FlakeSync

ENTRYPOINT /usr/bin/entrypoint.sh