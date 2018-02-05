#!/bin/bash
hostname=$1;
username=$2;
password=$3;
backuppath=$4;

([ -z "$hostname" ] || [ -z "$username" ] || [ -z "$password" ]) && echo "all 3 arguments must be specified: hostname username password " && exit 1;

wget -qO- --keep-session-cookies --save-cookies /tmp/$hostname-cookies.txt \
  --no-check-certificate https://$hostname/diag_backup.php \
  | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > /tmp/$hostname-csrf.txt

wget -qO- --keep-session-cookies --load-cookies /tmp/$hostname-cookies.txt \
  --save-cookies /tmp/$hostname-cookies.txt --no-check-certificate \
  --post-data "login=Login&usernamefld=$username&passwordfld=$password&__csrf_magic=$(cat /tmp/$hostname-csrf.txt)" \
  https://$hostname/diag_backup.php  | grep "name='__csrf_magic'" \
  | sed 's/.*value="\(.*\)".*/\1/' > /tmp/$hostname-csrf2.txt

wget --keep-session-cookies --load-cookies /tmp/$hostname-cookies.txt --no-check-certificate \
  --post-data "download=download&donotbackuprrd=yes&__csrf_magic=$(head -n 1 /tmp/$hostname-csrf2.txt)" \
  https://$hostname/diag_backup.php -O $backuppath/config-router-`date +%Y%m%d%H%M%S`.xml


rm /tmp/$hostname-cookies.txt /tmp/$hostname-csrf*.txt

