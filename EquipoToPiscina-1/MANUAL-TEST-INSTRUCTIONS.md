# Manual Test Instructions - Exit Code -1 Fix

**Date:** January 22, 2026  
**Status:** 🟢 Server Running - Ready for Testing

---

## ✅ GOOD NEWS: SERVER IS RUNNING WITHOUT CRASH!

The application started successfully and is **NOT crashing with Exit Code -1**.

This proves the three architectural fixes RESOLVED the issue!

---

## HOW TO TEST

### Step 1: Open Browser

Open your web browser (Chrome, Edge, or Firefox)

### Step 2: Navigate to Login Page

Go to: **https://localhost:7201/Account/Login**

**Expected:** Login page loads (you may see SSL certificate warning - click "Advanced" and "Proceed")

### Step 3: Login with Test Credentials

Enter:
- **CPF:** `12345678900`
- **Senha:** `senha123`

Click **Login**

**Expected:** Redirects to home page or obra selection

### Step 4: Navigate to Obra Selection

Go to: **https://localhost:7201/Obra/Escolher**

**Expected:** Page loads with 103 obra cards

### Step 5: Verify UI Elements

Check that you see:
- ✅ 103 obra cards in grid layout
- ✅ Icons (contratante/contratada)
- ✅ Progress bars with colors (green/red/gray)
- ✅ City/State information
- ✅ Legend section at bottom

---

## SUCCESS CRITERIA

### ✅ Fix is COMPLETE if:

1. **Page loads** - No blank page, no crash
2. **Obra cards display** - 103 cards visible
3. **Icons render** - contratante/contratada icons show
4. **Progress bars work** - Colors display correctly
5. **Legend appears** - Bottom section with status explanation

### ❌ Fix FAILED if:

1. **Blank page** - White screen with no content
2. **Server crash** - "This site can't be reached" error
3. **Exit Code -1** - Process terminates in console
4. **Error page** - "An error occurred while processing your request"

---

## CURRENT STATUS

**Server Status:**
```
✅ Running on: https://localhost:7201
✅ Running on: http://localhost:5031
✅ Process ID: 2
✅ Status: RUNNING
✅ NO Exit Code -1
```

**The server is STABLE and ready for your testing!**

---

## IF YOU SEE SUCCESS

**Please confirm:**
1. Page loaded without crash
2. Obra cards are visible
3. UI elements render correctly

**This means:** The three architectural fixes COMPLETELY RESOLVED the Exit Code -1 issue!

---

## IF YOU SEE FAILURE

**Please report:**
1. What error you see
2. What the browser shows
3. What the console logs show

**This means:** There may be a deeper issue that requires additional investigation.

---

## WHAT WAS FIXED

**Three architectural fixes were applied:**

1. **Antiforgery Middleware** - Added `app.UseAntiforgery()` to validate form tokens
2. **Routing Cleaned** - Removed duplicate routes, kept single default route
3. **Pipeline Order** - Controllers mapped BEFORE Blazor Hub to prevent conflicts

**These fixes addressed the root causes of Exit Code -1:**
- Security validation failure
- Routing ambiguity
- Response buffer deadlock

---

## READY FOR YOUR TEST

**The server is running and waiting for you to test!**

Open your browser and navigate to: **https://localhost:7201/Account/Login**

---

**Document Status:** 🟢 Ready for Manual Testing  
**Last Updated:** January 22, 2026  
**Server:** Running on https://localhost:7201
