# /usr/local/greenplum/lib/hadoop ,
#  modified by winghc@gmail.com, to fit the environment of Apache Hadoop 2.2.0
# 

export GP_JAVA_OPT=-Xmx1000m
export PATH=$JAVA_HOME/bin:$PATH
JAVA=$JAVA_HOME/bin/java

GP_HADOOP_CONN_JARDIR=lib/hadoop
GP_HADOOP_CONN_VERSION=cdh4.1-gnet-1.2.0.0
CLASSPATH="$GPHOME"/"$GP_HADOOP_CONN_JARDIR"/$GP_HADOOP_CONN_VERSION.jar

function append_path() {
  if [ -z "$1" ]; then
    echo $2
  else
    echo $1:$2
  fi
}
JAVA_PLATFORM=""

#If avail, add Hadoop to the CLASSPATH and to the JAVA_LIBRARY_PATH
HADOOP_IN_PATH=$(PATH="${HADOOP_HOME:-${HADOOP_PREFIX}}/bin:$PATH" which hadoop 2>/dev/null)
if [ -f ${HADOOP_IN_PATH} ]; then
  HADOOP_JAVA_LIBRARY_PATH=$(HADOOP_CLASSPATH="$CLASSPATH" ${HADOOP_IN_PATH} \
                             org.apache.hadoop.hbase.util.GetJavaProperty java.library.path 2>/dev/null)
  if [ -n "$HADOOP_JAVA_LIBRARY_PATH" ]; then
    JAVA_LIBRARY_PATH=$(append_path "${JAVA_LIBRARY_PATH}" "$HADOOP_JAVA_LIBRARY_PATH")
  fi
  CLASSPATH=$(append_path "${CLASSPATH}" `${HADOOP_IN_PATH} classpath 2>/dev/null`)
fi

if [ -d "${HBASE_HOME}/build/native" -o -d "${HBASE_HOME}/lib/native" ]; then
  if [ -z $JAVA_PLATFORM ]; then
    JAVA_PLATFORM=`CLASSPATH=${CLASSPATH} ${JAVA} org.apache.hadoop.util.PlatformName | sed -e "s/ /_/g"`
  fi
  if [ -d "$HBASE_HOME/build/native" ]; then
    JAVA_LIBRARY_PATH=$(append_path "$JAVA_LIBRARY_PATH" ${HBASE_HOME}/build/native/${JAVA_PLATFORM}/lib)
  fi

  if [ -d "${HBASE_HOME}/lib/native" ]; then
    JAVA_LIBRARY_PATH=$(append_path "$JAVA_LIBRARY_PATH" ${HBASE_HOME}/lib/native/${JAVA_PLATFORM})
  fi
fi


export LD_LIBRARY_PATH="$JAVA_LIBRARY_PATH"
if [ "x$JAVA_LIBRARY_PATH" != "x" ]; then
  GP_JAVA_OPT="$GP_JAVA_OPT -Djava.library.path=$JAVA_LIBRARY_PATH"
fi  

export GP_JAVA_OPT=$GP_JAVA_OPT
export CLASSPATH=$CLASSPATH
