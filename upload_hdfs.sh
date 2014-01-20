ll *.txt
hadoop fs -mkdir -p /data/greenplum/etb
hadoop fs -put *.txt /data/greenplum/etb
hadoop fs -ls /data/greenplum/etb

