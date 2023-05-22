FROM docker.io/bitnami/spark:latest

USER root
RUN pip3 install pyspark && \
    mkdir -p /usr/local/src/app

# If more packages are needed
# COPY requirements.txt /tmp/pip-tmp/
# RUN pip3 install -r /tmp/pip-tmp/requirements.txt && \
#     rm -rf /tmp/pip-tmp

WORKDIR /usr/local/src/app/program
ENTRYPOINT ["spark-submit", "--verbose", "--master", "local[*]", "--driver-memory", "1G", "distance.py"]