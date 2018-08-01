<img src="img/2000px-redmine_logo-svg.png" width="60%"/>

#  Instalação do Redmine Oracle Linux 7+

> Autor: 1T (T) Anders - DAbM

[TOC]

##  1. Introdução

Este **manual** destina-se a orientação de instalação do **Redmine** no sistema operacional **Oracle Linux 7+** com Banco de Dados MySQL.

**Pré requisitos:**
- Sistema Operacional: **Oracle Linux 7.3** com ao menos Interface gráfica selecionada.

###  1.1  Redmine
Redmine é um **software para gerenciamento** de projetos altamente flexível, é software livre (GNU General v2 – GPL). Suporta diversas funcionalidades primordiais ao gerenciamento e construção do projeto: gestão de versões, documentos, arquivos, repositórios. Planejamento, acompanhamento e workflow da execução das tarefas.

## 2. Instalação dos pacotes de dependências

Instalação dos pacotes de software básicos para configurações de ambiente e ferramentas de utilitário para compilar outros pacotes. 

###  2.1 Ajuste dos Repositórios

Antes de executar o script do shell, será necessário <u>habilitar</u> alguns repositórios na lista de repositórios publicos do **Oracle Linux 7**.

Com o usuário **root**, navegue até a pasta de repositórios.

```bash
# alterando diretivas repository
cd /etc/yum.repos.d
# vrf se tem o repoistório público do oracle
ls -lha public-yum-ol7.repo
# se ñ existir, ou desejar baixar um arquivo mais atualizado, basta fazer o download do repository

# For Oracle Linux 7, enter:
wget http://public-yum.oracle.com/public-yum-ol7.repo

# Após baixar para a pasta, Você pode ativar ou desativar repositórios no arquivo definindo o valor da diretiva enabled como 1 ou 0.
[23:45] root@localhost 
$ gedit public-yum-ol7.repo 
# ou
vim public-yum-ol7.repo
```

Dentro do arquivo: `/etc/yum.repos.d/public-yum-ol7.repo`, habilitar os seguintes repos conforme exemplo abaixo:

```ini
[ol7_optional_latest]
name=Oracle Linux $releasever Optional Latest ($basearch)
baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/optional/latest/$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[ol7_MySQL57]
name=MySQL 5.7 for Oracle Linux 7 ($basearch)
baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/MySQL57_community/$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[ol7_UEKR4]
name=Latest Unbreakable Enterprise Kernel Release 4 for Oracle Linux $releasever ($basearch)
baseurl=https://yum.oracle.com/repo/OracleLinux/OL7/UEKR4/$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[ol7_addons]
name=Oracle Linux $releasever Add ons ($basearch)
baseurl=https://yum.oracle.com/repo/OracleLinux/OL7/addons/$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[ol7_developer_EPEL]
name=Oracle Linux $releasever Development Packages ($basearch)
baseurl=https://yum.oracle.com/repo/OracleLinux/OL7/developer_EPEL/$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1
```
###  2.2 Instalação dos Pacotes

Pacotes necessários para a compilação e instalação do Redmine:
```bash
# Instalação das dependências

echo -e '\033[01;33m>>>>>>>> Instalando dependências <<<<<<<<\033[00m'
# instalando todos os pacotes que o redmine depende:
yum groups mark install "Development Tools"
yum groups mark convert "Development Tools"
yum -y groupinstall "Development Tools"

yum -y install gcc curl curl-devel gcc-c++ ImageMagick ImageMagick-devel ntp \
autoconf automake binutils make openssl openssl-devel zlib zlib-devel glibc \
glibc-devel libgcc expat-devel apr-util-devel mysql-devel \
ftp wget patch readline readline-devel libyaml-devel libffi-devel \
bzip2 libtool bison sqlite-devel \
perl perl-devel pcre pcre-devel libcurl-devel

echo -e '\033[00;36m----- Concluído ----- \033[00m'
```


### 2.3 Desabilitar o SELinux

O Oracle Linux possui  um recurso de segurança avançado chamado de **SELinux** no momento da instalação do SO. Faz-se necessário **desativar** para que a instalação prossiga sem problemas, após a instalação pode ativar novamente.

