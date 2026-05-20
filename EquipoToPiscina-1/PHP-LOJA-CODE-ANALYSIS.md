# ANÁLISE DE CÓDIGO - PHP LOJA

## 🔍 ANÁLISE PRELIMINAR (Baseada em Padrões Comuns)

**Nota**: Esta análise é baseada em padrões comuns encontrados em sistemas PHP de loja. Assim que tiver acesso ao repositório específico, farei uma análise detalhada do código real.

## 🚨 PROBLEMAS CRÍTICOS MAIS COMUNS

### **1. VULNERABILIDADES DE SEGURANÇA**

#### **SQL Injection (Crítico)**
```php
// ❌ CÓDIGO VULNERÁVEL TÍPICO:
$id = $_GET['id'];
$sql = "SELECT * FROM produtos WHERE id = " . $id;
$result = mysql_query($sql); // PERIGOSO!

// ❌ OUTRO EXEMPLO COMUM:
$busca = $_POST['busca'];
$query = "SELECT * FROM produtos WHERE nome LIKE '%" . $busca . "%'";

// ✅ CORREÇÃO NECESSÁRIA:
$stmt = $pdo->prepare("SELECT * FROM produtos WHERE id = ?");
$stmt->execute([$id]);

// ✅ PARA BUSCA:
$stmt = $pdo->prepare("SELECT * FROM produtos WHERE nome LIKE ?");
$stmt->execute(['%' . $busca . '%']);
```

#### **Cross-Site Scripting (XSS)**
```php
// ❌ CÓDIGO VULNERÁVEL:
echo "Bem-vindo, " . $_POST['nome']; // PERIGOSO!
echo "<h1>" . $_GET['titulo'] . "</h1>"; // PERIGOSO!

// ✅ CORREÇÃO:
echo "Bem-vindo, " . htmlspecialchars($_POST['nome'], ENT_QUOTES, 'UTF-8');
echo "<h1>" . htmlspecialchars($_GET['titulo'], ENT_QUOTES, 'UTF-8') . "</h1>";
```

#### **Cross-Site Request Forgery (CSRF)**
```php
// ❌ FORMULÁRIO SEM PROTEÇÃO:
<form method="POST" action="deletar_produto.php">
    <input type="hidden" name="id" value="123">
    <button type="submit">Deletar</button>
</form>

// ✅ COM PROTEÇÃO CSRF:
<?php
session_start();
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}
?>
<form method="POST" action="deletar_produto.php">
    <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?>">
    <input type="hidden" name="id" value="123">
    <button type="submit">Deletar</button>
</form>
```

#### **Upload de Arquivos Inseguro**
```php
// ❌ UPLOAD PERIGOSO:
move_uploaded_file($_FILES['imagem']['tmp_name'], 'uploads/' . $_FILES['imagem']['name']);

// ✅ UPLOAD SEGURO:
$allowed_types = ['image/jpeg', 'image/png', 'image/gif'];
$max_size = 2 * 1024 * 1024; // 2MB

if (in_array($_FILES['imagem']['type'], $allowed_types) && 
    $_FILES['imagem']['size'] <= $max_size) {
    
    $extension = pathinfo($_FILES['imagem']['name'], PATHINFO_EXTENSION);
    $filename = uniqid() . '.' . $extension;
    move_uploaded_file($_FILES['imagem']['tmp_name'], 'uploads/' . $filename);
}
```

### **2. PROBLEMAS DE PERFORMANCE**

#### **Consultas N+1**
```php
// ❌ PROBLEMA N+1:
$produtos = $pdo->query("SELECT * FROM produtos")->fetchAll();
foreach ($produtos as $produto) {
    $categoria = $pdo->query("SELECT nome FROM categorias WHERE id = " . $produto['categoria_id'])->fetch();
    echo $produto['nome'] . " - " . $categoria['nome'];
}

// ✅ SOLUÇÃO COM JOIN:
$sql = "SELECT p.nome as produto_nome, c.nome as categoria_nome 
        FROM produtos p 
        LEFT JOIN categorias c ON p.categoria_id = c.id";
$produtos = $pdo->query($sql)->fetchAll();
```

