ARG iris_image
ARG iris_tag
ARG IRIS_PASSWORD  # Recebendo o build-arg com a senha

FROM ${iris_image}:${iris_tag}

USER root

RUN mkdir -p /usr/local/irisbuild && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/local/irisbuild

USER ${ISC_PACKAGE_MGRUSER}

COPY --chown="${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP}" ./src-iris /usr/local/irisbuild

RUN pip install --no-warn-script-location --break-system-packages -r /usr/local/irisbuild/requirements_iris.txt

RUN iris start IRIS \
    && iris session IRIS < /usr/local/irisbuild/iris.script \
    && iris stop IRIS quietly

RUN echo "${IRIS_PASSWORD}" > /run/secrets/iris_pw  # Colocando o conteúdo do build-arg IRIS_PASSWORD no arquivo

RUN chmod 600 /run/secrets/iris_pw

RUN /usr/irissys/dev/Container/changePassword.sh /run/secrets/iris_pw

RUN rm -r /usr/local/irisbuild/*
