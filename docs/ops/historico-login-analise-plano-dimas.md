# Registro de Histórico de Login — Análise e Plano de Implementação

**Para:** Dimas  
**Data:** Junho 2026  
**Assunto:** A funcionalidade de registro de acesso de usuários existe no Equipamentos mas está **incompleta** no Piscinas (web) e **parcialmente quebrada** no App do Piscineiro (mobile)

---

## O que é essa funcionalidade

Toda vez que um usuário faz login no sistema, o RDO registra esse acesso na tabela `historico_login` do banco de dados `novo_rdoapp`. Isso permite que o administrador veja quem acessou o sistema, quando, de qual obra, e com qual CPF/e-mail.

Você pode visualizar esse histórico acessando:

```
https://sistema.rdoapp.com.br/historicoacesso/index
```

Essa página só aparece no menu para usuários com perfil **administrador**.

---

## O que é registrado na tabela

A tabela `historico_login` guarda as seguintes informações a cada acesso:

| Campo | Descrição |
|---|---|
| `col_id_colaborador` | ID do colaborador |
| `col_nr_cpf` | CPF do colaborador |
| `col_nm_colaborador` | Nome do colaborador |
| `col_ds_email` | E-mail do colaborador |
| `obr_id_obra` | ID da obra selecionada (pode ser nulo no primeiro login) |
| `obr_ds_obra` | Nome da obra selecionada |
| `data_login` | Data e hora do acesso |

O registro acontece em **dois momentos**:

1. **Login com CPF e senha** — registra o acesso com os campos da obra em branco (NULL)
2. **Seleção de obra** — registra um segundo acesso, desta vez com `obr_id_obra` e `obr_ds_obra` preenchidos

---

## Status atual por plataforma

### ✅ Equipamentos (sistema legado — `sistema.rdoapp.com.br`)

**Funciona completamente.** O fluxo é:

1. Usuário digita CPF + senha → backend chama `LoginUser` → insere linha no `historico_login` com obra NULL
2. Usuário seleciona uma obra → backend chama `LoginObra` → insere segunda linha com obra preenchida
3. Admin acessa `/historicoacesso/index` → vê tabela com filtros por CPF, nome, e-mail e data

Código responsável: `rdoappProject/Api/Models/LoginModel.cs` → método `InserirHistoricoLogin()`

---

### ⚠️ Piscinas Web (novo sistema — `piscinas.rdoapp.com.br`)

**O registro do login já funciona, mas a página de visualização não existia.**

- O `AccountController` já chama `InserirHistoricoLogin()` no momento do login → linha é gravada no banco ✅
- Porém, a rota `/historicoacesso/index` não tinha controller nem view — levava a um erro 404 ❌
- A página de admin para visualizar o histórico **foi implementada** e os arquivos já existem no código local ✅

**O que foi criado no projeto `RDO-CleanMigration-2026`:**

```
RdoApp.Core/Controllers/HistoricoAcessoController.cs   ← ARQUIVO NOVO
RdoApp.Core/Views/HistoricoAcesso/Index.cshtml         ← ARQUIVO NOVO
```

- `HistoricoAcessoController.cs` — controller com duas actions:
  - `GET /historicoacesso/index` — exibe a página (somente admin)
  - `POST /historicoacesso/buscar` — endpoint JSON com filtros por CPF, nome, e-mail e data, resultado paginado

- `Index.cshtml` — formulário de filtros + tabela com colunas Data, CPF, Nome, E-Mail, Obra + paginação

Nenhum arquivo existente foi modificado. Apenas os dois arquivos acima foram criados.

Após o deploy do Piscinas web, o admin poderá acessar `/historicoacesso/index` normalmente.

---

### ❌ App do Piscineiro (mobile — `RDOAppPiscinasMobile`)

**Parcialmente quebrado.** Dois problemas independentes:

#### Problema 1 — Login com CPF funciona ✅

O app envia `POST /api/login/LoginUser` com `{ cpf, senha }` → o backend Piscinas processa normalmente e grava o registro no `historico_login` com obra NULL. Essa parte está correta.

#### Problema 2 — Seleção de obra NÃO registra ❌

Quando o usuário seleciona uma obra no app, o código atual chama:

```
POST /api/Usuario/LoginObra   ← endpoint que não existe no backend
```

O endpoint correto é:

```
POST /api/login/LoginObra
```

