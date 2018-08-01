#!/bin/bash
# Script Autor: 1T (T) Anders
#
# -- VARS
DAY=`date +"%Y%m%d"`
HOUR=`date +"%H%M"`
BACKUP_PATH="/opt/redmine/backups"
BACKUP_PATH_APP="app_and_files"
BACKUP_LIVE_TIME="30"
BACKUP_HISTO_LIVE_TIME="180"
# VARS do redmine
REDMINE_HOME="/var/www/redmine"
REDMINE_FILES="/opt/redmine/files"
REDMINE_BACKUP_HOME="home_redmine_"$DAY"_"$HOUR".tar.bz2"
REDMINE_BACKUP_FILES="files_redmine_"$DAY"_"$HOUR".tar.bz2"
REDMINE_BACKUP_HISTO_HOME="mensal_home_redmine_"$DAY"_"$HOUR".tar.bz2"
REDMINE_BACKUP_HISTO_FILES="mensal_files_redmine_"$DAY"_"$HOUR".tar.bz2"
# estrategia dos bkp diarios
MODEL_BKP_DAILY_HOME="home_redmine_*.tar.bz2"
MODEL_BKP_DAILY_FILES="files_redmine_*.tar.bz2"
# estrategia busca bkp mensais
MODEL_BKP_HISTO_HOME="mensal_home_redmine_*.tar.bz2"
MODEL_BKP_HISTO_FILES="mensal_files_redmine_*.tar.bz2"

############### bloco 1
# faz backup da pasta raiz do redmine e da pasta onde estao os anexos
# Fazendo backup diário dir do Redmine antes de enviá-lo para um local remoto ...
echo "Daily backuping Redmine directory App before sending it to a remote place..."
tar -cjf $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HOME $REDMINE_HOME
echo "($BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HOME) done."
#---------- Arquivos enviados pelos usuarios da ferrmenta -----------#
# Fazendo backup diário dir do Redmine antes de enviá-lo para um local remoto ...
echo "Daily backuping Files directory before sending it to a remote place..."
tar -cjf $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_FILES $REDMINE_FILES
echo "($BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_FILES) done."

############### bloco 2
# faz uma cópia do backup do ultimo dia do 
# mês para pasta mensal de backups
TOMORROW=`date --date=tomorrow +%d`
if [ $TOMORROW -eq "1" ]; then
    echo
    echo "End of month : monthly backuping Redmine and files directory..."
    cp $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HOME $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HISTO_HOME
    echo "($BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HISTO_HOME) done."
    cp $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_FILES $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HISTO_FILES
    echo "($BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HISTO_FILES) done."
fi

############### bloco 3
# Removendo backups desatualizados antigos da pasta HOME
echo
echo "Purging outdated backups Redmine directory..."
# localizar e remover backups diários modificados acima de 30 dias
find $BACKUP_PATH/$BACKUP_PATH_APP/$MODEL_BKP_DAILY_HOME -mtime +$BACKUP_LIVE_TIME -exec rm {} \;
# localizar e remover backups mensais modificados acima de 180 dias
find $BACKUP_PATH/$BACKUP_PATH_APP/$MODEL_BKP_HISTO_HOME -mtime +$BACKUP_HISTO_LIVE_TIME -exec rm {} \;
echo "done."

############### bloco 4
# Removendo backups desatualizados antigos da pasta FILES
echo
echo "Purging outdated backups files directory..."
# localizar e remover backups diários modificados acima de 30 dias
find $BACKUP_PATH/$BACKUP_PATH_APP/$MODEL_BKP_DAILY_FILES -mtime +$BACKUP_LIVE_TIME -exec rm {} \;
# localizar e remover backups mensais modificados acima de 180 dias
find $BACKUP_PATH/$BACKUP_PATH_APP/$MODEL_BKP_HISTO_FILES -mtime +$BACKUP_HISTO_LIVE_TIME -exec rm {} \;
echo "done."