# Definindo variáveis de build para imagem base e tag
ARG iris_image
ARG iris_tag

# Usando a imagem base fornecida pelas variáveis iris_image e iris_tag
FROM ${iris_image}:${iris_tag}

# Tornando-se root para criar o diretório
USER root

# Criando o diretório /usr/local/irisbuild (caso não exista) e garantindo permissões adequadas
RUN mkdir -p /usr/local/irisbuild && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/local/irisbuild

# Voltando para o usuário padrão
USER ${ISC_PACKAGE_MGRUSER}

# Copiando os arquivos da pasta src-iris para /usr/local/irisbuild
COPY --chown="${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP}" ./src-iris /usr/local/irisbuild

# Instalando pacotes Python necessários
RUN pip install --no-warn-script-location --break-system-packages -r /usr/local/irisbuild/requirements_iris.txt

# Iniciando o IRIS, executando um script e depois parando o IRIS
RUN iris start IRIS \
    && iris session IRIS < /usr/local/irisbuild/iris.script \
    && iris stop IRIS quietly

# Copiando o arquivo de senha irispw para o container
COPY ./src-iris/irispw.txt /run/secrets/iris_pw.txt  # Montando o arquivo de senha diretamente

# Garantindo permissões adequadas para o arquivo de senha
RUN chmod 600 /run/secrets/iris_pw.txt

# Executando o script de mudança de senha
RUN /usr/irissys/dev/Container/changePassword.sh /run/secrets/iris_pw.txt

# Limpando arquivos temporários
RUN rm -r /usr/local/irisbuild/*
