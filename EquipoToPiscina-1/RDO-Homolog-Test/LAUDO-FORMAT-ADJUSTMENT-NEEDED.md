# AJUSTE NECESSÁRIO: FORMATO DOS CAMPOS CLORO, PH E ALCALINIDADE

## PROBLEMA IDENTIFICADO

Você está correto! Os campos **Cloro**, **PH** e **Alcalinidade** mudaram de formato na interface moderna, mas a integração do histórico ainda não está refletindo isso corretamente.

## SITUAÇÃO ATUAL

### Frontend (Interface Moderna)
- **Cloro**: Dropdown com IDs 1-5 → `["0 ppm", "0,5 < 1,0", "1,5 < 2,0", "2,5 < 3,0", "> 3,0"]`
- **PH**: Dropdown com IDs 1-6 → `["< 7.0", "7.0 < 7.2", "7.2 < 7.4", "7.4 < 7.6", "7.6 < 7.8", "> 7.8"]`
- **Alcalinidade**: Dropdown com IDs 1-6 → `["< 70", "70 < 80", "90 < 100", "110 < 120", "130 > 140", "> 140"]`

### Backend Atual (Integração do Histórico)
- **Cloro**: Mostra "Sim/Não" (formato antigo)
- **PH**: Mostra "Sim/Não" (formato antigo)
- **Alcalinidade**: Mostra "-" (campo não existe no banco real)

## PROBLEMA TÉCNICO

1. **Como os dados estão sendo salvos?**
   - Precisamos verificar se estão sendo salvos como **IDs numéricos** (1,2,3,4,5,6) 
   - Ou como **boolean** (true/false)

2. **Estrutura do banco real vs código do Gilberto**
   - **Banco real**: Campos `bit(1)` (boolean)
   - **Código Gilberto**: Campos `int` (IDs numéricos)

## PRÓXIMOS PASSOS NECESSÁRIOS

### 1. INVESTIGAR COMO OS DADOS ESTÃO SENDO SALVOS
Precisamos verificar:
- Se o LaudoModel.cs está salvando IDs numéricos ou boolean
- Como os dados aparecem no banco quando salvamos um laudo

### 2. AJUSTAR A INTEGRAÇÃO DO HISTÓRICO
Dependendo de como estão sendo salvos:

**Se salvos como IDs numéricos:**
```csharp
// Arrays de conversão
var cloroOptions = new[] { "", "0 ppm", "0,5 < 1,0", "1,5 < 2,0", "2,5 < 3,0", "> 3,0" };
var phOptions = new[] { "", "< 7.0", "7.0 < 7.2", "7.2 < 7.4", "7.4 < 7.6", "7.6 < 7.8", "> 7.8" };

// Converter ID para texto
this.nivelCloro = cloroId > 0 && cloroId < cloroOptions.Length ? cloroOptions[cloroId] : "-";
```

**Se salvos como boolean:**
```csharp
// Manter formato atual mas ajustar lógica
this.nivelCloro = laudo.lau_tp_nivel_cloro.HasValue ? (laudo.lau_tp_nivel_cloro.Value ? "Adequado" : "Inadequado") : "-";
```

### 3. TESTAR A INTEGRAÇÃO
1. Salvar um laudo com valores específicos
2. Verificar no banco como foram salvos
3. Verificar se o histórico mostra os valores corretos

## IMPLEMENTAÇÃO ATUAL

A integração do laudo com o histórico está **funcionando** mas com **formato incorreto**:
- ✅ JOIN laudo-tarefa por obra+data implementado
- ✅ Dados sendo recuperados do banco
- ❌ Formato dos campos Cloro/PH não corresponde à interface moderna
- ❌ Alcalinidade não existe no banco real

## RECOMENDAÇÃO

**PASSO 1**: Testar salvando um laudo e verificar como os dados aparecem no banco
**PASSO 2**: Ajustar a conversão dos valores na integração do histórico
**PASSO 3**: Testar se o botão relógio mostra os valores no formato correto

Você gostaria que eu investigue primeiro como os dados estão sendo salvos no banco?