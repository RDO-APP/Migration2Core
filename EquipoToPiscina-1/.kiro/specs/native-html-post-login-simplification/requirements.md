# Requirements Document: Native HTML POST Login Simplification

## Introduction

The current Blazor-First Authentication Bridge implementation is over-engineered with unnecessary JavaScript complexity (JWT tokens, JavaScript bridge, hidden form manipulation). This spec simplifies the authentication flow by using native HTML form POST, eliminating all JavaScript bridge code while maintaining the modern Blazor UI and fast client-side validation feedback.

**ROOT CAUSE OF OVER-ENGINEERING:**
- Incorrect assumption that Blazor components can't POST to MVC actions natively
- Unnecessary JWT token generation for "secure handoff"
- JavaScript bridge (`rdo-auth-bridge.js`) that manually populates and submits hidden forms
- Extra validation layer that duplicates work

**THE SIMPLER TRUTH:**
- Blazor EditForm supports native HTML POST with `method="post"` and `action="/path"`
- Blazor validates on client-side (fast feedback) BEFORE form submission
- Native browser POST sends data to MVC action (standard POST-REDIRECT-GET pattern)
- MVC action writes authentication cookie (has full HttpContext access)
- No JavaScript bridge needed!

## Glossary

- **EditForm**: Blazor component that can render as native HTML form with POST capability
- **Native_HTML_POST**: Standard browser form submission without JavaScript intervention
- **POST_REDIRECT_GET**: Standard web pattern where POST action redirects to GET endpoint
- **Client_Side_Validation**: Blazor validation that provides fast feedback before form submission
- **Cookie_Authentication**: ASP.NET Core authentication using HTTP cookies

## Requirements

### Requirement 1: Native HTML Form Submission

**User Story:** As a developer, I want to use native HTML form POST for authentication, so that the implementation is simple, standard, and maintainable.

#### Acceptance Criteria

1. THE System SHALL use Blazor EditForm with `method="post"` and `action="/Account/Login"` attributes
2. WHEN the form is valid, THE System SHALL allow native browser POST to MVC action
3. THE System SHALL NOT use JavaScript to manipulate or submit the form
4. THE System SHALL NOT use hidden forms for data transfer
5. THE System SHALL follow standard POST-REDIRECT-GET pattern

### Requirement 2: Blazor Client-Side Validation

**User Story:** As a user, I want immediate validation feedback when I enter my credentials, so that I know if there are errors before submitting.

#### Acceptance Criteria

1. WHEN a user enters CPF, THE System SHALL validate format in real-time using Blazor
2. WHEN a user enters password, THE System SHALL validate required field in real-time using Blazor
3. WHEN validation fails, THE System SHALL display error messages immediately without server round-trip
4. WHEN validation passes, THE System SHALL enable the submit button
5. THE System SHALL use DataAnnotationsValidator for validation rules

### Requirement 3: MVC Cookie Writing

**User Story:** As a system, I want the MVC controller to write authentication cookies, so that the user is properly authenticated after login.

#### Acceptance Criteria

1. WHEN the MVC Login action receives valid credentials, THE System SHALL validate against database
2. WHEN credentials are valid, THE System SHALL create ClaimsPrincipal with user claims
3. WHEN creating authentication, THE System SHALL write cookie using HttpContext.SignInAsync
4. WHEN "Remember Me" is checked, THE System SHALL set cookie expiry to 30 days
5. WHEN "Remember Me" is unchecked, THE System SHALL set cookie expiry to 8 hours

### Requirement 4: JavaScript Bridge Elimination

**User Story:** As a developer, I want to remove all unnecessary JavaScript bridge code, so that the codebase is simpler and more maintainable.

#### Acceptance Criteria

1. THE System SHALL NOT use `rdo-auth-bridge.js` JavaScript file
2. THE System SHALL NOT use `JwtTokenService` for token generation
3. THE System SHALL NOT use `AuthBridgeDto` for data transfer
4. THE System SHALL NOT use `AuthBridge` MVC action for cookie writing
5. THE System SHALL remove all JWT-related NuGet packages if not used elsewhere

### Requirement 5: Modern Blazor UI Preservation

**User Story:** As a user, I want to keep the modern Blazor login UI with fast feedback, so that the experience remains professional and responsive.

#### Acceptance Criteria

1. THE System SHALL keep LoginPage.razor as the UI component
2. THE System SHALL keep CPF masking functionality (rdo-login.js)
3. THE System SHALL keep modern CSS styling (rdo-login.css)
4. THE System SHALL keep password visibility toggle
5. THE System SHALL keep "Remember Me" checkbox functionality

### Requirement 6: Security Preservation

**User Story:** As a security-conscious developer, I want to maintain all security measures, so that authentication remains secure despite simplification.

#### Acceptance Criteria

1. THE System SHALL use anti-forgery tokens for POST protection
2. THE System SHALL validate credentials against database before writing cookie
3. THE System SHALL use secure cookie flags (HttpOnly, Secure, SameSite)
4. THE System SHALL hash passwords using existing password validation logic
5. THE System SHALL maintain session timeout rules (8 hours / 30 days)

### Requirement 7: Error Handling

**User Story:** As a user, I want clear error messages when login fails, so that I know what went wrong.

#### Acceptance Criteria

1. WHEN credentials are invalid, THE System SHALL return to login page with error message
2. WHEN database is unavailable, THE System SHALL display "System error" message
3. WHEN account is inactive, THE System SHALL display "Account inactive" message
4. THE System SHALL preserve entered CPF on validation failure
5. THE System SHALL NOT preserve password on validation failure (security)

### Requirement 8: Backward Compatibility

**User Story:** As a developer, I want to ensure the simplified login works with existing authentication middleware, so that no other parts of the system break.

#### Acceptance Criteria

1. THE System SHALL work with existing authentication middleware configuration
2. THE System SHALL work with existing authorization policies
3. THE System SHALL redirect to `/Obra/Escolher` after successful login
4. THE System SHALL maintain existing claims structure (NameIdentifier, Name, Role, etc.)
5. THE System SHALL work with existing logout functionality

## Out of Scope

- Changing the visual design of the login page
- Modifying the database schema or password hashing algorithm
- Implementing two-factor authentication
- Changing the redirect destination after login
- Modifying the "Forgot Password" functionality (already marked as "in development")

## Success Metrics

1. ✅ Zero JavaScript files needed for authentication handoff
2. ✅ Zero JWT token generation for login flow
3. ✅ Zero hidden forms for data transfer
4. ✅ Reduced code complexity (fewer files, fewer lines of code)
5. ✅ Maintained security (all existing security measures preserved)
6. ✅ Maintained UX (fast validation feedback, modern UI)
7. ✅ Standard web patterns (native HTML POST, POST-REDIRECT-GET)
