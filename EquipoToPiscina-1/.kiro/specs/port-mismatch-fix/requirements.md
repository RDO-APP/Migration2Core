# Port Mismatch Fix - Requirements

## Problem Statement

Visual Studio is configured to run on HTTPS port 7201 and HTTP port 5031, but all test scripts and documentation reference the incorrect port 5001. This causes connection failures and blank pages when users follow the instructions.

## Root Cause

The `launchSettings.json` file correctly specifies:
- HTTPS: `https://localhost:7201`
- HTTP: `http://localhost:5031`

However, all PowerShell test scripts and markdown documentation were created with hardcoded references to port 5001, which is not the actual port Visual Studio uses.

## User Stories

### US-1: Correct Port in Test Scripts
**As a** developer  
**I want** all PowerShell test scripts to use the correct port 7201  
**So that** I can run tests without connection failures

**Acceptance Criteria:**
- All `.ps1` files reference `https://localhost:7201` instead of `https://localhost:5001`
- Scripts that check multiple ports include 7201 as the primary port
- No references to port 5001 remain in active test scripts

### US-2: Correct Port in Documentation
**As a** developer  
**I want** all documentation to reference the correct port 7201  
**So that** I can follow instructions without confusion

**Acceptance Criteria:**
- All `.md` files reference `https://localhost:7201` instead of `https://localhost:5001`
- Quick start guides show the correct URL
- Testing instructions use the correct port

### US-3: Verify AccountController Redirects
**As a** user  
**I want** the AccountController to redirect to the correct port  
**So that** login redirects work properly

**Acceptance Criteria:**
- AccountController redirects use relative URLs (no hardcoded ports)
- Redirects work correctly on port 7201
- No hardcoded port references in controller code

## Technical Requirements

### TR-1: Update RUN-ESCOLHER-FINAL-TEST.ps1
- Change all references from `localhost:5001` to `localhost:7201`
- Update instructions to show correct port
- Verify script works with new port

### TR-2: Update Documentation Files
- Update all `.md` files with port references
- Focus on user-facing documentation first
- Update historical documentation for accuracy

### TR-3: Verify No Hardcoded Ports in Code
- Check all controllers for hardcoded port references
- Ensure all redirects use relative URLs
- Verify no port dependencies in services

## Out of Scope

- Changing the actual port configuration in launchSettings.json (already correct)
- Updating archived/backup documentation files
- Changing port numbers in historical commit messages

## Success Metrics

- Zero references to port 5001 in active scripts
- Zero references to port 5001 in user-facing documentation
- All test scripts run successfully on port 7201
- Login and redirect flow works without errors

## Dependencies

- launchSettings.json (already correct)
- Visual Studio configuration (already correct)
- No code changes required in controllers (already using relative URLs)

## Timeline

- **Phase 1:** Update critical test script (RUN-ESCOLHER-FINAL-TEST.ps1) - 5 minutes
- **Phase 2:** Update user-facing documentation - 10 minutes
- **Phase 3:** Verify AccountController - 5 minutes
- **Total:** 20 minutes

## Priority

**CRITICAL** - This is blocking the user from testing the 404 fix that was already implemented.
