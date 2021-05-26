from pyspark.sql import SQLContext, SparkSession, Row
from pyspark import *
from pyspark.sql.functions import *
from pyspark.sql.types import DateType

spark=SparkSession\
.builder\
.appName("Python Spark Dataframe")\
.config(conf = SparkConf())\
.getOrCreate()

sc = spark.sparkContext
sqlContext = SQLContext(sc)

########################
# Loading source files #
########################

# Load data on bank branch location from Payment Canada
#df_bank = spark.read.csv("[location of data file in csv format]", header=True)
#df_bank.createOrReplaceTempView("df_bank")

# Load data on 2017 Method of Payment Survey from the Bank of Canada
#df_MOP = spark.read.csv("[location of data file in csv format]", header=True)
#df_MOP.createOrReplaceTempView("df_MOP")

# Load data on PCCF from Statistics Canada
df_pccf = spark.read.csv("../Data/pccf_can_nov2019.csv", header=True) \
  .withColumn("pstlcode", upper(col("pstlcode"))) \
  .withColumn("pstlcode", regexp_replace(col("pstlcode"),"\s+","")) \
  .withColumn("fsa", col("pstlcode").substr(1,3)) \
  .withColumn("LDU", col("pstlcode").substr(4,6))

df_pccf.createOrReplaceTempView("df_pccf")

#######################################
# Distance to the nearest postal code #
#######################################

# Reference: Fast nearest-location finder for SQL (MySQL, PostgreSQL, SQL Server)
# URL: https://www.plumislandmedia.net/mysql/haversine-mysql-nearest-loc/

# Calculate the distance to other postal codes within the 100 km radius
df_loc = spark.sql("SELECT df_focal.fsa, df_focal.LDU, \
                     ( 111.045 * DEGREES(ACOS( LEAST(1.0, \
                       COS(RADIANS(df_focal.latitude))*COS(RADIANS(df_pair.latitude))*COS(RADIANS(df_focal.longitude - df_pair.longitude)) \
                       + SIN(RADIANS(df_focal.latitude))*SIN(RADIANS(df_pair.latitude))) )) ) AS distance \
                        FROM df_pccf AS df_focal \
                        LEFT JOIN df_pccf AS df_pair \
                          ON NOT(df_focal.fsa = df_pair.fsa AND df_focal.LDU = df_pair.LDU) \
                          AND (df_pair.latitude BETWEEN df_focal.latitude - (100/111.045) AND df_focal.latitude + (100/111.045)) \
                          AND (df_pair.longitude BETWEEN df_focal.longitude - (100/(111.045*COS(RADIANS(df_focal.latitude)))) \
                               AND df_focal.longitude + (100/(111.045*COS(RADIANS(df_focal.latitude))))) ")

df_loc.createOrReplaceTempView("df_loc")

# Find the distance to the nearest postal code (distance in km)
df_nearest = spark.sql("SELECT fsa, LDU, \
                         MIN(distance) AS distance_min \
                       FROM df_loc \
                       GROUP BY fsa, LDU ")

df_nearest.createOrReplaceTempView("df_nearest")

################
# Save dataset #
################

print('Saving data to files...')
df_nearest.printSchema()
df_nearest.write.parquet(path="df_nearest.parquet", mode="overwrite")

# Stop the sparkContext and cluster after processing
sc.stop()
