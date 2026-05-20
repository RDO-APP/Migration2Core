# AMBIENTE DE HOMOLOGAÇÃO - PHP LOJA

## 🎯 OBJETIVO
Criar ambiente de homologação para o sistema PHP "Loja" e realizar análise de código para identificar melhorias e correções necessárias.

## 📋 ESTRUTURA DO AMBIENTE DE HOMOLOGAÇÃO

### **1. CONFIGURAÇÃO DO SERVIDOR**

#### **Requisitos Mínimos:**
```
🖥️ SERVIDOR:
├── PHP 8.1+ (recomendado 8.2)
├── MySQL 8.0+ ou MariaDB 10.6+
├── Apache 2.4+ ou Nginx 1.20+
├── Composer (gerenciador de dependências)
├── Git (controle de versão)
└── SSL Certificate (Let's Encrypt)

💾 RECURSOS:
├── RAM: 2GB mínimo (4GB recomendado)
├── Storage: 20GB SSD
├── CPU: 2 cores
└── Bandwidth: 100Mbps
```

#### **Extensões PHP Necessárias:**
```php
// php.ini - Extensões obrigatórias
extension=mysqli
extension=pdo_mysql
extension=gd
extension=curl
extension=zip
extension=xml
extension=mbstring
extension=json
extension=openssl
extension=fileinfo
extension=intl
```

### **2. ESTRUTURA DE DIRETÓRIOS**

```
Loja-Homolog/
├── public/                 # Documentos públicos
│   ├── index.php          # Ponto de entrada
│   ├── assets/            # CSS, JS, imagens
│   │   ├── css/
│   │   ├── js/
│   │   └── images/
│   └── uploads/           # Arquivos enviados
├── src/                   # Código fonte
│   ├── Controllers/       # Controladores
│   ├── Models/           # Modelos de dados
│   ├── Views/            # Templates
│   ├── Services/         # Lógica de negócio
│   └── Utils/            # Utilitários
├── config/               # Configurações
│   ├── database.php      # Configuração BD
│   ├── app.php          # Configurações gerais
│   └── homolog.php      # Config homologação
├── database/             # Scripts de banco
│   ├── migrations/       # Migrações
│   ├── seeds/           # Dados iniciais
│   └── homolog-setup.sql # Setup homolog
├── tests/               # Testes automatizados
├── logs/                # Logs da aplicação
├── vendor/              # Dependências Composer
├── .env.homolog         # Variáveis ambiente
├── composer.json        # Dependências PHP
└── README-HOMOLOG.md    # Documentação
```

### **3. CONFIGURAÇÃO DE BANCO DE DADOS**

#### **Criação do Banco de Homologação:**
```sql
-- Criar banco de homologação
CREATE DATABASE loja_homolog CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criar usuário específico
CREATE USER 'loja_homolog'@'localhost' IDENTIFIED BY 'senha_segura_homolog_2024';
GRANT ALL PRIVILEGES ON loja_homolog.* TO 'loja_homolog'@'localhost';
FLUSH PRIVILEGES;

-- Configurações de performance
SET GLOBAL innodb_buffer_pool_size = 256M;
SET GLOBAL max_connections = 100;
```

#### **Arquivo .env.homolog:**
```env
# Configurações de Homologação
APP_ENV=homolog
APP_DEBUG=true
APP_URL=https://loja-homolog.rdoapp.com.br

# Database
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=loja_homolog
DB_USERNAME=loja_homolog
DB_PASSWORD=senha_segura_homolog_2024

# Email (usar Mailtrap para testes)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=seu_usuario_mailtrap
MAIL_PASSWORD=sua_senha_mailtrap

# Pagamentos (usar sandbox)
PAGSEGURO_SANDBOX=true
PAGSEGURO_EMAIL=sandbox@rdoapp.com.br
PAGSEGURO_TOKEN=token_sandbox

# Logs
LOG_CHANNEL=daily
LOG_LEVEL=debug
```

### **4. CONFIGURAÇÃO DO APACHE/NGINX**

#### **Apache VirtualHost:**
```apache
<VirtualHost *:80>
    ServerName loja-homolog.rdoapp.com.br
    DocumentRoot /var/www/loja-homolog/public
    
    <Directory /var/www/loja-homolog/public>
        AllowOverride All
        Require all granted
        
        # Rewrite rules
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>
    
    # Logs específicos
    ErrorLog /var/log/apache2/loja-homolog-error.log
    CustomLog /var/log/apache2/loja-homolog-access.log combined
</VirtualHost>

# SSL (Let's Encrypt)
<VirtualHost *:443>
    ServerName loja-homolog.rdoapp.com.br
    DocumentRoot /var/www/loja-homolog/public
    
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/loja-homolog.rdoapp.com.br/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/loja-homolog.rdoapp.com.br/privkey.pem
    
    # Mesmo conteúdo do VirtualHost HTTP
</VirtualHost>
```

### **5. SCRIPTS DE DEPLOY**

