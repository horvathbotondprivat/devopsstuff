#!/bin/bash
. /home/oracle/.bash_profile
if [[ $1 == "" ]]
then
	echo "Usage: $0 USERNAME"
	exit
fi
CONNECT_STRING="system/password"

sqlplus -S $CONNECT_STRING <<EOF 
set pages 100
set lines 200

select ses.USERNAME,
    substr(MACHINE,1,10) as MACHINE,
    substr(module,1,25) as module,
    status,
    'alter system kill session '''||SID||','||ses.SERIAL#||''';' as kill
from v\$session ses LEFT OUTER JOIN v\$process p ON (ses.paddr=p.addr)
where schemaname <> 'SYS'
and ses.username='$1'
;
EOF
echo "Is it ok to kill these sessions? (y/n)"
read ok_to_kill
if [[ x${ok_to_kill} != "xy" ]]
then
exit
fi

sqlplus -S $CONNECT_STRING <<EOF >session_kill_$$.sql
set pages 0
set lines 200
set echo off
set serveroutput off

select 
    'alter system kill session '''||SID||','||ses.SERIAL#||''';' as kill
from v\$session ses LEFT OUTER JOIN v\$process p ON (ses.paddr=p.addr)
where schemaname <> 'SYS'
and ses.username='$1'
;
EOF

#rm -f session_kill_$$.sql

