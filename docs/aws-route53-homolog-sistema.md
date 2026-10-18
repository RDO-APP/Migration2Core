# AWS — homolog sistema (índice)

Documentação técnica **canônica** (inventário Route 53, ALBs, procedimentos):

→ **[`aws-route53-rdoapp-dns-homolog-tecnico.md`](aws-route53-rdoapp-dns-homolog-tecnico.md)**

**Resumo (2026-10-17):**

- **`homolog.sistema.rdoapp.com.br`** — **não existe** na zona `rdoapp.com.br`.
- **`homologacao.piscinas.rdoapp.com.br`** — homolog **web sistema/obras** hoje (Alias → ALB `sistema-rdo-67414…`).
- **`homolog.loja.rdoapp.com.br`** — homolog Loja (Alias → ALB `loja-rdo-54827259…`) — modelo de **tipo** de registro, **não** de destino para Equipamentos.

Para Migration2Core na nuvem: apontar para ALB **sistema-rdo**, não **loja-rdo**.
