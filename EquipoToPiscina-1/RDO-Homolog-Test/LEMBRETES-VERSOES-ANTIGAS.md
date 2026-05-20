# LEMBRETES: VERSÕES ANTIGAS DO PROJETO

## VERSÕES UTILIZADAS ⚠️

### TECNOLOGIAS:
- **.NET Framework 4.8** (não .NET Core/5+)
- **C# 7.3 ou anterior** (não C# 8.0+)
- **Entity Framework 6.5.1** (não EF Core)
- **ASP.NET MVC 5** (não ASP.NET Core)
- **Visual Studio Community 2022** (projeto legado)

## RECURSOS PROIBIDOS ❌

### C# MODERNO (NÃO USAR):
```csharp
// ❌ Interpolação de strings (C# 6.0+)
$"Valor: {variavel}"

// ❌ Nullable reference types (C# 8.0+)
string? texto = null;

// ❌ Pattern matching avançado (C# 7.0+)
switch (obj) { case string s when s.Length > 0: break; }

// ❌ Top-level statements (C# 9.0+)
Console.WriteLine("Hello");

// ❌ Record types (C# 9.0+)
public record Person(string Name);
```

## RECURSOS PERMITIDOS ✅

### C# CLÁSSICO (USAR):
```csharp
// ✅ Concatenação tradicional
"Valor: " + variavel

// ✅ string.Format()
string.Format("Valor: {0}", variavel)

// ✅ Sintaxe clássica
if (texto != null && texto.Length > 0) { }

// ✅ Classes tradicionais
public class Person 
{
    public string Name { get; set; }
}
```

## ENTITY FRAMEWORK 6.x ✅

### SINTAXE CORRETA:
```csharp
// ✅ Entity Framework 6.x
context.Set<laudo>().FirstOrDefault(x => x.id == 1)
context.Entry(entity).State = EntityState.Modified
System.Data.Entity.DbFunctions.TruncateTime(date)

// ❌ EF Core (NÃO USAR)
context.Laudo.FirstOrDefault(x => x.Id == 1)
EF.Functions.DateDiffDay(date1, date2)
```

## REGRAS DE DESENVOLVIMENTO

### SEMPRE LEMBRAR:
1. **Usar sintaxe C# 7.3 ou anterior**
2. **Evitar recursos modernos do C#**
3. **Usar Entity Framework 6.x syntax**
4. **Testar compatibilidade com .NET Framework 4.8**
5. **Verificar se compila sem erros**

### QUANDO EM DÚVIDA:
- **Usar sintaxe mais antiga e segura**
- **Testar compilação antes de implementar**
- **Preferir concatenação a interpolação**
- **Usar string.Format() quando necessário**

---

**IMPORTANTE**: Este projeto usa tecnologias legadas. Sempre considerar compatibilidade com versões antigas antes de implementar qualquer recurso.