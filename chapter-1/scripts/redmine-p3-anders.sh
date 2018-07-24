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
	redmine_330_go
    fast_cgi_go
    config_redmine_go
    populando_bd_redmine_go
	echo -e "${c_red_b_white}----- Provisionamento Concluído ----- ${c_fechamento}"
}

#sub-rotina
redmine_330_go() {
	echo -e "${c_amarelo} >>>>>>>> Instalando Redmine 3.3.0 no Servidor <<<<<<<< ${c_fechamento}"
    cd /var/www
	sudo rm -rf /var/www/redmine/
	sudo mkdir -p /var/www/redmine/
	wget -nv http://www.redmine.org/releases/redmine-3.3.0.tar.gz -O - | tar -zvxf - --strip=1 -C /var/www/redmine

	rm -rf redmine-3.3.0.tar.gz
	mv redmine-3.3.0 redmine
	chown -R apache. redmine
	
	cp /var/www/redmine/config/database.yml.example /var/www/redmine/config//database.yml

	echo -e "${c_amarelo} Será editado o arquivo 'database.yml' \
	Entre o usuário e a senha criado no MySQL para o Redmine.${c_fechamento}"

	read -p "Digite '@' para abrir o arquivo: " -d '@' 

	vim /var/www/redmine/config/database.yml
	# ou
	#gedit /var/www/redmine/config/database.yml
    echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

#sub-rotina
fast_cgi_go() {
    echo -e "${c_amarelo} >>>>>>>> Instalando Redmine 3.3.0 no Servidor <<<<<<<< ${c_fechamento}"
    cd /var/www/redmine/public

    #renomeando os modelos de arquivo do redmine
    cp /var/www/redmine/public/dispatch.fcgi.example /var/www/redmine/public/dispatch.fcgi
    cp /var/www/redmine/public/htaccess.fcgi.example /var/www/redmine/public/.htaccess

    # instalando o mod_fcgid
    yum -y install mod_fcgid

    # se por uma acaso, após habilitar os repositórios citados no item 2.1, não tenha encontrado o pacote "mod_fcgid", então instale o repostório do Pacotes Adicionais para Enterprise Linux (EPEL) da distribuição do Fedora que podemos usar no OEL 7+
    #yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

    # repita a instalacao caso nao tenha conseguido anteriormente
    #yum -y install mod_fcgid
    echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

#subrotina
config_redmine_go() {
    echo -e "${c_amarelo} >>>>>>>> Editando o Arquivo 'configuration.yml' Redmine <<<<<<<< ${c_fechamento}"
    # Criando um usuário do linux chamado redmine no diretorio /opt/redmine
    adduser --home /opt/redmine --shell /bin/bash -c 'Redmine' redmine
    install -d -m 755 -o redmine -g redmine /opt/redmine
    # colocando o usu: redmine no grupo do apache
    usermod -a -G apache redmine
    # criando o arquivo files para ser desacoplado
    mkdir -p /opt/redmine/files
    # colocando o usu: redmine no grupo do apache
    chown -R apache:apache /opt/redmine
    chmod -R 777 /opt/redmine
    # senha para o novo usuario
    read -p "Será solictitado a senha do usuário redmine... digite qualquer tecla para continuar..."
    passwd redmine
    #usermod -p redmine redmine

    #renomeando o arquivo de configuração do redmine
    #cd /var/www/redmine/public
    cp /var/www/redmine/config/configuration.yml.example /var/www/redmine/config/configuration.yml
    
    echo -e "${c_azul}Será editado o arquivo 'configuration.yml' digite:${c_fechamento} ${c_amarelo}attachments_storage_path: /opt/redmine/files.${c_fechamento}"
    read -p "Digite '@' para abrir o arquivo: " -d '@'

    vim /var/www/redmine/config/configuration.yml

    echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

#sub-rotina
populando_bd_redmine_go() {
    echo -e "${c_amarelo} >>>>>>>> Populando o BD do Redmine <<<<<<<< ${c_fechamento}"
    # instalando os pacotes
    (cd /var/www/redmine && bundle install)    
    # gerando o token
    #RAILS_ENV=production rake generate_secret_token
    (cd /var/www/redmine && RAILS_ENV=production rake generate_secret_token)
    # populando o DB com conteúdo padrão
    #RAILS_ENV=production rake db:migrate
    (cd /var/www/redmine && RAILS_ENV=production rake db:migrate)
    # carregando as variáveis para usar a linguagem padrao
    #RAILS_ENV=production rake redmine:load_default_data
    (cd /var/www/redmine && RAILS_ENV=production rake redmine:load_default_data)
    
    service httpd restart
    echo -e "${c_azul} ----- Concluído ----- ${c_fechamento}"
}

main
exit 0
