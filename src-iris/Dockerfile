ARG IRIS_IMAGE=containers.intersystems.com/intersystems/irishealth-community
ARG IRIS_TAG=2024.1
FROM ${IRIS_IMAGE}:${IRIS_TAG}

COPY --chown="${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP}" . /opt/irisbuild
RUN pip install --no-warn-script-location -r /opt/irisbuild/requirements_iris.txt

RUN iris start IRIS \
    && iris session IRIS < /opt/irisbuild/iris.script \
    && iris stop IRIS quietly

ARG IRIS_PASSWORD
RUN echo "$IRIS_PASSWORD" > /tmp/password.txt && \
    /usr/irissys/dev/Container/changePassword.sh /tmp/password.txt && \
    rm /tmp/password.txt
    
RUN rm -r /opt/irisbuild/*
