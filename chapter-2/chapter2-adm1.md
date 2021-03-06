<img src="img/2000px-redmine_logo-svg.png" width="50%"/>
#  Administração do Redmine - Parte 1

> Autor: 1T (T) Anders - DAbM

[TOC]

##  1. Introdução

Este documento destina-se a orientação de **administração** do **Redmine** no sistema operacional **Oracle Linux 7+** com Banco de Dados MySQL.

**Pré requisitos:**
- Sistema Operacional: **Oracle Linux 7.3+** com ao menos Interface gráfica selecionada.

## 2. Instalação de Plugins no Redmine (Opcional)

Nesta seção iremos apresentar alguns plugins úteis para utilização no Redmine 3.3.0. Para instalar plugins no redmine basta seguir as orientações no link http://www.redmine.org/projects/redmine/wiki/Plugins. Iremos mostrar de um modo geral como funciona para instalar plugins:

#### Plugins - Lista de plugins

Uma lista completa de plugins Redmine disponív eis pode ser encontrada no [Diretório de Plugins](http://www.redmine.org/plugins). 

#### Instalando um plugin qualquer...

**Não precisa executar os comandos abaixo**, pois é um `exemplo` de uma instalação de um plugin qualquer.

1. Copie para o diretório ` /path/to/redmine/plugins`(Redmine 2.x) o plugin desejado ou também poderá copiar o plugin direto do GitHub da seguinte forma: `git clone git://github.com/user_name/name_of_the_plugin.git`, basta fazer as mudanças necessárias.

2. Se o plug-in exigir uma migração, execute o seguinte comando `/path/to/redmine/`para atualizar seu banco de dados (faça um backup do banco de dados antes).

   2.1. Para Redmine 2.x:

```
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

3. Reinicie Redmine

Agora você deve conseguir ver a lista de **plugins** em *Administração -> Plugins* e configurar o plug-in recém-instalado (se o plug-in precisar ser configurado). Para mais detalhes acesse o site [Install Plugins Redmine](http://www.redmine.org/projects/redmine/wiki/Plugins).

### 2.1 Instalando plugin - Redmine Image Clipboard Paste

Plugin para redmine que permite colar dados de imagem da área de transferência diretamente no campo de entrada de comentários em um novo chamado ou comentário. A imagem receberá um nome de arquivo aleatório e será adicionado como um anexo e também inserido no texto do comentário usando a linguagem de marcação do Redmine.  Para mais detalhes acesse: https://github.com/credativUK/redmine_image_clipboard_paste

Para instalar o plugin, clone do github e migre o banco de dados: 

```bash
cd /var/www/redmine
# clonando e copiando para o diretorio especifico
git clone git://github.com/credativUK/redmine_image_clipboard_paste.git plugins/redmine_image_clipboard_paste
# dentro da raiz do redmine execute
# volta para pagina do redmine
cd /var/www/redmine
bundle install
# depois instale o plugin
[18:04] root@localhost /var/www/redmine
$ bundle exec rake redmine:plugins:migrate RAILS_ENV=production
Migrating redmine_image_clipboard_paste (Image Clipboard Paste)...
# agora reinicie o servidor httpd
systemctl restart httpd.service
#ou
service httpd restart
```

Para desinstalar o plug-in, migre o banco de dados de volta e remova o plug-in: 

```bash
# navegue até o redmine
cd /var/www/redmine
# execute o comando para migrar o bd de volta
bundle exec rake redmine:plugins:migrate NAME=redmine_image_clipboard_paste VERSION=0 RAILS_ENV=production
# remova a pasta do plugin
rm -rf plugins/redmine_image_clipboard_paste
```

### 2.2 Instalando plugin - Redmine Embedded Video.

Plugin Embedded Video serve para fazer visualizar vídeos no Wiki do Redmine, muito útil  para criar Wikis de tutoriais em vídeos. Para mais informações acesse [Home Page](http://www.redmine.org/plugins/redmine_embedded_video)ou [GitHub](https://github.com/cforce/redmine_embedded_video).

```bash
# navegue até o redmine
cd /var/www/redmine/plugins
# caso exista algum pasta antiga do plugin
rm -rf redmine_embedded_video
# crie a pasta
mkdir -p redmine_embedded_video
# baixe do github
wget -nv https://github.com/cforce/redmine_embedded_video/archive/master.tar.gz -O - | tar -zvxf - --strip=1 -C redmine_embedded_video
# volte para raiz do redmine e execute
# volta para pagina do redmine
cd /var/www/redmine/
[18:36] root@localhost /var/www/redmine
$ bundle exec rake redmine:plugins:migrate RAILS_ENV=production
Migrating redmine_embedded_video (Redmine Embedded Video)...
Migrating redmine_image_clipboard_paste (Image Clipboard Paste)...
# reincie o httpd
service httpd restart
```

Para usar o plugi basta no documento do wiki usar da seguint maneira:

```markdown
# Sintaxe:
{{video(<ATTACHEMENT>|<URL>|<YOUTUBE_URL>[,<width>,<height>])}}

Para URLs externos, basta usar o URL completo do vídeo:
{{video(http://youtu.be/o9aA9wCQ9co)}}

Você pode antes de largura e altura de vídeo:
{{video(http://youtu.be/o9aA9wCQ9co[640,480])}}

Para escala relativa, basta digitar um valor:
{{video(http://youtu.be/o9aA9wCQ9co[640,])}}

Para vídeos anexados, não use nenhum caminho na frente do nome do arquivo do anexo:
{{video(History.flv)}}
{{video(vid.swf)}}
```

### 2.3 Instalando plugin - Line numbers Redmine.

Plugin Redmine que ativa numeração de linha em blocos de código e adiciona um botão de alternância para ligar/desligar. A alternância é útil se você quiser copiar e colar o código de um site Redmine sem copiar os números de linha. [Home Page Pugin](https://github.com/cdwertmann/line_numbers).

```bash
# navegue até o redmine
cd /var/www/redmine/plugins
rm -rf line_numbers
mkdir -p line_numbers
wget -nv https://github.com/cdwertmann/line_numbers/archive/master.tar.gz -O - | tar -zvxf - --strip=1 -C line_numbers
# basta reinicar o servidor apache
service httpd restart
```

### 2.4 Instalando plugin - Gist Embed Redmine.

Plugin Redmine para adicionar algum conteúdo interessante di **gist** do github. [Home Page](https://github.com/dergachev/redmine_gist).

```bash
# navegue até o redmine
cd /var/www/redmine/plugins
rm -rf redmine_gist
mkdir -p redmine_gist
wget -nv https://github.com/dergachev/redmine_gist/archive/master.tar.gz -O - | tar -zvxf - --strip=1 -C redmine_gist
# basta reinicar o servidor apache
service httpd restart
```

### 2.5 Instalando plugin para o SCRUM.

Neste tópico irei demonstrar **3 execelentes plugins** para trabalhar com o SCRUM no Redmine 3+. Existem outros plugins para o SCRUM e Kanban, fique a vontade.

#### 2.5.1 Plugin Scrum2b - [GitHub](https://github.com/scrum2b/scrum2b)

**Scrum2B Tool** é um aplicativo de Gerenciamento de Projetos, especializado em projetos Scrum/Ágil e de Desenvolvimento de Software, sendo utilizado e mantido pela [ScrumTobe Software]( <https://www.facebook.com/ScrumTobe> ). O Scrum2B Tool é construído como um plugin do [www.redmine.org](http://www.redmine.org/), livre para usar. 

Passos para instalação:

```bash
# navegue até o redmine
cd /var/www/redmine/plugins
#clonando o projeto
git clone https://github.com/scrum2b/scrum2b.git
# volta para pagina do redmine
cd /var/www/redmine/
# instalando dependencias
bundle install
# executando a migração
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
# basta reinicar o servidor apache
service httpd restart
```

Para aprender a usar o plugin sugiro um estudo nos sites: 

- http://agiledesk.herokuapp.com/projects/it-weshop-helpdesk/roadmap;
- https://github.com/scrum2b/scrum2b/wiki/Installation-Guide
- https://github.com/scrum2b/scrum2b/wiki/Screens

#### 2.5.2 Redmine SCRUM plugin - [Redmine Page Plugin](http://www.redmine.org/plugins/scrum-plugin#Sprint-board-screenshot)

Um dos **melhores** plugins de SCRUM para o redmine, ele é Open Source, e mantido pelo desenvolvedor [Emilio Gonzáles](https://www.patreon.com/ociotec), que pede contribuição para que gostaria de ajudá-lo. O plugin encontra-se na **versão 0.18.0 released** já com suporte ao **redmine 3.4+**, conforme [notícia no site de release do plugin](https://redmine.ociotec.com/news/15). 

O [Wiki do plugin](https://redmine.ociotec.com/projects/redmine-plugin-scrum/wiki) explica como instalar, configurar o plugin. Para usar com o plugin sugiro acessar o link do redmine do desenvolvedor para ver [como trabalhar com o SCRUM no Redmine](https://redmine.ociotec.com/projects/redmine-plugin-scrum/wiki/How_it_works).

Para instalar siga os passos:

```bash
# navegue até o redmine
cd /var/www/redmine/plugins
rm -rf scrum
mkdir -p scrum
wget -nv https://redmine.ociotec.com/attachments/download/476/scrum-v0.18.0.tar.gz -O - | tar -zvxf - --strip=1 -C scrum
# volta para pagina do redmine
cd /var/www/redmine/
# executando a migração
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
# basta reinicar o servidor apache
service httpd restart
```

#### 2.5.3 Redmine Agile Plugin: One tool to manage all your projects - [Redmine Agile](http://www.redmine.org/plugins/redmine_agile)

Uma excelente ferramenta para gerenciar os projetos em SCRUM. Este plugin tem uma [**versão free**](https://www.redmineup.com/pages/plugins/agile) que é a que iresmos instalar e outras [versões pagas](https://www.redmineup.com/pages/plugins/agile/pricing). Permite o uso das melhores práticas ágeis de qualquer metodologia - Scrum, Kanban ou misto. 

Passos para instalação da **versão free**, temos que cadastrar o email e baixar pelo email o plugin e depois copiar para o servidor - [Link de instalação](https://www.redmineup.com/pages/help/agile/installing-redmine-agile-plugin-on-linux). Para usar o plugin sugiro que acesse o [Getting Started do Plugin](https://www.redmineup.com/pages/help/agile).

```bash
# copiando da maquina local para o servidor
scp redmine_agile-1_4_6-light.zip root@192.168.0.103:/var/www/redmine/plugins
root@192.168.0.103's password: ****
# acessando o servidor
C:\Users\bryan\Downloads                                
λ ssh root@192.168.0.103                                
root@192.168.0.103's password: **** 
# no servidor descompacte com o unzip
[23:29] root@localhost /var/www/redmine/plugins
$ unzip redmine_agile-1_4_6-light.zip
# volte para a pagina do redmine
cd /var/www/redmine
#Install required gems
bundle install --without development test --no-deployment
# Migre as tabelas do plugin
bundle exec rake redmine:plugins NAME=redmine_agile RAILS_ENV=production
#Para Phussion Passenger basta tocar em restart.txtarquivo
touch tmp/restart.txt
# basta reinicar o servidor apache
service httpd restart
```

### 2.6 Instalando plugin redmine_more_code - [Github](https://github.com/HugoHasenbein/redmine_more_code)

Plugin para Redmine que permitirá a visualização de código de **cfc, cfm, clj, cpp, cu, cxx, c ++, C, dpr, gemspec, go, groovy, gvy, haml, hpp, h ++, html.bb, js, lua, mab, pas, phtml camarão, py3, raydebug, rjs, rpdf, ru, rxml, sass, taskpaper, modelo, tmproj, xaml**. Para instalar siga os passos:

```bash
cd /var/www/redmine/plugins
# clonando e copiando para o diretorio especifico
git clone https://github.com/HugoHasenbein/redmine_more_code.git
# agora reinicie o servidor httpd
systemctl restart httpd.service
#ou
service httpd restart
```

### 2.7 Instalando plugin Redmine Dashboard - [Github](https://github.com/jgraichen/redmine_dashboard/)

Este plugin [Redmine](http://redmine.org/) adiciona um **painel de issue - issue dashboard**, que suporta arrastar e soltar para problemas e vários filtros. Para instalar vamos instalar a **versão 2.7.1**, apesar de já possuir a versão 3, porém ainda não lançada:  **v3 pre-alpha**. Para mais detalhes acesse o [site do github v2 stable](https://github.com/jgraichen/redmine_dashboard/tree/stable-v2#readme).

```bash
# navega até o plugin do redmine
cd /var/www/redmine/plugins
# setando a versao requerida
# caso já possua uma nova versao para a versão 2 é só consultar no site do github
# https://github.com/jgraichen/redmine_dashboard/releases
REDMINE_DASHBOARD_VERSION=v2.7.1
rm -rf redmine_dashboard
mkdir -p redmine_dashboard
wget -nv https://github.com/jgraichen/redmine_dashboard/archive/${REDMINE_DASHBOARD_VERSION}.tar.gz -O - | tar -zvxf - --strip=1 -C redmine_dashboard
# volte para a raiz do redmine
cd /var/www/redmine/
#Install required gems
bundle install --without development test
# A migração de banco de dados não se faz necessária, basta reiniciar o apache
service httpd restart
```
Ao final das instalações dos plugins você pode **checar e configurar** todos os plugins em `/admin/plugins`. conforme imagem de exemplo abaixo.

![](img/plugin2.PNG)

## 3. Remover Plugins no Redmine (Opcional)

Nesta seção iremos demonstrar como remover plugin do redmine. Para remover plugins de um modo geral acesse [Uninstall Redmine Plugins ](http://www.redmine.org/projects/redmine/wiki/Plugins#Uninstalling-a-plugin).

**Não precisa executar os comandos abaixo**, pois é um `exemplo` de um uninstall de um plugin qualquer.

1. Se o plug-in exigiu uma migração, execute o seguinte comando para fazer downgrade do banco de dados (faça um backup do banco de dados antes): 

   Para Redmine 2.x:

   ```bash
   bundle exec rake redmine:plugins:migrate NAME=plugin_name VERSION=0 RAILS_ENV=production
   ```

2. Remova seu plugin da pasta plugins: `/path/to/redmine/plugins`(Redmine 2.x).

3. Reinicie Redmine.

### 3.1 Removendo o plugin - Line numbers Redmine

```bash
# navegue até o redmine
cd /var/www/redmine/plugins
rm -rf line_numbers
# basta reinicar o servidor apache
service httpd restart
```

## 4. Configurando o envio de email no Redmine (Opcional)

Outra função muito importante do **Redmine é usar e-mail** para notificar os membros quando o conteúdo de cada projeto muda. Para **configurar** o e-mail, edite o arquivo de configuração. 

Nesta seção iremos demonstrar a configuração para envio de email nos moldes da MB e do GMail, para outros meios favor consultar o [link de configuração de email no site do redmine](http://www.redmine.org/projects/redmine/wiki/EmailConfiguration).

#### Para configuração da MB:

```bash
# remover o postfix
yum remove postfix
#Instalar o sendmail:
yum install sendmail sendmail-cf.noarch mailx
```

Editar o arquivo de **configuração do redmine**, ateção para **não usar TAB**, mas **somente 2 espaços**:

```bash
vim /var/www/redmine/config/configuration.yml
```

No arquivo **descomente** a linha que trata do **sendmail**, conforme exemplo abaixo.

```yaml
# ==== Sendmail command
#
#  email_delivery:
#    delivery_method: :sendmail

## Altere para da forma abaixo:
    email_delivery:
      delivery_method: :sendmail
```

Editar o arquivo`vim /etc/mail/sendmail.mc` e colocar no final após todas as configurações:

```bash
define(`SMART_HOST', smtps.intranet.mb)dnl
define(`RELAY_MAILER_ARGS', `TCP $h 465')dnl
define(`ESMTP_MAILER_ARGS', `TCP $h 465')dnl
```

Executar o seguinte **comando para atualizar a configuração do sendmail**: 

```bash
make -C /etc/mail
service sendmail restart
```

Entrar em contato com a DCTIM (**último responsável:** VICTOR Hugo Okabayashi, **dctim-3111**, Telefone **2104-5456** Retelma **8110-5456**) solicitando adicionar o **IP do servidor Redmine** para utilizar o serviço de envio de e-mail do servidor **smtps.intranet.mb**. 

Para testar o **Sendmail no terminal** após prontificação da etapa acima  (trocar o endereço **nome_usuario_internet@marinha.mil.br** pelo fornecido pelo CTIM): 
`echo "Teste envio STARTTLS " | mail -s "Sendmail domino Relay" nome_usuario_internet@marinha.mil.br`

Terminado os testes com o sendmail, será necessário SOL por meio de MSG para a DCTIM para liberar a comunicação entre os servidores do Redmine e o LOTUS NOTES. Abaixo segue o modelo de MSG:

```markdown
"Solicito autorizar o envio de e-mail, utilizando o protocolo STARTTLS, do servidor de Aplicação Redmine de endereço IP (IP do servidor Redmine) para o servidor Domino de endereço smtps.intranet.mb BT"
```

 Obs.: Estes teste não foram realizados ainda na rede da MB.

#### Para configuração com GMail

Editar o arquivo de **configuração do redmine**, ateção para **não usar TAB**, mas **somente 2 espaços**:

```bash
vim /var/www/redmine/config/configuration.yml
```

Se você quiser usar o **GMail/Google Apps** e outros servidores **SMTP** que exigem **TLS**, terá que adicionar algumas configurações relacionadas a TLS:

```yaml
production:
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      enable_starttls_auto: true
      address: "smtp.gmail.com" 
      port: 587
      domain: "smtp.gmail.com" 
      authentication: :plain
      user_name: "your_email@gmail.com" 
      password: "your_password"
```

Ao enviar o **GSuite** (anteriormente **Google Apps**), é bom usar o redirecionamento SMTP,  que tem limites de envio muito maiores. Mais informações e guia detalhado sobre como habilitar a retransmissão de SMTP estão aqui: https://support.google.com/a/answer/2956491

 Ao configurar o serviço de retransmissão de SMTP, use algo assim:

- Nome: Redmine
  1. Remetentes permitidos:
     - Somente usuários registrados do Google Apps em meus domínios - no caso de você ter criado um usuário dedicado do G Suite para o Redmine
  2. Autenticação 
     - Aceitar apenas correio dos endereços IP especificados - endereço IP do seu servidor Redmine
     - Requer autenticação SMTP
  3. Criptografia
     - Requer criptografia TLS

A configuração pode ser bem simples:

```yaml
production:
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      address: smtp-relay.gmail.com
      port: 587
      domain: smtp-relay.gmail.com
      authentication: :plain
      user_name: your_email@gmail.com
      password: your_password
```

## 5. Referências e Links

- http://www.redmine.org/projects/redmine/wiki/RedmineBackupRestore                