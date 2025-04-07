ARG IRIS_IMAGE=containers.intersystems.com/intersystems/irishealth-community
ARG IRIS_TAG=2024.1

FROM ${IRIS_IMAGE}:${IRIS_TAG}

ARG IRIS_PASSWORD
ARG MONGO_CREDENTIALS

COPY . /opt/irisbuild

# Instala a dependência do requirements
RUN pip install --no-warn-script-location -r /opt/irisbuild/requirements_iris.txt

# Substitui os placeholders nos arquivos de credenciais
RUN sed -i "s|##IRIS_PASSWORD##|${IRIS_PASSWORD}|" /opt/irisbuild/irispw.txt && \
    sed -i "s|##MONGO_CREDENTIALS##|${MONGO_CREDENTIALS}|" /opt/irisbuild/mongodb.user

# Executa o script para instalação/configuração
RUN iris start IRIS && \
    iris session IRIS < /opt/irisbuild/iris.script && \
    iris stop IRIS quietly

RUN rm -r /opt/irisbuild/*

