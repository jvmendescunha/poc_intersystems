ARG iris_image
ARG iris_tag
 
FROM ${iris_image}:${iris_tag}
 
USER root
 
RUN mkdir -p /usr/local/irisbuild && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/local/irisbuild
USER ${ISC_PACKAGE_MGRUSER}
 
COPY --chown="${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP}" ./src-iris /usr/local/irisbuild
 
RUN pip install --no-warn-script-location --break-system-packages -r /usr/local/irisbuild/requirements_iris.txt
 
RUN iris start IRIS \
     && iris session IRIS < /usr/local/irisbuild/iris.script \
     && iris stop IRIS quietly

RUN --mount=type=secret,id=iris_pw,mode=0444 /usr/irissys/dev/Container/changePassword.sh /run/secrets/iris_pw
 
RUN rm -r /usr/local/irisbuild/*
