# MOBILE ESCOLHER OBRA SCREEN - TECHNICAL BRIEFING FOR CARLOS
**Date**: February 4, 2026  
**Target**: React Native Mobile App  
**Screen**: Escolher Obra (Work Selection)  
**Purpose**: Complete technical specification for mobile implementation

---

## SCREEN OVERVIEW

### What This Screen Does
The "Escolher Obra" (Choose Work) screen is the **first screen after login**. It displays a grid of work cards (obras) that the user has access to. When the user taps a card, they select that work and navigate to the main work dashboard.

### User Flow
```
Login → Escolher Obra → [Select Work] → Work Dashboard (Etapas/Tarefas)
```

---

## VISUAL LAYOUT

### Screen Structure
```
┌─────────────────────────────────────┐
│  [Logo] Piscinas    [User Menu ▼]  │ ← Header
├─────────────────────────────────────┤
│                                     │
│  ┌──────┐  ┌──────┐  ┌──────┐     │
│  │ Card │  │ Card │  │ Card │     │ ← Work Cards Grid
│  │  #1  │  │  #2  │  │  #3  │     │   (2 columns on mobile)
│  └──────┘  └──────┘  └──────┘     │
│                                     │
│  ┌──────┐  ┌──────┐  ┌──────┐     │
│  │ Card │  │ Card │  │ Card │     │
│  │  #4  │  │  #5  │  │  #6  │     │
│  └──────┘  └──────┘  └──────┘     │
│                                     │
└─────────────────────────────────────┘
```

### Mobile Specific
- **2 columns** on mobile (vs 3-5 on desktop)
- **Scrollable** vertical list
- **Touch-friendly** card size (minimum 150x120 dp)
- **Pull-to-refresh** to reload works

---

## HEADER COMPONENT

### Header Elements

**Left Side**:
- Logo icon (icon-logo from Fontello)
- Text "Piscinas"

**Right Side**:
- User avatar image
- User name
- Dropdown menu icon

### Header Actions (Dropdown Menu)

**Menu Items**:
1. **Trocar Senha** (Change Password) → Navigate to ChangePassword screen
2. **Sair** (Logout) → Call logout API, clear storage, navigate to Login

### Header Buttons (Permission-Based)

**Important**: These buttons appear based on user permissions!

**Button 1: Dashboard da Unidade Escolar**
- Icon: `icon-dashboard`
- Permission: `"acessarDashboard"` for route `"/dashboard/index"`
- Action: Navigate to Dashboard screen
- Visibility: Only if user has permission

**Button 2: Dashboard Geral**
- Icon: `fa-bar-chart` (FontAwesome)
- Permission: `"visualizar"` for route `"/chart"`
- Action: Navigate to Charts screen
- Visibility: Only if user has permission

**Button 3: Nova Unidade Escolar**
- Icon: `fa-plus` (FontAwesome)
- Permission: `"visualizar"` for route `"/obra/cadastro"`
- Action: Navigate to New Work screen
- Visibility: Only if user has permission

---

## PERMISSION SYSTEM (CRITICAL!)

### How Permissions Work

**Storage**: After login, store user's routes in AsyncStorage or Redux:
```javascript
{
  routes: [
    { 
      path: "/obra/escolher", 
      permissions: ["visualizar"] 
    },
    { 
      path: "/chart", 
      permissions: ["visualizar"] 
    },
    { 
      path: "/obra/cadastro", 
      permissions: ["visualizar"] 
    },
    // ... more routes
  ]
}
```

**Permission Check Function** (exact copy of legacy logic):
```javascript
function hasPermission(permission, route) {
  const userData = getUserData(); // from AsyncStorage or Redux
  
  if (!userData || !userData.routes) {
    return false;
  }
  
  // Find route by path
  const userRoute = userData.routes.find(r => r.path === route);
  
  if (!userRoute) {
    return false; // Route not found
  }
  
  if (!userRoute.permissions) {
    return false; // Route has no permissions
  }
  
  // Check if permission exists in route's permissions array
  return userRoute.permissions.includes(permission);
}
```

