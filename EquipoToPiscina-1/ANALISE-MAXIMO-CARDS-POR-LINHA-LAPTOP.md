# Análise: Máximo de Cards por Linha em Laptop

## RESUMO EXECUTIVO
Análise detalhada para determinar o número máximo de cards de obra que podem caber em uma linha em telas de laptop, considerando diferentes resoluções e tamanhos de tela.

## 1. RESOLUÇÕES TÍPICAS DE LAPTOP

### LAPTOPS COMUNS
- **13" - 14"**: 1366x768, 1920x1080
- **15" - 16"**: 1920x1080, 2560x1440
- **17"**: 1920x1080, 2560x1440, 3840x2160

### RESOLUÇÕES MAIS USADAS
1. **1366x768** (HD) - Laptops básicos
2. **1920x1080** (Full HD) - Padrão atual
3. **2560x1440** (2K) - Laptops premium
4. **3840x2160** (4K) - Laptops high-end

## 2. CÁLCULO DE ESPAÇO DISPONÍVEL

### NOSSA IMPLEMENTAÇÃO ATUAL
```css
.main-content {
    max-width: 1200px;
    margin: 0 auto;
    padding: 40px 20px;
}

.lista-obras .item {
    padding: 0 3px; /* 6px total por card */
    flex-basis: 20%; /* 5 cards = 100% */
}
```

### ESPAÇO EFETIVO POR RESOLUÇÃO

#### 1366x768 (HD)
- **Largura disponível**: 1200px (limitado por max-width)
- **Padding lateral**: 40px (20px cada lado)
- **Largura efetiva**: 1120px
- **Cards atuais**: 5 cards × 224px = 1120px ✅

#### 1920x1080 (Full HD)
- **Largura disponível**: 1200px (limitado por max-width)
- **Padding lateral**: 40px
- **Largura efetiva**: 1120px
- **Cards atuais**: 5 cards × 224px = 1120px ✅

#### 2560x1440 (2K)
- **Largura disponível**: 1200px (limitado por max-width)
- **Largura efetiva**: 1120px
- **Potencial desperdiçado**: 1360px de espaço não usado!

#### 3840x2160 (4K)
- **Largura disponível**: 1200px (limitado por max-width)
- **Largura efetiva**: 1120px
- **Potencial desperdiçado**: 2640px de espaço não usado!

## 3. CÁLCULO MÁXIMO DE CARDS

### DIMENSÕES MÍNIMAS POR CARD
- **Largura mínima**: 180px (para manter legibilidade)
- **Padding**: 6px total (3px cada lado)
- **Largura total por card**: 186px

### MÁXIMO TEÓRICO POR RESOLUÇÃO

#### 1366x768 (HD)
- **Largura útil**: 1326px (1366 - 40px padding)
- **Cards máximos**: 1326 ÷ 186 = **7 cards**

#### 1920x1080 (Full HD)
- **Largura útil**: 1880px (1920 - 40px padding)
- **Cards máximos**: 1880 ÷ 186 = **10 cards**

#### 2560x1440 (2K)
- **Largura útil**: 2520px (2560 - 40px padding)
- **Cards máximos**: 2520 ÷ 186 = **13 cards**

#### 3840x2160 (4K)
- **Largura útil**: 3800px (3840 - 40px padding)
- **Cards máximos**: 3800 ÷ 186 = **20 cards**

## 4. RECOMENDAÇÕES PRÁTICAS

### CONFIGURAÇÃO OTIMIZADA
```css
/* Remover limitação de max-width */
.main-content {
    /* max-width: 1200px; <- REMOVER */
    margin: 0 auto;
    padding: 40px 20px;
}

/* Responsivo otimizado */
@media (min-width: 1200px) {
    .lista-obras .item {
        flex-basis: 16.66%; /* 6 cards */
    }
}

@media (min-width: 1400px) {
    .lista-obras .item {
        flex-basis: 14.28%; /* 7 cards */
    }
}

@media (min-width: 1600px) {
    .lista-obras .item {
        flex-basis: 12.5%; /* 8 cards */
    }
}

@media (min-width: 1800px) {
    .lista-obras .item {
        flex-basis: 11.11%; /* 9 cards */
    }
}

@media (min-width: 2000px) {
    .lista-obras .item {
        flex-basis: 10%; /* 10 cards */
    }
}
```

## 5. CONFIGURAÇÃO RECOMENDADA POR TELA

### LAPTOP 13"-14" (1366x768)
- **Recomendado**: 6-7 cards por linha
- **Flex-basis**: 16.66% ou 14.28%

### LAPTOP 15"-16" (1920x1080)
- **Recomendado**: 8-10 cards por linha
- **Flex-basis**: 12.5% ou 10%

### LAPTOP 17" (2560x1440)
- **Recomendado**: 10-12 cards por linha
- **Flex-basis**: 10% ou 8.33%

### DESKTOP 4K (3840x2160)
- **Recomendado**: 15-20 cards por linha
- **Flex-basis**: 6.66% ou 5%

## 6. IMPLEMENTAÇÃO SUGERIDA

### OPÇÃO 1: CONSERVADORA (Recomendada)
```css
@media (min-width: 1200px) {
    .main-content {
        max-width: none; /* Remove limitação */
        padding: 40px 60px; /* Mais padding em telas grandes */
    }
    
    .lista-obras .item {
        flex-basis: 16.66%; /* 6 cards */
    }
}

@media (min-width: 1600px) {
    .lista-obras .item {
        flex-basis: 12.5%; /* 8 cards */
    }
}

@media (min-width: 2000px) {
    .lista-obras .item {
        flex-basis: 10%; /* 10 cards */
    }
}
```

### OPÇÃO 2: AGRESSIVA (Máximo aproveitamento)
```css
@media (min-width: 1200px) {
    .main-content {
        max-width: none;
        padding: 40px 60px;
    }
    
    .lista-obras .item {
        flex-basis: 14.28%; /* 7 cards */
    }
}

@media (min-width: 1400px) {
    .lista-obras .item {
        flex-basis: 11.11%; /* 9 cards */
    }
}

@media (min-width: 1800px) {
    .lista-obras .item {
        flex-basis: 8.33%; /* 12 cards */
    }
}
```

## 7. RESPOSTA DIRETA

### MÁXIMO RECOMENDADO POR TIPO DE LAPTOP:

1. **Laptop 13"-14"**: **6-7 cards** por linha
2. **Laptop 15"-16"**: **8-10 cards** por linha  
3. **Laptop 17"**: **10-12 cards** por linha

### IMPLEMENTAÇÃO IMEDIATA SUGERIDA:
- **Remover** `max-width: 1200px` do `.main-content`
- **Adicionar** breakpoints para 6, 8 e 10 cards
- **Manter** design atual para telas menores

## 8. CONCLUSÃO

**RESPOSTA**: O máximo prático para laptops é:
- **Laptops comuns (15")**: **8-10 cards** por linha
- **Laptops grandes (17")**: **10-12 cards** por linha

**RECOMENDAÇÃO**: Implementar a Opção 1 (Conservadora) que oferece melhor equilíbrio entre aproveitamento de espaço e usabilidade.

---
*Análise realizada em: 28 de Dezembro de 2025*
*Recomendação: 8-10 cards para laptops padrão*