# Blank Page Forensic Analysis - Requirements

**Date**: January 17, 2026  
**Status**: 🔍 **INVESTIGATION ONLY - NO CODE CHANGES**  
**Type**: Root Cause Analysis

---

## Executive Summary

The Escolher Obra page (`/Obra/Escolher`) renders blank despite:
- ✅ Controller executing successfully (103 obras retrieved)
- ✅ `Layout = null` (no layout dependency)
- ✅ Standalone HTML structure
- ✅ CSS files exist in `wwwroot/css/`
- ✅ Static file middleware configured in `Program.cs`

**This spec investigates 5 critical areas to identify the root cause.**

---

## Investigation Objectives

### Primary Goal
Identify why the Escolher Obra page renders blank when all components appear correct.

### Secondary Goals
1. Verify Bootstrap dependency requirements
2. Compare legacy vs new controller implementations
3. Analyze Tag Helper usage and potential issues
4. Understand layout selection mechanism
5. Review Blazor component architecture

---

## 5-Point Investigation Framework

### Question 1: Is Bootstrap Needed in the CSS?

**Hypothesis**: CSS might depend on Bootstrap classes that aren't loaded.

**Investigation Steps**:
- ✅ Analyze `escolher-legacy.css` for Bootstrap class usage
- ✅ Compare with legacy HTML structure
- ✅ Verify if progress bars use Bootstrap or custom CSS
- ✅ Check grid layout implementation (CSS Grid vs Bootstrap Grid)

**Expected Outcome**: Determine if Bootstrap is a hard dependency.

---

### Question 2: Controller - Legacy vs New Comparison

**Hypothesis**: New controller might be missing critical logic from legacy implementation.

**Investigation Steps**:
- ✅ Compare legacy API controller (`ObraController.cs` in AngularJS)
- ✅ Compare new MVC controller (`ObraController.cs` in .NET 8)
- ✅ Verify data transformation logic
- ✅ Check progress calculation methods
- ✅ Analyze status CSS class determination
- ✅ Compare error handling approaches

**Expected Outcome**: Identify any missing functionality or logic differences.

---

### Question 3: Can TagHelper Be an Issue?

**Hypothesis**: Tag Helpers might be causing rendering failures.

**Investigation Steps**:
- ✅ Scan `Escolher.cshtml` for Tag Helper usage (`asp-*` attributes)
- ✅ Check for `<environment>`, `<cache>`, or `<component>` tags
- ✅ Verify tilde (`~`) path resolution
- ✅ Analyze form submission mechanism

**Expected Outcome**: Determine if Tag Helpers are causing issues.

---

### Question 4: Did You Abandon _LayoutSelection.cshtml?

**Hypothesis**: Layout selection mechanism might be broken.

**Investigation Steps**:
- ✅ Verify `_LayoutSelection.cshtml` exists
- ✅ Check if `Escolher.cshtml` uses it (`Layout = null` vs `Layout = "_LayoutSelection"`)
- ✅ Understand Option A vs Option B vs Option C architecture
- ✅ Analyze layout inheritance chain

**Expected Outcome**: Understand layout selection strategy and if it's intentional.

---

### Question 5: How is RdoObraCards.razor Written?

**Hypothesis**: Blazor component might be better implemented than Razor view.

**Investigation Steps**:
- ✅ Review `RdoObraCards.razor` implementation
- ✅ Check `RdoObraCards.razor.css` scoped styles
- ✅ Compare with `Escolher.cshtml` inline Razor
- ✅ Analyze component parameters and event handling
- ✅ Verify if component is being used

**Expected Outcome**: Assess component quality and usage status.

---

## Acceptance Criteria

### Investigation Complete When:

1. **Bootstrap Dependency**: ✅ Confirmed whether Bootstrap is required
2. **Controller Comparison**: ✅ Identified any missing logic or differences
3. **Tag Helper Analysis**: ✅ Verified Tag Helper usage and potential issues
4. **Layout Strategy**: ✅ Understood layout selection mechanism
5. **Component Architecture**: ✅ Reviewed Blazor component implementation

### Root Cause Identified When:

- **Primary Issue**: Most likely cause of blank page identified
- **Secondary Issues**: Contributing factors documented
- **Diagnostic Steps**: Clear testing procedures defined
- **Fix Strategy**: Recommended solution path outlined

---

## Out of Scope

- ❌ Code changes or fixes
- ❌ Implementation of solutions
- ❌ Testing fixes
- ❌ Deployment considerations

**This is ANALYSIS ONLY** - no code modifications will be made.

---

## Success Metrics

1. **Clarity**: Root cause clearly identified with evidence
2. **Completeness**: All 5 investigation areas thoroughly analyzed
3. **Actionability**: Clear next steps for fixing the issue
4. **Documentation**: Comprehensive analysis document created

---

## Risk Assessment

### Low Risk
- Pure investigation, no code changes
- No impact on running system

### Medium Risk
- Analysis might not identify root cause
- Multiple contributing factors possible

### High Risk
- None (investigation only)

---

## Dependencies

### Required Files
- ✅ `RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml`
- ✅ `RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs`
- ✅ `RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css`
- ✅ `RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css`
- ✅ `RDO-NET8-Migration/RdoApp.Core/Program.cs`
- ✅ `RDO-Production-Gilberto/rdoappProject/Api/Controllers/ObraController.cs`
- ✅ `RDO-Production-Gilberto/rdoappProject/Client/Views/Obra/escolher.html`

### Required Context
- ✅ Option A implementation strategy
- ✅ Legacy architecture understanding
- ✅ Static file middleware configuration

---

## Timeline

- **Investigation Start**: January 17, 2026
- **Expected Duration**: 1-2 hours
- **Deliverable**: Comprehensive analysis document

---

## Notes

- User explicitly requested **NO CODE CHANGES**
- Focus is on understanding, not fixing
- Analysis should be thorough and evidence-based
- Document should guide future fix implementation
