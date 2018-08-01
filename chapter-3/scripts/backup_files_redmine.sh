#!/bin/bash
# Script Autor: 1T (T) Anders
#
###########################################################################
###########################################################################
# VARS DE BACKUP
DAY=`date +"%Y%m%d"`
HOUR=`date +"%H%M"`
BACKUP_PATH="/opt/redmine/backups"
BACKUP_PATH_APP="app_and_files"
BACKUP_LIVE_TIME="30"
BACKUP_HISTO_LIVE_TIME="180"
# VARS DE LOCALIZACO DO REDMINE E DO FILES, CASO ESTEJA SEPARADO
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
# retorna a versao do Oracle Linux
###########################################################################
VERSION_SO=`cat /etc/oracle-release`
TOMORROW=`date --date=tomorrow +%d`
###########################################################################

# Rotina principal do script e chamada na ordem abaixo do arquivo
main() {
	echo "----- Rotina de Backup do Redmine no Servidor: ${VERSION_SO} -----"

	bkp_daily_dir_redmine
    bkp_daily_dir_redmine_files
    bkp_monthly_dir_redmine
    bkp_monthly_dir_redmine_files
    remove_daily_dir_redmine_files
    remove_monthly_dir_redmine_files

	echo "----- Rotina de Backup Concluído ----- "
}

############### bloco 1
# Fazendo backup diário dir do Redmine antes de enviá-lo para um local remoto ...
bkp_daily_dir_redmine() 
{
    echo
    echo "Realizando backup diário diretório 'Redmine', antes de enviar para um local remoto..."
    tar -cjf $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HOME $REDMINE_HOME
    echo "arquivo: '$BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HOME' pronto."
}

# Anexos enviados pelos usuarios da ferrmenta
bkp_daily_dir_redmine_files() 
{
    echo
    echo "Realizando backup diário diretório do 'files', antes de enviar para um local remoto..."
    tar -cjf $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_FILES $REDMINE_FILES
    echo "arquivo: '$BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_FILES' pronto."
}

############### bloco 2
# faz uma cópia do backup do ultimo dia do mês para pasta mensal de backups
bkp_monthly_dir_redmine() 
{
    if [ $TOMORROW -eq "1" ]; then
        echo
        echo "fim do mês : Realizando backup mensal do diretório Redmine..."
        
        cp $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HOME $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HISTO_HOME
        
        echo "arquivo: '$BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HISTO_HOME' pronto."
    fi
}
# faz uma cópia do backup do ultimo dia do mês para pasta mensal de backups
bkp_monthly_dir_redmine_files() 
{
    if [ $TOMORROW -eq "1" ]; then
        echo
        echo "fim do mês : Realizando backup mensal do diretório file..."

        cp $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_FILES $BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HISTO_FILES

        echo "arquivo: '$BACKUP_PATH/$BACKUP_PATH_APP/$REDMINE_BACKUP_HISTO_FILES' pronto."
    fi
}

############### bloco 3
# Removendo backups desatualizados antigos da pasta HOME acima de 30 dias
remove_daily_dir_redmine_files() 
{
    echo
    echo "Removendo backups diários antigos da pasta 'Redmine' acima de 30 dias..."
    # localizar e remover backups diários modificados acima de 30 dias
    find $BACKUP_PATH/$BACKUP_PATH_APP/$MODEL_BKP_DAILY_HOME -mtime +$BACKUP_LIVE_TIME -exec rm {} \;

    echo "Removendo backups diários antigos da pasta 'files' acima de 30 dias..."
    # localizar e remover backups diários modificados acima de 30 dias
    find $BACKUP_PATH/$BACKUP_PATH_APP/$MODEL_BKP_DAILY_FILES -mtime +$BACKUP_LIVE_TIME -exec rm {} \;
    
    echo "pronto."
}

# Removendo backups desatualizados antigos da pasta HOME
remove_monthly_dir_redmine_files() 
{
    echo
    echo "Removendo backups mensais antigos da pasta 'redmine' acima de 180 dias..."    
    # localizar e remover backups mensais modificados acima de 180 dias
    find $BACKUP_PATH/$BACKUP_PATH_APP/$MODEL_BKP_HISTO_HOME -mtime +$BACKUP_HISTO_LIVE_TIME -exec rm {} \;
    
    echo "Removendo backups mensais antigos da pasta 'files' acima de 180 dias..."
    find $BACKUP_PATH/$BACKUP_PATH_APP/$MODEL_BKP_HISTO_FILES -mtime +$BACKUP_HISTO_LIVE_TIME -exec rm {} \;
    echo "pronto."
}

#chamando rotine principal
main
exit 0