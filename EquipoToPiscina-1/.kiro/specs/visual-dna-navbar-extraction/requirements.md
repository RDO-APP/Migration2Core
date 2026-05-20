# Visual DNA Extraction - Main Top Navbar

## Overview
Extract and replicate the exact visual DNA of the legacy header system in Pure Blazor environment, ensuring 100% visual parity while eliminating all legacy technical debt.

## User Stories

### Story 1: Visual Parity Analysis
**As a** developer migrating from legacy to Pure Blazor  
**I want** a comprehensive forensic analysis of the legacy header structure  
**So that** I can replicate the exact visual hierarchy and RDO brand identity  

**Acceptance Criteria:**
- [ ] Complete audit table mapping legacy vs Blazor implementation
- [ ] Identification of all 7 header elements with exact positioning
- [ ] CSS class mapping from legacy to modern equivalents
- [ ] Logo asset verification and correct path implementation

### Story 2: Brand Block Implementation
**As a** user of the RDO system  
**I want** the official RDO logo and "PISCINAS" branding to be prominently displayed  
**So that** I can immediately identify the application and maintain brand consistency  

**Acceptance Criteria:**
- [ ] RDO logo displays correctly from `~/images/logo.png`
- [ ] "RDO App Piscinas" text appears with proper typography
- [ ] Brand block maintains exact spacing and alignment from legacy
- [ ] Responsive behavior matches legacy implementation

### Story 3: Global Navigation System
**As a** user navigating the application  
**I want** a hamburger menu that provides access to all major sections  
**So that** I can efficiently navigate between different areas of the system  

**Acceptance Criteria:**
- [ ] Hamburger menu icon displays correctly
- [ ] Pure Blazor C# state management (no jQuery)
- [ ] Menu expands/collapses with smooth animations
- [ ] Navigation items match legacy functionality

### Story 4: Context Indicator
**As a** user working on specific projects  
**I want** to see the current Obra/Unidade Escolar name in the header  
**So that** I always know which project context I'm working in  

**Acceptance Criteria:**
- [ ] Dynamic context display based on current selection
- [ ] Proper text truncation for long names
- [ ] Consistent typography with legacy system

### Story 5: Dynamic Spacer
**As a** user viewing the header on different screen sizes  
**I want** the layout to adapt properly with flexible spacing  
**So that** all elements remain visible and properly aligned  

**Acceptance Criteria:**
- [ ] Flexbox-based responsive spacing
- [ ] No fixed widths that break on mobile
- [ ] Maintains visual balance across all screen sizes

### Story 6: Action Toolbar (6 Buttons)
**As a** user performing common tasks  
**I want** quick access to 6 functional action buttons  
**So that** I can efficiently perform frequent operations  

**Acceptance Criteria:**
- [ ] All 6 buttons display with correct icons
- [ ] Proper hover states and visual feedback
- [ ] Exact spacing and sizing from legacy
- [ ] Pure Blazor EventCallback communication

### Story 7: User Identity & Menu
**As a** logged-in user  
**I want** to see my name and access profile/logout options  
**So that** I can manage my account and session  

**Acceptance Criteria:**
- [ ] User name displays correctly
- [ ] Dropdown menu with Profile and Logout options
- [ ] Pure Blazor state management for dropdown
- [ ] Proper authentication state handling

## Technical Requirements

### Architecture Constraints
- **Pure Blazor Only**: Zero jQuery, AngularJS, or legacy JavaScript
- **Modern CSS**: Flexbox/Grid layout, no Bootstrap hacks
- **Visual Parity**: Exact match to legacy appearance
- **Performance**: Fast rendering, minimal DOM manipulation

### Browser Support
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

### Accessibility Requirements
- WCAG 2.1 AA compliance
- Keyboard navigation support
- Screen reader compatibility
- High contrast mode support

## Definition of Done
- [ ] All 7 header elements implemented and positioned correctly
- [ ] Visual comparison shows 100% parity with legacy
- [ ] Zero legacy JavaScript dependencies
- [ ] All user stories pass acceptance criteria
- [ ] Responsive design works on mobile, tablet, desktop
- [ ] Accessibility audit passes
- [ ] Performance metrics meet targets