#### **Falta de Cache**
```php
// ❌ SEM CACHE:
function getProdutosMaisVendidos() {
    // Consulta complexa executada a cada requisição
    $sql = "SELECT p.*, COUNT(ip.produto_id) as vendas 
            FROM produtos p 
            LEFT JOIN itens_pedido ip ON p.id = ip.produto_id 
            GROUP BY p.id 
            ORDER BY vendas DESC 
            LIMIT 10";
    return $pdo->query($sql)->fetchAll();
}

// ✅ COM CACHE:
function getProdutosMaisVendidos() {
    $cache_key = 'produtos_mais_vendidos';
    $cache_file = 'cache/' . $cache_key . '.json';
    
    if (file_exists($cache_file) && (time() - filemtime($cache_file)) < 3600) {
        return json_decode(file_get_contents($cache_file), true);
    }
    
    // Consulta apenas se cache expirou
    $sql = "SELECT p.*, COUNT(ip.produto_id) as vendas 
            FROM produtos p 
            LEFT JOIN itens_pedido ip ON p.id = ip.produto_id 
            GROUP BY p.id 
            ORDER BY vendas DESC 
            LIMIT 10";
    $result = $pdo->query($sql)->fetchAll();
    
    file_put_contents($cache_file, json_encode($result));
    return $result;
}
```

### **3. PROBLEMAS DE ESTRUTURA**

#### **Código Espaguete**
```php
// ❌ TUDO EM UM ARQUIVO:
<?php
// conexao.php + validacao + processamento + html tudo junto
if ($_POST['acao'] == 'login') {
    $usuario = $_POST['usuario'];
    $senha = md5($_POST['senha']); // MD5 é inseguro!
    $sql = "SELECT * FROM usuarios WHERE usuario = '$usuario' AND senha = '$senha'";
    // ... 200 linhas de código misturado
}
?>
<html>
<!-- HTML misturado com PHP -->
</html>

// ✅ ESTRUTURA MVC:
// Controllers/AuthController.php
class AuthController {
    public function login($request) {
        $validator = new LoginValidator();
        if (!$validator->validate($request)) {
            return $this->error('Dados inválidos');
        }
        
        $user = $this->userService->authenticate($request['usuario'], $request['senha']);
        if ($user) {
            $this->session->set('user_id', $user['id']);
            return $this->redirect('/dashboard');
        }
        
        return $this->error('Credenciais inválidas');
    }
}
```

### **4. PROBLEMAS DE VALIDAÇÃO**

#### **Falta de Validação de Dados**
```php
// ❌ SEM VALIDAÇÃO:
$email = $_POST['email'];
$telefone = $_POST['telefone'];
$cep = $_POST['cep'];

// Salva direto no banco sem validar
$sql = "INSERT INTO clientes (email, telefone, cep) VALUES ('$email', '$telefone', '$cep')";

// ✅ COM VALIDAÇÃO:
class ClienteValidator {
    public function validate($dados) {
        $erros = [];
        
        if (!filter_var($dados['email'], FILTER_VALIDATE_EMAIL)) {
            $erros[] = 'Email inválido';
        }
        
        if (!preg_match('/^\(\d{2}\)\s\d{4,5}-\d{4}$/', $dados['telefone'])) {
            $erros[] = 'Telefone inválido';
        }
        
        if (!preg_match('/^\d{5}-\d{3}$/', $dados['cep'])) {
            $erros[] = 'CEP inválido';
        }
        
        return empty($erros) ? true : $erros;
    }
}
```

## 🔧 PLANO DE CORREÇÕES

### **FASE 1: Segurança Crítica (1 semana)**
```php
// 1. Implementar prepared statements em todas as consultas
// 2. Adicionar escape de HTML em todos os outputs
// 3. Implementar tokens CSRF
// 4. Validar uploads de arquivos
// 5. Atualizar hashing de senhas (bcrypt)

// Exemplo de classe de segurança:
class Security {
    public static function hashPassword($password) {
        return password_hash($password, PASSWORD_BCRYPT);
    }
    
    public static function verifyPassword($password, $hash) {
        return password_verify($password, $hash);
    }
    
    public static function generateCSRFToken() {
        if (empty($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }
        return $_SESSION['csrf_token'];
    }
    
    public static function validateCSRFToken($token) {
        return hash_equals($_SESSION['csrf_token'], $token);
    }
}
```

### **FASE 2: Performance (1-2 semanas)**
```php
// 1. Implementar sistema de cache
// 2. Otimizar consultas SQL
// 3. Adicionar índices no banco
// 4. Implementar lazy loading de imagens
// 5. Minificar CSS/JS

// Exemplo de classe de cache:
class Cache {
    private $cache_dir = 'storage/cache/';
    
    public function get($key) {
        $file = $this->cache_dir . md5($key) . '.cache';
        
        if (file_exists($file) && (time() - filemtime($file)) < 3600) {
            return unserialize(file_get_contents($file));
        }
        
        return null;
    }
    
    public function set($key, $data, $ttl = 3600) {
        $file = $this->cache_dir . md5($key) . '.cache';
        file_put_contents($file, serialize($data));
        touch($file, time() + $ttl);
    }
}
```

