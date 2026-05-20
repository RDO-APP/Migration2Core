# RDO APP PISCINAS - LOGIN MODULE TECHNICAL BRIEFING (REACT NATIVE)

**Date**: February 1, 2026  
**Developer**: Carlos (React Native)  
**Module**: Mobile Login Screen  
**API Version**: .NET 8  
**Language**: English

---

## 🎯 OVERVIEW

This document provides functional and architectural specifications for implementing the login screen in the RDO App Piscinas mobile application using React Native.

**IMPORTANT CONTEXT**: 
- This is the **SECOND migration attempt** from legacy code
- First attempt was **frustrated/failed**
- Current .NET 8 migration is **PAUSED** to support mobile development
- This briefing focuses on **functional/architectural aspects only**
- **NO C# backend implementation details** will be revealed

---

## 🎨 1. VISUAL IDENTITY

### 1.1 Logo and Branding

**Primary Element**: Fontello Icon + "Piscinas" Text

**Composition**:
- **Icon**: Fontello custom icon (unicode `\e80c`)
- **Text**: "Piscinas" in SF UI Display Light font
- **Icon Color**: White (#FFFFFF)
- **Text Color**: White (#FFFFFF)
- **Icon Size**: 43px
- **Text Size**: 14px (uppercase)

**Positioning**:
- Centered at top of screen
- Top margin: 20% of screen height
- Spacing between icon and text: 8px

**Critical Note**: 
- The icon is NOT an emoji (🏊)
- It's a custom Fontello font icon with unicode `\e80c`
- Font file: `fontello.ttf` (request from design team)

### 1.2 Color Palette

**Screen Background**:
- Primary color: `#27496F` (dark blue)
- Optional gradient: `#27496F` → `#1C334D`

**Input Fields**:
- Background: Transparent with white bottom border
- Text: White (#FFFFFF)
- Placeholder: White with 60% opacity (#FFFFFF99)
- Active border: White (#FFFFFF)
- Inactive border: White with 40% opacity (#FFFFFF66)

**Buttons**:
- "LOGIN" button: `#0088DD` (light blue)
- "LOGIN" button (hover/pressed): `#0073BB` (darker blue)
- Button text: White (#FFFFFF)
- Button height: 41px
- Border radius: 8px

**Text Elements**:
- Labels: White (#FFFFFF)
- Links: White (#FFFFFF)
- Error messages: `#D04541` (red)

### 1.3 Typography

**Font Family** (priority order):
1. SF UI Display (Light, Medium, Bold)
2. Fallback: System default (San Francisco on iOS, Roboto on Android)

**Font Sizes**:
- Logo text: 14px (uppercase)
- Labels: 16px
- Input text: 16px
- Button: 16px (uppercase)
- Links: 14px
- Error messages: 14px

---

## 📋 2. FIELDS AND VALIDATION

### 2.1 CPF Field (Brazilian Tax ID)

**Type**: Text Input with mask
**Label**: "CPF"
**Placeholder**: "000.000.000-00"
**Required**: Yes

**Format Mask**:
- Pattern: `XXX.XXX.XXX-XX`
- Only numbers accepted
- Auto-formatting during typing
- Example: `567.065.455-20`

**Client-Side Validations**:

1. **Empty Field**:
   - Message: "CPF is required"
   - Trigger: On submit attempt

2. **Invalid Format**:
   - Message: "Invalid CPF"
   - Trigger: On blur (onBlur)
   - Validation: Must have exactly 11 digits

3. **Check Digit Validation** (Optional but recommended):
   - Standard CPF validation algorithm
   - Message: "Invalid CPF"
   - Trigger: On blur (onBlur)

**Behavior**:
- Auto-capitalization: Disabled
- Auto-correction: Disabled
- Keyboard: Numeric
- Clear field: "X" icon when filled

**API Format**:
- Send CPF WITHOUT formatting (numbers only)
- Example: `56706545520` (not `567.065.455-20`)

### 2.2 Password Field

**Type**: Secure Text Input
**Label**: "Password"
**Placeholder**: "Enter your password"
**Required**: Yes

**Client-Side Validations**:

1. **Empty Field**:
   - Message: "Password is required"
   - Trigger: On submit attempt

2. **Minimum Length**:
   - Minimum: 4 characters (based on legacy system)
   - Message: "Password must be at least 4 characters"
   - Trigger: On blur (onBlur)

**Behavior**:
- Show/Hide password: Eye icon (toggle)
- Auto-capitalization: Disabled
- Auto-correction: Disabled
- Keyboard: Default (allows special characters)
- Password is case-sensitive

### 2.3 "Remember Me" Checkbox

**Type**: Checkbox
**Label**: "Remember me"
**Default Value**: Unchecked (false)
**Required**: No

**Behavior**: See section 3.1

### 2.4 "LOGIN" Button

**Type**: Button (Submit)
**Text**: "LOGIN" (uppercase)
**Initial State**: Enabled

**States**:

1. **Normal**: Color `#0088DD`
2. **Pressed**: Color `#0073BB`
3. **Loading**: 
   - Show spinner/activity indicator
   - Text: "LOGGING IN..." or just spinner
   - Disable interaction
4. **Disabled**: 
   - Color: `#999999`
   - Opacity: 0.5

**Validation Before Submit**:
- CPF filled and valid
- Password filled with minimum 4 characters
- If validations fail: Show error messages and don't call API

### 2.5 "Forgot Password" Link

**Type**: Link/TouchableOpacity
**Text**: "Forgot password"
**Color**: White (#FFFFFF)
**Position**: Below "LOGIN" button

**Behavior**:
- Navigate to password recovery screen
- **Note**: Feature to be implemented in future phase

---

## 🔐 3. BUSINESS RULES

### 3.1 "Remember Me" Functionality

**Purpose**: Keep user authenticated between app sessions.

**Behavior When CHECKED**:

1. **Persistent Storage**:
   - Save user CPF in secure storage (SecureStore/Keychain)
   - Save authentication token in secure storage
   - Save flag `rememberMe: true`

2. **Next App Launch**:
   - Check if valid token exists in storage
   - If token exists and is valid: Perform automatic login (silent login)
   - If token exists but expired: Clear storage and show login screen
   - Pre-fill CPF field with saved value

3. **Session Duration**:
   - Token remains valid for 30 days (server configuration)
   - After 30 days: User must login again

**Behavior When UNCHECKED**:

1. **Temporary Storage**:
   - Save token only in memory (state/context)
   - DO NOT save in persistent storage
   - Save flag `rememberMe: false`

2. **Next App Launch**:
   - Always show login screen
   - Empty fields (don't pre-fill)

3. **Session Duration**:
   - Token valid only while app is running
   - On app close: Token is lost

**Implementation Example**:

```javascript
// Pseudo-code (not actual implementation)

// On successful login:
if (rememberMe) {
  await SecureStore.setItemAsync('userCpf', cpf);
  await SecureStore.setItemAsync('authToken', token);
  await SecureStore.setItemAsync('rememberMe', 'true');
} else {
  // Only save in context/state
  setAuthToken(token);
}

// On app launch:
const rememberMe = await SecureStore.getItemAsync('rememberMe');
if (rememberMe === 'true') {
  const token = await SecureStore.getItemAsync('authToken');
  if (token) {
    // Validate token with API
    // If valid: Perform automatic login
    // If invalid: Clear storage and show login
  }
}

// On logout:
await SecureStore.deleteItemAsync('userCpf');
await SecureStore.deleteItemAsync('authToken');
await SecureStore.deleteItemAsync('rememberMe');
```


### 3.2 Two-Step Authentication Flow

**CRITICAL**: The RDO App Piscinas uses a 2-step authentication process:

**Step 1: User Login**
- Endpoint: `POST /api/Account/Login`
- Input: CPF + Password
- Output: Authentication token + User data
- **Note**: At this step, user is authenticated but has NOT selected a work site yet

**Step 2: Work Site Selection**
- Endpoint: `POST /api/Obra/Selecionar`
- Input: Work Site ID
- Output: Complete context (user + work site + permissions)
- **Note**: Only after this step can user access app functionalities

**Mobile Flow**:

1. User logs in (Step 1)
2. App receives list of available work sites
3. If user has only 1 work site: Select automatically
4. If user has multiple work sites: Show selection screen
5. After selection (Step 2): Navigate to main screen

### 3.3 Error Handling

**Validation Errors** (Client-Side):
- Show message below field with error
- Message color: `#D04541` (red)
- Don't call API if validation errors exist

**API Errors** (Server-Side):

1. **Invalid Credentials** (401 Unauthorized):
   - Message: "Invalid CPF or password"
   - Position: Below "LOGIN" button
   - Clear password field
   - Keep focus on password field

2. **Inactive User** (403 Forbidden):
   - Message: "Inactive user. Contact administrator."
   - Position: Below "LOGIN" button

3. **Connection Error** (Network Error):
   - Message: "Connection error. Check your internet and try again."
   - Position: Below "LOGIN" button
   - Button: "TRY AGAIN"

4. **Server Error** (500 Internal Server Error):
   - Message: "Server error. Try again later."
   - Position: Below "LOGIN" button

5. **Timeout**:
   - Timeout: 30 seconds
   - Message: "Request took too long. Try again."
   - Position: Below "LOGIN" button

**General Error Behavior**:
- Light device vibration (optional)
- Shake animation on fields with errors
- Keep filled data (except password on invalid credentials)

### 3.4 Security Requirements

**Credential Storage**:
- ❌ NEVER store password in plain text
- ❌ NEVER store encrypted password
- ✅ Store only authentication token
- ✅ Use SecureStore/Keychain for secure storage

**API Communication**:
- ✅ Always use HTTPS
- ✅ Validate SSL certificate
- ✅ Include token in header: `Authorization: Bearer {token}`

**Session Timeout**:
- Token expires after 30 days (if "Remember me" checked)
- Token expires on app close (if "Remember me" unchecked)
- On expiration: Redirect to login screen

---

## 🔌 4. API INTEGRATION

### 4.1 Login Endpoint

**URL**: `POST /api/Account/Login`

**Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "cpf": "56706545520",
  "senha": "1234"
}
```

**Request Notes**:
- CPF must be sent WITHOUT formatting (numbers only)
- Password is case-sensitive
- Field names are in Portuguese: "cpf" and "senha"

**Success Response (200 OK)**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usuario": {
    "id": 123,
    "nome": "Ricardo Freire",
    "cpf": "56706545520",
    "email": "ricardo@example.com",
    "ativo": true
  },
  "obras": [
    {
      "id": 1,
      "nome": "Escola Municipal João Silva",
      "idObraColaborador": 456
    },
    {
      "id": 2,
      "nome": "Escola Estadual Maria Santos",
      "idObraColaborador": 457
    }
  ]
}
```

**Error Response (401 Unauthorized)**:
```json
{
  "success": false,
  "message": "CPF ou senha incorretos"
}
```

**Error Response (403 Forbidden)**:
```json
{
  "success": false,
  "message": "Usuário inativo"
}
```

### 4.2 Token Validation Endpoint

**URL**: `GET /api/Account/ValidateToken`

**Headers**:
```
Authorization: Bearer {token}
```

**Success Response (200 OK)**:
```json
{
  "valid": true,
  "expiresAt": "2026-03-03T10:30:00Z"
}
```

**Error Response (401 Unauthorized)**:
```json
{
  "valid": false,
  "message": "Token inválido ou expirado"
}
```

**When to Use**:
- On app launch (if "Remember me" was checked)
- Before making important requests
- Periodically (every 5 minutes) if app is in use

### 4.3 Work Site Selection Endpoint

**URL**: `POST /api/Obra/Selecionar`

**Headers**:
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "obraId": 1
}
```

**Success Response (200 OK)**:
```json
{
  "success": true,
  "obra": {
    "id": 1,
    "nome": "Escola Municipal João Silva",
    "endereco": "Rua das Flores, 123",
    "cidade": "São Paulo",
    "estado": "SP"
  },
  "permissoes": [
    "visualizar_tarefas",
    "criar_rdo",
    "editar_medicoes"
  ]
}
```

---

## 📱 5. MOBILE TECHNICAL SPECIFICATIONS

### 5.1 Responsiveness

**Supported Screen Sizes**:
- Smartphones: 320px - 428px (width)
- Tablets: 768px - 1024px (width)

**Orientation**:
- Primary: Portrait (vertical)
- Secondary: Landscape (horizontal) - optional

**Size Adaptations**:

**Small Smartphones** (< 375px):
- Logo: 35px
- Fields: Height 44px
- Button: Height 44px
- Spacing: Reduced by 20%

**Medium Smartphones** (375px - 414px):
- Logo: 43px (default)
- Fields: Height 48px
- Button: Height 48px
- Spacing: Default

**Large Smartphones** (> 414px):
- Logo: 50px
- Fields: Height 52px
- Button: Height 52px
- Spacing: Increased by 10%

### 5.2 Accessibility

**Minimum Requirements**:

1. **Descriptive Labels**:
   - All fields must have visible labels
   - Use `accessibilityLabel` for screen readers

2. **Color Contrast**:
   - Minimum: 4.5:1 (WCAG AA)
   - White on `#27496F`: 7.2:1 ✅

3. **Touch Target Size**:
   - Minimum: 44x44 points (iOS) / 48x48 dp (Android)
   - Apply to all interactive elements

4. **Haptic Feedback**:
   - Light vibration on button tap
   - Vibration on error

5. **Screen Readers**:
   - VoiceOver support (iOS)
   - TalkBack support (Android)

### 5.3 Performance

**Maximum Times**:
- Initial render: < 1 second
- Touch response: < 100ms
- API call: < 5 seconds (ideal), < 30 seconds (timeout)

**Optimizations**:
- Lazy loading of images
- Debounce on validations (300ms)
- Asset caching (logo, fonts)

### 5.4 Testing Scenarios

**Mandatory Test Cases**:

1. **Successful Login**:
   - CPF: `567.065.455-20`
   - Password: `1234`
   - Result: Navigate to work site selection

2. **Invalid Credentials**:
   - CPF: `111.111.111-11`
   - Password: `wrong`
   - Result: Error message

3. **Empty Field Validation**:
   - Leave fields empty
   - Click "LOGIN"
   - Result: Error messages

4. **Remember Me Checked**:
   - Login with checkbox checked
   - Close and reopen app
   - Result: Automatic login

5. **Remember Me Unchecked**:
   - Login with checkbox unchecked
   - Close and reopen app
   - Result: Empty login screen

6. **Offline Mode**:
   - Disable internet
   - Try to login
   - Result: Connection error message

---

## 🎬 6. NAVIGATION FLOW

### 6.1 Complete Flow

```
[Splash Screen]
       ↓
[Check Saved Token]
       ↓
   ┌───┴───┐
   │       │
[Valid   [Invalid/
Token]   No Token]
   │       │
   │   [Login Screen] ← YOU ARE HERE
   │       ↓
   │   [Authentication]
   │       ↓
   │   ┌───┴───┐
   │   │       │
   │ [1 Site] [Multiple
   │   │       Sites]
   │   │       │
   │   │   [Choose Work Site]
   │   │       │
   └───┴───────┘
       ↓
[Home Screen / Dashboard]
```

### 6.2 Post-Login Navigation

**If user has 1 work site**:
1. Select work site automatically
2. Navigate directly to Home Screen

**If user has multiple work sites**:
1. Navigate to "Choose Work Site" screen
2. User selects work site
3. Navigate to Home Screen

**If user has no work sites**:
1. Show message: "You are not associated with any work site. Contact administrator."
2. "LOGOUT" button to return to login

---

## 📦 7. REQUIRED ASSETS

### 7.1 Fonts

**Fontello** (logo icon):
- File: `fontello.ttf`
- Logo unicode: `\e80c`
- **Note**: Request file from design team

**SF UI Display**:
- `SFUIDisplay-Light.ttf`
- `SFUIDisplay-Medium.ttf`
- `SFUIDisplay-Bold.ttf`
- **Note**: Request files from design team

### 7.2 Images

**Logo** (fallback if font doesn't load):
- `logo.png` (1x, 2x, 3x)
- Base size: 43x43 px
- Format: PNG with transparency

**Icons**:
- `eye-open.png` (show password)
- `eye-closed.png` (hide password)
- `clear-icon.png` (clear field)

---

## ✅ 8. IMPLEMENTATION CHECKLIST

### Interface
- [ ] Screen with blue background (#27496F)
- [ ] Logo centered at top (icon + "Piscinas" text)
- [ ] CPF field with mask (XXX.XXX.XXX-XX)
- [ ] Password field with show/hide toggle
- [ ] "Remember me" checkbox
- [ ] "LOGIN" button with states (normal, pressed, loading, disabled)
- [ ] "Forgot password" link
- [ ] Error messages below fields
- [ ] Responsive for different screen sizes

### Validations
- [ ] Empty CPF validation
- [ ] Invalid CPF validation (format)
- [ ] Empty password validation
- [ ] Short password validation (< 4 characters)
- [ ] Disable button during loading
- [ ] Show spinner during request

### Functionality
- [ ] API login integration
- [ ] API error handling
- [ ] Secure token storage (if "Remember me")
- [ ] Token validation on app launch
- [ ] Automatic login (if valid token)
- [ ] CPF pre-fill (if "Remember me")
- [ ] Navigation to work site selection screen
- [ ] Automatic selection (if only 1 site)

### Security
- [ ] HTTPS communication
- [ ] Secure storage (SecureStore/Keychain)
- [ ] Don't store password
- [ ] Validate SSL certificate
- [ ] Request timeout (30s)

### Accessibility
- [ ] Descriptive labels
- [ ] Screen reader support
- [ ] Minimum touch size (44x44 / 48x48)
- [ ] Adequate contrast (4.5:1)
- [ ] Haptic feedback

### Testing
- [ ] Successful login test
- [ ] Invalid credentials test
- [ ] Empty fields test
- [ ] "Remember me" checked test
- [ ] "Remember me" unchecked test
- [ ] Offline mode test
- [ ] Timeout test
- [ ] Different screen sizes test

---

## 📞 9. CONTACTS AND SUPPORT

**API Questions**:
- Consult API documentation
- Documentation endpoint: `/swagger` (development environment)

**Design Questions**:
- Consult design team
- Reference: Web application at `https://[SERVER_URL]`

**Business Rules Questions**:
- Consult Product Owner
- Additional documentation: `LEGACY-LOGIN-ANALYSIS.md`

---

## 📝 10. IMPORTANT NOTES

1. **CPF Without Formatting in API**: Always remove dots and dashes before sending to API
2. **JWT Token**: Store securely, never in common AsyncStorage
3. **Two-Step Authentication**: Login + Work Site Selection (don't forget!)
4. **Timeout**: Configure 30-second timeout for requests
5. **Offline Mode**: Implement connection detection before calling API
6. **Testing**: Use CPF `567.065.455-20` and password `1234` for testing
7. **Migration Context**: This is the SECOND migration attempt (first one failed)
8. **Current Status**: .NET 8 migration is PAUSED to support mobile development

---

## 🚨 CRITICAL CONTEXT

### Migration History

**First Attempt (Failed)**:
- Attempted migration from legacy ASP.NET Framework + AngularJS
- Encountered multiple critical issues
- Week-long blank page crisis
- Authentication failures
- Project was abandoned

**Second Attempt (Current - PAUSED)**:
- Clean migration to .NET 8
- 48 entities successfully migrated (100%)
- Login page implemented and working
- Escolher Obra (Work Site Selection) header implemented (95%)
- **Status**: PAUSED to support mobile development
- **Reason**: Mobile app needs to be developed in parallel

**Why This Matters for You**:
- Backend API is stable and tested
- Authentication flow is proven to work
- You can trust the API endpoints provided
- Focus on mobile implementation without backend concerns

---

## 🎯 SUCCESS CRITERIA

Your implementation will be considered successful when:

1. ✅ User can login with valid credentials
2. ✅ User sees appropriate error messages for invalid credentials
3. ✅ "Remember me" functionality works correctly
4. ✅ Token is stored securely
5. ✅ Automatic login works on app relaunch
6. ✅ Navigation to work site selection works
7. ✅ All validations work as specified
8. ✅ UI matches design specifications
9. ✅ Accessibility requirements are met
10. ✅ All test scenarios pass

---

**END OF BRIEFING**

*Good luck with the implementation, Carlos! 🚀*

**Questions?** Feel free to reach out to the team for clarification on any point in thiNs document.

