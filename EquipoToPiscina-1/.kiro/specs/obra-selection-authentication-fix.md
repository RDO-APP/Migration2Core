# Obra Selection Authentication Fix Specification

## Overview
This spec addresses the persistent issue with the `test-obra-selection-fix-final.ps1` script and ensures proper authentication flow for obra selection functionality.

## Problem Statement
The obra selection test script consistently fails because:
1. API endpoints require authentication but tests are not properly authenticated
2. The authentication flow between login and API calls is not properly maintained
3. Session management between web requests is inconsistent

## User Stories

### Story 1: Authenticated API Testing
**As a** developer  
**I want** the test script to properly authenticate before testing API endpoints  
**So that** I can verify the obra selection functionality works end-to-end  

**Acceptance Criteria:**
- [ ] Test script successfully logs in with Ricardo's credentials
- [ ] Session is maintained across subsequent API calls
- [ ] ObterObras API returns actual obra data (not 401 Unauthorized)
- [ ] Test verifies that Ricardo can see his 4 assigned obras

### Story 2: Ricardo User Access Verification
**As a** system administrator  
**I want** to verify Ricardo's user access and obra assignments  
**So that** I can confirm the authentication and authorization system works correctly  

**Acceptance Criteria:**
- [ ] Ricardo can log in with CPF: 567.065.455-20
- [ ] Ricardo can log in with Password: RXL8DjdYj6Y=
- [ ] Ricardo has access to exactly 4 unidades escolares
- [ ] First obra is "EMEF PROF. ANTONIO DUARTE DE ALMEIDA"

### Story 3: End-to-End Obra Selection Flow
**As a** user (Ricardo)  
**I want** to select an obra and navigate to its etapas/tarefas  
**So that** I can perform my daily work tasks  

**Acceptance Criteria:**
- [ ] Login page loads without errors
- [ ] Authentication succeeds with valid credentials
- [ ] Obra selection page displays available obras as cards
- [ ] Clicking an obra navigates to etapas page without 500 errors
- [ ] Etapas page displays actual data from the database

## Technical Requirements

### Authentication Flow
1. **Login Process:**
   - User enters CPF: 567.065.455-20
   - User enters Password: RXL8DjdYj6Y=
   - System validates credentials against database
   - System creates authenticated session with proper claims
   - System redirects to dashboard/obra selection

2. **Session Management:**
   - Claims include user ID (not just CPF)
   - Session persists across page navigation
   - API calls inherit authentication from session

3. **API Authorization:**
   - ObterObras API validates user authentication
   - API returns obras assigned to authenticated user
   - Proper error handling for unauthorized requests

### Database Requirements
- User exists in colaboradores table with CPF: 567.065.455-20
- User has PasswordHash matching: RXL8DjdYj6Y=
- User is assigned to 4 obras through obra_colaborador relationship
- User status is active (Ativo = true)

## Implementation Tasks

### Task 1: Fix Test Script Authentication
**Priority:** High  
**Effort:** 2 hours  

Update `test-obra-selection-fix-final.ps1` to:
- Perform actual login with session management
- Maintain cookies/session across API calls
- Test authenticated endpoints properly
- Verify actual data responses (not just status codes)

### Task 2: Verify Authentication Service
**Priority:** High  
**Effort:** 1 hour  

Ensure AuthService properly:
- Sets ClaimTypes.NameIdentifier with user ID (not CPF)
- Creates persistent authentication cookies
- Handles session expiration gracefully

### Task 3: Database Verification
**Priority:** Medium  
**Effort:** 30 minutes  

Verify database state:
- Ricardo's user record exists and is active
- Password hash is correct
- Obra assignments are properly configured
- All required tables have correct relationships

### Task 4: End-to-End Manual Testing
**Priority:** High  
**Effort:** 1 hour  

Manual verification:
- Login flow works in browser
- Obra selection displays correctly
- Navigation to etapas works
- No console errors or 500 responses

## Definition of Done
- [ ] Test script runs successfully without authentication errors
- [ ] Ricardo can log in and see his 4 assigned obras
- [ ] Obra selection leads to functional etapas page
- [ ] No 401, 500, or other HTTP errors in the flow
- [ ] Session management works across page navigation
- [ ] All acceptance criteria are met

## Risk Mitigation
- **Risk:** Session timeout during testing
  - **Mitigation:** Implement proper session refresh in test script
- **Risk:** Database inconsistencies
  - **Mitigation:** Verify and fix database state before testing
- **Risk:** Authentication claims mismatch
  - **Mitigation:** Ensure consistent claim types between AuthService and API controllers

## Success Metrics
- Test script success rate: 100%
- Login success rate: 100%
- API response time: < 2 seconds
- Zero authentication-related errors in logs