```bash
echo -e "\033[01;33m>>>>>>>> Desabilitando SELINUX e firewall <<<<<<<<\033[00m"

sudo systemctl stop firewalld
sudo systemctl disable firewalld

sudo setenforce 0
sudo sed -i "s/SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config
sudo sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

echo -e '\033[00;36m----- Concluído ----- \033[00m'

echo -e "\033[01;33m>>>>>>>> Reiniciando o Sistema para aplicar alterações <<<<<<<<\033[00m"
systemctl reboot
```

### 2.4 (Opcional) Habilitando o Firewall após toda a instalação do Redmine

Recomenda-se a execução deste tópico quando **terminar** o processo de **instalação e configuração do Redmine** no Oracle Linux 7+.
```bash
systemctl start firewalld.service
systemctl enable firewalld.service

setenforce Permissive
sudo sed -i "s/SELINUX=disabled/SELINUX=permissive/g" /etc/selinux/config
#habilitando algumas portas 
firewall-cmd --add-port=22/tcp --permanent
firewall-cmd --add-port=22/tcp --permanent
firewall-cmd --add-port=3052/tcp --permanent
firewall-cmd --add-port=3052/udp --permanent
firewall-cmd --add-port=6547/udp --permanent
firewall-cmd --add-port=6547/tcp --permanent
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --add-port=5500/tcp --permanent
firewall-cmd --add-port=10051/tcp --permanent
firewall-cmd --add-port=10050/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --add-port=9418/tcp --permanent
firewall-cmd --add-port=2049/tcp --permanent
firewall-cmd --add-port=2049/udp --permanent

echo -e "\033[01;33m>>>>>>>> Reiniciando o Sistema para aplicar alterações <<<<<<<<\033[00m"
systemctl reboot
```

## 3. Instalação do Banco de Dados - MySQL

O MySQL é o SGBD de código aberto mais popular, o MySQL tem alta velocidade, estabilidade e facilidade de uso, portabilidade, operando em vários sistemas operacionais oferecem um grande sistema é muito poderoso funções de utilidade.

### 3.1 Instalação do MySQL

```bash
echo -e "\033[01;33m>>>>>>>> Instalando Mysql no Servidor <<<<<<<<\033[00m"
	
# o script abaixo foi tornado obsoleto no OEL 7.3 e substituido pelos community
#sudo yum -y install mariadb-server mariadb mariadb-devel
sudo yum -y install mysql-community-server mysql-community-client mysql-community-devel

sudo chkconfig mysqld on
sudo service mysqld start
sudo service mysqld status

echo -e '\033[00;36m----- Concluído ----- \033[00m'
```

Após a instalação do pacote do banco de dados o sistema **gera** automaticamente uma **senha do usuário root** do MySQL que precisa ser usada para configruar o acesso e criação do banco do Redmine.

Durante o processo de instalação, uma **senha temporária** é gerada para o usuário **root** do MySQL, sua localização encontra-se no arquivo `/var/log/mysqld.log` na expressão **'temporary password'** que precisa ser usada para configruar o acesso e criação do banco do Redmine.

```bash
# para recuperar a senha temporária do mysql
cat /var/log/mysqld.log | grep 'temporary password'

# comando para configurar o mysql
mysql_secure_installation

Securing the MySQL server deployment.
Enter password for user root: ****** <- senha temporária
...

#(A senha existente para a raiz da conta do usuário expirou. Por favor, defina uma nova senha.)
The existing password for the user account root has expired. Please set a new password.
New password: 
Re-enter new password:

#(Alterar a senha do root?)
Change the password for root ? ((Press y|Y for Yes, any other key for No) : no

#(Remover usuários anônimos?)
Remove anonymous users? (Press y|Y for Yes, any other key for No) : y

#(Desativar login root remotamente?)
Disallow root login remotely? (Press y|Y for Yes, any other key for No) : no

#(Remover banco de dados de teste e acesso a ele?)
Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y

#(Recarregue as tabelas de privilégios agora?)
Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
```


![](img/2.PNG)


![](img/3.PNG)

### 3.2 Criação da Base do Redmine

```bash
# conectar no MySQL
mysql -uroot -p

mysql> CREATE DATABASE redmine CHARACTER SET utf8;
mysql> GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost' IDENTIFIED BY 'Senha@2018';
mysql> FLUSH PRIVILEGES;
mysql> \q;
```
![Fi](img/4.PNG)

Acessando com o usuario **redmine** para teste de conexão:

```mariadb
# conectar no MySQL
mysql -uredmine -p
Enter password: Redmine@2018

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| redmine            |
+--------------------+
2 rows in set (0,00 sec)

mysql> exit;
```

