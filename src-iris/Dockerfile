ARG IRIS_IMAGE=containers.intersystems.com/intersystems/irishealth-community
ARG IRIS_TAG=2024.1

FROM ${IRIS_IMAGE}:${IRIS_TAG}

ARG IRIS_PASSWORD
ARG MONGO_CREDENTIALS
ARG MONGO_URI

ENV MONGO_URI=${MONGO_URI}

COPY --chown=irisowner:iris . /opt/irisbuild

RUN pip install --no-warn-script-location -r /opt/irisbuild/requirements_iris.txt

RUN sed -i "s|##IRIS_PASSWORD##|${IRIS_PASSWORD}|" /opt/irisbuild/irispw.txt && \
    sed -i "s|##MONGO_CREDENTIALS##|${MONGO_CREDENTIALS}|" /opt/irisbuild/mongodb.user && \
    echo "${MONGO_URI}" > /opt/irisbuild/mongodb.uri

RUN echo "Running iris.script..." && \
    iris start IRIS && \
    iris session IRIS -U %SYS "do ##class(%SYSTEM.OBJ).Load('/opt/irisbuild/iris.script','ck')" && \
    iris stop IRIS quietly

RUN rm -r /opt/irisbuild/*
