<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>RDO Homolog - Teste OK</title>
    <style>
        body { font-family: Arial; margin: 50px; background: #f0f8ff; }
        .success { color: green; font-size: 24px; font-weight: bold; }
        .info { color: #333; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="success">RDO HOMOLOG FUNCIONANDO!</div>
    <div class="info">
        <p><strong>Data/Hora:</strong> <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss") %></p>
        <p><strong>Status:</strong> Web.config corrigido com sucesso</p>
        <p><strong>Proximo passo:</strong> <a href="/">Fazer login (567.065.455-20 / 1234)</a></p>
    </div>
</body>
</html>
