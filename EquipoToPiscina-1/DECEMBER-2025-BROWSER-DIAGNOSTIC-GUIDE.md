# December 2025 Restoration - Browser Diagnostic Guide

**Date**: January 20, 2026  
**Purpose**: Step-by-step guide for investigating blank page  
**Status**: USER INVESTIGATION GUIDE

---

## WHAT TO DO NOW

You need to check what's happening in the browser when you access the blank page.

---

## STEP-BY-STEP INSTRUCTIONS

### 1. Open the Application

```
1. Navigate to: https://localhost:7201/Obra/Escolher
2. You should see a blank page (this is the issue)
3. Keep this tab open
```

---

### 2. Open Developer Tools (F12)

**Windows/Linux:**
- Press `F12` key
- OR Right-click anywhere → "Inspect" or "Inspect Element"

**Mac:**
- Press `Cmd + Option + I`
- OR Right-click anywhere → "Inspect Element"

You should see a panel open at the bottom or side of your browser.

---

### 3. CHECK CONSOLE TAB

**What to look for:**

```
Click on "Console" tab in Developer Tools

Look for RED error messages like:
❌ Uncaught TypeError: Cannot read property 'Descricao' of undefined
❌ ReferenceError: escolherObra is not defined
❌ Failed to load resource: the server responded with a status of 500
❌ Razor compilation error
```

**What to report:**

- Are there ANY red error messages?
- If yes, copy the EXACT error text
- Take a screenshot if possible

**Example of what you might see:**

```
✅ GOOD (no errors):
   Console is empty or only has info messages

❌ BAD (has errors):
   TypeError: Cannot read property 'Descricao' of undefined
   at Escolher.cshtml:line 123
```

---

### 4. CHECK NETWORK TAB

**What to look for:**

```
1. Click on "Network" tab in Developer Tools
2. Reload the page (F5 or Ctrl+R)
3. Look at the list of requests

Find the request to "/Obra/Escolher"
Check its status code:
✅ 200 OK = Good (page loaded)
❌ 404 Not Found = Bad (page not found)
❌ 500 Internal Server Error = Bad (server error)
```

**What to report:**

- What is the status code for `/Obra/Escolher`?
- Are there any failed requests (red text)?
- Are Bootstrap/jQuery files loading? (look for `bootstrap.min.css`, `jquery.min.js`)

**Example:**

```
✅ GOOD:
   /Obra/Escolher → 200 OK
   /lib/bootstrap/dist/css/bootstrap.min.css → 200 OK
   /lib/jquery/dist/jquery.min.js → 200 OK

❌ BAD:
   /Obra/Escolher → 500 Internal Server Error
   /lib/bootstrap/dist/css/bootstrap.min.css → 404 Not Found
```

---

### 5. VIEW PAGE SOURCE

**What to look for:**

```
1. Right-click on the blank page
2. Select "View Page Source" (NOT "Inspect")
3. A new tab opens with HTML code

Check if:
✅ There is HTML code visible
❌ Page is completely empty (no HTML at all)
❌ There's an error message in the HTML
```

**What to report:**

- Is there HTML code present?
- If yes, can you see the blue header HTML? (look for `<nav class="top-nav">`)
- If yes, can you see obra cards HTML? (look for `<div class="lista-obras">`)
- If no HTML, is the page completely blank?

**Example:**

```
✅ GOOD (HTML present but not rendering):
   <!DOCTYPE html>
   <html lang="pt-BR">
   <head>
   ...
   <nav class="top-nav">
   ...

❌ BAD (completely empty):
   (blank page, no HTML at all)

❌ BAD (error message):
   <html>
   <body>
   <h1>Server Error</h1>
   <p>An error occurred while processing your request.</p>
   </body>
   </html>
```

---

## WHAT TO REPORT BACK

Please provide the following information:

### Console Tab
```
[ ] No errors (console is clean)
[ ] Has errors (provide error text below)

Error text:
_________________________________
_________________________________
_________________________________
```

### Network Tab
```
/Obra/Escolher status: _______ (200, 404, 500, etc.)

Failed requests:
_________________________________
_________________________________
```

### Page Source
```
[ ] HTML is present (page has code but not rendering)
[ ] Page is completely empty (no HTML at all)
[ ] Error message in HTML (provide message below)

Details:
_________________________________
_________________________________
```

---

## INTERPRETATION GUIDE

### Scenario A: Console has errors
**Meaning:** JavaScript or Razor compilation issue  
**Next step:** Fix the specific error

### Scenario B: Network shows 500 error
**Meaning:** Server-side error (controller or view)  
**Next step:** Check server logs

### Scenario C: Network shows 200 OK, but blank page
**Meaning:** Model type mismatch (most likely)  
**Next step:** Apply model type fix

### Scenario D: HTML present but not rendering
**Meaning:** CSS/JavaScript not loading  
**Next step:** Check asset paths

### Scenario E: Page completely empty
**Meaning:** View not found or severe error  
**Next step:** Check routing and view location

---

## MOST LIKELY SCENARIO

Based on the restoration, **Scenario C** is most likely:

```
✅ Network: /Obra/Escolher returns 200 OK
✅ Console: No errors (or minimal errors)
❌ Result: Blank page (nothing renders)

Cause: Model type mismatch
  - View expects: IEnumerable<dynamic>
  - Controller returns: IEnumerable<ObraViewModel>
  - Razor fails silently when types don't match

Fix: Change model type in line 1 of Escolher.cshtml
```

---

## AFTER GATHERING INFORMATION

Once you have the diagnostic information, report back with:

1. **Console errors** (if any)
2. **Network status codes**
3. **Page source status** (HTML present or empty)

Then we can:
- **Confirm** the model type mismatch diagnosis
- **Apply** the quick fix (change 1 line)
- **OR** investigate further if needed

---

## QUICK REFERENCE

**Open Developer Tools:** `F12`  
**Reload Page:** `F5` or `Ctrl+R`  
**View Page Source:** Right-click → "View Page Source"

**Tabs to check:**
1. Console (for errors)
2. Network (for request status)
3. Page Source (for HTML content)

---

**Status**: 📋 INVESTIGATION GUIDE  
**Next**: Gather browser diagnostics  
**Then**: Report findings for analysis

---

## SCREENSHOTS WOULD HELP

If possible, take screenshots of:
1. Console tab (showing any errors)
2. Network tab (showing /Obra/Escolher request)
3. Page source (showing HTML or empty page)

This will help confirm the diagnosis quickly!
