# Plano clique a clique — `homolog.sistema.rdoapp.com.br` (homolog Equipamentos)

**Objetivo:** URL oficial de homolog **Equipamentos / obras** (incl. Migration2Core), **sem** usar nomes “piscinas” nem **`hm`**.  
**ALB:** Sistema-RDO · **Target group:** `tg-equipamentos` (mesmo backend que `hm` hoje).  
**Referência infra:** [`aws-route53-rdoapp-dns-homolog-tecnico.md`](aws-route53-rdoapp-dns-homolog-tecnico.md)

---

## Sobre `hm.rdoapp.com.br` — apagar ou manter?

| Pergunta | Resposta |
|----------|----------|
| **Uso agora?** | Só histórico/atalho; **502** hoje; mesma função que **`homolog.sistema`** terá. |
| **Uso depois de `homolog.sistema` OK?** | **Nenhum** planejado para Equipamentos. |
| **Por que não apagar *antes* de criar o novo?** | Não é obrigatório manter — só **não apague primeiro** para não ficar sem nenhum host apontando para `tg-equipamentos` enquanto configura o novo nome. |
| **Quando apagar `hm`?** | **Logo após** passo 8 (E2E verde em `homolog.sistema`) — **mesma sessão**, passos 9A–9C abaixo. |

**`homologacao.piscinas.rdoapp.com.br`:** não apagar neste plano (legado Piscinas / ops); só **deixar de usar** para Equipamentos.

---

## Pré-requisitos

- [ ] Login AWS conta **RDOApp**, região **us-east-2** para EC2/ALB/ACM.
- [ ] Política de banco **A** fechada (homolog RDS — credenciais fora do Git).
- [ ] Tempo estimado: **30–60 min** (DNS + ALB + cert + nginx; app/deploy à parte).

---

## Fase 1 — Route 53 (DNS) — detalhado clique a clique

**Resultado esperado:** registro **`homolog.sistema.rdoapp.com.br`** resolve para o mesmo ALB **Sistema-RDO** que **`hm.rdoapp.com.br`**.  
**Tempo:** ~5–10 min (+ propagação DNS até ~TTL, em geral poucos minutos).

> **Atenção:** Fase 1 **só cria o nome na internet**. Até a **Fase 2** (regra ALB) + backend saudável, o browser pode dar **502** ou cair na regra **padrão** — isso é normal.

---

### Passo 1.1 — Abrir a zona correta

