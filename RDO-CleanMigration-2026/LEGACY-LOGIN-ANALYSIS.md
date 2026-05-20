# 🔍 LEGACY LOGIN ANALYSIS - The Gilberto Code

## Architecture Overview

**Pattern**: ASP.NET Framework Web API + AngularJS SPA
- **Backend**: Web API controllers return JSON
- **Frontend**: AngularJS makes AJAX calls to `/Api/Login/LoginUser`
- **Authentication**: TWO-STEP process (User → Obra)

---

## STEP 1: User Login (`LoginUser`)

### Input
```json
{
  "cpf": "567.065.455-20",
  "senha": "plaintext_password"
}
```

### Process Flow

1. **CPF Normalization**
   ```csharp
   cpf = cpf.Replace(".", "").Replace("-", "");
   // "567.065.455-20" → "56706545520"
   ```

2. **Password Encryption**
   ```csharp
   senha = Seguranca.EncryptTripleDES(param.senha);
   // Encrypts password using TripleDES
   ```

3. **Database Query**
   ```csharp
   var Colaborador = context.colaborador.FirstOrDefault(
       u => u.col_nr_cpf == cpf && u.col_ds_senha == senha
   );
   ```
   - Searches `colaborador` table
   - Matches CPF (without formatting) AND encrypted password
   - Returns NULL if not found → throws "Usuário ou senha não existem."

4. **Build Response**
   ```csharp
   LoginViewModel {
       Usuario: {
           Id: colaborador.col_id_colaborador,
           NomeUsuario: colaborador.col_nm_colaborador,
           Email: colaborador.col_ds_email,
           Senha: Seguranca.DecryptTripleDES(senha) // Decrypted for client
       },
       Routes: ObterRotasDefault(Colaborador),
       Menu: ObterMenuDefault(Colaborador)
   }
   ```

5. **Log History**
   ```csharp
   InserirHistoricoLogin(new HistoricoLogin {
       col_id_colaborador,
       col_ds_email,
       col_nm_colaborador,
       col_nr_cpf,
       data_login: DateTime.Now
   });
   ```

### Output
```json
{
  "Usuario": {
    "Id": 302,
    "NomeUsuario": "Ricardo Freire",
    "Email": "ricardo@example.com",
    "Senha": "RXL8DjdYj6Y="
  },
  "Routes": [...],
  "Menu": {...}
}
```

---

## STEP 2: Obra Selection (`LoginObra`)

### Input
```json
{
  "idUsuario": 302,
  "idObra": 123
}
```

### Process Flow

1. **Find Obra-Colaborador Relationship**
   ```csharp
   obra_colaborador objObraColaborador = context.obra_colaborador
       .FirstOrDefault(oc => oc.oco_id_obra == idObra && oc.oco_id_colaborador == idUsuario);
   ```

2. **Build Full Context**
   ```csharp
   LoginViewModel {
       Usuario: {...},
       ObraColaborador: {
           IdObraColaborador,
           NomeObra,
           IdObra,
           IdColaborador,
           IdGrupo,
           IdCargo,
           ContratanteContratada: "t" or "d",
           TipoLicencaColaboradorGrupo: "basica" or "gratuita"
       },
       Obra: {
           IdObra,
           Descricao,
           idDono,
           idContratante,
           idContratada,
           ObraFinalizada: bool
       },
       Routes: ObterRotas(idGrupo), // Permission-based routes
       Menu: ObterMenu(idGrupo)      // Permission-based menu
   }
   ```

3. **License Verification**
   ```csharp
   string statusLicenca = VerificarLicenca(empresa.Token);
   if (statusLicenca != "ATIVA") {
       throw new Exception("A licença dessa empresa está " + statusLicenca);
   }
   ```

4. **Log History with Obra**
   ```csharp
   InserirHistoricoLogin(new HistoricoLogin {
       col_id_colaborador,
       obr_id_obra,
       obr_ds_obra,
       data_login: DateTime.Now
   });
   ```

---

## Key Components

### 1. Password Encryption
```csharp
Seguranca.EncryptTripleDES(plaintext)  // Encrypt for storage/comparison
Seguranca.DecryptTripleDES(encrypted)  // Decrypt for client
```
- Uses TripleDES algorithm
- Passwords stored ENCRYPTED in database
- NOT hashed - they can be decrypted

### 2. Routes System
- **Default Routes**: Everyone gets basic routes (escolher obra, alterar senha, etc.)
- **Admin Routes**: If `col_st_admin == true`, add admin routes (pagina, menu, grupo)
- **Permission Routes**: Based on `grupo_pagina_acao` table (RBAC system)

### 3. Menu System
- Based on `gru_id_menu` from grupo
- Hierarchical structure: `menu_pagina` with `mpa_id_pagina_pai`
- Built recursively: Parent pages → Child pages