### **FASE 3: Refatoração (2-3 semanas)**
```php
// 1. Implementar padrão MVC
// 2. Separar lógica de negócio
// 3. Criar camada de serviços
// 4. Implementar dependency injection
// 5. Adicionar testes unitários

// Estrutura MVC sugerida:
src/
├── Controllers/
│   ├── ProdutoController.php
│   ├── ClienteController.php
│   └── PedidoController.php
├── Models/
│   ├── Produto.php
│   ├── Cliente.php
│   └── Pedido.php
├── Services/
│   ├── ProdutoService.php
│   ├── EmailService.php
│   └── PagamentoService.php
├── Validators/
│   ├── ProdutoValidator.php
│   └── ClienteValidator.php
└── Utils/
    ├── Database.php
    ├── Security.php
    └── Cache.php
```

## 📊 MÉTRICAS DE QUALIDADE

### **Ferramentas de Análise Recomendadas:**
```bash
# Análise estática
composer require --dev phpstan/phpstan
./vendor/bin/phpstan analyse src/ --level=8

# Code style
composer require --dev squizlabs/php_codesniffer
./vendor/bin/phpcs --standard=PSR12 src/

# Detecção de bugs
composer require --dev phpmd/phpmd
./vendor/bin/phpmd src/ text cleancode,codesize,controversial,design,naming,unusedcode

# Testes
composer require --dev phpunit/phpunit
./vendor/bin/phpunit tests/
```

### **Métricas Esperadas Após Correções:**
- ✅ **Cobertura de testes**: > 80%
- ✅ **Complexidade ciclomática**: < 10
- ✅ **Duplicação de código**: < 5%
- ✅ **Vulnerabilidades**: 0
- ✅ **Performance**: < 2s tempo de resposta

## 🚀 MODERNIZAÇÃO SUGERIDA

### **Migração para PHP 8.2:**
```php
// Aproveitar recursos modernos:
// 1. Typed properties
// 2. Match expressions
// 3. Named arguments
// 4. Attributes
// 5. Enums

class Produto {
    public function __construct(
        public readonly int $id,
        public string $nome,
        public float $preco,
        public StatusProduto $status = StatusProduto::ATIVO
    ) {}
    
    public function getDesconto(): float {
        return match($this->status) {
            StatusProduto::PROMOCAO => 0.20,
            StatusProduto::LIQUIDACAO => 0.50,
            default => 0.0
        };
    }
}

enum StatusProduto: string {
    case ATIVO = 'ativo';
    case INATIVO = 'inativo';
    case PROMOCAO = 'promocao';
    case LIQUIDACAO = 'liquidacao';
}
```

## 📋 CHECKLIST DE AUDITORIA

### **Segurança:**
- [ ] Todas as consultas SQL usam prepared statements
- [ ] Todos os outputs são escapados (htmlspecialchars)
- [ ] Tokens CSRF implementados em formulários
- [ ] Upload de arquivos validado e seguro
- [ ] Senhas usando bcrypt/argon2
- [ ] Headers de segurança configurados
- [ ] Validação de entrada em todos os endpoints

### **Performance:**
- [ ] Sistema de cache implementado
- [ ] Consultas SQL otimizadas (sem N+1)
- [ ] Índices adequados no banco de dados
- [ ] Imagens otimizadas e lazy loading
- [ ] CSS/JS minificados e comprimidos
- [ ] CDN configurado para assets estáticos

### **Código:**
- [ ] Estrutura MVC implementada
- [ ] Separação de responsabilidades
- [ ] Código duplicado removido
- [ ] Padrões PSR seguidos
- [ ] Documentação adequada
- [ ] Testes unitários > 80% cobertura

## 🎯 PRÓXIMOS PASSOS

1. **Fornecer acesso ao repositório** para análise detalhada
2. **Executar script de setup** do ambiente de homologação
3. **Realizar auditoria completa** do código atual
4. **Priorizar correções** por criticidade
5. **Implementar melhorias** fase por fase
6. **Testar** em ambiente de homologação
7. **Deploy** para produção

**Assim que tiver o link correto do repositório, farei uma análise específica e detalhada do código real!** 🔍