#!/bin/bash
# Setup Ambiente de Homologação - PHP Loja
# Autor: Kiro AI Assistant
# Data: $(date +%Y-%m-%d)

echo "🚀 CONFIGURANDO AMBIENTE DE HOMOLOGAÇÃO - PHP LOJA"
echo "=================================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Verificar se está rodando como root
if [[ $EUID -eq 0 ]]; then
   error "Este script não deve ser executado como root"
   exit 1
fi

# Verificar sistema operacional
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    log "Sistema Linux detectado"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    log "Sistema macOS detectado"
else
    error "Sistema operacional não suportado"
    exit 1
fi

# Configurações
PROJECT_NAME="loja-homolog"
PROJECT_DIR="/var/www/$PROJECT_NAME"
DB_NAME="loja_homolog"
DB_USER="loja_homolog"
DB_PASS="senha_segura_homolog_2024"
DOMAIN="loja-homolog.rdoapp.com.br"

log "Iniciando configuração do ambiente de homologação..."

# 1. Atualizar sistema
log "Atualizando sistema..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get upgrade -y
elif command -v yum &> /dev/null; then
    sudo yum update -y
elif command -v brew &> /dev/null; then
    brew update && brew upgrade
fi

# 2. Instalar dependências
log "Instalando dependências..."

if command -v apt-get &> /dev/null; then
    # Ubuntu/Debian
    sudo apt-get install -y \
        apache2 \
        mysql-server \
        php8.2 \
        php8.2-cli \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-xml \
        php8.2-gd \
        php8.2-curl \
        php8.2-zip \
        php8.2-mbstring \
        php8.2-json \
        php8.2-intl \
        composer \
        git \
        certbot \
        python3-certbot-apache
        
elif command -v yum &> /dev/null; then
    # CentOS/RHEL
    sudo yum install -y \
        httpd \
        mysql-server \
        php \
        php-cli \
        php-fpm \
        php-mysql \
        php-xml \
        php-gd \
        php-curl \
        php-zip \
        php-mbstring \
        php-json \
        composer \
        git
        
elif command -v brew &> /dev/null; then
    # macOS
    brew install \
        apache2 \
        mysql \
        php@8.2 \
        composer \
        git
fi

# 3. Configurar MySQL
log "Configurando MySQL..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# 4. Criar estrutura de diretórios
log "Criando estrutura de diretórios..."
sudo mkdir -p $PROJECT_DIR/{public,src,config,database,tests,logs,storage}
sudo mkdir -p $PROJECT_DIR/public/{assets/{css,js,images},uploads}
sudo mkdir -p $PROJECT_DIR/src/{Controllers,Models,Views,Services,Utils}
sudo mkdir -p $PROJECT_DIR/database/{migrations,seeds}
sudo mkdir -p $PROJECT_DIR/storage/{cache,sessions,logs}

# 5. Configurar permissões
log "Configurando permissões..."
sudo chown -R www-data:www-data $PROJECT_DIR
sudo chmod -R 755 $PROJECT_DIR
sudo chmod -R 775 $PROJECT_DIR/storage
sudo chmod -R 775 $PROJECT_DIR/logs

# 6. Criar arquivo de configuração
log "Criando arquivos de configuração..."

# .env.homolog
sudo tee $PROJECT_DIR/.env.homolog > /dev/null <<EOF
# Configurações de Homologação - PHP Loja
APP_ENV=homolog
APP_DEBUG=true
APP_URL=https://$DOMAIN

# Database
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASS

# Email (Mailtrap para testes)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=
MAIL_PASSWORD=

# Logs
LOG_CHANNEL=daily
LOG_LEVEL=debug

# Cache
CACHE_DRIVER=file
SESSION_DRIVER=file

# Timezone
APP_TIMEZONE=America/Sao_Paulo
EOF

# config/database.php
sudo tee $PROJECT_DIR/config/database.php > /dev/null <<'EOF'
<?php
return [
    'default' => 'mysql',
    
    'connections' => [
        'mysql' => [
            'driver' => 'mysql',
            'host' => $_ENV['DB_HOST'] ?? 'localhost',
            'port' => $_ENV['DB_PORT'] ?? '3306',
            'database' => $_ENV['DB_DATABASE'] ?? 'loja_homolog',
            'username' => $_ENV['DB_USERNAME'] ?? 'loja_homolog',
            'password' => $_ENV['DB_PASSWORD'] ?? '',
            'charset' => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
            'options' => [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ],
        ],
    ],
];
EOF

# public/index.php
sudo tee $PROJECT_DIR/public/index.php > /dev/null <<'EOF'
<?php
// Carregar variáveis de ambiente
if (file_exists(__DIR__ . '/../.env.homolog')) {
    $lines = file(__DIR__ . '/../.env.homolog', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '=') !== false && strpos($line, '#') !== 0) {
            list($key, $value) = explode('=', $line, 2);
            $_ENV[trim($key)] = trim($value);
        }
    }
}

// Configurações básicas
error_reporting($_ENV['APP_DEBUG'] === 'true' ? E_ALL : 0);
ini_set('display_errors', $_ENV['APP_DEBUG'] === 'true' ? 1 : 0);
date_default_timezone_set($_ENV['APP_TIMEZONE'] ?? 'America/Sao_Paulo');

// Autoload (se usar Composer)
if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    require_once __DIR__ . '/../vendor/autoload.php';
}

// Roteamento básico
$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);

