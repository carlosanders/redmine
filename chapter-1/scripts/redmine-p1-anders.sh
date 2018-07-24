#!/bin/bash
# Script Autor: 1T (T) Anders
###########################################################################
###########################################################################
ver_so=`cat /etc/oracle-release`
usuario_logado=$USER

### cores ###
c_red_b_white="\033[01;47;31m"
c_amarelo="\033[01;33m"
c_azul="\033[00;36m"
c_fechamento="\033[00m"


# Rotina principal do script e chamada na ordem abaixo do arquivo
main() {
	echo -e "${c_red_b_white}>>>>>>>> Servidor: ${ver_so} <<<<<<<<${c_fechamento}"

	vrf_modo_root
	tools_go
	config_disable_selinux_go
	mysql_go
	apache_go

	echo -e "${c_red_b_white}----- Provisionamento Concluído ----- ${c_fechamento}"
}

vrf_modo_root(){
	echo -e "${c_amarelo} >>>>>>>> Verificando modo root... <<<<<<<< ${c_fechamento}"

	if [ "$EUID" -ne 0 ]
		then echo "ERRO: Para configurar os repositórios execute este script como root"
		exit
	fi

	if [ -f /etc/yum.repos.d/public-yum-ol7.repo ] 
		then 
		cp /etc/yum.repos.d/public-yum-ol7.repo /root/public-yum-ol7-old.repo
		rm /etc/yum.repos.d/public-yum-ol7.repo
		curl http://public-yum.oracle.com/public-yum-ol7.repo > /etc/yum.repos.d/public-yum-ol7.repo		
		else
		curl http://public-yum.oracle.com/public-yum-ol7.repo > /etc/yum.repos.d/public-yum-ol7.repo		
	fi

	#habilitando repos
    yum-config-manager --enable ol7_addons
    yum-config-manager --enable ol7_UEKR4
    yum-config-manager --enable ol7_MySQL57
    yum-config-manager --enable ol7_optional_latest
	#desabilitado, pois as vz apr problemas
	#yum-config-manager --enable ol7_developer_EPEL
    #yum-config-manager --save --setopt=ol7_developer_EPEL.skip_if_unavailable=true

	echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

#sub-rotina de isntalação de pacotes de dependencias
tools_go() {
	echo -e "${c_amarelo} >>>>>>>> Instalando dependências <<<<<<<<${c_fechamento}"

	#sudo yum check-update
	yum makecache

	sudo yum groups mark install "Development Tools"
	yum groups mark convert "Development Tools"
	sudo yum -y groupinstall "Development Tools"

	sudo yum -y install gcc curl curl-devel gcc-c++ ImageMagick ImageMagick-devel ntp \
	autoconf automake binutils make openssl openssl-devel zlib zlib-devel glibc \
	glibc-devel libgcc expat-devel apr-util-devel mysql-devel \
	ftp wget patch readline readline-devel libyaml-devel libffi-devel \
	bzip2 libtool bison sqlite-devel \
	perl perl-devel pcre pcre-devel libcurl-devel

	#echo -e '\033[00;36m----- Concluído ----- \033[00m'
    echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

#sub-rotina para configurações
config_disable_selinux_go() {

	echo -e "${c_amarelo} >>>>>>>> Desabilitando SELINUX e firewall <<<<<<<<${c_fechamento}"

    sudo systemctl stop firewalld
	sudo systemctl disable firewalld

	#sudo echo '${usuario_logado} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

	sudo setenforce 0

	sudo sed -i "s/SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config
	sudo sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

	#echo -e '\033[00;36m----- Concluído ----- \033[00m'
    echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

#sub-rotina
mysql_go() {
	echo -e "${c_amarelo} >>>>>>>> Instalando Mysql no Servidor <<<<<<<< ${c_fechamento}"
	
	# o script abaixo foi tornado obsoleto no OEL 7.3 e substituido pelos community
	#sudo yum -y install mariadb-server mariadb mariadb-devel
	sudo yum -y install mysql-community-server mysql-community-client mysql-community-devel

	sudo chkconfig mysqld on
	sudo service mysqld start
	sudo service mysqld status

	#echo -e '\033[00;36m----- Concluído ----- \033[00m'
    echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

#sub-rotina
apache_go() {
	echo -e "${c_amarelo} >>>>>>>> Instalando Apache no Servidor <<<<<<<<${c_fechamento}"
	
	sudo yum -y install httpd httpd-devel apr-devel mod_ssl
	
	#permite que você possa executar scripts em PHP com as permissões de seus respectivos proprietários
	#yum -y install mod_fcgid

	sudo systemctl enable httpd
	sudo chkconfig httpd on
    #sudo apachectl start
	sudo service httpd start

	firewall-cmd --zone=zone --add-port=80/tcp
	firewall-cmd --permanent --zone=zone --add-port=80/tcp

	#echo -e '\033[00;36m----- Concluído ----- \033[00m'
    echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

main

echo -e "${c_amarelo} >>>>>>>> Reinicie o Sistema <<<<<<<<${c_fechamento}"
echo -e "${c_amarelo} comando: systemctl reboot ${c_fechamento}"
exit 0
