FROM intersystemsdc/irishealth-community:2021.1

COPY --chown=irisowner:iris /opt/irisbuild /opt/irisbuild

RUN /usr/irissys/dev/python/bin/python3 -m pip install --no-warn-script-location -r /opt/irisbuild/requirements_iris.txt

RUN iris start IRIS \
    && iris session IRIS < /opt/irisbuild/iris.script \
    && iris stop IRIS quietly

RUN --mount=type=secret,id=iris_pw,mode=0444 /usr/irissys/dev/Container/changePassword.sh /run/secrets/iris_pw

RUN rm -r /opt/irisbuild/*
