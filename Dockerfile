FROM bitnami/spark:latest

USER root
# Install python requirements
RUN pip install pyspark
ADD . /usr/local/src/
WORKDIR /usr/local/src/program
ENTRYPOINT ["spark-submit", "distance.py"]