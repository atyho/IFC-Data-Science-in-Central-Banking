FROM docker.io/bitnami/spark:latest

USER root
RUN pip install pyspark jupyterlab && \
    mkdir -p /usr/local/src/app

WORKDIR /usr/local/src/app/program
ENTRYPOINT [ "spark-submit", "--verbose", "--master", "local[*]", "--driver-memory", "4G", "distance.py"]