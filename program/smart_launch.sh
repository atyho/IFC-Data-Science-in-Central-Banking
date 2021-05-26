#!/bin/bash
# Created by Barbara Collignon. July 2017.
# Modified by Christopher Demone and Anson Ho. November 2018.

echo " "
echo "Executing smart_launch.sh..."

echo ""
echo "Current working directory is :" && pwd

echo ""
echo "checking options and arguments..."
if [[ "$#" -lt 12 ]] || [ "$1" == "--h" ]; then
    echo "INCORRECT SYNTAX. Values and/or options are missing."
    echo
    echo "Usage :"
    echo "For automated configuration:"
    echo "smart_launch.sh -m val1 -u val2 -c val3 -n val4 -e val5 -p val6 -d val7 -f val8"
    echo "-m : SLURM_MEM_PER_NODE (G)"
    echo "-u : SLURM_CPUS_ON_NODE"
    echo "-c : Class"
    echo "-n : SLURM_JOB_NUM_NODES"
    echo "-e : Executor cores (max = 5)"
    echo "-p : Program"
    echo "-d : Data path(s) - seperate multiple by ',' with NO wildcards '*'"
    echo "-f : File"
    echo
    echo "For user input configuration:"
    echo "smart_launch.sh -d val1 -s val2 -w val3 -c val4 -e val5 -p val6 -f val7"
    echo "-d : Driver memory"
    echo "-s : Shuffle partitions"
    echo "-w : Workers per node"
    echo "-c : Class"
    echo "-e : Executor cores (max = 5)"
    echo "-p : Program"
    echo "-f : File"
    echo
    exit

elif [[ "$#" -ge 6 ]] && [ "$1" == "-m" ]; then
    while getopts "m:u:c:n:e:p:d:f:" option;
    do
        case ${option} in
        m) MEMORY=${OPTARG}
                ;;
        u) CORES=${OPTARG}
                ;;
        c) CLASS=${OPTARG}
                ;;
        n) NODES=${OPTARG}
                ;;
        e) ECORES=${OPTARG}
                ;;
        p) PROG=${OPTARG}
                ;;
        d) FPATHS=${OPTARG}
                ;;
        f) FILE=${OPTARG}
                ;;
        [?])    echo ""
                echo "Usage :"
                echo "spark_launch -m val1 -u val2 -c val3 -n val4 -e val5 -p val6 -d val7 -f val8"
                echo "-m : SLURM_MEM_PER_NODE (G)"
                echo "-u : SLURM_CPUS_ON_NODE"
                echo "-c : Class"
                echo "-n : SLURM_JOB_NUM_NODES"
                echo "-e : Executor cores (max = 5)"
                echo "-p : Program"
                echo "-d : data path(s) - separate multiple by ',' with NO wildcards '*'"
                echo "-f : File"
                echo
                exit 1;;
        esac
    done
elif [[ "$#" -eq 6 ]] && [ "$1" != "-m" ]; then
    while getopts "d:s:w:c:e:p:f:" option;
    do
        case ${option} in
        d) DRIVER=${OPTARG}
                ;;
        s) SHUFF=${OPTARG}
                ;;
        w) WORKERS=${OPTARG}
                ;;
        c) CLASS=${OPTARG}
                ;;
        e) ECORES=${OPTARG}
                ;;
        p) PROG=${OPTARG}
                ;;
        f) FILE=${OPTARG}
                ;;
        [?])    echo ""
                echo "Usage :"
                echo "smart_launch.sh -d val1 -s val2 -w val3 -c val4 -e val5 -p val6 -f val7"
                echo "-d : Driver memory"
                echo "-s : Shuffle partitions"
                echo "-w : Workers per node"
                echo "-c : Class"
                echo "-e : Executor cores (max = 5)"
                echo "-p : Program"
                echo "-f : File"
                echo
                exit 1;;
        esac
    done
fi

if [ "$FILE" != "" ]; then
echo "My file is $FILE"
else
echo "My file is NONE"
fi
echo ""

if [ ! -d /scratch/hadoop/$USER ]; then
  echo "creating log dir for user:" $USER
  mkdir /scratch/hadoop/$USER
  chmod go-rw /scratch/hadoop/$USER
  echo "/scratch/hadoop/$USER"
fi
echo ""

if [ ! -d /scratch/hadoop/$USER/tmp ]; then
   mkdir /scratch/hadoop/$USER/tmp
fi

echo "cleaning up old yarn deamons..."
stop-history-server.sh
stop-yarn.sh
echo ""
echo "starting Yarn where the job is submitted..."
start-yarn.sh

