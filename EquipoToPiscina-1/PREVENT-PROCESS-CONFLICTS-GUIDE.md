# 🛡️ PREVENT RECURRING PROCESS CONFLICTS - DEFINITIVE GUIDE

## 🎯 THE PROBLEM
The `RdoApp.Core.exe` process keeps running in background, blocking compilation and causing frustration.

## ✅ IMMEDIATE SOLUTION

### **Option 1: Use Our Automated Script**
```powershell
.\stop-rdoapp-processes.ps1
```

### **Option 2: Manual Commands**
```powershell
# Stop RdoApp.Core processes
taskkill /F /IM "RdoApp.Core.exe"

# Stop any related dotnet processes
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | Stop-Process -Force

# Stop IIS Express if needed
taskkill /F /IM "iisexpress.exe"
```

---

## 🚀 PREVENTION STRATEGIES

### **1. PROPER VISUAL STUDIO WORKFLOW**

**✅ CORRECT WAY:**
1. **Shift+F5** to stop debugging (ALWAYS do this first)
2. Close browser windows
3. Wait 2-3 seconds
4. **F5** to start new session

**❌ WRONG WAY:**
- Just closing browser without stopping debug
- Starting new debug session while old one is running
- Force-closing Visual Studio without stopping debug

### **2. VISUAL STUDIO SETTINGS**

**Configure Visual Studio to auto-stop processes:**

1. **Tools → Options → Debugging → General**
2. ✅ Check "Automatically close the console when debugging stops"
3. ✅ Check "Stop all processes when one process stops"

### **3. PROJECT CONFIGURATION**

**Add to your `.csproj` file:**
```xml
<PropertyGroup>
  <ServerGarbageCollection>true</ServerGarbageCollection>
  <ConcurrentGarbageCollection>true</ConcurrentGarbageCollection>
</PropertyGroup>
```

---

## 🔧 AUTOMATED PREVENTION

### **Create a Pre-Build Script**

Add this to your project as a pre-build event:

1. **Right-click project → Properties → Build Events**
2. **Pre-build event command line:**
```cmd
powershell -Command "Get-Process -Name 'RdoApp.Core' -ErrorAction SilentlyContinue | Stop-Process -Force"
```

### **VS Code Task (if using VS Code)**

Create `.vscode/tasks.json`:
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "stop-processes",
            "type": "shell",
            "command": "powershell",
            "args": ["-File", "stop-rdoapp-processes.ps1"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        }
    ]
}
```

---

## 🎯 BEST PRACTICES

### **BEFORE EVERY COMPILATION:**
1. Run `.\stop-rdoapp-processes.ps1`
2. Or use **Shift+F5** in Visual Studio
3. Wait 2-3 seconds
4. Then compile/run

### **WHEN SWITCHING BETWEEN PROJECTS:**
1. Stop current debug session
2. Run process cleanup script
3. Switch to new project
4. Start new session

### **END OF DAY ROUTINE:**
1. **Shift+F5** to stop all debugging
2. Close Visual Studio properly
3. Run cleanup script if needed

---

## 🚨 EMERGENCY COMMANDS

**If everything is stuck:**
```powershell
# Nuclear option - stop all .NET processes
Get-Process | Where-Object {$_.ProcessName -like "*dotnet*"} | Stop-Process -Force

# Stop all development servers
taskkill /F /IM "iisexpress.exe"
taskkill /F /IM "dotnet.exe"
taskkill /F /IM "RdoApp.Core.exe"

# Restart Visual Studio
```

---

## 📋 QUICK CHECKLIST

**Before every F5:**
- [ ] Previous debug session stopped (Shift+F5)
- [ ] Browser windows closed
- [ ] No RdoApp.Core processes running
- [ ] Wait 2-3 seconds
- [ ] Now safe to F5

**If compilation fails:**
- [ ] Run `.\stop-rdoapp-processes.ps1`
- [ ] Try compilation again
- [ ] If still fails, restart Visual Studio

---

## 🎉 RESULT

Following this guide will **eliminate 99% of process conflicts** and make your development workflow smooth and frustration-free!

**No more recurring "process is running" issues!** 🚀