1. Login [Console AWS](https://console.aws.amazon.com/) (conta **RDOApp**).
2. Barra de busca superior: digite **`Route 53`** → Enter.
3. Menu esquerdo: **Zonas hospedadas**.
4. Na tabela, clique no **nome** **`rdoapp.com.br`** (coluna **Nome da zona hospedada**).
   - Deve mostrar **Pública** e ~**35** registros (número pode variar).
5. Confirme o breadcrumb: `Route 53 > Zonas hospedadas > rdoapp.com.br`.

**Errar a zona** (ex.: `livrodeordem.com.br`) cria o registro no domínio errado.

---

### Passo 1.2 — Abrir o registro modelo **`hm`** (só leitura)

Antes de criar, veja o que copiar:

1. Na caixa **Filtrar registros**, digite: **`hm`**.
2. Clique na linha **`hm.rdoapp.com.br`** (ou nome **`hm`**).
3. Anote (painel direito ou detalhes):

| Campo | Anotar seu valor |
|-------|------------------|
| Tipo | deve ser **A** |
| Alias | **Sim** |
| Valor / rotear tráfego para | deve citar **`Sistema-RDO`** ou `dualstack.sistema-rdo-67414…` |
| Política de roteamento | em geral **Simples** |

4. Feche o painel **sem editar** `hm`.

Se `hm` apontar para **Loja-RDO**, **pare** e avise — o modelo estaria errado (esperado: **Sistema-RDO**).

---

### Passo 1.3 — Verificar se `homolog.sistema` já existe

1. Limpe o filtro ou busque: **`homolog.sistema`**.
2. Se **já existir** registro → **não** crie duplicata; pule para **Passo 1.6** (teste DNS).
3. Se **não existir** → continue.

---

### Passo 1.4 — Criar registro (assistente)

1. Botão laranja **Criar registro** (topo da lista de registros).
2. **Criação de registro rápida** ou **Assistente** — use o que mostrar os campos abaixo (no console BR costuma ser um painel lateral).

Preencha **exatamente**:

| Campo (UI português) | Valor |
|----------------------|--------|
| **Nome do registro** | `homolog.sistema` |
| *(texto de ajuda)* | Route 53 completa para **`homolog.sistema.rdoapp.com.br`** — **não** digite o domínio inteiro se a UI já mostra `.rdoapp.com.br` ao lado |
| **Tipo de registro** | **A – IPv4** |
| **Alias** | **Sim** / ativado |
| **Rotear tráfego para** | **Application Load Balancer** ou **Balanceador de carga da aplicação** |
| **Região** | **us-east-2 (Ohio)** |
| **Balanceador de carga** | **Sistema-RDO** (selecione na lista; DNS interno termina em `…elb.amazonaws.com`) |
| **Política de roteamento** | **Política de roteamento simples** |
| **Avaliar integridade do destino** | deixe **Sim** (padrão recomendado para Alias ALB) |
| **TTL** | *(cinza / automático em Alias)* — não precisa preencher |

3. **Não** marque:
   - Tipo **CNAME** (use **A + Alias** para ALB).
   - ALB **Loja-RDO**.
   - Região **us-east-1** ou outra.

4. Clique **Criar registro** / **Criar registros**.

---

### Passo 1.5 — Conferir na tabela

1. Busque **`homolog.sistema`** no filtro.
2. A nova linha deve mostrar:
   - **Nome:** `homolog.sistema.rdoapp.com.br` (ou `homolog.sistema`)
   - **Tipo:** A
   - **Alias:** Sim
   - **Valor:** mesmo padrão de `hm` (`dualstack.sistema-rdo-67414…`)

3. **Exportar (opcional):** botão **Importar zona** / export — backup antes de mudanças futuras.

---

### Passo 1.6 — Testar no Windows (PowerShell)

```powershell
nslookup homolog.sistema.rdoapp.com.br
```

| Resultado | Significado |
|-----------|-------------|
| Endereços **iguais** a `hm` / `sistema` (ex.: `3.151.60.22`, `18.191.114.223`) | **Fase 1 OK** |
| **Non-existent domain** / não encontrado | Aguarde 2–5 min e repita; confira zona `rdoapp.com.br` |
| IPs diferentes de **Loja** / outro ALB | Registro criado no ALB errado — revisar Passo 1.4 |

Comparar:

```powershell
nslookup hm.rdoapp.com.br
nslookup homolog.sistema.rdoapp.com.br
```

IPs devem ser **equivalentes** (mesmo ALB).

---

### Passo 1.7 — Teste browser (expectativa realista)

1. Abra `https://homolog.sistema.rdoapp.com.br/`

| O que vê | Próximo passo |
|----------|----------------|
| **502 Bad Gateway** | Normal **até Fase 2 + 4** — DNS OK, falta regra ALB e/ou `tg-equipamentos` |
| **Login RDO** (improvável só com Fase 1) | Regra padrão pegou tráfego — conferir Fase 2 |
| **Erro de certificado** | Fase 3 (ACM) |
| **Não abre / DNS error** | Voltar Passo 1.5–1.6 |

---

### Erros comuns (Fase 1)

| Erro | Correção |
|------|----------|
| Nome `homolog.sistema.rdoapp.com.br` duplicado na caixa nome | Use só **`homolog.sistema`** |
| Alias **desligado** + IP manual | Ligue **Alias** e escolha **Sistema-RDO** |
| **Loja-RDO** selecionado | Apague registro e recrie com **Sistema-RDO** |
| CNAME para ALB | Apague; ALB usa **A Alias** |

---

### Checklist Fase 1 (marque)

- [ ] Zona **`rdoapp.com.br`** aberta  
- [ ] Modelo **`hm`** conferido → **Sistema-RDO**  
- [ ] Registro **`homolog.sistema`** criado (A, Alias)  
- [ ] `nslookup homolog.sistema.rdoapp.com.br` responde  
- [ ] IPs alinhados com `hm`  

**Concluída Fase 1 →** continuar **[Fase 2 — ALB](#fase-2--alb-regra-de-host)** (regra Host `homolog.sistema.rdoapp.com.br` → `tg-equipamentos`).

---

## Fase 2 — ALB (regra de host) {#fase-2--alb-regra-de-host}

**Pré-requisito:** Fase 1 OK — `nslookup homolog.sistema.rdoapp.com.br` → ex.: `18.191.114.223`, `3.151.60.22` (ALB **Sistema-RDO**).

**Resultado esperado:** tráfego com Host **`homolog.sistema.rdoapp.com.br`** vai para **`tg-equipamentos`** (igual `hm`), **não** para a regra padrão **`Ipv4-RDO`**.

---

### Passo 2.1 — Região e load balancer

1. Console AWS → barra de busca: **EC2**.
2. Canto superior direito: região **Leste dos EUA (Ohio) / us-east-2** (mesma do ALB).
3. Menu esquerdo: **Balanceadores de carga** / **Load balancers**.
4. Clique **`Sistema-RDO`** (Tipo: application · Esquema: Internet-facing).

---

### Passo 2.2 — Abrir regras do HTTPS

1. Aba **Receptores e regras**.
2. Na linha **HTTPS:443**, clique **Ver regras** (ou link do número de regras **4**).
3. Você deve ver a lista atual:

| Prioridade | Host (resumo) | Target group |
|------------|---------------|--------------|
| 1 | `piscinas.rdoapp.com.br` | tg-piscinas |
| 2 | `hm.rdoapp.com.br` | tg-equipamentos |
| 3 | `homologacao.piscinas.rdoapp.com.br` | tg-equipamentos |
| Última | Padrão | Ipv4-RDO |

---

### Passo 2.3 — Adicionar regra

1. Botão **Adicionar regra** / **Insert rule** (ícone **+** entre linhas ou no topo).
2. Escolha prioridade: **inserir acima da regra padrão** — ex. nova regra com prioridade **4** *ou* **entre 3 e padrão** (console pode renumerar).

**Condição (IF):**

1. **Adicionar condição** → tipo **Host header** / **Cabeçalho de host**.
2. Valor **exato:** `homolog.sistema.rdoapp.com.br`  
   - Sem `https://`, sem barra final, **minúsculas** como no certificado.

**Ação (THEN):**

1. **Encaminhar para** / **Forward to** → **Grupo de destinos** / **Target group**.
2. Selecione **`tg-equipamentos`** (nome completo pode ser `tg-equipamentos-…` — o mesmo da regra **hm**).
3. Peso **100%**.
4. **Aderência** (stickiness): **Desativar** (igual regras existentes, salvo padrão diferente).

**Tag (opcional):** `homolog.sistema.rdoapp.com.br`

3. **Salvar** / **Save** regras (botão no canto da tela de regras).

---

### Passo 2.4 — Conferir ordem

A nova regra deve aparecer **antes** da **Última (padrão)**.

- **`homolog.sistema.rdoapp.com.br`** → **tg-equipamentos**
- **`sistema.rdoapp.com.br`** (sem regra própria) → continua caindo na **padrão** → **Ipv4-RDO**

**Não** editar regra **1** (piscinas) nem **padrão**.

---

### Passo 2.5 — Teste rápido

1. Browser: `https://homolog.sistema.rdoapp.com.br/`
   - **502** ainda é possível → backend **tg-equipamentos** (Fase 4) — mas **não** deve abrir o **login de prod** de `sistema` se a regra Host estiver certa.
2. `https://sistema.rdoapp.com.br/login` → deve continuar **prod**.

---

### Checklist Fase 2

- [ ] Regra Host **`homolog.sistema.rdoapp.com.br`** → **`tg-equipamentos`**
- [ ] Regra **padrão** intacta → **Ipv4-RDO**
- [ ] **sistema.rdoapp.com.br** prod OK

**Concluída Fase 2 →** Fase 3 (cert, se aviso TLS) e **Fase 4** (`tg-equipamentos` healthy).

---

## Fase 3 — Certificado TLS (ACM)

1. **Certificate Manager** → região **us-east-2**.
2. Abrir certificado usado no listener (**`rdoapp.com.br`**, ID `469c1581-…`) **ou** solicitar novo.
3. Se o cert **não** cobrir `homolog.sistema.rdoapp.com.br`:
   - **Solicitar certificado** → nomes adicionais: `homolog.sistema.rdoapp.com.br` (ou wildcard `*.rdoapp.com.br`).
   - Validar via **CNAME** no Route 53 (botão automático).
4. Se trocou cert: **EC2** → **Sistema-RDO** → listener **HTTPS:443** → **Editar** → associar certificado atualizado.

Teste: browser `https://homolog.sistema.rdoapp.com.br` — erro de cert **antes** de 502 indica ACM pendente.

---

## Fase 4 — Target group homolog (502) {#fase-4-target-group-homolog}

**Pré-requisito:** Fase 2 OK — regra Host **`homolog.sistema.rdoapp.com.br`** → **`tg-equipamentos-homolog-5081`** (ou o TG que você escolheu para homolog Equipamentos).

**Resultado esperado:** na aba **Destinos**, pelo menos **1 instância** com status **Healthy**; browser em `https://homolog.sistema.rdoapp.com.br/` deixa de ser **502** (pode ainda falhar login/app — Fase 5–6).

**502** com DNS e regra ALB corretos = quase sempre **TG vazio**, **unhealthy** ou **porta/SG errados** — não é Route 53.

---

### Passo 4.1 — Abrir o grupo de destino certo

1. Console AWS → **EC2**.
2. Região **Leste dos EUA (Ohio) / us-east-2** (canto superior direito).
3. Menu esquerdo: **Grupos de destino** / **Target groups**.
4. Caixa **Filtrar** ou busca: **`homolog-5081`** (ou nome completo **`tg-equipamentos-homolog-5081`**).
5. Clique na linha do TG — **não** abra **`Ipv4-RDO`** (prod) nesta fase, salvo comparação no passo 4.6.

---

### Passo 4.2 — Ler o resumo (aba Detalhes)

Na parte superior ou aba **Detalhes**, anote:

| Campo | O que anotar |
|-------|----------------|
| **Protocolo : porta do destino** | Ex.: **HTTP : 5081** (nome do TG sugere **5081**) |
| **Tipo de destino** | **Instância** (Instance) |
| **VPC** | Deve ser a **mesma** do ALB **Sistema-RDO** (`vpc-ea507a82` ou equivalente na sua conta) |
| **Balanceador de carga associado** | Deve listar **Sistema-RDO** (listener HTTPS:443) |

Se **porta ≠ 5081**, use a porta que aparecer aqui em todos os passos seguintes (nginx, SG, teste).

---

### Passo 4.3 — Aba **Destinos** (diagnóstico principal)

1. Clique na aba **Destinos** / **Targets**.
2. Veja a tabela **Destinos registrados**.

| O que você vê | Significado | Próximo passo |
|---------------|-------------|----------------|
| **Lista vazia** | Nenhuma EC2 recebe tráfego deste TG | **Passo 4.5** (registrar destino) |
| **1+ linhas**, coluna **Status** = **Healthy** | ALB consegue falar com a instância na porta | **Passo 4.7** (browser); se ainda 502 → **Fase 5** (nginx `server_name`) |
| **Unhealthy** (vermelho) | Porta fechada, app off, health check falha, ou SG | **Passo 4.4** + **4.5** |
| **Draining** | Manutenção / desregistro em curso | Aguardar ou registrar de novo |

3. Clique no **ID da instância** (link `i-…`) — abre a EC2. Anote **Nome** / tag (ex.: servidor sistema).

**Não** registrar a mesma instância duas vezes no **mesmo** TG com a **mesma** porta.

---

### Passo 4.4 — Aba **Verificação de integridade** (health check)

1. Aba **Verificação de integridade** / **Health checks**.
2. Anote:

| Campo | Típico | Se falhar |
|-------|--------|-----------|
| **Protocolo** | HTTP | HTTPS na instância raramente — conferir nginx |
| **Caminho** | `/` ou path específico | App não responde 200 nesse path → unhealthy |
| **Porta** | **Traffic port** (= porta do destino, ex. 5081) | Deve bater com nginx/listen |
| **Códigos de sucesso** | 200 | 301/302 às vezes OK se configurado |
| **Intervalo / limiar** | padrão AWS | Só muda se souber o motivo |

3. (Opcional) Botão **Editar verificação de integridade** — **não** altere na primeira passada; só se souber que o app responde em `/Account/Login` e `/` dá 404.

**Causa comum de Unhealthy:** nada escutando na **5081** na EC2, ou security group da instância **não** permite tráfego **do SG do ALB** na porta 5081.

---

### Passo 4.5 — Registrar destino (se lista vazia ou instância errada)

1. Ainda no TG **`tg-equipamentos-homolog-5081`** → aba **Destinos**.
2. Botão **Registrar destinos** / **Register targets**.
3. **Instâncias disponíveis:** marque a **EC2 do sistema** (a mesma que aparece em **`Ipv4-RDO`** se prod roda na mesma máquina — compare no passo 4.6).
4. **Porta para o tráfego:** **`5081`** (ou a porta do passo 4.2).
5. **Incluir como pendente abaixo** → **Registrar destinos pendentes**.
6. Aguarde **1–3 minutos**; atualize a página (F5).

Status deve ir para **Initial** → **Healthy**. Se ficar **Unhealthy**, vá para **Passo 4.8**.

---

### Passo 4.6 — Comparar com prod (só leitura)

Para não adivinhar qual servidor usar:

1. **Grupos de destino** → abra **`Ipv4-RDO`**.
2. Aba **Destinos** — anote **ID(s) da instância** e **porta** (ex.: 80, 443, 8080).
3. Volte ao **`tg-equipamentos-homolog-5081`**:
   - Homolog na **mesma EC2** com **outra porta** (5081) é o padrão esperado pelo nome do TG.
   - Se homolog TG estiver **vazio** e prod tiver instância saudável → registrar **essa** instância na **5081** (não na porta de prod).

**Não** altere destinos de **`Ipv4-RDO`**.

---

### Passo 4.7 — Teste browser (após Healthy)

1. `https://homolog.sistema.rdoapp.com.br/`

| Resultado | Próximo |
|-----------|---------|
| **502** com targets **Healthy** | **Fase 5** — nginx/IIS sem `server_name homolog.sistema…` ou upstream errado na 5081 |
| **502** com **Unhealthy** | **Passo 4.8** |
| **Login / página RDO** | Fase 4 OK para ALB; seguir **Fase 6–7** (app Core/legado) |
| **Erro certificado** | **Fase 3** |

2. Confirme prod: `https://sistema.rdoapp.com.br/login` ainda OK.

---

### Passo 4.8 — Unhealthy: security group (console, sem SSM)

1. **EC2** → **Instâncias** → clique na instância do destino.
2. Aba **Segurança** → **Grupos de segurança** (link do SG).
3. **Regras de entrada** — deve existir algo como:
   - **Origem:** SG do **Sistema-RDO** (balanceador), **ou** CIDR da VPC,
   - **Porta:** **5081** (TCP),
   - **Descrição:** ex. ALB → homolog equipamentos.

4. **EC2** → **Balanceadores de carga** → **Sistema-RDO** → aba **Segurança** — anote o **SG do ALB**.

5. Se **não** houver regra ALB → 5081 na instância:
   - **Editar regras de entrada** → **Adicionar regra**:
     - Tipo: **Personalizado TCP**
     - Porta: **5081**
     - Origem: **Grupo de segurança** → selecione o SG do **Sistema-RDO**
   - **Salvar regras**.

6. Volte ao TG → **Destinos**; aguarde health check (até ~2–3 min).

Se continuar **Unhealthy** → **Fase 5** (SSM: `ss -tlnp | grep 5081`, nginx, serviço parado).

---

### Passo 4.9 — (Opcional) Outros TGs equipamentos

Se **`tg-equipamentos-hml-5081`** existir:

1. Abra e compare **Destinos** com **`homolog-5081`**.
2. **Regra ALB `hm`** pode apontar para **hml** — não misture portas.
3. **`homolog.sistema`** deve usar **só** o TG da regra 4 (**homolog-5081**).

Não apagar TGs nesta fase.

---

### Checklist Fase 4

- [ ] TG **`tg-equipamentos-homolog-5081`** aberto (porta anotada)
- [ ] Pelo menos **1 destino** registrado na porta correta
- [ ] Status **Healthy**
- [ ] SG instância permite **ALB → porta homolog**
- [ ] Browser: **502 resolvido** ou encaminhado para **Fase 5** (Healthy mas 502)

**Concluída Fase 4 (Healthy + página)** → **Fase 5–6** se ainda faltar vhost/app · senão **Fase 7** E2E.

---

## Fase 5 — Servidor web (EC2 / SSM)

Com **Session Manager** na instância atrás de `tg-equipamentos`:

1. Localizar config **nginx** (ou IIS) que hoje atende **`hm.rdoapp.com.br`**.
2. **Duplicar** `server { … server_name hm… }` → novo bloco:
   - `server_name homolog.sistema.rdoapp.com.br;`
   - mesmo `root` / `proxy_pass` / app pool de homolog Equipamentos.
3. `nginx -t` → reload nginx (ou recycle app pool IIS).
4. **Não** mexer em `sistema.rdoapp.com.br` (prod = `Ipv4-RDO` / outro vhost).

*(Detalhe depende do layout no servidor — documentar path após SSM.)*

---

## Fase 6 — App homolog (legado ou Migration2Core)

**Legado Equipamentos homolog:** garantir site/publicação apontando connection string **homolog** (`piscinas_rdoapp_homologa`).

**Migration2Core (`RdoApp.Core`):**

1. Publish Release na instância ou deploy pipeline.
2. `ASPNETCORE_ENVIRONMENT=Staging` (ou Production com secrets homolog).
3. Connection string homolog via **arquivo local / Parameter Store** — não Git.
4. Kestrel + reverse proxy no vhost **`homolog.sistema`**.

---

## Fase 7 — Smoke test (browser)

1. `https://homolog.sistema.rdoapp.com.br/` — esperado: login RDO (legado ou Core), **não** 502.
2. Confirmar **`https://sistema.rdoapp.com.br`** continua prod (não regressão).

Checklist E2E: [`e2e-fase0-checklist.md`](e2e-fase0-checklist.md) — base URL = **`homolog.sistema`**.

---

## Fase 8 — OK formal

- [ ] DNS resolve  
- [ ] HTTPS válido  
- [ ] Login → Escolher obra → Cards (Fase 0)  
- [ ] Data + responsável no checklist  

---

## Fase 9 — Apagar `hm` (logo após OK — recomendado)

**Só execute se passo 8 passou** e ninguém depende de `hm` (bookmark interno).

### 9A — ALB

1. **Sistema-RDO** → **HTTPS:443** → **Regras**.
2. Excluir regra **prioridade 2** · tag **`hm.rdoapp.com.br`**.

### 9B — Route 53

1. Zona **`rdoapp.com.br`** → registro **`hm`** → **Excluir**.

### 9C — Servidor (opcional)

1. Remover `server_name hm.rdoapp.com.br` do nginx ou desativar site IIS **hm**.

### 9D — Verificação

- `nslookup hm.rdoapp.com.br` → NXDOMAIN (após TTL).
- Homolog oficial único: **`homolog.sistema.rdoapp.com.br`**.

---

## O que **não** fazer neste plano

| Ação | Motivo |
|------|--------|
| Apagar **`homologacao.piscinas`** | Pode ser legado Piscinas; fora do escopo Equipamentos |
| Apagar regra **`piscinas.rdoapp.com.br`** → `tg-piscinas` | Vertical separada |
| Alterar target group **`Ipv4-RDO`** (padrão prod) | Risco produção |
| Apagar **`hm` antes** do passo 8 | Sem URL homolog equipamentos funcional |

---

## Resumo visual

```text
Route 53: homolog.sistema ──► ALB Sistema-RDO ──► regra Host homolog.sistema
                                                      │
                                                      ▼
                                              tg-equipamentos ──► EC2 homolog Equipamentos
                                                      │
                                              (hm removido após OK)
```

---

## Links

- DNS/ALB detalhado: [`aws-route53-rdoapp-dns-homolog-tecnico.md`](aws-route53-rdoapp-dns-homolog-tecnico.md)
- Plano migração: [`plano-preparacao-migracao-homolog.md`](plano-preparacao-migracao-homolog.md)
