# Escolher Blank Page Investigation - Tasks

**Created:** January 20, 2026  
**Status:** Ready for Execution  
**Priority:** CRITICAL

---

## Task Breakdown

### Phase 1: Diagnostic (No Changes) ⏳

**Objective:** Gather information about the blank page issue without making any changes

#### Task 1.1: Browser Console Diagnostic
**Status:** ⏳ Pending User Input  
**Assignee:** User  
**Estimated Time:** 2 minutes

**Steps:**
1. Open browser to `https://localhost:7201/Obra/Escolher`
2. Press F12 to open Developer Tools
3. Click Console tab
4. Take screenshot of any errors
5. Report findings

**Deliverable:** Screenshot or text of console errors (if any)

**Questions to Answer:**
- Are there any red error messages?
- Are there any warnings?
- Are there any JavaScript errors?

---

#### Task 1.2: Network Tab Diagnostic
**Status:** ⏳ Pending User Input  
**Assignee:** User  
**Estimated Time:** 2 minutes

**Steps:**
1. Stay in F12 Developer Tools
2. Click Network tab
3. Refresh page (Ctrl+F5)
4. Look for red/failed requests
5. Take screenshot
6. Report findings

**Deliverable:** Screenshot of Network tab showing all requests

**Questions to Answer:**
- Are there any 404 errors?
- Are there any 500 errors?
- Do fontello.css and escolher-legacy.css load successfully?
- What is the status code for /Obra/Escolher request?

---

#### Task 1.3: Page Source Diagnostic
**Status:** ⏳ Pending User Input  
**Assignee:** User  
**Estimated Time:** 2 minutes

**Steps:**
1. Right-click on blank page
2. Select "View Page Source" (Ctrl+U)
3. Copy first 50 lines of HTML
4. Report findings

**Deliverable:** First 50 lines of page source

**Questions to Answer:**
- Is there any HTML content?
- Is the page completely empty?
- Is there an error message?
- Does it show `<!DOCTYPE html>`?

---

#### Task 1.4: Elements Tab Diagnostic
**Status:** ⏳ Pending User Input  
**Assignee:** User  
**Estimated Time:** 2 minutes

**Steps:**
1. Stay in F12 Developer Tools
2. Click Elements tab
3. Expand `<html>` → `<body>`
4. Take screenshot
5. Report findings

**Deliverable:** Screenshot of Elements tab showing DOM structure

**Questions to Answer:**
- Is there content in the `<body>` tag?
- Are elements present but hidden?
- Is the DOM tree complete or partial?

---

#### Task 1.5: File Existence Check
**Status:** ⏳ Pending Kiro Execution  
**Assignee:** Kiro  
**Estimated Time:** 1 minute

**Steps:**
```powershell
# Check if CSS files exist:
Test-Path "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css"
Test-Path "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"

# Check if font files exist:
Test-Path "RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.woff2"
Test-Path "RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.woff"
```

**Deliverable:** File existence report

**Questions to Answer:**
- Do the CSS files exist?
- Do the font files exist?
- Are they in the correct locations?

---

#### Task 1.6: Model Type Analysis
**Status:** ⏳ Pending Kiro Execution  
**Assignee:** Kiro  
**Estimated Time:** 2 minutes

**Steps:**
1. Read current Escolher.cshtml
2. Check `@model` directive
3. Read ObraController.cs
4. Check return type of Escolher() action
5. Compare types

**Deliverable:** Model type comparison report

**Questions to Answer:**
- What model type does the view expect?
- What model type does the controller return?
- Do they match?

---

### Phase 2: Root Cause Analysis 🔍

**Objective:** Identify the exact cause of the blank page based on diagnostic findings

#### Task 2.1: Analyze Diagnostic Findings
**Status:** ⏳ Pending Phase 1 Completion  
**Assignee:** Kiro  
**Estimated Time:** 5 minutes

**Steps:**
1. Review all diagnostic findings
2. Identify patterns
3. Eliminate unlikely causes
4. Focus on most likely cause

**Deliverable:** Root cause hypothesis with evidence

---

#### Task 2.2: Verify Root Cause Hypothesis
**Status:** ⏳ Pending Task 2.1  
**Assignee:** Kiro  
**Estimated Time:** 5 minutes

