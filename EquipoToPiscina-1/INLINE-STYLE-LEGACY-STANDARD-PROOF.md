# INLINE STYLE LEGACY STANDARD PROOF

## Strategy: Bypass CSS Files Completely

**Problem**: CSS files may be ignored or overridden by other styles.
**Solution**: Apply styles INLINE directly in the HTML to prove the 300x130px Legacy Standard works.

## Inline Styles Applied

### Main Container (Outer Div)
```html
<div style="width: 300px !important; height: 130px !important; min-width: 300px !important; max-width: 300px !important; overflow: hidden !important; border: 1px solid #ccc; display: block; margin: 0; padding: 0; box-sizing: border-box; flex-shrink: 0; flex-grow: 0; flex-basis: 300px;">
```

### Internal Rows (All 4 Rows)
```html
<div style="display: flex; align-items: center; padding: 4px 8px; overflow: hidden; flex-shrink: 0; width: 100%; max-width: 284px; margin: 0 auto; box-sizing: border-box; [row-specific styles]">
```

### Toolbar Buttons (5 Buttons with White Borders)
```html
<button style="background: transparent; border: 1px solid white; color: white; padding: 3px 5px; font-size: 10px; cursor: pointer; border-radius: 3px; width: 26px; height: 18px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
```

### Progress Bar Container
```html
<div style="width: 100%; max-width: 250px; height: 12px; background: #e9ecef; border-radius: 6px; overflow: hidden; position: relative; display: flex; align-items: center; margin: 0 auto; box-sizing: border-box;">
```

### Dates Container
```html
<div style="width: 100%; height: 100%; display: flex; align-items: center; gap: 10px; justify-content: space-between;">
```

## Implementation Details

### Files Modified
- `RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor`

### Key Features
1. **CSS Bypass**: All critical styles applied inline, ignoring external CSS files
2. **Hard Constraints**: 300x130px dimensions enforced at HTML level
3. **Internal Limits**: All rows constrained to 284px max-width
4. **White Borders**: Toolbar buttons have explicit white borders
5. **Overflow Control**: Hidden overflow prevents content from breaking layout

## Decision Point

### If This Works (Cards are 300x130px):
- ✅ Legacy Standard PROVEN
- ✅ Inline styles override all CSS conflicts
- ✅ Continue with current approach

### If This Doesn't Work (Cards still stretch):
- ❌ Stop fighting CSS issues
- ➡️ Move immediately to **Task 5: Implementing Toolbar Buttons**
- 🎯 Focus on functionality over layout perfection

## Testing
Run the verification script:
```powershell
.\test-inline-style-legacy-standard.ps1
```

## Expected Results
- Cards exactly 300px wide × 130px tall
- No stretching regardless of content
- Toolbar buttons with white borders visible
- All content constrained within boundaries

**Status**: 🧪 INLINE STYLE PROOF APPLIED - TESTING REQUIRED
**Date**: 2026-01-03
**Next Step**: Test → If works: Continue | If fails: Move to Task 5