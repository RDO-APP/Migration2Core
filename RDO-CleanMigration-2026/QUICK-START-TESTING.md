# QUICK START - LOGIN TESTING

## 🚨 CRITICAL FIX APPLIED
Database connection now points to **AWS RDS** instead of localhost!

---

## ⚡ Quick Start (3 Steps)

### 1. Start Application
```bash
cd RDO-CleanMigration-2026/RDO-CleanMigration-2026/RdoApp.Core
dotnet run
```

### 2. Open Browser
Navigate to: **https://localhost:5001/Account/Login**

### 3. Test Login
**Credentials**:
- CPF: `567.065.455-20`
- Password: `ricardo123` (or actual password)

---

## 🎯 Expected Results

### ✅ SUCCESS Scenario
1. Form submits credentials
2. CPF normalized: `567.065.455-20` → `56706545520`
3. Password encrypted: `ricardo123` → `RXL8DjdYj6Y=`
4. Database query finds Ricardo Freire
5. Session created with user info
6. **Redirect to**: `/Obra/Escolher` (obra selection page)

### ❌ FAILURE Scenarios

#### Scenario A: "Invalid credentials"
**Cause**: Password doesn't match encrypted value in database
**Solution**: Verify actual password or check database value

#### Scenario B: Database connection error
**Cause**: Cannot connect to AWS RDS
**Solution**: Check network, firewall, or AWS RDS status

#### Scenario C: User not found
**Cause**: CPF doesn't exist in database
**Solution**: Verify CPF in database or use different test user

---

## 🔍 Troubleshooting

### Check Database Connection
```bash
# From application directory
dotnet ef database drop --force
dotnet ef database update
```

### Query Ricardo's Record (MySQL Client)
```sql
USE piscinas_rdoapp_homologa;

SELECT 
    col_ds_nome,
    col_ds_cpf,
    col_ds_senha,
    col_st_ativo
FROM colaborador
WHERE col_ds_cpf = '56706545520';
```

### Test Encryption (C# Console)
```csharp
using RdoApp.Core.Utils;

string password = "ricardo123";
string encrypted = Seguranca.EncryptTripleDES(password);
Console.WriteLine($"Encrypted: {encrypted}");
// Should output: RXL8DjdYj6Y=
```

---

## 📊 What Changed

### Connection String
**BEFORE**: `Server=localhost;Database=piscinas_rdoapp;...`
**AFTER**: `Server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;Database=piscinas_rdoapp_homologa;...`

### Impact
- ✅ Now queries **real production database** on AWS RDS
- ✅ Ricardo's user record should be found
- ✅ Login should work with correct password

---

## 📝 Test Checklist

- [ ] Application starts without errors
- [ ] Login page loads at `/Account/Login`
- [ ] Form accepts CPF and password
- [ ] Form submits to `/Account/Login` POST
- [ ] Database query executes successfully
- [ ] User found in database
- [ ] Session created with user info
- [ ] Redirects to `/Obra/Escolher`

---

## 🎉 Success Criteria

**Login is working when**:
1. ✅ No errors in console
2. ✅ No "Invalid credentials" message
3. ✅ Redirects to obra selection page
4. ✅ User info stored in session

---

## 📞 Report Results

After testing, report:
1. ✅ **SUCCESS**: "Login works! Redirected to obra selection"
2. ❌ **FAILURE**: "Error message: [exact error text]"
3. 🟡 **PARTIAL**: "Login accepted but [describe issue]"

---

**READY FOR TESTING** 🚀