switch ($path) {
    case '/':
        echo "<h1>🏪 Loja Homologação</h1>";
        echo "<p>Ambiente de homologação configurado com sucesso!</p>";
        echo "<p>Versão PHP: " . PHP_VERSION . "</p>";
        echo "<p>Ambiente: " . ($_ENV['APP_ENV'] ?? 'production') . "</p>";
        break;
        
    case '/health':
        header('Content-Type: application/json');
        echo json_encode([
            'status' => 'ok',
            'timestamp' => date('Y-m-d H:i:s'),
            'environment' => $_ENV['APP_ENV'] ?? 'production',
            'php_version' => PHP_VERSION,
        ]);
        break;
        
    default:
        http_response_code(404);
        echo "<h1>404 - Página não encontrada</h1>";
        break;
}
EOF

# 7. Configurar Apache VirtualHost
log "Configurando Apache VirtualHost..."
sudo tee /etc/apache2/sites-available/$PROJECT_NAME.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot $PROJECT_DIR/public
    
    <Directory $PROJECT_DIR/public>
        AllowOverride All
        Require all granted
        
        # Rewrite rules
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>
    
    # Logs específicos
    ErrorLog /var/log/apache2/$PROJECT_NAME-error.log
    CustomLog /var/log/apache2/$PROJECT_NAME-access.log combined
    
    # Configurações de segurança
    ServerTokens Prod
    ServerSignature Off
    
    # Headers de segurança
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
</VirtualHost>
EOF

# Habilitar site e módulos
sudo a2ensite $PROJECT_NAME.conf
sudo a2enmod rewrite
sudo a2enmod headers
sudo systemctl reload apache2

# 8. Criar .htaccess
sudo tee $PROJECT_DIR/public/.htaccess > /dev/null <<'EOF'
RewriteEngine On

# Redirecionar para HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Roteamento
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]

# Segurança
<Files ".env*">
    Order allow,deny
    Deny from all
</Files>

# Cache para assets
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
</IfModule>
EOF

# 9. Criar composer.json
sudo tee $PROJECT_DIR/composer.json > /dev/null <<'EOF'
{
    "name": "rdoapp/loja-homolog",
    "description": "Sistema de Loja - Ambiente de Homologação",
    "type": "project",
    "require": {
        "php": "^8.1",
        "ext-pdo": "*",
        "ext-json": "*",
        "ext-mbstring": "*"
    },
    "require-dev": {
        "phpunit/phpunit": "^10.0",
        "phpstan/phpstan": "^1.0",
        "squizlabs/php_codesniffer": "^3.7"
    },
    "autoload": {
        "psr-4": {
            "App\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "scripts": {
        "test": "phpunit",
        "analyse": "phpstan analyse src/",
        "cs-check": "phpcs --standard=PSR12 src/",
        "cs-fix": "phpcbf --standard=PSR12 src/"
    }
}
EOF

# 10. Instalar dependências Composer
log "Instalando dependências Composer..."
cd $PROJECT_DIR
sudo -u www-data composer install

# 11. Criar script de deploy
sudo tee $PROJECT_DIR/deploy-homolog.sh > /dev/null <<'EOF'
#!/bin/bash
# Deploy Automático - Loja Homologação

echo "🚀 Iniciando deploy para homologação..."

# Backup
echo "📦 Criando backup..."
sudo cp -r /var/www/loja-homolog /var/www/backups/loja-homolog-$(date +%Y%m%d_%H%M%S)

# Atualizar código
echo "📥 Atualizando código..."
git pull origin main

# Dependências
echo "📦 Instalando dependências..."
composer install --no-dev --optimize-autoloader

# Cache
echo "🧹 Limpando cache..."
rm -rf storage/cache/*

# Permissões
echo "🔐 Configurando permissões..."
sudo chown -R www-data:www-data .
sudo chmod -R 755 .
sudo chmod -R 775 storage logs

# Reiniciar serviços
echo "🔄 Reiniciando serviços..."
sudo systemctl reload apache2

echo "✅ Deploy concluído!"
EOF

sudo chmod +x $PROJECT_DIR/deploy-homolog.sh

# 12. Configurar logs
log "Configurando sistema de logs..."
sudo mkdir -p /var/log/loja-homolog
sudo chown www-data:www-data /var/log/loja-homolog

# 13. Teste de conectividade
log "Testando configuração..."

# Testar MySQL
if mysql -u$DB_USER -p$DB_PASS -e "USE $DB_NAME; SELECT 1;" &> /dev/null; then
    log "✅ Conexão MySQL funcionando"
else
    error "❌ Problema na conexão MySQL"
fi

# Testar Apache
if systemctl is-active --quiet apache2; then
    log "✅ Apache funcionando"
else
    error "❌ Apache não está funcionando"
fi

# Testar PHP
if php -v &> /dev/null; then
    log "✅ PHP funcionando ($(php -r 'echo PHP_VERSION;'))"
else
    error "❌ Problema com PHP"
fi

# 14. Informações finais
echo ""
echo "🎉 CONFIGURAÇÃO CONCLUÍDA!"
echo "========================="
echo ""
info "📁 Diretório do projeto: $PROJECT_DIR"
info "🌐 URL local: http://localhost (adicione $DOMAIN ao /etc/hosts)"
info "🗄️ Banco de dados: $DB_NAME"
info "👤 Usuário DB: $DB_USER"
info "📊 Logs: /var/log/apache2/$PROJECT_NAME-*.log"
echo ""
warning "⚠️  PRÓXIMOS PASSOS:"
echo "1. Adicionar '$DOMAIN' ao DNS ou /etc/hosts"
echo "2. Configurar SSL com Let's Encrypt: sudo certbot --apache -d $DOMAIN"
echo "3. Clonar código da loja: git clone [REPO_URL] $PROJECT_DIR"
echo "4. Executar migrações de banco de dados"
echo "5. Configurar variáveis de ambiente específicas"
echo ""
log "✅ Ambiente de homologação pronto para uso!"
EOF