Além disso, o payload enviado está errado. O backend espera apenas `{ idUsuario, idObra }`, mas o app envia campos extras que não são lidos.

**Consequência:** A segunda linha do histórico — aquela que registra qual obra o piscineiro acessou — nunca é gravada para usuários do app mobile. O admin não consegue saber por qual obra o piscineiro entrou.

---

## O que precisa ser feito

### Para o Piscinas Web

**Já implementado.** Os dois arquivos foram criados no projeto `RDO-CleanMigration-2026` e estão prontos para deploy:

- `RdoApp.Core/Controllers/HistoricoAcessoController.cs`
- `RdoApp.Core/Views/HistoricoAcesso/Index.cshtml`

Nenhuma outra mudança é necessária no lado web.

### Para o App do Piscineiro

Uma correção no arquivo `src/services/obraService.ts` do repositório `RDOAppPiscinasMobile`:

**Antes (código atual — quebrado):**
```typescript
export async function LoginObra(
  {idObra, idUsuario, obra, user}: 
  {idObra: number, idUsuario: number, obra: any, user: any}
) {
  const OPTIONS = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
    body: JSON.stringify({ idObra, idUsuario, obra, user }),
  }
  // ERRADO — esse endpoint não existe
  const response = await handleCall(BASE_URL, '/api/Usuario/LoginObra', OPTIONS)
  return await handleResponse<unknown>(response);
}
```

**Depois (corrigido):**
```typescript
export async function LoginObra(
  { idObra, idUsuario }: { idObra: number; idUsuario: number }
) {
  const OPTIONS = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
    // Backend lê apenas param.idUsuario e param.idObra
    body: JSON.stringify({ idObra, idUsuario }),
  };

  // CORRETO — mesmo endpoint que o sistema web usa
  const response = await handleCall(BASE_URL, '/api/login/LoginObra', OPTIONS);
  return handleResponse<unknown>(response);
}
```

Essa é a única mudança necessária no app mobile. Uma linha de endpoint e o cleanup do payload.

---

## Resumo executivo

| Plataforma | Login grava histórico? | Seleção de obra grava histórico? | Admin pode visualizar? |
|---|---|---|---|
| Equipamentos (legado web) | ✅ Sim | ✅ Sim | ✅ Sim |
| Piscinas (novo web) | ✅ Sim | ✅ Sim | ✅ Sim — página criada, aguarda deploy |
| App do Piscineiro (mobile) | ✅ Sim | ❌ Não — endpoint errado | ✅ Aparece no histórico web |

*Disponível após deploy.

---

## Impacto dessa correção

Sem essa funcionalidade completa, o administrador não consegue:

- Saber **quando** um piscineiro acessou o sistema pelo app
- Saber **qual obra** o piscineiro entrou
- Auditar acessos suspeitos ou indevidos
- Confirmar se um colaborador realmente trabalhou em um dia específico

Com a correção do endpoint no app mobile, todos os acessos — web e mobile — passam a aparecer de forma unificada na mesma página de histórico do Piscinas.

---

## Arquivos relevantes para referência

| Arquivo | Sistema | Papel |
|---|---|---|
| `rdoappProject/Api/Models/LoginModel.cs` | Equipamentos (legado) | Lógica completa de `InserirHistoricoLogin`, `LoginUser`, `LoginObra`, `GetHistoricoLogin` |
| `rdoappProject/Api/Controllers/LoginController.cs` | Equipamentos (legado) | Endpoint `/api/login/LoginObra` e `/api/login/GetHistoricoLogin` |
| `rdoappProject/Client/Views/HistoricoAcesso/index.html` | Equipamentos (legado) | Tela de histórico com filtros (AngularJS) |
| `RdoApp.Core/Controllers/AccountController.cs` | Piscinas (novo web) | Já chama `InserirHistoricoLogin` no login |
| `RdoApp.Core/Controllers/HistoricoAcessoController.cs` | Piscinas (novo web) | **Criado** — controller com GET (página) e POST (busca JSON paginada) |
| `RdoApp.Core/Views/HistoricoAcesso/Index.cshtml` | Piscinas (novo web) | **Criado** — tela de histórico com filtros, aguarda deploy |
| `src/services/obraService.ts` | App do Piscineiro (mobile) | **Precisa corrigir** o endpoint de `LoginObra` |
| `src/services/authService.ts` | App do Piscineiro (mobile) | Login com CPF já está correto |
