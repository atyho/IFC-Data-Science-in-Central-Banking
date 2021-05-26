sudo apt install default-jdk scala git

http://spark.apache.org/downloads.html

mkdir spark_source
cd spark_source
wget http://apache.mirror.vexxhost.com/spark/spark-3.0.0/spark-3.0.0-bin-hadoop3.2.tgz

tar -xvf spark-3.0.0-bin-hadoop3.2.tgz

mv spark-3.0.0-bin-hadoop3.2 /opt/spark

nano /etc/profile
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYSPARK_PYTHON=/usr/bin/python3

http://54.147.239.191:8080/

start-master.sh
start-slave.sh spark://ip-172-31-70-46.ec2.internal:7077

# Test Spark Shell
spark-shell
pyspark

# To start a master server
start-master.sh

# To stop the master
stop-master.sh

# Start both master and server
start-all.sh

# Stop all instances
stop-all.sh