### 4. History Logging
- Logs every login to `historico_login` table
- Tracks: colaborador, obra (if selected), timestamp
- Uses Dapper for raw SQL insert

---

## Database Tables Used

1. **colaborador**
   - `col_nr_cpf` (without formatting)
   - `col_ds_senha` (TripleDES encrypted)
   - `col_st_admin` (boolean for admin access)

2. **obra_colaborador**
   - Links colaborador to obra
   - Contains `oco_id_grupo` (permissions)
   - Contains `oco_id_cargo` (role)

3. **grupo**
   - Defines permission set
   - `gru_id_menu` (menu structure)
   - `gru_st_contratante` (1=contratante, 2=contratada)
   - `gru_id_licenca` (license type)

4. **grupo_pagina_acao**
   - RBAC: grupo → pagina → acao
   - Defines what each grupo can do

5. **historico_login**
   - Audit trail of all logins

---

## .NET 8 Translation Strategy

### What Changes
1. **Web API → MVC Controller**
   - `ApiController` → `Controller`
   - `HttpResponseMessage` → `IActionResult`
   - JSON returned via `return Ok(data)`

2. **Entity Framework 6 → EF Core 8**
   - `rdoappEntities` → `RdoDbContext`
   - Same LINQ queries work
   - Connection string in appsettings.json

3. **Session/Cookie Management**
   - Add `UseAuthentication()` and `UseAuthorization()`
   - Store user in Claims after login
   - Use `HttpContext.Session` for obra selection

4. **TripleDES Encryption**
   - Copy `Seguranca` class EXACTLY
   - Same encryption key
   - Same algorithm

### What Stays EXACTLY the Same
1. ✅ CPF normalization logic
2. ✅ Password encryption (TripleDES)
3. ✅ Database queries (same tables, same columns)
4. ✅ Two-step login flow (User → Obra)
5. ✅ Routes and Menu building logic
6. ✅ History logging
7. ✅ License verification

---

## Implementation Plan for .NET 8

### Phase 1: User Login
```csharp
[HttpPost]
public async Task<IActionResult> Login([FromBody] LoginRequest request)
{
    // 1. Normalize CPF
    string cpf = request.Cpf.Replace(".", "").Replace("-", "");
    
    // 2. Encrypt password
    string encryptedPassword = Seguranca.EncryptTripleDES(request.Senha);
    
    // 3. Query database
    var colaborador = await _context.Colaboradores
        .FirstOrDefaultAsync(c => c.CpfNumero == cpf && c.Senha == encryptedPassword);
    
    if (colaborador == null)
        return BadRequest("Usuário ou senha não existem.");
    
    // 4. Build response
    var response = new LoginViewModel {
        Usuario = new UsuarioViewModel {
            Id = colaborador.Id,
            NomeUsuario = colaborador.Nome,
            Email = colaborador.Email,
            Senha = Seguranca.DecryptTripleDES(colaborador.Senha)
        },
        Routes = ObterRotasDefault(colaborador),
        Menu = ObterMenuDefault(colaborador)
    };
    
    // 5. Log history
    await InserirHistoricoLogin(new HistoricoLogin {
        ColaboradorId = colaborador.Id,
        // ...
    });
    
    // 6. Create authentication cookie
    var claims = new List<Claim> {
        new Claim(ClaimTypes.NameIdentifier, colaborador.Id.ToString()),
        new Claim(ClaimTypes.Name, colaborador.Nome),
        new Claim(ClaimTypes.Email, colaborador.Email)
    };
    
    await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme,
        new ClaimsPrincipal(new ClaimsIdentity(claims, "Cookies")));
    
    return Ok(response);
}
```

### Phase 2: Obra Selection
```csharp
[HttpPost]
public async Task<IActionResult> LoginObra([FromBody] ObraSelectionRequest request)
{
    // Same logic as legacy LoginObra
    // Store obra context in session
    HttpContext.Session.SetInt32("ObraId", request.IdObra);
    
    return Ok(response);
}
```

---

## Critical Success Factors

1. **Copy Seguranca class EXACTLY** - encryption must match
2. **Use same database** - no schema changes
3. **Two-step flow** - don't try to "simplify" it
4. **Test with real data** - CPF: 567.065.455-20, Password: RXL8DjdYj6Y=
5. **Verify in incognito** - no CDN dependencies

---

## Next Steps

1. ✅ Analysis complete
2. ⏳ Copy Seguranca.cs from legacy
3. ⏳ Implement AccountController.Login()
4. ⏳ Implement AccountController.LoginObra()
5. ⏳ Create Login.cshtml (already exists, verify)
6. ⏳ Test with real credentials
7. ⏳ Implement Obra selection page