**Steps:**
1. Design targeted test for hypothesis
2. Execute test
3. Analyze results
4. Confirm or reject hypothesis

**Deliverable:** Confirmed root cause with evidence

---

### Phase 3: Fix Strategy Selection 📋

**Objective:** Choose the best approach to fix the identified issue

#### Task 3.1: Evaluate Fix Options
**Status:** ⏳ Pending Phase 2 Completion  
**Assignee:** Kiro  
**Estimated Time:** 5 minutes

**Steps:**
1. List all possible fixes
2. Assess pros/cons of each
3. Evaluate risk and effort
4. Rank by success probability

**Deliverable:** Fix options comparison table

---

#### Task 3.2: Recommend Fix Strategy
**Status:** ⏳ Pending Task 3.1  
**Assignee:** Kiro  
**Estimated Time:** 2 minutes

**Steps:**
1. Select optimal fix strategy
2. Document rationale
3. Outline implementation steps
4. Identify risks

**Deliverable:** Recommended fix strategy document

---

#### Task 3.3: Get User Approval
**Status:** ⏳ Pending Task 3.2  
**Assignee:** User  
**Estimated Time:** Variable

**Steps:**
1. Review recommended fix strategy
2. Ask questions if needed
3. Approve or request alternative
4. Give permission to proceed

**Deliverable:** User approval to implement fix

---

### Phase 4: Implementation (With Permission) 🔧

**Objective:** Apply the approved fix and verify it works

#### Task 4.1: Create Backup
**Status:** ⏳ Pending User Approval  
**Assignee:** Kiro  
**Estimated Time:** 1 minute

**Steps:**
```powershell
# Backup current version:
Copy-Item 'RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml' `
          'RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml.pre-fix-backup' `
          -Force
```

**Deliverable:** Backup file created

---

#### Task 4.2: Implement Fix
**Status:** ⏳ Pending Task 4.1  
**Assignee:** Kiro  
**Estimated Time:** Variable (depends on fix)

**Steps:**
1. Apply approved fix
2. Make minimal changes
3. Document changes
4. Save file

**Deliverable:** Fixed Escolher.cshtml file

---

#### Task 4.3: Test Page Rendering
**Status:** ⏳ Pending Task 4.2  
**Assignee:** User  
**Estimated Time:** 2 minutes

**Steps:**
1. Navigate to `https://localhost:7201/Obra/Escolher`
2. Verify page is not blank
3. Check if content is visible
4. Report findings

**Deliverable:** Test result (pass/fail)

---

#### Task 4.4: Test Blue Header
**Status:** ⏳ Pending Task 4.3 Pass  
**Assignee:** User  
**Estimated Time:** 1 minute

**Steps:**
1. Verify blue header is visible
2. Check logo displays
3. Check user name displays
4. Check navigation icons display

**Deliverable:** Test result (pass/fail)

---

#### Task 4.5: Test Filters
**Status:** ⏳ Pending Task 4.3 Pass  
**Assignee:** User  
**Estimated Time:** 2 minutes

**Steps:**
1. Type in "Unidade Escolar" input
2. Verify cards filter
3. Type in "Município" input
4. Verify cards filter
5. Clear inputs
6. Verify all cards show

**Deliverable:** Test result (pass/fail)

---

#### Task 4.6: Test Obra Cards
**Status:** ⏳ Pending Task 4.3 Pass  
**Assignee:** User  
**Estimated Time:** 2 minutes

**Steps:**
1. Verify cards display in grid
2. Check icons are visible
3. Check progress bars show
4. Hover over card (check hover effect)
5. Click a card
6. Verify navigation to Etapa/Cards

**Deliverable:** Test result (pass/fail)

---

#### Task 4.7: Test Console Clean
**Status:** ⏳ Pending Task 4.3 Pass  
**Assignee:** User  
**Estimated Time:** 1 minute

**Steps:**
1. Open F12 Console
2. Refresh page
3. Check for errors
4. Check Network tab for 404s

**Deliverable:** Test result (pass/fail)

---

### Phase 5: Documentation 📝

**Objective:** Document the fix and how to verify it works

