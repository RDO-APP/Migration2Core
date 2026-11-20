# Homolog — `/convidada` aceite (Contratante / Contratada)

**Trilha:** EQ-R · **M7+** · **Prod ref:** `#/convidada` · `Client/Views/Convidada/Index.html` + `ConvidadaController.js`  
**Homolog hoje:** SPA + BFF (`/convidada` · `BffConvidadaController` · `ConvidadaAceiteService`) — **não** stub EmMigracao  
**Convite e-mail OK (O4w · 20/11):** toast + Gmail · link `?o={guid}` · **C4 PASS** 2026-11-20 ~15:25 

---

## Papel no fluxo

1. Diretor envia convite (obra com **só** contratante **ou** só contratada).  
2. E-mail: “ser **CONTRATANTE** …” ou CONTRATADA + link `/convidada?o={obr_cd_convite}`.  
3. Convidado preenche empresa + usuário → **ACESSAR** → sessão → `/obra/escolher`.  
4. Código do convite é **anulado** após aceite.

`tipoConvite`: **1** = falta contratante (`empresa1` null) · **2** = falta contratada (`empresa2` null).  
Grupo: `gru_st_contratante == tipoConvite` ∧ `gru_st_diretor == 1` ∧ mesma licença da obra.

---

## Campos (prod)

### Dados da Empresa

| Campo | Model | Regra |
|-------|--------|--------|
| CNPJ | `cnpjEmpresa` | obrigatório · válido · blur → `ObterEmpresaCNPJ` (preenche + trava se existir) |
| Razão Social | `razaoSocial` | obrigatório · ≥ 3 |
| Nome Fantasia | `nomeFantasia` | obrigatório · ≥ 3 |
| Setor | `idSetor` | lista `GET api/setor/Lista` |
| Ramo | `idRamo` | lista `GET api/ramo/Lista` |

### Dados do Usuário

| Campo | Model | Regra |
|-------|--------|--------|
| CPF | `cpf` | obrigatório · válido · blur → `ObterColaboradorCPF` (preenche + trava se existir) |
| Nome | `nomeColaborador` | obrigatório · ≥ 3 |
| E-mail | `emailColaborador` | obrigatório · e-mail válido |
| Telefone | `telefoneColaborador` | obrigatório |
| UF | `idUf` | `POST api/municipio/ListaUFConvidada` |
| Município | `idMunicipio` | `POST api/municipio/ListaMunicipioConvidada` (body = idUf) |
| Senha | `senha` | obrigatório · ≥ 4 · = confirmação |
| Confirmação | `confirmacaoSenha` | idem |
| Cargo | `cargo` | obrigatório · `POST api/cargo/Lista/` |

**Query:** `o` = `obr_cd_convite` (Guid com hífens) → enviado como `idObra` no POST (nome legado confuso).

---

## APIs prod

| Call | Uso |
|------|-----|
| `POST api/obra/VerificarConvite` `{ idObra: guid }` | Convite válido; senão bloqueia form |
| `GET api/setor/Lista` · `GET api/ramo/Lista` · `POST api/cargo/Lista` | Lookups |
| `POST api/municipio/ListaUFConvidada` · `ListaMunicipioConvidada` | UF/município (rotas *Convidada* = anônimas) |
| `POST api/empresa/ObterEmpresaCNPJ` | Autocomplete empresa |
| `POST api/Colaborador/ObterColaboradorCPF` | Autocomplete usuário |
| `POST api/login/AcessoConvidada` | Salva colab + empresa · `AtualizarConvidada` · zera `obr_cd_convite` · `LoginUser` |
| Cancelar | → `#/login` |

---

## MVP Core (ordem)

| # | Entrega |
|---|---------|
| **C1** | `AllowAnonymous` SPA `/convidada` (sai do stub) + bootstrap BFF (obra nome/papel + lookups) |
| **C2** | `POST …/verificar` · `POST …/acessar` (paridade `AcessoConvidada` + cookie Login) |
| **C3** | Autocomplete CNPJ/CPF + validações client |
| **C4** | Smoke: link do e-mail → ACESSAR → Escolher · Contratante preenchido na Index |

**Fora do MVP:** clone listas colab/equip no convite · polish pixel-perfect Bootstrap 3.

---

## Tentativas

| # | Data | Nota | Resultado |
|---|------|------|-----------|
| **C0** | 2026-11-20 ~11:20 | O4 SMTP OK · stub visto no link | — |
| **C1** | 2026-11-20 ~11:30 | SPA `/convidada` + BFF bootstrap/lookups | ☑ código |
| **C2** | 2026-11-20 ~11:30 | `POST …/acessar` + cookie → Escolher | ☑ código · smoke via C4 |
| **C3** | 2026-11-20 ~11:30 | Autocomplete CNPJ/CPF | ☑ código |
| **C4** | 2026-11-20 ~15:25 | Contratante → Escolher · Diretor Contratante MIGRAÇÃO 15/11 | ☑ **PASS** |

---

## Smoke pós-deploy (Lucio · C4) — **PASS ~15:25**

1. Deploy OK (`Deploy homolog Core Linux OK` · Login 200).  
2. Abrir o link do e-mail **ou** reenviar Convite na obra (se Guid já invalidado).  
3. Página **não** é mais stub EmMigracao — form Empresa + Usuário.  
4. CNPJ blur (empresa existente trava campos) · CPF blur (idem).  
5. **ACESSAR** → redirect `/Obra/Escolher`.  
6. Em `/Obra/Index`, coluna **Contratante** preenchida na obra do convite.  
7. Mesmo link de novo → “convite já foi utilizado”.
