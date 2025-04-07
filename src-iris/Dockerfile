ARG iris_image
ARG iris_tag

FROM ${iris_image}:${iris_tag}

RUN mkdir -p /usr/local/irisbuild

COPY --chown="${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP}" ./src-iris /usr/local/irisbuild

RUN pip install --no-warn-script-location --break-system-packages -r /usr/local/irisbuild/requirements_iris.txt

RUN iris start IRIS \
    && iris session IRIS < /usr/local/irisbuild/iris.script \
    && iris stop IRIS quietly

COPY ./src-iris/irispw.txt /run/secrets/iris_pw  # Copiar o arquivo de senha para o local adequado

RUN chmod 600 /run/secrets/iris_pw

RUN /usr/irissys/dev/Container/changePassword.sh /run/secrets/iris_pw

RUN rm -r /usr/local/irisbuild/*
