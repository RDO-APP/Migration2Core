# 🚀 HOW TO RUN IN VISUAL STUDIO

## 🔍 TROUBLESHOOTING: F5 DOESN'T WORK

If pressing F5 doesn't start the application, try these solutions:

---

## ✅ SOLUTION 1: Check the Startup Project

1. In Visual Studio, look at the **Solution Explorer** (right side)
2. Right-click on **RdoApp.Core** project
3. Select **"Set as Startup Project"**
4. The project name should now be **bold**
5. Press **F5** again

---

## ✅ SOLUTION 2: Check the Debug Configuration

1. Look at the toolbar at the top
2. Find the dropdown that says **"Debug"** or **"Release"**
3. Make sure it's set to **"Debug"**
4. Next to it, find the dropdown with profile names
5. Select **"https"** or **"http"**
6. Press **F5** again

---

## ✅ SOLUTION 3: Use the Green Play Button

1. Look at the toolbar at the top
2. Find the **green play button** (▶️)
3. Next to it should say **"https"** or **"RdoApp.Core"**
4. Click the **green play button**
5. Browser should open automatically

---

## ✅ SOLUTION 4: Run from Command Line

If Visual Studio still doesn't work, use the command line:

1. Open **PowerShell** or **Command Prompt**
2. Run these commands:

```powershell
cd C:\Dev\RDO-CleanMigration-2026\RDO-CleanMigration-2026\RdoApp.Core
dotnet run
```

3. You should see output like:
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: https://localhost:7176
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5229
```

4. Open your browser manually
5. Navigate to: `https://localhost:7176/Account/Login`

---

## ✅ SOLUTION 5: Check Output Window

1. In Visual Studio, go to **View → Output** (or press Ctrl+Alt+O)
2. In the "Show output from:" dropdown, select **"Debug"**
3. Press **F5** again
4. Look for error messages in the Output window
5. Copy any error messages and share them

---

## ✅ SOLUTION 6: Clean and Rebuild

1. In Visual Studio, go to **Build → Clean Solution**
2. Wait for it to finish
3. Go to **Build → Rebuild Solution**
4. Wait for it to finish (should say "Build succeeded")
5. Press **F5** again

---

## ✅ SOLUTION 7: Check Error List

1. In Visual Studio, go to **View → Error List** (or press Ctrl+\, E)
2. Look for any **red errors** (not warnings)
3. If you see errors, they need to be fixed first
4. Share the error messages if you need help

---

## 🎯 EXPECTED BEHAVIOR

When F5 works correctly, you should see:

1. **Visual Studio builds the project** (progress bar at bottom)
2. **Output window shows** "Build succeeded"
3. **Browser opens automatically** to `https://localhost:7176`
4. **Login page displays** with blue gradient background

---

## 📊 WHAT TO CHECK IN VISUAL STUDIO

### Check 1: Is RdoApp.Core the Startup Project?
- Look in Solution Explorer
- The startup project name should be **bold**
- If not bold, right-click → "Set as Startup Project"

### Check 2: Is the Profile Selected?
- Look at the toolbar
- Should show **"https"** or **"RdoApp.Core"** next to the green play button
- If it says "IIS Express", change it to "https"

### Check 3: Are There Build Errors?
- Check the Error List (View → Error List)
- Red errors must be fixed before running
- Yellow warnings are okay

### Check 4: Is the Port Available?
- The app uses ports 7176 (https) and 5229 (http)
- If another app is using these ports, it won't start
- Try closing other running applications

---

## 🔧 ALTERNATIVE: RUN WITHOUT DEBUGGING

Instead of F5, try **Ctrl+F5** (Run Without Debugging):

1. Press **Ctrl+F5** (not F5)
2. This runs the app without attaching the debugger
3. Browser should open automatically
4. If this works, the issue is with the debugger configuration

---

## 📝 WHAT TO REPORT

If none of these solutions work, please share:

1. **Visual Studio version**: Help → About Microsoft Visual Studio
2. **Error messages**: From Output window or Error List
3. **What happens**: Does anything happen when you press F5?
4. **Build output**: Does it say "Build succeeded" or "Build failed"?

---

## 🎯 QUICK TEST

Try this quick test to see if the project works:

```powershell
cd C:\Dev\RDO-CleanMigration-2026\RDO-CleanMigration-2026\RdoApp.Core
dotnet build
dotnet run
```

If this works, the project is fine and it's just a Visual Studio configuration issue.

---

**Try these solutions and let me know what happens!** 🚀
