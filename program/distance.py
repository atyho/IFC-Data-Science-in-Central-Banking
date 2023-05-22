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

# Load data on 2017 bank branch location from Payments Canada
df_bank = spark.read.csv("../data/branch_locations_2017.csv", header=True) \
  .withColumn("Postal", upper(col("Postal"))) \
  .withColumn("Postal", regexp_replace(col("Postal"),"\s+","")) \
  .withColumn("fsa", col("Postal").substr(1,3)) \
  .withColumn("LDU", col("Postal").substr(4,6)).distinct()
  
df_bank.createOrReplaceTempView("df_bank")

# Load data on PCCF from Statistics Canada
df_pccf = spark.read.csv("../data/pccf.csv", header=True) 
df_pccf.createOrReplaceTempView("df_pccf")

#######################################
# Distance to the nearest postal code #
#######################################

# Reference: Fast nearest-location finder for SQL (MySQL, PostgreSQL, SQL Server)
# URL: https://www.plumislandmedia.net/mysql/haversine-mysql-nearest-loc/

# Calculate the fly-over distance to all bank branches within the 100 km radius
df_loc = spark.sql("SELECT df_pccf.fsa, df_pccf.LDU, df_pccf.latitude, df_pccf.longitude, \
                     ( 111.045 * DEGREES(ACOS( LEAST(1.0, \
                       COS(RADIANS(df_pccf.latitude))*COS(RADIANS(df_bank.lat))*COS(RADIANS(df_pccf.longitude - df_bank.lng)) \
                       + SIN(RADIANS(df_pccf.latitude))*SIN(RADIANS(df_bank.lat))) )) ) AS distance \
                   FROM df_pccf \
                   LEFT JOIN df_bank \
                     ON (df_bank.lat BETWEEN df_pccf.latitude - (100/111.045) AND df_pccf.latitude + (100/111.045)) \
                     AND (df_bank.lng BETWEEN df_pccf.longitude - (100/(111.045*COS(RADIANS(df_pccf.latitude)))) \
                          AND df_pccf.longitude + (100/(111.045*COS(RADIANS(df_pccf.latitude))))) ")

df_loc.createOrReplaceTempView("df_loc")

# Find the distance to the nearest postal code (distance in km)
df_nearest = spark.sql("SELECT fsa, LDU, latitude, longitude, \
                         MIN(distance) AS distance_min \
                       FROM df_loc \
                       GROUP BY fsa, LDU, latitude, longitude ")

df_nearest.createOrReplaceTempView("df_nearest")

# Merge results with main data set
df_distance = spark.sql("SELECT df_pccf.*, df_nearest.distance_min \
                        FROM df_pccf \
                        LEFT JOIN df_nearest \
                          ON df_pccf.fsa = df_nearest.fsa \
                          AND df_pccf.LDU = df_nearest.LDU ")

df_distance.createOrReplaceTempView("df_distance")

################
# Save dataset #
################

print('Saving data to files...')

df_distance.printSchema()
#df_distance.write.parquet(path="df_distance.parquet", mode="overwrite")
df_distance.write.csv(path="dist_data", mode="overwrite", sep=",", header="true")

# Stop the sparkContext and cluster after processing
sc.stop()
