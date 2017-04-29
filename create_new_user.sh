if [[ $1 = "" ]] 
then
echo "Usage: first parameter should be the new user name, e.g.: $0 USERNAME";exit
fi 

sqlplus system/password <<EOF
create user $1 identified by $1;
grant connect to $1;
grant unlimited tablespace to $1;
grant resource to $1;
EOF
