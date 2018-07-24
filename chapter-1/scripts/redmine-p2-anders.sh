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
### Arquivos ###


# Rotina principal do script e chamada na ordem abaixo do arquivo
main() {
	echo -e "${c_red_b_white}>>>>>>>> Servidor: ${ver_so} <<<<<<<<${c_fechamento}"
	mysql_go
    mysql_DB_create_go
	ruby_233_go
    install_passenger_go
    virtual_host_apache_go    
	echo -e "${c_red_b_white}----- Provisionamento Concluído ----- ${c_fechamento}"
}

#sub-rotina
mysql_go() {
	echo -e "${c_amarelo} >>>>>>>> Configurando MySQL <<<<<<<< ${c_fechamento}"

    #yum -y install expect

    cat /var/log/mysqld.log | grep 'temporary password'
    read -p "Cole a senha do root aqui: " MYSQL_ROOT_PASSWORD
    echo 
    read -p "Entre com a nove senha do root: " NEW_PASSWD_ROOT
    #NEW_PASSWD_ROOT="Or@cle2018"
    # não aceitamos nomes nulo
    [ "$MYSQL_ROOT_PASSWORD" ] || { echo "ERRO: senha temporária inválida";exit; }

    [ "$NEW_PASSWD_ROOT" ] || { echo "ERRO: nova senha inválida";exit; }

    SECURE_MYSQL=$(expect -c "
    set timeout 10
    spawn mysql_secure_installation
    expect \"Enter password for user root:\"
    send \"$MYSQL_ROOT_PASSWORD\r\"
    expect \"New password:\"
    send \"$NEW_PASSWD_ROOT\r\"
    expect \"Re-enter new password:\"
    send \"$NEW_PASSWD_ROOT\r\"
    expect \"Change the password for root?\"
    send \"n\r\"
    expect \"Remove anonymous users?\"
    send \"y\r\"
    expect \"Disallow root login remotely?\"
    send \"n\r\"
    expect \"Remove test database and access to it?\"
    send \"y\r\"
    expect \"Reload privilege tables now?\"
    send \"y\r\"
    expect eof
    ")

    echo "$SECURE_MYSQL"

    #aptitude -y purge expect

    echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

#sub-rotina
mysql_DB_create_go() {
	echo -e "${c_amarelo} >>>>>>>> Criando DB MySQL <<<<<<<< ${c_fechamento}"
    #mysql -uroot mysql < arquivo.sql
    cat redmine.sql | mysql -u root -p mysql
    echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

#sub-rotina
ruby_233_go() {
	echo -e "${c_amarelo} >>>>>>>> Instalando Ruby no Servidor <<<<<<<<${c_fechamento}"

	# substituido pelo pacote que esta no repo publico do oracle linux
	#
    #https://rpmfind.net/linux/rpm2html/search.php?query=libyaml-devel
    #https://rpmfind.net/linux/rpm2html/search.php?query=libyaml-devel(x86-64)
	#sudo wget https://rpmfind.net/linux/centos/7.5.1804/os/x86_64/Packages/libyaml-devel-0.1.4-11.el7_0.x86_64.rpm
	#sudo rpm -Uvh libyaml-devel-0.1.4-11.el7_0.x86_64.rpm
	
	#https://rvm.io/rvm/install
	#https://github.com/rvm/rvm/

	#instale a chave pública mpapis usada para verificar o pacote 
	#de instalação para garantir a segurança .
	curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import -
	#ou
	#sudo gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
	
	# baixar e instalar o gerenciador de pacotes do ruby 
	\curl -sSL https://get.rvm.io | sudo bash -s stable
	# atualizar as variaveis de ambientes
	source /etc/profile.d/rvm.sh
	#recargamos as variáveis do rvm
	rvm reload
	#checamos o rvm
	rvm requirements run
	# instalando a versao correta do ruby para o redmine 3.3.0
	# caso esteja instalando uma verao superior do redmine tem que vrf qual ruby
	# sera instalado
	rvm install 2.3.3
	#rvm install ruby-2.3.3
	# ativando a versao do ruby
	rvm --default use ruby-2.3.3
	# verificando as instalacoes dos pacotes
	ruby --version && gem --version

    echo -e "${c_amarelo} Instalando algumas gems requeridas ${c_fechamento}"
	## Instalamos algunas gems requeridas
	gem update --system
	gem update
	gem install bundle
	gem install rails
	gem install passenger
	gem install mysql2
	# outras gems necessarias
	gem install rake
	gem install rbpdf
	gem install rbpdf-font
	gem install image_magick
	gem install rmagick	

	echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

#sub-rotina
install_passenger_go(){
    echo -e "${c_amarelo} >>>>>>>> Configurando Passenger... <<<<<<<<${c_fechamento}"
    # comando para compilar o passenger
    passenger-install-apache2-module

    passenger_conf="/etc/httpd/conf.modules.d/00-passenger.conf"

	cat << EOF > ${passenger_conf}
LoadModule passenger_module /usr/local/rvm/gems/ruby-2.3.3/gems/passenger-5.3.3/buildout/apache2/mod_passenger.so
   <IfModule mod_passenger.c>
     PassengerRoot /usr/local/rvm/gems/ruby-2.3.3/gems/passenger-5.3.3
     PassengerDefaultRuby /usr/local/rvm/gems/ruby-2.3.3/wrappers/ruby
   </IfModule>
EOF

    service httpd restart
    echo -e "${c_azul}----- Concluído ----- ${c_fechamento}"
}

#sub-rotina
virtual_host_apache_go() {

	echo -e "${c_amarelo} >>>>>>>> Configurando VirtuaHost no Apache... <<<<<<<<${c_fechamento}"

    redmine_conf="/etc/httpd/conf.d/redmine.conf"

	cat << EOF > ${redmine_conf}
<VirtualHost *:80>
    PassengerEnabled on
    ServerName redmine.domain.com
    ServerAdmin your_domain@domain.com
    ErrorLog logs/redmine_error_log
	
    DocumentRoot /var/www/redmine/public
    <Directory /var/www/redmine/public >
        Options Indexes ExecCGI FollowSymLinks
        Order allow,deny
        Allow from all
        AllowOverride all      
        #AllowOverride FileInfo
        Require all granted
        Options -MultiViews
    </Directory>
</VirtualHost>
EOF

	sudo apachectl restart
	echo -e "${c_azul}----- Concluído ----- ${c_fechamento}"
}

main
exit 0
