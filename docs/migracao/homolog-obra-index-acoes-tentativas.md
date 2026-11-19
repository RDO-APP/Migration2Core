# Homolog — Obras `/Obra/Index` ações (convite / copiar)

**Trilha:** EQ-R · **Página:** menu ☰ Obras · SPA `ObraIndexPage` · BFF `GET /api/bff/obras/index/bootstrap`  
**Usuário smoke:** CPF `538.219.635-49` · Diretor Contratada · Georges `824.351.035-49`  
**Prod ref:** `Client/Views/Obra/index.html` — `fa-send` · `fa-copy` · `fa-edit` · `fa-trash-o`

---

## Tentativas

| # | Hipótese | Solução aplicada | Resultado | Evidência |
|---|----------|------------------|-----------|-----------|
| **O1** | Ações faltavam por GPA só em `/obra/index` | Bootstrap com `PermissionHelper(…, "/obra/index")` | Só **editar** + **excluir** | Print migração sem avião/copiar; prod com 4 ícones |
| **O2** | GPA canônico em `/obra/lista` (cms §3.1) | `CanObraLista` = `/obra/index` **∪** `/obra/lista` + BFF delete/convidar | Botões **no DOM** (title funciona) mas **ícones invisíveis** | Tooltip «Enviar Convite» / «Copiar Obra» no espaço vazio; editar/lixeira OK |
| **O3** | Subset FA em `escolher.css` sem `fa-send`/`fa-copy` | Glifos `\f1d8` / `\f0c5` (+ `fa-search`) em `wwwroot/css/escolher.css` e `.lista-tarefas` em `cards-page.css` | **Smoke OK 11/nov** — homolog (lista `1a ETAPA…`) com avião+copiar+editar+lixeira na FACHADA | Print Lucio FACHADA OESTE |
| **O4** | `Erro 500 (enviar convite)` | `Forbid()` → 403 DTO; try/catch BFF+serviço; `SmtpMailService` compartilhado; Guid convite com hífens (prod); SPA parse 400 → `errorMessage` | Código local 19/11 — smoke pós-deploy | Toast deve ser sucesso **ou** mensagem SMTP/`Já existe…` — **não** 500 genérico |
| **O5** | Copiar obra = stub Em migração | `GET /api/bff/obras/cadastro?copiar={id}` · `BuildCopiaAsync` · SPA `/Obra/Cadastro?copiar=` · Salvar = nova | Código local 19/11 — smoke pós-deploy | Cabeçalho pré-preenchido; colab/equip **depois** (gap vs prod) |

---

## Smoke pós-O4 / O5 (após publish+deploy)

### Convite (O4)

1. Obra com só contratante **ou** só contratada → Enviar Convite → toast sucesso **ou** *Não foi possível enviar o e-mail: …* (SMTP).
2. Obra com **ambas** empresas → *Já existe empresa contratante e contratada…*
3. E-mail vazio/inválido → validação sem 500.
4. Link `/convidada` → stub Em migração (**esperado** neste ciclo).

### Copiar (O5)

1. Index → Copiar na obra → cadastro «Copiar obra» com nome/datas/endereço/empresas.
2. Alterar nome → Salvar → obra nova na lista; original intacta.
3. Sem permissão `copiarObra` → botão oculto / 403.

**SMTP homolog:** mesmo `Smtp:*` do Esqueci senha (E1). Sem host válido o e-mail falha com mensagem clara — configurar no EC2 fora do Git.

**Fora deste ciclo:** aceitar convite (`/convidada` completo) · clone em massa colab/equip no mesmo Salvar.

**Filtro «Contratante»:** paridade prod — **não** é bug desta fila.