## 4. Instalação do Ruby

Ruby é uma linguagem de programação orientada a objetos, com sintaxe herdada de Ada e Perl. Também compartilhar alguns recursos com Python, Lisp, Dylan e CLU.

Fornece padrões de programação, incluindo programação funcional, orientado a objetos, imperativo, reflexivo, utiliza dinâmica variável e gerenciamento automático de memória.

### 4.1 Pacotes do RVM e Ruby 

```bash
echo -e "\033[01;33m>>>>>>>> Instalando Ruby no Servidor <<<<<<<<\033[00m"

#instale a chave pública mpapis usada para verificar o pacote 
#de instalação para garantir a segurança .
curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import -

# --------------------------------------------------------------------
# baixar e instalar o gerenciador de pacotes do ruby 
\curl -sSL https://get.rvm.io | sudo bash -s stable
# caso você não tenha conseguido instalar o comando acima, provavelmente foi devido
# as suas restrições de proxy, caso você possua na sua empresa/Organização.
# Nesta situação você precisa configruar o proxy para linha de comando para que os seguintes
# aplicativos do linux tenham acesso:
# curl ,yum, wget e git
# para configurar o proxy, disponibilizei um script para o Oracle Linux 7+ que configura
# basta você substituir os dados: user_proxy, user_passwd, url_proxy, port_proxy e user_logado
# links dos scripts: 
# https://gist.github.com/carlosanders/0cc57800eb8f1e7244d06503c7426750
# https://gist.github.com/carlosanders/547c7da77bb1f258911ea8b35926e9ca
# nao esqueça de verificar se também o git está configurado com o proxy.
# se não estiver proceda sua configuração conforme comados abaixo:
git config --global http.proxy http://user_proxy:user_passwd@url_proxy:port_proxy
git config --global https.proxy http://user_proxy:user_passwd@url_proxy:port_proxy
git config --global http.sslverify false
# --- só execute o passo abaixo se você teve problemas com o proxy.
# após essas configurações proceda novamene a instalação do rvm pelo curl:
# link de referencia: https://rvm.io/workflow/proxy
curl -sSL https://get.rvm.io | sudo -E bash -s stable
# --------------------------------------------------------------------
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

echo -e '\033[00;36m----- Concluído ----- \033[00m'
```

## 5. Instalando o Apache

Para este manual o Redmine usará o Apache como servidor web, rodando o ruby que foi instalado.

```bash
echo -e "\033[01;33m>>>>>>>> Instalando Apache no Servidor <<<<<<<<\033[00m"
	
sudo yum -y install httpd httpd-devel apr-devel mod_ssl

sudo systemctl enable httpd
sudo chkconfig httpd on
sudo apachectl start
sudo service httpd start

# caso já tenha habilitado o firewall, se não for usar, ignore
firewall-cmd --zone=zone --add-port=80/tcp
firewall-cmd --permanent --zone=zone --add-port=80/tcp

echo -e '\033[00;36m----- Concluído ----- \033[00m'
```

### 5.2 Configurando Passenger

Agora tem que compilar o módulo de `passenger` para o apache, quando for solicitado a linguagem, selecione apenas **ruby**.  Ressalta-se que ao rodar este comando será exibido para adicionar o `LoadModule passenger_module` do ruby para ser carregado no arquivo de configuração do Apache.

```bash
# comando para compilar o passenger
passenger-install-apache2-module

Welcome to the Phusion Passenger Apache 2 module installer, v5.3.3.

This installer will guide you through the entire installation process. It
shouldn't take more than 3 minutes in total.
...
Which languages are you interested in?

Use <space> to select.
If the menu doesn't display correctly, press '!'

‣ ⬢  Ruby
  ⬢  Python
  ⬡  Node.js
  ⬡  Meteor
....
--------------------------------------------
Almost there!

Please edit your Apache configuration file, and add these lines:

LoadModule passenger_module /usr/local/rvm/gems/ruby-2.3.3/gems/passenger-5.3.3/buildout/apache2/mod_passenger.so
  <IfModule mod_passenger.c>
    PassengerRoot /usr/local/rvm/gems/ruby-2.3.3/gems/passenger-5.3.3
    PassengerDefaultRuby /usr/local/rvm/gems/ruby-2.3.3/wrappers/ruby
  </IfModule>

After you restart Apache, you are ready to deploy any number of web
applications on Apache, with a minimum amount of configuration!

Press ENTER when you are done editing.

--------------------------------------------
Validating installation...

 * Checking whether this Passenger install is in PATH... ✓
 * Checking whether there are no other Passenger installations... ✓
 * Checking whether Apache is installed... ✓
 * Checking whether the Passenger module is correctly configured in Apache... ✓

Everything looks good. :-)
```

