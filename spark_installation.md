# Linux environment

### Prerequise

For Spark to run, install Java by 
``sudo apt install default-jdk``

### Optional: Install PySpark with PyPi

For Spark to run in Python, install the [pyspark](https://pypi.org/project/pyspark/) package by ``pip install pyspark``.

*Note that the pyspark package will also install a version of Spark that works with Python.* By default, it is a single node in a standalone configuration. That will be sufficient for running Spark on a local machine or for testing purpose. To use Spark with Scala or R, or install Spark on an existing cluster, download and [install the full version of Spark](#Install-Full-Version-of-Apache-Spark).

### Install Full Version of Apache Spark

Download Apache Spark from their [website](http://spark.apache.org/downloads.html). Pick the package type ``Pre-built for Apache Hadoop 3.2 and later``. Apache Hadoop is a framework that allows for the distributed processing of large data sets across clusters of computers. Later on, when we launch Spark, resources on our Hadoop cluster is managed by Spark's [standalone cluster manager](https://spark.apache.org/docs/latest/spark-standalone.html) (by default), which is the simplest way to run Spark application in a clustered environment.

Create a new directory named spark_source by typing ``mkdir spark_source``. Enter the new directory by typing ``cd spark_source`` and place the downloaded Spark installation tgz file there. Alternatively, type ``wget https://www.apache.org/dyn/closer.lua/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz`` to get Apache Spark 3.1.1 (latest version atthe time of this instruction).

Decompress the file by ``tar -xvf spark-3.1.1-bin-hadoop3.2.tgz``. Move the decompressed files to ``\opt`` by typing ``mv spark-3.1.1-bin-hadoop3.2 /opt/spark``.

Add the following paths to your system's user profile in ``/etc/profile``:
```
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYSPARK_PYTHON=/usr/bin/python3
```

### Interactive Analysis with the Spark Shell

For command line interface, simply type ``pyspark`` in your terminal.

To run Spark on Jupyter Lab, install the [findspark](https://pypi.org/project/findspark/) package by typing ``pip install findspark``. Include the following script before in your Jupyter notebook before ``import pyspark``
```
import findspark
findspark.init()

import pyspark
```

### Starting a Spark Cluster Manually

To start a standalone master server maunally, type ``start-master.sh``. Once started, the master will print out a ``spark://HOST:PORT`` URL for itself, which you can use to connect workers to it, or pass as the "master" argument to SparkContext. You can also find this URL on the master’s web UI, which is http://localhost:8080 by default.

Similarly, you can start a worker and connect to the master by ``start-worker.sh <master-spark-URL>``, replace ``<master-spark-URL>`` by the URL printed out when you launch the master. Once you have started a worker, you should see the new node listed at the master’s web UI (http://localhost:8080 by default) along with its number of CPUs and memory (minus one gigabyte left for the OS).

Alternatively, start both the master and workers by ``start-all.sh``. This launch scripts defaults to a single machine (localhost). See Spark 3.1.1 [cluster launch scripts](https://spark.apache.org/docs/3.1.1/spark-standalone.html#cluster-launch-scripts) for details on advanced Spark configurations.

To stop all Spark instances, exit Spark enter ``stop-all.sh``.

# Windows environment
To be added

Reference
---
Spark 3.1.1 Documentation - [Quick Start](https://spark.apache.org/docs/latest/quick-start.html)
  
[Spark 3.1.1 Spark Standalone Mode](https://spark.apache.org/docs/3.1.1/spark-standalone.html)
