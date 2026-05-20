# RDO APP PISCINAS - BRIEFING MÓDULO DE LOGIN (REACT NATIVE)

**Data**: 27 de Janeiro de 2026  
**Desenvolvedor**: Carlos (React Native)  
**Módulo**: Tela de Login Mobile  
**Versão da API**: .NET 8

---

## 🎯 VISÃO GERAL

Este documento descreve as especificações funcionais e arquiteturais para implementação da tela de login no aplicativo mobile React Native do RDO App Piscinas.

---

## 🎨 1. IDENTIDADE VISUAL

### Logo e Branding

**Elemento Principal**: Ícone Fontello + Texto "Piscinas"

**Composição**:
- **Ícone**: Fontello custom icon (unicode `\e80c`)
- **Texto**: "Piscinas" em fonte SF UI Display Light
- **Cor do Ícone**: Branco (#FFFFFF)
- **Cor do Texto**: Branco (#FFFFFF)
- **Tamanho do Ícone**: 43px
- **Tamanho do Texto**: 14px (uppercase)

**Posicionamento**:
- Centralizado no topo da tela
- Margem superior: 20% da altura da tela
- Espaçamento entre ícone e texto: 8px

### Paleta de Cores

**Fundo da Tela**:
- Cor primária: `#27496F` (azul escuro)
- Gradiente opcional: `#27496F` → `#1C334D`

**Campos de Input**:
- Fundo: Transparente com borda inferior branca
- Texto: Branco (#FFFFFF)
- Placeholder: Branco com 60% de opacidade (#FFFFFF99)
- Borda ativa: Branco (#FFFFFF)
- Borda inativa: Branco com 40% de opacidade (#FFFFFF66)

**Botões**:
- Botão "ENTRAR": `#0088DD` (azul claro)
- Botão "ENTRAR" (hover/pressed): `#0073BB` (azul mais escuro)
- Texto do botão: Branco (#FFFFFF)
- Altura do botão: 41px
- Border radius: 8px

**Textos**:
- Labels: Branco (#FFFFFF)
- Links: Branco (#FFFFFF)
- Mensagens de erro: `#D04541` (vermelho)

### Fontes

**Família de Fontes** (em ordem de prioridade):
1. SF UI Display (Light, Medium, Bold)
2. Fallback: System default (San Francisco no iOS, Roboto no Android)

**Tamanhos**:
- Logo texto: 14px (uppercase)
- Labels: 16px
- Input text: 16px
- Botão: 16px (uppercase)
- Links: 14px
- Mensagens de erro: 14px

---

## 📋 2. CAMPOS E VALIDAÇÃO

### 2.1 Campo CPF

**Tipo**: Text Input com máscara
**Label**: "CPF"
**Placeholder**: "000.000.000-00"
**Obrigatório**: Sim

**Máscara de Formatação**:
- Formato: `XXX.XXX.XXX-XX`
- Apenas números são aceitos
- Formatação automática durante digitação
- Exemplo: `567.065.455-20`

**Validações Client-Side**:

1. **Campo Vazio**:
   - Mensagem: "CPF é obrigatório"
   - Momento: Ao tentar submeter

2. **Formato Inválido**:
   - Mensagem: "CPF inválido"
   - Momento: Ao perder foco (onBlur)
   - Validação: Deve ter exatamente 11 dígitos

3. **Validação de Dígitos Verificadores** (Opcional mas recomendado):
   - Algoritmo padrão de validação de CPF
   - Mensagem: "CPF inválido"
   - Momento: Ao perder foco (onBlur)

**Comportamento**:
- Auto-capitalização: Desabilitada
- Auto-correção: Desabilitada
- Teclado: Numérico
- Limpar campo: Ícone "X" quando preenchido

### 2.2 Campo Senha

**Tipo**: Secure Text Input
**Label**: "Senha"
**Placeholder**: "Digite sua senha"
**Obrigatório**: Sim

**Validações Client-Side**:

1. **Campo Vazio**:
   - Mensagem: "Senha é obrigatória"
   - Momento: Ao tentar submeter

2. **Comprimento Mínimo**:
   - Mínimo: 4 caracteres (baseado no sistema legado)
   - Mensagem: "Senha deve ter no mínimo 4 caracteres"
   - Momento: Ao perder foco (onBlur)

**Comportamento**:
- Mostrar/Ocultar senha: Ícone de olho (toggle)
- Auto-capitalização: Desabilitada
- Auto-correção: Desabilitada
- Teclado: Padrão (permite caracteres especiais)

### 2.3 Checkbox "Lembrar-me"

**Tipo**: Checkbox
**Label**: "Lembrar-me"
**Valor Padrão**: Desmarcado (false)
**Obrigatório**: Não

**Comportamento**: Ver seção 3.1

### 2.4 Botão "ENTRAR"

**Tipo**: Button (Submit)
**Texto**: "ENTRAR" (uppercase)
**Estado Inicial**: Habilitado

**Estados**:

1. **Normal**: Cor `#0088DD`
2. **Pressed**: Cor `#0073BB`
3. **Loading**: 
   - Mostrar spinner/activity indicator
   - Texto: "ENTRANDO..." ou apenas spinner
   - Desabilitar interação
4. **Disabled**: 
   - Cor: `#999999`
   - Opacidade: 0.5

**Validação Antes de Submeter**:
- CPF preenchido e válido
- Senha preenchida e com mínimo 4 caracteres
- Se validações falharem: Mostrar mensagens de erro e não chamar API

### 2.5 Link "Esqueci minha senha"

**Tipo**: Link/TouchableOpacity
**Texto**: "Esqueci minha senha"
**Cor**: Branco (#FFFFFF)
**Posicionamento**: Abaixo do botão "ENTRAR"

**Comportamento**:
- Navegar para tela de recuperação de senha
- **Nota**: Funcionalidade a ser implementada em fase futura

---

## 🔐 3. REGRAS DE NEGÓCIO

### 3.1 Funcionalidade "Lembrar-me"

**Objetivo**: Manter o usuário autenticado entre sessões do aplicativo.

**Comportamento Quando MARCADO**:

1. **Armazenamento Persistente**:
   - Salvar CPF do usuário em storage seguro (AsyncStorage ou SecureStore)
   - Salvar token de autenticação em storage seguro
   - Salvar flag `rememberMe: true`

2. **Próxima Abertura do App**:
   - Verificar se existe token válido no storage
   - Se token existe e é válido: Fazer login automático (silent login)
   - Se token existe mas expirou: Limpar storage e mostrar tela de login
   - Pré-preencher campo CPF com valor salvo

3. **Duração da Sessão**:
   - Token permanece válido por 30 dias (configuração do servidor)
   - Após 30 dias: Usuário deve fazer login novamente

**Comportamento Quando DESMARCADO**:

1. **Armazenamento Temporário**:
   - Salvar token apenas em memória (state/context)
   - NÃO salvar em storage persistente
   - Salvar flag `rememberMe: false`

2. **Próxima Abertura do App**:
   - Sempre mostrar tela de login
   - Campos vazios (não pré-preencher)

3. **Duração da Sessão**:
   - Token válido apenas enquanto app está em execução
   - Ao fechar app: Token é perdido

**Implementação Recomendada**:

```javascript
// Pseudo-código (não é código real)

// Ao fazer login com sucesso:
if (rememberMe) {
  await SecureStore.setItemAsync('userCpf', cpf);
  await SecureStore.setItemAsync('authToken', token);
  await SecureStore.setItemAsync('rememberMe', 'true');
} else {
  // Apenas salvar em context/state
  setAuthToken(token);
}

// Ao abrir o app:
const rememberMe = await SecureStore.getItemAsync('rememberMe');
if (rememberMe === 'true') {
  const token = await SecureStore.getItemAsync('authToken');
  if (token) {
    // Validar token com API
    // Se válido: Fazer login automático
    // Se inválido: Limpar storage e mostrar login
  }
}

// Ao fazer logout:
await SecureStore.deleteItemAsync('userCpf');
await SecureStore.deleteItemAsync('authToken');
await SecureStore.deleteItemAsync('rememberMe');
```

### 3.2 Fluxo de Autenticação (2 Etapas)

**IMPORTANTE**: O sistema RDO App Piscinas usa autenticação em 2 etapas:

**Etapa 1: Login do Usuário**
- Endpoint: `POST /api/Account/Login`
- Input: CPF + Senha
- Output: Token de autenticação + Dados do usuário
- **Nota**: Nesta etapa, o usuário está autenticado mas ainda NÃO selecionou uma obra

**Etapa 2: Seleção de Obra**
- Endpoint: `POST /api/Obra/Selecionar`
- Input: ID da Obra
- Output: Contexto completo (usuário + obra + permissões)
- **Nota**: Apenas após esta etapa o usuário pode acessar funcionalidades do app

**Fluxo no Mobile**:

1. Usuário faz login (Etapa 1)
2. App recebe lista de obras disponíveis
3. Se usuário tem apenas 1 obra: Selecionar automaticamente
4. Se usuário tem múltiplas obras: Mostrar tela de seleção
5. Após seleção (Etapa 2): Navegar para tela principal

### 3.3 Tratamento de Erros

**Erros de Validação** (Client-Side):
- Mostrar mensagem abaixo do campo com erro
- Cor da mensagem: `#D04541` (vermelho)
- Não chamar API se houver erros de validação

**Erros da API** (Server-Side):

1. **Credenciais Inválidas** (401 Unauthorized):
   - Mensagem: "CPF ou senha incorretos"
   - Posição: Abaixo do botão "ENTRAR"
   - Limpar campo senha
   - Manter foco no campo senha

2. **Usuário Inativo** (403 Forbidden):
   - Mensagem: "Usuário inativo. Entre em contato com o administrador."
   - Posição: Abaixo do botão "ENTRAR"

3. **Erro de Conexão** (Network Error):
   - Mensagem: "Erro de conexão. Verifique sua internet e tente novamente."
   - Posição: Abaixo do botão "ENTRAR"
   - Botão: "TENTAR NOVAMENTE"

4. **Erro do Servidor** (500 Internal Server Error):
   - Mensagem: "Erro no servidor. Tente novamente mais tarde."
   - Posição: Abaixo do botão "ENTRAR"

5. **Timeout**:
   - Timeout: 30 segundos
   - Mensagem: "A requisição demorou muito. Tente novamente."
   - Posição: Abaixo do botão "ENTRAR"

**Comportamento Geral de Erros**:
- Vibração leve do dispositivo (opcional)
- Animação de shake nos campos com erro
- Manter dados preenchidos (exceto senha em caso de credenciais inválidas)

### 3.4 Segurança

**Armazenamento de Credenciais**:
- ❌ NUNCA armazenar senha em plain text
- ❌ NUNCA armazenar senha criptografada
- ✅ Armazenar apenas token de autenticação
- ✅ Usar SecureStore/Keychain para armazenamento seguro

**Comunicação com API**:
- ✅ Sempre usar HTTPS
- ✅ Validar certificado SSL
- ✅ Incluir token no header: `Authorization: Bearer {token}`

**Timeout de Sessão**:
- Token expira após 30 dias (se "Lembrar-me" marcado)
- Token expira ao fechar app (se "Lembrar-me" desmarcado)
- Ao expirar: Redirecionar para tela de login

---

## 🔌 4. INTEGRAÇÃO COM API

### 4.1 Endpoint de Login

**URL**: `POST /api/Account/Login`

**Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "cpf": "56706545520",
  "senha": "1234"
}
```

**Notas sobre Request**:
- CPF deve ser enviado SEM formatação (apenas números)
- Senha é case-sensitive

**Response Success (200 OK)**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usuario": {
    "id": 123,
    "nome": "Ricardo Freire",
    "cpf": "56706545520",
    "email": "ricardo@example.com",
    "ativo": true
  },
  "obras": [
    {
      "id": 1,
      "nome": "Escola Municipal João Silva",
      "idObraColaborador": 456
    },
    {
      "id": 2,
      "nome": "Escola Estadual Maria Santos",
      "idObraColaborador": 457
    }
  ]
}
```

**Response Error (401 Unauthorized)**:
```json
{
  "success": false,
  "message": "CPF ou senha incorretos"
}
```

**Response Error (403 Forbidden)**:
```json
{
  "success": false,
  "message": "Usuário inativo"
}
```

### 4.2 Validação de Token

**URL**: `GET /api/Account/ValidateToken`

**Headers**:
```
Authorization: Bearer {token}
```

**Response Success (200 OK)**:
```json
{
  "valid": true,
  "expiresAt": "2026-02-26T10:30:00Z"
}
```

**Response Error (401 Unauthorized)**:
```json
{
  "valid": false,
  "message": "Token inválido ou expirado"
}
```

**Quando Usar**:
- Ao abrir o app (se "Lembrar-me" estava marcado)
- Antes de fazer requisições importantes
- Periodicamente (a cada 5 minutos) se app está em uso

---

## 📱 5. ESPECIFICAÇÕES TÉCNICAS MOBILE

### 5.1 Responsividade

**Tamanhos de Tela Suportados**:
- Smartphones: 320px - 428px (largura)
- Tablets: 768px - 1024px (largura)

**Orientação**:
- Primária: Portrait (vertical)
- Secundária: Landscape (horizontal) - opcional

**Adaptações por Tamanho**:

**Smartphones Pequenos** (< 375px):
- Logo: 35px
- Campos: Altura 44px
- Botão: Altura 44px
- Espaçamento: Reduzido em 20%

**Smartphones Médios** (375px - 414px):
- Logo: 43px (padrão)
- Campos: Altura 48px
- Botão: Altura 48px
- Espaçamento: Padrão

**Smartphones Grandes** (> 414px):
- Logo: 50px
- Campos: Altura 52px
- Botão: Altura 52px
- Espaçamento: Aumentado em 10%

### 5.2 Acessibilidade

**Requisitos Mínimos**:

1. **Labels Descritivos**:
   - Todos os campos devem ter labels visíveis
   - Usar `accessibilityLabel` para leitores de tela

2. **Contraste de Cores**:
   - Mínimo: 4.5:1 (WCAG AA)
   - Branco sobre `#27496F`: 7.2:1 ✅

3. **Tamanho de Toque**:
   - Mínimo: 44x44 pontos (iOS) / 48x48 dp (Android)
   - Aplicar a todos os elementos interativos

4. **Feedback Tátil**:
   - Vibração leve ao tocar botões
   - Vibração ao ocorrer erro

5. **Leitores de Tela**:
   - Suporte a VoiceOver (iOS)
   - Suporte a TalkBack (Android)

### 5.3 Performance

**Tempos Máximos**:
- Renderização inicial: < 1 segundo
- Resposta ao toque: < 100ms
- Chamada de API: < 5 segundos (ideal), < 30 segundos (timeout)

**Otimizações**:
- Lazy loading de imagens
- Debounce em validações (300ms)
- Cache de assets (logo, fontes)

### 5.4 Testes

**Cenários de Teste Obrigatórios**:

1. **Login com Sucesso**:
   - CPF: `567.065.455-20`
   - Senha: `1234`
   - Resultado: Navegar para seleção de obra

2. **Login com Credenciais Inválidas**:
   - CPF: `111.111.111-11`
   - Senha: `wrong`
   - Resultado: Mensagem de erro

3. **Validação de Campos Vazios**:
   - Deixar campos vazios
   - Clicar "ENTRAR"
   - Resultado: Mensagens de erro

4. **Lembrar-me Marcado**:
   - Fazer login com checkbox marcado
   - Fechar e reabrir app
   - Resultado: Login automático

5. **Lembrar-me Desmarcado**:
   - Fazer login com checkbox desmarcado
   - Fechar e reabrir app
   - Resultado: Tela de login vazia

6. **Modo Offline**:
   - Desabilitar internet
   - Tentar fazer login
   - Resultado: Mensagem de erro de conexão

---

## 🎬 6. FLUXO DE NAVEGAÇÃO

### 6.1 Fluxo Completo

```
[Splash Screen]
       ↓
[Verificar Token Salvo]
       ↓
   ┌───┴───┐
   │       │
[Token    [Token
Válido]   Inválido/
   │      Ausente]
   │       │
   │   [Login Screen] ← VOCÊ ESTÁ AQUI
   │       ↓
   │   [Autenticação]
   │       ↓
   │   ┌───┴───┐
   │   │       │
   │ [1 Obra] [Múltiplas
   │   │       Obras]
   │   │       │
   │   │   [Escolher Obra]
   │   │       │
   └───┴───────┘
       ↓
[Home Screen / Dashboard]
```

### 6.2 Navegação Após Login

**Se usuário tem 1 obra**:
1. Selecionar obra automaticamente
2. Navegar direto para Home Screen

**Se usuário tem múltiplas obras**:
1. Navegar para tela "Escolher Obra"
2. Usuário seleciona obra
3. Navegar para Home Screen

**Se usuário não tem obras**:
1. Mostrar mensagem: "Você não está associado a nenhuma obra. Entre em contato com o administrador."
2. Botão "SAIR" para voltar ao login

---

## 📦 7. ASSETS NECESSÁRIOS

### 7.1 Fontes

**Fontello** (ícone do logo):
- Arquivo: `fontello.ttf`
- Unicode do logo: `\e80c`
- **Nota**: Solicitar arquivo ao time de design

**SF UI Display**:
- `SFUIDisplay-Light.ttf`
- `SFUIDisplay-Medium.ttf`
- `SFUIDisplay-Bold.ttf`
- **Nota**: Solicitar arquivos ao time de design

### 7.2 Imagens

**Logo** (fallback se fonte não carregar):
- `logo.png` (1x, 2x, 3x)
- Tamanho base: 43x43 px
- Formato: PNG com transparência

**Ícones**:
- `eye-open.png` (mostrar senha)
- `eye-closed.png` (ocultar senha)
- `clear-icon.png` (limpar campo)

---

## ✅ 8. CHECKLIST DE IMPLEMENTAÇÃO

### Interface
- [ ] Tela com fundo azul (#27496F)
- [ ] Logo centralizado no topo (ícone + texto "Piscinas")
- [ ] Campo CPF com máscara (XXX.XXX.XXX-XX)
- [ ] Campo Senha com toggle mostrar/ocultar
- [ ] Checkbox "Lembrar-me"
- [ ] Botão "ENTRAR" com estados (normal, pressed, loading, disabled)
- [ ] Link "Esqueci minha senha"
- [ ] Mensagens de erro abaixo dos campos
- [ ] Responsivo para diferentes tamanhos de tela

### Validações
- [ ] Validação de CPF vazio
- [ ] Validação de CPF inválido (formato)
- [ ] Validação de senha vazia
- [ ] Validação de senha curta (< 4 caracteres)
- [ ] Desabilitar botão durante loading
- [ ] Mostrar spinner durante requisição

### Funcionalidades
- [ ] Integração com API de login
- [ ] Tratamento de erros da API
- [ ] Armazenamento seguro de token (se "Lembrar-me")
- [ ] Validação de token ao abrir app
- [ ] Login automático (se token válido)
- [ ] Pré-preenchimento de CPF (se "Lembrar-me")
- [ ] Navegação para tela de seleção de obra
- [ ] Seleção automática (se 1 obra apenas)

### Segurança
- [ ] Comunicação HTTPS
- [ ] Armazenamento seguro (SecureStore/Keychain)
- [ ] Não armazenar senha
- [ ] Validar certificado SSL
- [ ] Timeout de requisição (30s)

### Acessibilidade
- [ ] Labels descritivos
- [ ] Suporte a leitores de tela
- [ ] Tamanho mínimo de toque (44x44 / 48x48)
- [ ] Contraste adequado (4.5:1)
- [ ] Feedback tátil

### Testes
- [ ] Teste de login com sucesso
- [ ] Teste de credenciais inválidas
- [ ] Teste de campos vazios
- [ ] Teste de "Lembrar-me" marcado
- [ ] Teste de "Lembrar-me" desmarcado
- [ ] Teste de modo offline
- [ ] Teste de timeout
- [ ] Teste em diferentes tamanhos de tela

---

## 📞 9. CONTATOS E SUPORTE

**Dúvidas sobre API**:
- Consultar documentação da API
- Endpoint de documentação: `/swagger` (ambiente de desenvolvimento)

**Dúvidas sobre Design**:
- Consultar time de design
- Referência: Aplicação web em `https://[URL_DO_SERVIDOR]`

**Dúvidas sobre Regras de Negócio**:
- Consultar Product Owner
- Documentação adicional: `LEGACY-LOGIN-ANALYSIS.md`

---

## 📝 10. NOTAS IMPORTANTES

1. **CPF sem Formatação na API**: Sempre remover pontos e traços antes de enviar para API
2. **Token JWT**: Armazenar de forma segura, nunca em AsyncStorage comum
3. **Autenticação em 2 Etapas**: Login + Seleção de Obra (não esquecer!)
4. **Timeout**: Configurar timeout de 30 segundos para requisições
5. **Modo Offline**: Implementar detecção de conexão antes de chamar API
6. **Testes**: Usar CPF `567.065.455-20` e senha `1234` para testes

---

**FIM DO BRIEFING**

*Boa sorte com a implementação, Carlos! 🚀*