**Usage in Component**:
```javascript
// Show Dashboard button only if user has permission
{hasPermission('acessarDashboard', '/dashboard/index') && (
  <TouchableOpacity onPress={() => navigation.navigate('Dashboard')}>
    <Icon name="icon-dashboard" />
  </TouchableOpacity>
)}

// Show Charts button only if user has permission
{hasPermission('visualizar', '/chart') && (
  <TouchableOpacity onPress={() => navigation.navigate('Charts')}>
    <Icon name="fa-bar-chart" />
  </TouchableOpacity>
)}

// Show New Work button only if user has permission
{hasPermission('visualizar', '/obra/cadastro') && (
  <TouchableOpacity onPress={() => navigation.navigate('NewWork')}>
    <Icon name="fa-plus" />
  </TouchableOpacity>
)}
```

---

## WORK CARD COMPONENT

### Card Data Structure

**Obra Entity** (from API):
```typescript
interface Obra {
  obrIdObra: number;              // Work ID
  obrDsObra: string;              // Work name/description
  obrDsEndereco: string;          // Address
  obrNrCep: string;               // ZIP code
  obrDsBairro: string;            // Neighborhood
  munIdMunicipio: number;         // Municipality ID
  municipio: {                    // Municipality object
    munNmMunicipio: string;       // Municipality name
    munSgUf: string;              // State abbreviation (SP, RJ, etc)
  };
  empIdEmpresa: number;           // Company ID
  obrDtInicio: string;            // Start date (ISO format)
  obrDtTermino: string | null;   // End date (ISO format or null)
  obrStAtivo: boolean;            // Active status
  
  // Calculated fields (from backend or calculate in app)
  totalTarefas: number;           // Total tasks
  tarefasConcluidas: number;      // Completed tasks
  percentualConclusao: number;    // Completion percentage (0-100)
}
```

### Card Visual Design

**Card Layout**:
```
┌────────────────────────────┐
│ ESCOLA MUNICIPAL EXEMPLO   │ ← Work name (bold, 16sp)
├────────────────────────────┤
│ 📍 Rua Exemplo, 123        │ ← Address (14sp)
│    Bairro - São Paulo/SP   │ ← Neighborhood - City/State
├────────────────────────────┤
│ ━━━━━━━━━━━━━━━━━━━━━━━━ │ ← Progress bar
│ 75% concluído              │ ← Percentage text
│ 15/20 tarefas              │ ← Tasks completed/total
└────────────────────────────┘
```