#TODO: rename variables from SLURM so they aren't the same as the command line argument
# Automated configuration
if [ "$1" == "-m" ]; then
    #TODO:if cores_per_executor > 5 : exit and print why (if we switch to Lustre may be different)
    # Execute autotmated configuration for user
    size_per_partition=128                          # TODO:: optimize this setting
    DAEMON_CORES=3                                  # Cores reserved for YARN Daemons
    N_AM=1                                          # Number of AM 'executors'
    AM_CORES=1                                      # Number of cores reserved for YARN AM
    ALLOC_MEM=$(echo $MEMORY | sed 's/[^0-9]*//g')  # Memory allocated by SLURM
    SLURM_CPUS_ON_NODE=$CORES                       # Number of cores allocated by SLURM
    SLURM_JOB_NUM_NODES=$NODES                      # Number of nodes (1 for client)
    CORES_PER_EXECUTOR=$ECORES                      # -executor-cores

    if [ "$FPATHS" != "" ]; then
        PATHS=$(echo ${FPATHS//,/ })
        PATH_ARR=($PATHS)
        LENGTH=${#PATH_ARR[@]}
        if [ "$LENGTH" -gt 1 ]; then
            size=0
            REAL_PARTS=0

            #TODO: this could be inconvenient if they have many paths
            # Also what if they only want a subset of the files in the path:: right now we select all.
            # NOTE: 10s for 600 files when paths initially defined with * (count 1 by 1) less than 1s other way
            # Perhaps set an option so that they can select subset of data.
            for path in $PATHS; do
                fsize=$(du -bc ${path}/*.parquet | tail -1 | cut -f 1 | awk '{x += $1} END { print x /(1024.0*1024.0) }')
                size=$(echo "($size + $fsize)" | bc -l)
                real=$(ls -A ${path}/*.parquet | wc -l)
                REAL_PARTS=$(echo "($REAL_PARTS + $real)" | bc -l)
            done

        elif [ "$LENGTH" -eq 1 ]; then
            size=$(du -bc $path | tail -1 | cut -f 1 | awk '{x += $1} END { print x /(1024.0*1024.0) }')
            REAL_PARTS=$(ls -A ${file} | wc -l)
        elif [ "$LENGTH" -lt 1 ]; then
            echo ""
            echo "For automated configuration user must input path(s)"
            echo "to data files used within their Spark application/"
            echo "Please input these paths with -p [path1],[path2]..."
            echo "NOTE: path should not include wild cards '*'."
            echo "For option details: smart_lauch.sh --h"
            echo ""
        fi

        echo "Total data size = ${size}MB"
        SHUFFLE_PARTITIONS=$(printf '%.0f' "$(bc -l <<< "$size / $size_per_partition")")
        if [ "$SHUFFLE_PARTITIONS" -lt "$REAL_PARTS" ]; then
            SHUFFLE_PARTITIONS=$REAL_PARTS
        elif [ "$REAL_PARTS" -lt "$SHUFFLE_PARTITIONS" ]; then
            actual_partition_size=$(printf '%.0f' "$(bc -l <<< "$size / $REAL_PARTS")")
            echo ""
            echo "Partioning non-optimal. Consider repartitioning data."
            echo "Data should have numPartitions = ${SHUFFLE_PARTITIONS}"
            echo "Currently you have ${REAL_PARTS} partitions, where each"
            echo "partition is ${actual_partition_size}MB in size"
            echo ""
        fi
    else
        SHUFFLE_PARTITIONS=200
    fi

    CORES_PER_NODE=$(echo "($SLURM_CPUS_ON_NODE - $DAEMON_CORES)"| bc -l)
    NCORES=$(printf '%.0f' "$(echo "($SLURM_JOB_NUM_NODES * $CORES_PER_NODE)-($N_AM * $AM_CORES)" | bc -l)")
    NUM_EXECUTORS=$(printf '%.0f' "$(echo "($NCORES / $CORES_PER_EXECUTOR)-0.5" | bc -l)")
    EXEC_PER_NODE=$(printf '%.0f' "$(echo "($NUM_EXECUTORS/$SLURM_JOB_NUM_NODES)" | bc -l)")

    # Memory settings cant use floats for memory specifications in spark-submit
    OVERHEAD=$(printf '%.0f' "$(echo "($ALLOC_MEM*0.15)" | bc -l)")

    # Minimum overhead is 2GB
    if [ "$OVERHEAD" -lt 2048 ]; then
        OVERHEAD=2048
    fi

    # Memory settings in MB
    REAL_MEM=$(printf '%.0f' "$(echo "($ALLOC_MEM - $OVERHEAD)" | bc -l)")
    EXECUTOR_MEM=$(printf '%.0f' "$(echo "(($REAL_MEM - ($DAEMON_CORES*1024)) / ($EXEC_PER_NODE + $N_AM))" | bc -l)")
    # AM_MEMORY-1G(default) for yarn.scheduler.minimum-allocation-mb
    # AM_MEMORY in cluster mode == driver-memory
    # AM_MEMORY calculated like this so that we don't exceed allocated memory from SLURM
    # Also, 1GB per daemon core is set aside for YARN daemons
    # TODO: cant set spark.yarn.am.memory in spark-submit :: could leave default and distribute this memory
    # accross all executors - though in cluster mode can't do this since this memory is used by driver
    # NOTE: SLURM_MEM_PER_NODE given in MB

    AM_MEMORY=$EXECUTOR_MEM

    # TODO: Test how MAX_RESULT effects peformance or if MAX_RESULT=$AM_MEMORY ALWAYS
    # Current max(MAX_RESULT) = 2GB

    MAX_RESULT=$(printf '%.0f' "$(echo "$AM_MEMORY*0.9" | bc -l)")

    #if [ "$AM_MEMORY" -lt 2097152 ]; then
    #    MAX_RESULT=$AM_MEMORY
    #else
    #    MAX_RESULT=2097152
    #fi

    echo ""
    echo "----------------------SETTINGS--------------------"
    echo "spark.sql.shuffle.partitions = ${SHUFFLE_PARTITIONS}"
    echo "Cores per node (accounting for daemons) = ${CORES_PER_NODE}"
    echo "Total number of cores for executors = ${NCORES}"
    echo "Total number of executors (after AM allocation) = ${NUM_EXECUTORS}"
    echo "Executors per node (excluding AM) = ${EXEC_PER_NODE}"
    echo "Executor memory (after overhead) = ${EXECUTOR_MEM}MB"
    echo "Total overhead = ${OVERHEAD}MB"
    echo "Driver Max result size = ${MAX_RESULT}MB"
    echo ""

    if [ "$FILE" != "" ]; then
    echo "My file is $FILE"
    else
    echo "My file is NONE"
    fi
    echo ""

    if [ "$FILE" != "" ]; then
    spark-submit --verbose --driver-memory ${AM_MEMORY}m --driver-cores $AM_CORES --conf spark.sql.shuffle.partitions=$SHUFFLE_PARTITIONS --conf spark.driver.maxResultSize=${MAX_RESULT}m --num-executors $NUM_EXECUTORS --executor-cores $ECORES --executor-memory ${EXECUTOR_MEM}m --class $CLASS --master yarn --deploy-mode client $PROG --files $FILE
    else
    spark-submit --verbose --driver-memory ${AM_MEMORY}m --driver-cores $AM_CORES --conf spark.sql.shuffle.partitions=$SHUFFLE_PARTITIONS --conf spark.driver.maxResultSize=${MAX_RESULT}m --conf spark.executor.instances=$NUM_EXECUTORS --conf spark.executor.cores=$ECORES --conf spark.executor.memory=${EXECUTOR_MEM}m --class $CLASS --master yarn --deploy-mode client $PROG
    fi

# User input configuration
elif [ "$1" == "-d" ]; then
    echo $1 $2 $3 $4
    echo "The number of executors is $WORKERS"
    echo "The number of workers per executor is 1"
    echo "My class is $CLASS"
    echo "My program is $PROG"

    if [ "$FILE" != "" ]; then
    echo "My file is $FILE"
    else
    echo "My file is NONE"
    fi
    echo ""

    if [ "$FILE" != "" ]; then
    spark-submit --verbose --driver-memory $DRIVER --conf spark.sql.shuffle.partitions=$SHUFF --conf spark.driver.maxResultSize=2048m --conf spark.driver.extraClassPath=/usr/local/tools/spark-nohive/spark-2.1.1/sparkmeasure/spark-measure_2.11-0.14-SNAPSHOT.jar --num-executors $WORKERS --executor-cores $ECORES --class $CLASS --master yarn --deploy-mode client $PROG --files $FILE
    else
    spark-submit --verbose --driver-memory $DRIVER --conf spark.sql.shuffle.partitions=$SHUFF --conf spark.driver.maxResultSize=2048m --conf spark.driver.extraClassPath=/usr/local/tools/spark-nohive/spark-2.1.1/sparkmeasure/spark-measure_2.11-0.14-SNAPSHOT.jar --num-executors $WORKERS --executor-cores $ECORES --class $CLASS --master yarn --deploy-mode client $PROG
    fi

fi

echo "waiting for all tasks to be completed..."
wait
echo "stopping Yarn on the host..."
stop-yarn.sh
echo

echo "DONE."
echo ""
CURRENT=$(pwd | awk 'BEGIN{FS="/"}{print $NF}')
EXEC=$(echo $PROG | awk 'BEGIN{FS="/"}{print $NF}')
echo "archiving HOURLY log files"

now=$(date +%F)
logfiles=$(ls INFO.log."$now"* | wc -l)

if [ $logfiles -gt 0 ]; then
#if [[ -f INFO.log."$now"* ]]; then
    tar cvzf "$CURRENT"_"$CLASS"_"$EXEC".tgz INFO.log."$now"*
    now=$(date | awk '{print $1_$3_$2_$6}')
    if [ ! -d /scratch/hadoop/$USER/$now ]; then
        mkdir /scratch/hadoop/$USER/$now
    fi
    mv "$CURRENT"_"$CLASS"_"$EXEC".tgz /scratch/hadoop/$USER/$now
else
   echo "NO HOURLY LOG FILES FOR TODAY"
fi
