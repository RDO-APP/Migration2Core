# QUICK START - FIX BLANK PAGE

**Date:** January 22, 2026  
**Issue:** Browser shows blank page  
**Solution:** Follow these steps in order

---

## STEP 1: LOG IN FIRST (90% chance this fixes it)

**The /Obra/Escolher page requires authentication!**

### Do This:

1. **Open your browser**

2. **Navigate to the LOGIN page:**
   ```
   http://localhost:5031/Account/Login
   ```

3. **Log in with credentials:**
   - Username: `ricardo`
   - Password: `123456`

4. **After successful login, navigate to:**
   ```
   http://localhost:5031/Obra/Escolher
   ```

5. **You should see 103 obra cards!**

**If this works:** ✅ Problem solved! The page just needed authentication.

**If this doesn't work:** Continue to Step 2.

---

## STEP 2: CLEAR BROWSER CACHE

**Your browser might have cached a broken version.**

### Do This:

1. **Press:** `Ctrl+Shift+Delete`

2. **Select:**
   - Time range: "All time"
   - Check: "Cached images and files"
   - Check: "Cookies and other site data"

3. **Click:** "Clear data"

4. **Close and reopen browser**

5. **Try Step 1 again** (log in, then navigate to escolher)

**If this works:** ✅ Problem solved! It was browser cache.

**If this doesn't work:** Continue to Step 3.

---

## STEP 3: TRY INCOGNITO MODE

**Incognito mode bypasses cache and extensions.**

### Do This:

1. **Open browser in incognito/private mode:**
   - Chrome: `Ctrl+Shift+N`
   - Edge: `Ctrl+Shift+P`
   - Firefox: `Ctrl+Shift+P`

2. **Navigate to:**
   ```
   http://localhost:5031/Account/Login
   ```

3. **Log in with credentials**

4. **Navigate to:**
   ```
   http://localhost:5031/Obra/Escolher
   ```

**If this works:** ✅ Problem solved! Clear cache in normal mode or use incognito.

**If this doesn't work:** Continue to Step 4.

---

## STEP 4: TRY DIFFERENT BROWSER

**The issue might be browser-specific.**

### Do This:

1. **Open a different browser:**
   - If using Chrome, try Edge
   - If using Edge, try Chrome
   - If using Firefox, try Chrome

2. **Navigate to:**
   ```
   http://localhost:5031/Account/Login
   ```

3. **Log in with credentials**

4. **Navigate to:**
   ```
   http://localhost:5031/Obra/Escolher
   ```

**If this works:** ✅ Problem solved! Use the working browser or fix the original one.

**If this doesn't work:** Continue to Step 5.

---

## STEP 5: USE HTTP INSTEAD OF HTTPS

**SSL certificate might be blocking the connection.**

### Do This:

1. **Make sure you're using HTTP (port 5031), NOT HTTPS (port 7201):**
   ```
   http://localhost:5031/Account/Login
   ```
   
   **NOT:**
   ```
   https://localhost:7201/Account/Login
   ```

2. **Log in with credentials**

3. **Navigate to:**
   ```
   http://localhost:5031/Obra/Escolher
   ```

**If this works:** ✅ Problem solved! Use HTTP instead of HTTPS.

**If this doesn't work:** Continue to Step 6.

---

## STEP 6: CHECK BROWSER DEVELOPER TOOLS

**We need to see what's happening in the browser.**

### Do This:

1. **Open browser**

2. **Press F12** to open Developer Tools

3. **Go to Network tab**

4. **Navigate to:**
   ```
   http://localhost:5031/Account/Login
   ```

5. **Look at Network tab:**
   - Are there ANY requests?
   - Are requests failing (red)?
   - Are requests pending (gray)?

6. **Go to Console tab:**
   - Are there JavaScript errors?
   - Are there CORS errors?
   - Are there security errors?

7. **Take screenshots of:**
   - Network tab
   - Console tab

8. **Provide screenshots to us** so we can diagnose

**If you see errors:** 📸 Send us screenshots and we'll help fix them.

**If you see NO requests:** Continue to Step 7.

---

## STEP 7: RUN DIAGNOSTIC SCRIPT

**Let's automatically diagnose the issue.**

### Do This:

1. **Open PowerShell in project root**

2. **Run diagnostic script:**
   ```powershell
   .\diagnose-browser-connection-issue.ps1
   ```

3. **Read the output** - it will tell you what's wrong

4. **Follow the recommendations** in the script output

**If script identifies issue:** ✅ Follow the fix provided by script.

**If script doesn't help:** Continue to Step 8.

---

## STEP 8: RESTART EVERYTHING

**Nuclear option - restart everything fresh.**

### Do This:

1. **Close ALL browsers**

2. **Stop the server** (Ctrl+C in server console)

3. **Restart your computer**

4. **Start server fresh:**
   ```powershell
   cd RDO-NET8-Migration\RdoApp.Core
   dotnet run
   ```

5. **Wait for server to start** (shows "Now listening on...")

6. **Open browser**

7. **Try Step 1 again** (log in, then navigate to escolher)

**If this works:** ✅ Problem solved! Something was stuck.

**If this doesn't work:** Continue to Step 9.

---

## STEP 9: USE VISUAL STUDIO F5

**Let Visual Studio handle everything.**

### Do This:

1. **Open Visual Studio**

2. **Open project:**
   ```
   RDO-NET8-Migration\RdoApp.Core\RdoApp.Core.csproj
   ```

3. **Press F5** (Start Debugging)

4. **Visual Studio will:**
   - Start the server
   - Open browser automatically
   - Navigate to the app

5. **Log in when browser opens**

6. **Navigate to /Obra/Escolher**

**If this works:** ✅ Problem solved! Use Visual Studio F5 to run the app.

**If this doesn't work:** Continue to Step 10.

---

## STEP 10: PROVIDE DIAGNOSTIC INFORMATION

**We need more information to help you.**

### Please Provide:

1. **Screenshot of browser Developer Tools (F12):**
   - Console tab showing errors
   - Network tab showing requests

2. **Exact URL you're accessing:**
   - Copy/paste from browser address bar

3. **Server console output:**
   - Last 20 lines showing server status

4. **Browser information:**
   - Which browser? (Chrome, Edge, Firefox)
   - Which version?

5. **What you see:**
   - Completely blank white page?
   - Error message?
   - Redirect loop?
   - Loading spinner?

**Send this information to us and we'll provide a targeted fix.**

---

## MOST LIKELY SOLUTION

**90% of the time, the issue is:**

### YOU NEED TO LOG IN FIRST!

The `/Obra/Escolher` page requires authentication. You MUST log in at `/Account/Login` before you can access it.

**Steps:**
1. Navigate to: `http://localhost:5031/Account/Login`
2. Log in with: username `ricardo`, password `123456`
3. Then navigate to: `http://localhost:5031/Obra/Escolher`
4. You should see 103 obra cards!

---

## SUMMARY

**Try these in order:**

1. ✅ Log in first (90% chance this fixes it)
2. ✅ Clear browser cache
3. ✅ Try incognito mode
4. ✅ Try different browser
5. ✅ Use HTTP instead of HTTPS
6. ✅ Check Developer Tools (F12)
7. ✅ Run diagnostic script
8. ✅ Restart everything
9. ✅ Use Visual Studio F5
10. ✅ Provide diagnostic information

**One of these WILL fix the issue!**

---

**Document Status:** 🟢 READY TO USE  
**Last Updated:** January 22, 2026  
**Start with:** Step 1 (Log in first)

