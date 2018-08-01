#!/bin/bash
# Script Autor: 1T (T) Anders

# nome do banco dados redmine a ser backupeado
REDMINE_DB_NAME=redmine
# login user redmine:
REDMINE_DB_USER=root
REDMINE_DB_PASS=Or@cle2018
# configura a data atual
NOW=$(date +"%d%m%Y_%H%M%Sh")
DAY=`date +"%d/%m/%Y"`
HOUR=`date +"%H:%M"`
# configura o arquivo
REDMINE_DB_BACKUP_FILE_SQL="/opt/redmine/dump/backup_redmine_${NOW}.sql"
REDMINE_DB_BACKUP_FILE_BZ2="/opt/redmine/dump/backup_redmine_${NOW}.tar.bz2"

# Backup Database sem compactação
echo "Snapshot backuping Redmine MySQL db:${REDMINE_DB_NAME} - data: ${DAY}-${HOUR}"
mysqldump --user=$REDMINE_DB_USER --password=$REDMINE_DB_PASS $REDMINE_DB_NAME > $REDMINE_DB_BACKUP_FILE_SQL
echo "($REDMINE_DB_BACKUP) done."
echo
echo "Compacting file: ${REDMINE_DB_BACKUP_FILE_SQL} MySQL db into Redmine instance..."
# Compactando o arquivo SQL
tar -cjf $REDMINE_DB_BACKUP_FILE_BZ2 $REDMINE_DB_BACKUP_FILE_SQL
# para descompactar:
# tar -jxvf redmine_20180723_0218.tar.bz2

# -- Purging old outdated backups
echo
echo "Purging SQL Plain backups..."
rm -rf $REDMINE_DB_BACKUP_FILE_SQL
echo "done."