**Card Styling**:
- Background: White (#FFFFFF)
- Border: 1px solid #E0E0E0
- Border radius: 8dp
- Shadow: elevation 2 (Android) / shadowOpacity 0.1 (iOS)
- Padding: 16dp
- Margin: 8dp

**Progress Bar Colors** (based on percentage):
- 0-33%: Red (#E74C3C)
- 34-66%: Yellow (#F39C12)
- 67-100%: Green (#27AE60)

### Card Interaction

**On Press**:
1. Store selected work ID in AsyncStorage/Redux
2. Update user session with selected work
3. Navigate to Work Dashboard (Etapas/Tarefas screen)

**Visual Feedback**:
- Ripple effect on Android
- Opacity change on iOS (activeOpacity={0.7})
- Scale animation (optional): scale from 1.0 to 0.98 on press

---

## API ENDPOINTS

### 1. Get User's Works

**Endpoint**: `GET /api/obra/escolher`

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "obrIdObra": 1,
      "obrDsObra": "ESCOLA MUNICIPAL EXEMPLO",
      "obrDsEndereco": "Rua Exemplo, 123",
      "obrNrCep": "01234567",
      "obrDsBairro": "Centro",
      "munIdMunicipio": 1,
      "municipio": {
        "munNmMunicipio": "São Paulo",
        "munSgUf": "SP"
      },
      "empIdEmpresa": 1,
      "obrDtInicio": "2024-01-15T00:00:00",
      "obrDtTermino": null,
      "obrStAtivo": true,
      "totalTarefas": 20,
      "tarefasConcluidas": 15,
      "percentualConclusao": 75.0
    },
    // ... more obras
  ]
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "message": "Token inválido ou expirado"
}
```

### 2. Select Work

**Endpoint**: `POST /api/obra/selecionar`

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "obraId": 1
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Obra selecionada com sucesso",
  "data": {
    "obraId": 1,
    "obraNome": "ESCOLA MUNICIPAL EXEMPLO"
  }
}
```

---

## STATE MANAGEMENT

### Component State

```typescript
interface EscolherObraState {
  obras: Obra[];                  // List of works
  loading: boolean;               // Loading indicator
  refreshing: boolean;            // Pull-to-refresh indicator
  error: string | null;           // Error message
  selectedObraId: number | null;  // Currently selected work
}
```

### Redux Store (if using Redux)

```typescript
// Store structure
{
  auth: {
    user: {
      id: number,
      name: string,
      email: string,
      routes: Route[]  // ← IMPORTANT: Store routes for permissions!
    },
    token: string
  },
  obra: {
    list: Obra[],
    selected: Obra | null,
    loading: boolean,
    error: string | null
  }
}
```

---

## REACT NATIVE COMPONENT EXAMPLE

### EscolherObraScreen.tsx

```typescript
import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  RefreshControl,
  StyleSheet,
  ActivityIndicator
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface Obra {
  obrIdObra: number;
  obrDsObra: string;
  obrDsEndereco: string;
  obrDsBairro: string;
  municipio: {
    munNmMunicipio: string;
    munSgUf: string;
  };
  totalTarefas: number;
  tarefasConcluidas: number;
  percentualConclusao: number;
}

export const EscolherObraScreen = () => {
  const navigation = useNavigation();
  const [obras, setObras] = useState<Obra[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadObras();
  }, []);

  const loadObras = async () => {
    try {
      const token = await AsyncStorage.getItem('authToken');
      
      const response = await fetch('https://api.example.com/api/obra/escolher', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      const result = await response.json();

      if (result.success) {
        setObras(result.data);
        setError(null);
      } else {
        setError(result.message);
      }
    } catch (err) {
      setError('Erro ao carregar obras');
      console.error(err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const handleSelectObra = async (obra: Obra) => {
    try {
      const token = await AsyncStorage.getItem('authToken');
      
      // Call API to select work
      const response = await fetch('https://api.example.com/api/obra/selecionar', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ obraId: obra.obrIdObra })
      });

      const result = await response.json();

      if (result.success) {
        // Store selected work
        await AsyncStorage.setItem('selectedObraId', obra.obrIdObra.toString());
        await AsyncStorage.setItem('selectedObraNome', obra.obrDsObra);
        
        // Navigate to work dashboard
        navigation.navigate('WorkDashboard', { obraId: obra.obrIdObra });
      }
    } catch (err) {
      console.error('Error selecting obra:', err);
    }
  };

  const getProgressColor = (percentage: number): string => {
    if (percentage <= 33) return '#E74C3C'; // Red
    if (percentage <= 66) return '#F39C12'; // Yellow
    return '#27AE60'; // Green
  };

  const renderObraCard = ({ item }: { item: Obra }) => (
    <TouchableOpacity
      style={styles.card}
      onPress={() => handleSelectObra(item)}
      activeOpacity={0.7}
    >
      <Text style={styles.cardTitle}>{item.obrDsObra}</Text>
      
      <View style={styles.cardAddress}>
        <Text style={styles.addressText}>
          📍 {item.obrDsEndereco}
        </Text>
        <Text style={styles.addressText}>
          {item.obrDsBairro} - {item.municipio.munNmMunicipio}/{item.municipio.munSgUf}
        </Text>
      </View>

      <View style={styles.progressContainer}>
        <View style={styles.progressBarBackground}>
          <View
            style={[
              styles.progressBarFill,
              {
                width: `${item.percentualConclusao}%`,
                backgroundColor: getProgressColor(item.percentualConclusao)
              }
            ]}
          />
        </View>
        <Text style={styles.progressText}>
          {item.percentualConclusao.toFixed(0)}% concluído
        </Text>
        <Text style={styles.tasksText}>
          {item.tarefasConcluidas}/{item.totalTarefas} tarefas
        </Text>
      </View>
    </TouchableOpacity>
  );

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#26476D" />
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.centerContainer}>
        <Text style={styles.errorText}>{error}</Text>
        <TouchableOpacity onPress={loadObras} style={styles.retryButton}>
          <Text style={styles.retryButtonText}>Tentar Novamente</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={obras}
        renderItem={renderObraCard}
        keyExtractor={(item) => item.obrIdObra.toString()}
        numColumns={2}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => {
              setRefreshing(true);
              loadObras();
            }}
          />
        }
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5'
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20
  },
  listContainer: {
    padding: 8
  },
  card: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    padding: 16,
    margin: 8,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    minHeight: 180
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#26476D',
    marginBottom: 12
  },
  cardAddress: {
    marginBottom: 12
  },
  addressText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4
  },
  progressContainer: {
    marginTop: 'auto'
  },
  progressBarBackground: {
    height: 8,
    backgroundColor: '#E0E0E0',
    borderRadius: 4,
    overflow: 'hidden',
    marginBottom: 8
  },
  progressBarFill: {
    height: '100%',
    borderRadius: 4
  },
  progressText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 4
  },
  tasksText: {
    fontSize: 12,
    color: '#666'
  },
  errorText: {
    fontSize: 16,
    color: '#E74C3C',
    textAlign: 'center',
    marginBottom: 20
  },
  retryButton: {
    backgroundColor: '#26476D',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8
  },
  retryButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600'
  }
});
```

---

## PERMISSION HELPER UTILITY

### utils/PermissionHelper.ts

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

interface Route {
  path: string;
  permissions: string[];
}

interface UserData {
  routes: Route[];
}

/**
 * Check if user has permission for a specific route
 * EXACT COPY of legacy Permission.check() logic
 */
export const hasPermission = async (
  permission: string,
  route: string
): Promise<boolean> => {
  try {
    // Get user data from AsyncStorage
    const userDataJson = await AsyncStorage.getItem('userData');
    
    if (!userDataJson) {
      return false;
    }

    const userData: UserData = JSON.parse(userDataJson);

    if (!userData.routes) {
      return false;
    }

    // Find route by path
    const userRoute = userData.routes.find(r => r.path === route);

    if (!userRoute) {
      return false; // Route not found
    }

    if (!userRoute.permissions) {
      return false; // Route has no permissions
    }

    // Check if permission exists in route's permissions array
    return userRoute.permissions.includes(permission);
  } catch (error) {
    console.error('Error checking permission:', error);
    return false;
  }
};

/**
 * Synchronous version (if userData is already in memory/Redux)
 */
export const hasPermissionSync = (
  userData: UserData | null,
  permission: string,
  route: string
): boolean => {
  if (!userData || !userData.routes) {
    return false;
  }

  const userRoute = userData.routes.find(r => r.path === route);

  if (!userRoute || !userRoute.permissions) {
    return false;
  }

  return userRoute.permissions.includes(permission);
};
```

---

## TESTING CHECKLIST

### Functional Tests

- [ ] Screen loads and displays list of works
- [ ] Pull-to-refresh reloads works
- [ ] Tapping a card selects the work and navigates
- [ ] Progress bars show correct colors based on percentage
- [ ] Address and location display correctly
- [ ] Error handling works (no internet, API error)
- [ ] Loading indicator appears while fetching data

### Permission Tests

- [ ] Dashboard button appears only if user has "acessarDashboard" permission
- [ ] Charts button appears only if user has "visualizar" for "/chart"
- [ ] New Work button appears only if user has "visualizar" for "/obra/cadastro"
- [ ] Buttons are hidden if user doesn't have permissions

### Visual Tests

- [ ] Cards display in 2 columns on mobile
- [ ] Cards have proper spacing and shadows
- [ ] Text is readable and properly sized
- [ ] Progress bars are visible and colored correctly
- [ ] Touch feedback works (ripple/opacity)

### Edge Cases

- [ ] Empty list (no works assigned to user)
- [ ] Single work (only one card)
- [ ] Long work names (text truncation)
- [ ] Missing municipality data
- [ ] 0% completion
- [ ] 100% completion

---

## SUMMARY FOR CARLOS

### Key Points

1. **Permission System is Critical**: Store user's routes after login, check permissions before showing buttons
2. **Use Exact Legacy Logic**: The `hasPermission()` function must match legacy `Permission.check()`
3. **2-Column Grid**: Mobile uses 2 columns (vs 3-5 on desktop)
4. **Progress Colors**: Red (0-33%), Yellow (34-66%), Green (67-100%)
5. **Card Interaction**: Tap card → select work → navigate to dashboard
6. **Pull-to-Refresh**: Allow users to reload works list

### Files to Create

1. `screens/EscolherObraScreen.tsx` - Main screen component
2. `components/ObraCard.tsx` - Reusable work card component
3. `utils/PermissionHelper.ts` - Permission checking utility
4. `services/ObraService.ts` - API calls for works

### API Integration

- Base URL: `https://api.example.com` (replace with actual)
- Authentication: Bearer token in headers
- Endpoints: `/api/obra/escolher`, `/api/obra/selecionar`

---

**Ready for Implementation**: All specifications provided  
**Questions**: Contact me if anything is unclear  
**Good luck, Carlos!** 🚀