#### Task 5.1: Document Changes
**Status:** ⏳ Pending Phase 4 Completion  
**Assignee:** Kiro  
**Estimated Time:** 5 minutes

**Steps:**
1. List all changes made
2. Explain why each change was needed
3. Document before/after state
4. Create verification steps

**Deliverable:** Change documentation file

---

#### Task 5.2: Update Spec Status
**Status:** ⏳ Pending Task 5.1  
**Assignee:** Kiro  
**Estimated Time:** 2 minutes

**Steps:**
1. Mark all tasks as complete
2. Update spec status to "Complete"
3. Add completion date
4. Archive spec

**Deliverable:** Updated spec files

---

## Quick Reference: Most Likely Fix

### If Root Cause is Model Type Mismatch

**Fix:** Change one line in Escolher.cshtml

**Before:**
```csharp
@model IEnumerable<dynamic>
```

**After:**
```csharp
@model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>
```

**Time:** 30 seconds  
**Risk:** Minimal  
**Success Probability:** 90%

---

### If Root Cause is Missing CSS Files

**Fix:** Create external CSS files from backup inline CSS

**Steps:**
1. Extract inline CSS from backup
2. Create `fontello.css` file
3. Create `escolher-legacy.css` file
4. Verify files load

**Time:** 10 minutes  
**Risk:** Low  
**Success Probability:** 70%

---

### If Root Cause is Unknown

**Fix:** Full restore of December 2025 backup

**Steps:**
1. Backup current version
2. Restore entire backup file
3. Verify all dependencies
4. Test page

**Time:** 5 minutes  
**Risk:** None  
**Success Probability:** 100%

---

## Task Dependencies

```
Phase 1 (Diagnostic)
├── Task 1.1: Console Diagnostic
├── Task 1.2: Network Diagnostic
├── Task 1.3: Page Source Diagnostic
├── Task 1.4: Elements Diagnostic
├── Task 1.5: File Existence Check
└── Task 1.6: Model Type Analysis
         ↓
Phase 2 (Root Cause Analysis)
├── Task 2.1: Analyze Findings
└── Task 2.2: Verify Hypothesis
         ↓
Phase 3 (Fix Strategy)
├── Task 3.1: Evaluate Options
├── Task 3.2: Recommend Strategy
└── Task 3.3: Get User Approval
         ↓
Phase 4 (Implementation)
├── Task 4.1: Create Backup
├── Task 4.2: Implement Fix
├── Task 4.3: Test Rendering
├── Task 4.4: Test Header
├── Task 4.5: Test Filters
├── Task 4.6: Test Cards
└── Task 4.7: Test Console
         ↓
Phase 5 (Documentation)
├── Task 5.1: Document Changes
└── Task 5.2: Update Spec Status
```

---

## Current Status

**Phase 1:** ⏳ READY TO START  
**Phase 2:** ⏳ WAITING FOR PHASE 1  
**Phase 3:** ⏳ WAITING FOR PHASE 2  
**Phase 4:** ⏳ WAITING FOR USER APPROVAL  
**Phase 5:** ⏳ WAITING FOR PHASE 4

**Next Action:** Execute Phase 1 diagnostic tasks

---

## Estimated Timeline

| Phase | Tasks | Time | Status |
|-------|-------|------|--------|
| Phase 1: Diagnostic | 6 tasks | 10-15 min | ⏳ Ready |
| Phase 2: Root Cause | 2 tasks | 10 min | ⏳ Waiting |
| Phase 3: Fix Strategy | 3 tasks | 7 min + user time | ⏳ Waiting |
| Phase 4: Implementation | 7 tasks | 5-30 min | ⏳ Waiting |
| Phase 5: Documentation | 2 tasks | 7 min | ⏳ Waiting |
| **TOTAL** | **20 tasks** | **39-69 min** | ⏳ Not Started |

**Best Case:** 39 minutes (if model type fix works immediately)  
**Worst Case:** 69 minutes (if full diagnostic and complex fix needed)  
**Most Likely:** 45 minutes (model type fix + testing)

---

**Status:** Tasks Defined - Ready to Execute Phase 1  
**Next Action:** Begin diagnostic tasks (no changes to code yet)
