# Linux environment

### Prerequise
For Spark to run, install Java Development Kit by 
``sudo apt install default-jdk``

### Optional: Install PySpark with PyPi
For Spark to run in Python, install the PySpark package by ``pip install pyspark``.

### Install Apache Spark
Download Apache Spark from their [website](http://spark.apache.org/downloads.html). Note that Spark is set up to work on computer clusters, so we have to choose a software framework for the cluster. Pick the package type ``Pre-built for Apache Hadoop 3.2 and later``. Later on, when we launch Spark, resources on our Hadoop cluster is managed by Spark's [standalone cluster manager](https://spark.apache.org/docs/latest/spark-standalone.html) (by default), which is the simplest way to run Spark application in a clustered environment.

Create a new directory named spark_source by typing ``mkdir spark_source``. Enter the new directory by typing ``cd spark_source`` and place the downloaded Spark installation tgz file there. Alternatively, type ``wget https://www.apache.org/dyn/closer.lua/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz`` to get Apache Spark 3.1.1 (latest version atthe time of this instruction).

Decompress the file by ``tar -xvf spark-3.1.1-bin-hadoop3.2.tgz``. Move the decompressed files to ``\opt`` by typing ``mv spark-3.1.1-bin-hadoop3.2 /opt/spark``.

Edit the configuration of your system using nano by typing ``nano /etc/profile``. Add the following paths:
```
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYSPARK_PYTHON=/usr/bin/python3
```

### Launch Spark

To start a standalone master server maunally, type ``start-master.sh``. Once started, the master will print out a ``spark://HOST:PORT`` URL for itself, which you can use to connect workers to it, or pass as the "master" argument to SparkContext. You can also find this URL on the master’s web UI, which is http://localhost:8080 by default.

Similarly, you can start a worker and connect to the master by ``start-worker.sh <master-spark-URL>``, replace ``<master-spark-URL>`` by the URL printed out when you launch the master. Once you have started a worker, you should see the new node listed at the master’s web UI (http://localhost:8080 by default) along with its number of CPUs and memory (minus one gigabyte left for the OS).

Alternatively, start both the master and workers by ``start-all.sh``. This launch scripts defaults to a single machine (localhost). See Spark 3.1.1 [cluster launch scripts](https://spark.apache.org/docs/3.1.1/spark-standalone.html#cluster-launch-scripts) for details on advanced Spark configurations.

To launch Spark in Python, type ``pyspark``. To launch Spark in interactive model, edit the configuration of your system by typing ``nano /etc/profile``, and then add the following paths:
```
export PYSPARK_DRIVER_PYTHON="jupyter"
export PYSPARK_DRIVER_PYTHON_OPTS="lab"
```

After your work is done, stop all instances by typing ``stop-all.sh``.

# Reference 
Spark 3.1.1 Documentation - [Quick Start](https://spark.apache.org/docs/latest/quick-start.html)
  
[Spark 3.1.1 Spark Standalone Mode](https://spark.apache.org/docs/3.1.1/spark-standalone.html)
