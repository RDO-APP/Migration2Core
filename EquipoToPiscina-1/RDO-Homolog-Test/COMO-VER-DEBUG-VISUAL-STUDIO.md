# Como Ver Mensagens DEBUG no Visual Studio

## Onde Ver as Mensagens DEBUG LAUDO

As mensagens `DEBUG LAUDO` que adicionamos no código podem ser vistas de duas formas:

### 1. Janela de Saída (Output Window)
1. **Abrir a janela**: Menu `Exibir` → `Saída` (ou `View` → `Output`)
2. **Selecionar fonte**: No dropdown "Mostrar saída de:", selecione `Debug`
3. **Executar aplicação**: Pressione F5 para executar em modo Debug
4. **Fazer ação**: Salve uma medição com dados de laudo
5. **Ver mensagens**: As mensagens aparecerão na janela de saída

### 2. Janela de Debug (Debug Output)
1. **Executar em Debug**: Pressione F5 (não Ctrl+F5)
2. **Abrir janela Debug**: Menu `Depurar` → `Janelas` → `Saída` (ou `Debug` → `Windows` → `Output`)
3. **Ver mensagens**: As mensagens `System.Diagnostics.Debug.WriteLine` aparecerão aqui

## Mensagens que Você Verá

Quando salvar uma medição com dados de laudo, você verá mensagens como:

```
DEBUG LAUDO - Controller recebeu: IdTarefa=123, NivelCloro=3, NivelPH=4
DEBUG LAUDO - Iniciando salvamento - IdTarefa: 123
DEBUG LAUDO - NivelCloro: 3, NivelPH: 4, NivelAlcalinidade: 3, Limpidez: sim
DEBUG LAUDO - Salvamento concluído, linhas afetadas: 1
DEBUG LAUDO - Resultado do salvamento: True
```

## Para o Histórico (Botão Relógio)

Quando clicar no botão relógio, você verá:

```
DEBUG HISTORICO - Carregando histórico para tarefa: 123
DEBUG HISTORICO - Dados do laudo encontrados: NivelCloro=3, NivelPH=4
DEBUG HISTORICO - Conversão: Cloro=1,5 < 2,0, PH=7.4 < 7.6
```

## Dicas Importantes

1. **Modo Debug**: Certifique-se de executar com F5 (Debug), não Ctrl+F5 (Release)
2. **Configuração**: Vá em `Projeto` → `Propriedades` → `Build` e certifique-se que `DEBUG` está definido
3. **Limpar janela**: Use Ctrl+L para limpar a janela de saída
4. **Filtrar**: Use Ctrl+F para procurar por "DEBUG LAUDO" na janela de saída

## Teste Direto no Banco

Se não conseguir ver as mensagens, execute o arquivo `insert-test-laudo-data.sql` no DBeaver para inserir dados de teste diretamente no banco e verificar se o histórico funciona.