Criando o arquivo `00-passenger.conf` para ser adicionado na configuração do **Apache**:

```bash
passenger-config --root
# A saída do comando retorna o caminho da raiz do módulo do passenger
## Exemplo ##
/usr/local/rvm/gems/ruby-2.3.3/gems/passenger-5.1.2

# criação do arquivo
vim /etc/httpd/conf.modules.d/00-passenger.conf
```

O **conteúdo** do arquivo será algo **<u>parecido</u>** como o exemplo abaixo, este não signifca que será o mesmo conteúdo do seu arquivo, portanto sugiro que extraia o conteúdo do **passo acima** em que você instalou o `passenger-install-apache2-module` este programa gera o conteúdo do para que você copie e cole no arquivo `00-passenger.conf`. Ressalto que o seu conteúdo estará após a seguinte linha: ***Please edit your Apache configuration file, and add these lines***

```ruby
LoadModule passenger_module /usr/local/rvm/gems/ruby-2.3.3/gems/passenger-5.3.3/buildout/apache2/mod_passenger.so
   <IfModule mod_passenger.c>
     PassengerRoot /usr/local/rvm/gems/ruby-2.3.3/gems/passenger-5.3.3
     PassengerDefaultRuby /usr/local/rvm/gems/ruby-2.3.3/wrappers/ruby
   </IfModule>
```

![](img/9.PNG)

Após salvar o arquivo, será necessário reiniciar o apache.

```bash
service httpd restart
```

### 5.3 Configurando o VirtualHost

```bash
# crie um arquivo
touch /etc/httpd/conf.d/redmine.conf
# edit para coltar o trecho abaixo
vim /etc/httpd/conf.d/redmine.conf

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

# Reinicie o Apache
service httpd restart
```

## 6. Instalação do Redmine 3.3.0

