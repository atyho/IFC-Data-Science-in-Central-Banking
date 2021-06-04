# Apache PySpark Usage

Apache PySpark is an interface for Apache Spark in Python. It allows you to write Spark applications using Python APIs and provides the PySpark shell for interactive data analysis in a distributed environment. PySpark supports most of Spark’s features such as Spark SQL, DataFrame, Streaming, MLlib (Machine Learning) and Spark Core. For details, see the [Apahe PySpark documentation](https://spark.apache.org/docs/latest/api/python/).

This guide contains the procedures needed to install **Spark 3.1.2** (latest release as of June 1, 2021) on [Ubuntu Linux](#Linux-Environment), [Windows 10](#Windows-10-Environment), and [how to execute Spark programs](#Running-Spark-Programs). Additional information is available in the [references](#Reference). PySpark requires **Java 8 or later**, as well as **Python 3.6 or above**. This guide assumes a compatible version of python is already installed. 

# Linux Environment

### Install Java

For Spark to run, install Java by 
```bash
sudo apt install default-jdk
```

### Optional: Install PySpark with PyPi

For Spark to run in Python, install the [pyspark](https://pypi.org/project/pyspark/) package
```python
pip install pyspark
```

*Note that the pyspark package will also install a version of Spark that works with Python.* By default, it is a single node in a standalone configuration. That will be sufficient for running Spark on a single machine, see more in [launching applications in batch mode](#Launching-Applications-in-Batch-Mode). To use Spark with Scala or R, or install Spark on an existing cluster, download and [install the full version of Spark](#Install-Full-Version-of-Apache-Spark).

### Install Full Version of Apache Spark

Download Apache Spark from their [website](http://spark.apache.org/downloads.html). Choose Spark release 3.1.2 and pick the package pre-built for Apache Hadoop 3.2 and later. Apache Hadoop is a framework that allows for the distributed processing of large data sets across clusters of computers.

Create a new directory named spark_source by 
```bash
mkdir spark_source
```
Enter the new directory 
```bash
cd spark_source
```
Place the downloaded Spark installation tgz file there. Alternatively, you can get Apache Spark 3.1.2 (latest version at the time of this instruction) by
```bash
wget https://www.apache.org/dyn/closer.lua/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz
```
Decompress the file 
```bash
tar -xvf spark-3.1.2-bin-hadoop3.2.tgz
```
Move the decompressed files to ``\opt``
```bash
sudo mv spark-3.1.2-bin-hadoop3.2 /opt/spark
```

Add the following paths to your system's user profile in ``/etc/profile``:
```bash
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYSPARK_PYTHON=/usr/bin/python3
```

# Windows 10 Environment

### Install Java

Download and install Java from Oracle's [Java website](https://www.java.com/en/download/).

### Install Apache Spark

The steps are similar to those for a Linux environment. Therefore the procedures are only briefly described in this section. For details, see the section on [installing full version of Apache Spark](#Install-Full-Version-of-Apache-Spark).

Download Apache Spark from their [website](http://spark.apache.org/downloads.html). Choose the latest Spark release 3.1.2 (as of June 1, 2021) and pick a package type pre-built for Apache Hadoop 3.2 and later (as of June 1, 2021). Extract the files from the downloaded tgz file in any directory of your choice (here we refer to it as ``SPARK_HOME``) using [7-Zip](https://www.7-zip.org/) or other compatible tools.

### Install winutils

[winutils](https://github.com/cdarlint/winutils) are sets of Windows binaries for Apache Hadoop. To setup a Hadoop cluster for Spark, we need to install winutils and configure the Spark installation to find winutils.

To install winutils, download [winutils for hadoop 3.2.1](https://github.com/cdarlint/winutils/tree/master/hadoop-3.2.1). Note that winutils are different for each Hadoop version, with hadoop 3.2.1 being the latest release. Create a folder called ``hadoop`` inside the ``SPARK_HOME`` directory, then copy the ``bin`` folder to the ``hadoop`` folder in the ``SPARK_HOME`` directory.

### Configure Windows Environment Variables and Paths

Add new environment variables through the [Windows PowerShell](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/hh831491(v=ws.11)#start-windows-powershell).

Create the following system environment variables
```powershell
SETX SPARK_HOME "[path to SPARK_HOME directory]"
SETX HADOOP_HOME %SPARK_HOME%\hadoop
SETX JAVA_HOME "[path to Java directory]"
```
Replace ``[path to SPARK_HOME directory]`` and ``[path to Java directory]`` by the actual path to your Spark and Java directory, respectively. You can find the path to your Java directory by ``where java``.

Add the following paths to Path environment variable
```powershell
SETX Path %SPARK_HOME%\bin
SETX Path %HADOOP_HOME%\bin
```

# Running Spark Programs

There are two ways to run a program in Spark. Namely, one can use a notebook to conduct [interactive analysis with Spark](#Interactive-Analysis-with-Spark) or execute a spark program with Python API in [batch mode](#Launching-Applications-in-Batch-Mode). Users can also use Spark's web user interfaces (Web UI) to [monitor the status](#Monitoring-through-Spark-Web-UI) of the Spark cluster.

### Interactive Analysis with Spark

For interactive analysis in Spark, install the [findspark](https://pypi.org/project/findspark/) package by executing ``pip install findspark``. In your notebook, import and initialize the ``findspark`` library before importing ``pyspark``:
```python
import findspark
findspark.init()
import pyspark
```

You can either use a notebook or a command line interface. In the former case, simply open your notebook in Jupyter. In the latter case, simply launch a Spark shell by executing ``pyspark`` in your terminal.

### Launching Applications in Batch Mode

You can use the ``spark-submit`` command to launch a spark program in batch mode. For example, to run ``example.py`` in command interface, execute 
```bash
spark-submit example.py
```
By default, Spark will start in *client* mode, where Spark is launched as a client to the Hadoop cluster. The input and output of the application is attached to the console. 

Alternatively, if the machines executing your application is different from the machine that executes ``spark-submit``, [cluster mode](https://spark.apache.org/docs/latest/cluster-overview.html) can be used (optional) to minimize network latency between the drivers and the executors. *As of Spark 3.1.2, Spark standalone cluster does not support cluster mode for Python applications.*

For more information, see [submitting applications](https://spark.apache.org/docs/latest/submitting-applications.html) in Spark.

### Monitoring through Spark Web UI

To monitor the status and resources consumption on your Spark cluster, open a web browser and navigate to http://localhost:4040/. You can replace localhost with the name of your system.

You should see an Apache Spark shell Web UI, where you can find information on job details, current job stages, state of executors, etc. See Spark [documentation on Web UI](https://spark.apache.org/docs/latest/web-ui.html) for more details.

# Reference

- Spark Documentation - [Quick Start](https://spark.apache.org/docs/latest/quick-start.html)
  
- Spark Documentation - [Cluster Mode Overview](https://spark.apache.org/docs/latest/cluster-overview.html)

- Spark API Docs - [PySpark Documentation](https://spark.apache.org/docs/latest/api/python/index.html)

<!--- 
https://www.shubhamdipt.com/blog/how-to-setup-hadoop-in-aws-ec2-instances/
https://www.linode.com/docs/guides/how-to-install-and-set-up-hadoop-cluster/
https://jupyterhub-on-hadoop.readthedocs.io/en/latest/index.html 
--->