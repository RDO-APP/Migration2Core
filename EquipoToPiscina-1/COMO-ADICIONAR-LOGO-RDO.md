# Como Adicionar o Logo do RDO App

## Instruções para usar o logo real na tela de login

### 1. Salvar o Logo
- Pegue uma das imagens do logo RDO que você forneceu
- Salve como: `rdo-logo.png`
- Coloque no caminho: `RDO-NET8-Migration/RdoApp.Core/wwwroot/images/rdo-logo.png`

### 2. Formatos Suportados
- PNG (recomendado)
- JPG/JPEG
- SVG
- Tamanho recomendado: 512x512px ou maior

### 3. Fallback Automático
- Se a imagem não for encontrada, o sistema usa o texto "rdo" como fallback
- Não quebra a aplicação se o arquivo não existir

### 4. Como Testar
1. Salve o logo no local correto
2. Compile o projeto (Ctrl+Shift+B)
3. Execute com F5
4. Abra em modo incógnito
5. Veja o logo real na tela de login

### 5. Estrutura de Pastas
```
RDO-NET8-Migration/
└── RdoApp.Core/
    └── wwwroot/
        └── images/
            └── rdo-logo.png  ← Coloque aqui
```

### 6. Código Implementado
O sistema já está preparado para usar o logo automaticamente:
- Tenta carregar a imagem primeiro
- Se falhar, mostra o texto "rdo"
- Funciona sem quebrar a aplicação

## Resultado
- Logo profissional na tela de login
- Tamanho 90x90px com bordas arredondadas
- Sombra e efeitos visuais aplicados
- Integração perfeita com o design existente