O Redmine programa principal do sistema de **gerenciamento de projeto**, devemos baixar e instalar o programa a partir do [site do Redmine](http://www.redmine.org/).

### 6.1 Baixando o pacote zipado do site do Redmine

```bash
echo -e "\033[01;33m>>>>>>>> Instalando Redmine 3.3.0 no Servidor <<<<<<<<\033[00m"

cd /var/www
# para remover caso já exista uma pasta com o nome redmine
sudo rm -rf /var/www/redmine/
# cria uma pasta com o nome redmine, se não fizer esta etapa, ocorrerá um erro na etapa posterior
sudo mkdir -p /var/www/redmine/
wget -nv http://www.redmine.org/releases/redmine-3.3.0.tar.gz -O - | tar -zvxf - --strip=1 -C redmine
# caso queira remover o arquivo baixado execute o comando abaixo
rm -rf redmine-3.3.0.tar.gz
# alterando o dono do arquivo para o usuário apache
chown -R apache. redmine
# acessando o arquivo redmine
cd redmine
# copiando o arquivo e renomeando
cp config/database.yml.example config/database.yml
# abrindo o vim para editar o arquivo
vim /var/www/redmine/config/database.yml
# ou
#gedit /var/www/redmine/config/database.yml

echo -e '\033[00;36m----- Concluído ----- \033[00m'
```

![](img/6.PNG)

### 6.2 Configuração do Arquivo do Redmine

```bash
vim /var/www/redmine/config/database.yml
# ou
#gedit /var/www/redmine/config/database.yml
```

Dentro do arquivo altere a configurações de acesso ao banco:

```yaml
# Configure o usuario e senha
production:
    adapter: mysql2
    database: redmine
    host: localhost
    username: usuario-de-acesso-redmine-do-BD
    password: "Senha-do-usuario-redmine-do-BD"
    encoding: utf8
    
# exemplo
production:
  adapter: mysql2
  database: redmine
  host: localhost
  username: redmine
  password: Senha@2018
  encoding: utf8
```

![](img/7.PNG)

### 6.3 (Opcional) Configuração Htaccess e FastCGI

**Opcionalmente** você pode configurar os parâmetros de `.htaccess` e `dispatch.fcgi`para ter uma performance a mais no redmine na medida que sua aplicação crescer. 

Os arquivos `.htaccess` (ou "arquivos de configuração distribuída") oferecem um meio de fazer mudanças nas configurações por-diretório. Um arquivo, contendo uma ou mais diretrizes de configurações, é colocado em um diretório em particular, e as diretrizes se aplicam para aquele diretório e todos os seu subdiretórios subseqüentes. 

O **Common Gateway Interface (CGI)** é um “acordo” entre os servidores [*HTTP*](https://klauslaube.com.br/tag/http.html) e as aplicações *Web*. Por baixo dos panos, o servidor *Web* vai informar uma série de parâmetros para o seu programa, e é dever do seu programa entregar uma resposta “bem formada” para o servidor *Web*.

Isso quer dizer que, para o *CGI*, não importa qual linguagem ou banco de dados o seu programa está usando. Para ele, importa a passagem dos parâmetros e a resposta. Logo, é perfeitamente possível desenvolvermos nossas páginas até mesmo com a linguagem **C**. O ***FastCGI*** segue o mesmo princípio do ***CGI***, mas possui uma série de particularidades (e vantagens) em relação ao seu “**primogênito**” . Para mais detalhes acesse: [Entendendo o CGI, FastCGI e WSGI](https://klauslaube.com.br/2012/11/02/entendendo-o-cgi-fastcgi-e-wsgi.html).

```bash
cd /var/www/redmine/public

#renomeando os modelos de arquivo do redmine
cp dispatch.fcgi.example dispatch.fcgi
cp htaccess.fcgi.example .htaccess

# instalando o mod_fcgid
yum -y install mod_fcgid
# se por uma acaso, após habilitar os repositórios citados no item 2.1, não tenha encontrado o pacote "mod_fcgid", então instale o repostório do Pacotes Adicionais para Enterprise Linux (EPEL) da distribuição do Fedora que podemos usar no OEL 7+
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# repita a instalacao caso nao tenha conseguido anteriormente
yum -y install mod_fcgid
```

### 6.4 (Opcional) Ajustando o arquivo de configuração do Redmine 

Esta etapa também é <u>opcional</u>, mas **altamente recomendada**, pois permite que separemos os arquivos que serão enviados para o diretório da Ferramenta Redmine. Dessa forma fica **desacoplado** os arquivos do uso da ferramenta com os arquivos da aplicação, facilitando a gerência para uma posterior **atualização do Redmine**.

```bash
echo -e "\033[01;33m>>>>>>>> Configurando o Redmine 3.3.0 no Servidor <<<<<<<<\033[00m"

# Criando um usuário do linux chamado redmine no diretorio /opt/redmine
adduser --home /opt/redmine --shell /bin/bash -c 'Redmine application' redmine
install -d -m 755 -o redmine -g redmine /opt/redmine
# colocando o usu: redmine no grupo do apache
usermod -a -G apache redmine
# criando o arquivo files para ser desacoplado
mkdir -p /opt/redmine/files
# colocando o usu: redmine no grupo do apache
chown -R apache:apache /opt/redmine
chmod -R 777 /opt/redmine
# senha para o novo usuario
passwd redmine
#usermod -p redmine redmine

#renomeando o arquivo de configuração do redmine
cd /var/www/redmine/public
cp /var/www/redmine/config/configuration.yml.example /var/www/redmine/config/configuration.yml

#sudo su - redmine

echo -e '\033[00;36m----- Concluído ----- \033[00m'
```

Editando o arquivo `configuration.yml`, conforme exemplo abaixo:

```yaml
vim /var/www/redmine/config/configuration.yml

# trecho do arquivo

# Absolute path to the directory where attachments are stored.
# The default is the 'files' directory in your Redmine instance.
# Your Redmine instance needs to have write permission on this
# directory.
# Examples:
# attachments_storage_path: /var/redmine/files
# attachments_storage_path: D:/redmine/files
attachments_storage_path: /opt/redmine/files
```

### 6.5 Instalamos os bundles  e populando o banco de dados

```bash
# instalando os pacotes
bundle install
# gerando o token
RAILS_ENV=production rake generate_secret_token
# populando o DB com conteúdo padrão
RAILS_ENV=production rake db:migrate
# carregando as variáveis para usar a linguagem padrao
RAILS_ENV=production rake redmine:load_default_data
```
![](img/8.PNG)

## 7. Testando o Redmine no Navegador web

Após concluído todas as 6 etapas, iremos testar se a aplicação funcionará no navegador web.

### 7.1 Abrindo o Redmine

Por padrão na instalação o Redmine vem com  um usuário **admin** com a senha **admin**. Acesse o navegador web e acesse o **IP do seu servidor**, no meu exemplo é o **IP 192.168.0.113**, ou se preferir dentro de seu servidor acesse: `http://localhost`ou `http://127.0.0.1`.

![Redmine](img/redmine1.PNG)

## 8. Automatização e Referências

### 8.1 Scripts para otimizar a instação do Redmine

Para facilitar foi desenvolvido alguns **scripts de shell** para serem executados e auxiliar na instalação do redmine, os scripts encontram-se em anexo ao manual de instalação.

#### 8.1.1 Passos para automatização da instalação do Redmine 3.3.0

Os **scripts** disponibilizados foram testados com **êxito** no ambiente de virtualização, caso deseje alterar qualquer subrotina dos scripts, fique a vontade, só peço que deixe os comentário do **Autor**.

- [ ] Passo 1 - Execute o `redmine-p1-anders.sh`. Neste passo **não** terá **interatividade** com o usuário.

```bash
#permissão de execução no arquivo
chmod +x redmine-p1-anders.sh
# ao executar este script nenhuma intervenção manual será necessária
# o OEL irá reiniciar após as instalaçãoes das rotinas:

# vrf_modo_root -> VRF se está com o modo root e atualiza os repos
# tools_go -> instalações das dependencias
# config_disable_selinux_go -> desabilitando o SELinux e Firewall
# mysql_go -> instalação do MySQL
# apache_go -> instalação do Apache
bash redmine-p1-anders.sh
#ou
./redmine-p1-anders.sh
```
- [ ] Passo 2 - Execute o `redmine-p2-anders.sh`. Neste passo **terá interatividade** com o usuário, **fique atento**.

```bash
#permissão de execução no arquivo
chmod +x redmine-p2-anders.sh
# ao executar este script nenhuma intervenção manual será necessária
# o OEL irá reiniciar após as instalaçãoes das rotinas:

# config_mysql_go -> Configura segurança do MySQL e altera senha do root -> interatividade
# mysql_DB_create_go -> criação do BD do Redmine, será lido arquivo:'redmine.sql'
#                       altera para suas necessidades.
# ruby_233_go -> Instalando RVM e Ruby 2.3.3 e gems
# install_passenger_go -> Instalando o Passenger. -> interatividade
# virtual_host_apache_go -> Configurando o VirtualHost do Apache, caso deseje altera fique
#                           a vontade
bash redmine-p2-anders.sh
#ou
./redmine-p2-anders.sh
```
Conteúdo do arquivo: `redmine.sql`, executado na subrotina `mysql_DB_create_go` do **Passo 2**.
```sql
CREATE DATABASE redmine CHARACTER SET utf8;
GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost' IDENTIFIED BY 'Senha@2018';
FLUSH PRIVILEGES;
```

- [ ] Passo 3 - Execute o `redmine-p3-anders.sh`. Neste passo **terá interatividade** com o usuário, **fique atento**.

```bash
#permissão de execução no arquivo
chmod +x redmine-p3-anders.sh
# ao executar este script nenhuma intervenção manual será necessária
# o OEL irá reiniciar após as instalaçãoes das rotinas:

# redmine_330_go -> Instalando Redmine 3.3.0 no Servidor. -> interatividade
# fast_cgi_go -> Instalando o FastCGI e htaccess do redmine. Passo Opcional
# config_redmine_go -> Editando o Arquivo 'configuration.yml' Redmine. -> interatividade
# populando_bd_redmine_go -> Populando o BD do Redmine. -> interatividade
bash redmine-p3-anders.sh
#ou
./redmine-p3-anders.sh
```
### 8.2 Referências e Links

- http://blog.psyreactor.com.ar/instalar-redmine-centos-7/
- http://cctg.blogspot.com/2017/08/centos-7-redmine-333.html
- https://www.rosehosting.com/blog/how-to-install-redmine-on-centos-7/
- https://rvm.io/rvm/install
- https://fedoraproject.org/wiki/EPEL#How_can_I_use_these_extra_packages.3F
- https://www.rosehosting.com/blog/how-to-install-redmine-on-centos-7/
- https://respirandolinux.com.br/2018/04/02/redmine-instalacao-de-gerenciador-de-projetos-com-software-livre-parte-1/