#### **deploy-homolog.sh:**
```bash
#!/bin/bash
# Deploy para Homologação - Loja PHP

echo "🚀 Iniciando deploy para homologação..."

# Backup do ambiente atual
echo "📦 Criando backup..."
sudo cp -r /var/www/loja-homolog /var/www/backups/loja-homolog-$(date +%Y%m%d_%H%M%S)

# Atualizar código do Git
echo "📥 Atualizando código..."
cd /var/www/loja-homolog
git pull origin main

# Instalar dependências
echo "📦 Instalando dependências..."
composer install --no-dev --optimize-autoloader

# Executar migrações
echo "🗄️ Executando migrações..."
php artisan migrate --env=homolog

# Limpar cache
echo "🧹 Limpando cache..."
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# Definir permissões
echo "🔐 Configurando permissões..."
sudo chown -R www-data:www-data /var/www/loja-homolog
sudo chmod -R 755 /var/www/loja-homolog
sudo chmod -R 775 /var/www/loja-homolog/storage
sudo chmod -R 775 /var/www/loja-homolog/bootstrap/cache

# Reiniciar serviços
echo "🔄 Reiniciando serviços..."
sudo systemctl reload apache2
sudo systemctl restart php8.2-fpm

echo "✅ Deploy concluído com sucesso!"
echo "🌐 Acesse: https://loja-homolog.rdoapp.com.br"
```

### **6. MONITORAMENTO E LOGS**

#### **Configuração de Logs:**
```php
// config/logging.php
<?php
return [
    'default' => env('LOG_CHANNEL', 'daily'),
    
    'channels' => [
        'daily' => [
            'driver' => 'daily',
            'path' => storage_path('logs/loja-homolog.log'),
            'level' => env('LOG_LEVEL', 'debug'),
            'days' => 14,
        ],
        
        'error' => [
            'driver' => 'daily',
            'path' => storage_path('logs/error.log'),
            'level' => 'error',
            'days' => 30,
        ],
        
        'performance' => [
            'driver' => 'daily',
            'path' => storage_path('logs/performance.log'),
            'level' => 'info',
            'days' => 7,
        ],
    ],
];
```

## 🔍 ANÁLISE DE CÓDIGO - CHECKLIST

### **1. SEGURANÇA**
```php
// ❌ PROBLEMAS COMUNS A VERIFICAR:

// SQL Injection
$sql = "SELECT * FROM users WHERE id = " . $_GET['id']; // PERIGOSO!

// XSS
echo $_POST['nome']; // PERIGOSO!

// CSRF
// Falta de tokens CSRF em formulários

// ✅ CORREÇÕES NECESSÁRIAS:
// Usar prepared statements
$stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$_GET['id']]);

// Escapar output
echo htmlspecialchars($_POST['nome'], ENT_QUOTES, 'UTF-8');

// Implementar CSRF tokens
```

### **2. PERFORMANCE**
```php
// ❌ PROBLEMAS A VERIFICAR:

// Consultas N+1
foreach ($produtos as $produto) {
    $categoria = $db->query("SELECT * FROM categorias WHERE id = " . $produto['categoria_id']);
}

// Falta de cache
// Consultas desnecessárias
// Imagens não otimizadas

// ✅ MELHORIAS:
// Usar JOIN ou eager loading
// Implementar cache (Redis/Memcached)
// Otimizar imagens (WebP, lazy loading)
```

### **3. ESTRUTURA DE CÓDIGO**
```php
// ❌ PROBLEMAS COMUNS:
// Código espaguete (tudo em um arquivo)
// Falta de separação de responsabilidades
// Código duplicado
// Falta de validação de dados

// ✅ PADRÕES A IMPLEMENTAR:
// MVC (Model-View-Controller)
// Repository Pattern
// Service Layer
// Dependency Injection
```

## 🧪 TESTES AUTOMATIZADOS

### **Configuração PHPUnit:**
```php
// tests/ProductTest.php
<?php
use PHPUnit\Framework\TestCase;

class ProductTest extends TestCase
{
    public function testCreateProduct()
    {
        $product = new Product();
        $product->setName('Produto Teste');
        $product->setPrice(99.90);
        
        $this->assertEquals('Produto Teste', $product->getName());
        $this->assertEquals(99.90, $product->getPrice());
    }
    
    public function testProductValidation()
    {
        $product = new Product();
        
        $this->assertFalse($product->isValid()); // Nome obrigatório
        
        $product->setName('Produto');
        $product->setPrice(-10); // Preço inválido
        
        $this->assertFalse($product->isValid());
    }
}
```

## 📊 MÉTRICAS DE QUALIDADE

### **Ferramentas de Análise:**
```bash
# Instalar ferramentas de qualidade
composer require --dev phpstan/phpstan
composer require --dev squizlabs/php_codesniffer
composer require --dev phpmd/phpmd

# Executar análises
./vendor/bin/phpstan analyse src/
./vendor/bin/phpcs --standard=PSR12 src/
./vendor/bin/phpmd src/ text cleancode,codesize,controversial,design,naming,unusedcode
```

## 🚀 PRÓXIMOS PASSOS

### **FASE 1: Setup Inicial (1 semana)**
1. ✅ Configurar servidor de homologação
2. ✅ Clonar repositório PHP_Loja_Edivaldo
3. ✅ Configurar banco de dados
4. ✅ Testar funcionalidades básicas

### **FASE 2: Análise e Correções (2-3 semanas)**
1. 🔍 Auditoria de segurança completa
2. 🔍 Análise de performance
3. 🔍 Refatoração de código
4. 🔍 Implementação de testes

### **FASE 3: Melhorias (2-3 semanas)**
1. 🚀 Modernização para PHP 8.2
2. 🚀 Implementação de cache
3. 🚀 Otimização de banco de dados
4. 🚀 Deploy automatizado

## 📝 RELATÓRIO DE ANÁLISE

**Assim que tiver acesso ao repositório, vou gerar um relatório detalhado com:**

- ✅ **Vulnerabilidades encontradas**
- ✅ **Problemas de performance**
- ✅ **Código duplicado**
- ✅ **Padrões não seguidos**
- ✅ **Sugestões de melhorias**
- ✅ **Plano de refatoração**

**Me forneça o link correto do repositório ou acesso para fazer a análise completa!** 🔍