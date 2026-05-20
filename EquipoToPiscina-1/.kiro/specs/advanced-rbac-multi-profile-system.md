# Advanced RBAC Multi-Profile System - Requirements Specification

## 🎯 **PROJECT OVERVIEW**

**Objective**: Expand the current binary RBAC system (Contratante/Contratada) to support multiple stakeholder types in construction projects, enabling comprehensive access control for diverse user profiles.

**Current State**: Successfully implemented user-group-based icon system with t/d conversion fix
**Target State**: Multi-dimensional access control supporting 10+ stakeholder types with granular permissions

---

## 📋 **USER STORIES**

### **Epic 1: Core Profile System**

#### **US-1.1: As a System Administrator**
- **I want to** create and manage multiple user profile types beyond Contratante/Contratada
- **So that** I can support diverse construction project stakeholders
- **Acceptance Criteria**:
  - [ ] Can create new profile types (Fiscalização, Governo, Consultoria, etc.)
  - [ ] Each profile has unique icon, color, and permissions
  - [ ] Profile hierarchy system supports inheritance
  - [ ] Backward compatibility with existing Contratante/Contratada profiles

#### **US-1.2: As a Project Manager**
- **I want to** assign users to projects with specific profile types
- **So that** each stakeholder sees appropriate data and interface elements
- **Acceptance Criteria**:
  - [ ] Can assign multiple profile types to same user for different projects
  - [ ] Profile assignment determines icon display and data access
  - [ ] Users only see data relevant to their assigned profile
  - [ ] Profile changes reflect immediately in UI

### **Epic 2: Government & Compliance Profiles**

#### **US-2.1: As a Government Inspector**
- **I want to** access project data in read-only mode with compliance focus
- **So that** I can monitor regulatory compliance without affecting project data
- **Acceptance Criteria**:
  - [ ] Read-only access to all project technical data
  - [ ] Can create inspection reports and compliance notes
  - [ ] Cannot modify project timelines or financial data
  - [ ] Special "Governo" icon and interface elements

#### **US-2.2: As a Quality Auditor (Fiscalização)**
- **I want to** review project quality metrics and create audit reports
- **So that** I can ensure project standards compliance
- **Acceptance Criteria**:
  - [ ] Access to quality control data and metrics
  - [ ] Can flag non-compliance issues
  - [ ] Cannot approve payments or modify budgets
  - [ ] Special "Fiscalização" icon and audit-focused interface

### **Epic 3: Specialized Contractor Profiles**

#### **US-3.1: As a Subcontractor**
- **I want to** see only tasks assigned to my company
- **So that** I can focus on my specific responsibilities
- **Acceptance Criteria**:
  - [ ] View only assigned tasks and related data
  - [ ] Can update progress on assigned tasks
  - [ ] Cannot see other subcontractors' data
  - [ ] Special "Subempreiteiro" icon

#### **US-3.2: As a Supplier**
- **I want to** track material requirements and delivery schedules
- **So that** I can manage logistics efficiently
- **Acceptance Criteria**:
  - [ ] View material requirements for assigned projects
  - [ ] Update delivery schedules and inventory status
  - [ ] Cannot access labor or financial data
  - [ ] Special "Fornecedor" icon

### **Epic 4: Professional Services Profiles**

#### **US-4.1: As a Technical Consultant**
- **I want to** provide advisory services with limited data modification rights
- **So that** I can support project success without full administrative access
- **Acceptance Criteria**:
  - [ ] View project progress and technical documentation
  - [ ] Create advisory reports and recommendations
  - [ ] Limited modification rights for technical specifications
  - [ ] Special "Consultoria" icon

#### **US-4.2: As a Safety Officer**
- **I want to** monitor and enforce safety compliance across all project aspects
- **So that** I can ensure workplace safety standards
- **Acceptance Criteria**:
  - [ ] Access to all safety-related data
  - [ ] Can create incident reports and safety orders
  - [ ] Authority to stop work for safety violations
  - [ ] Special "Segurança" icon with high priority access

---

## 🏗️ **TECHNICAL REQUIREMENTS**

### **Database Schema Enhancements**

#### **New Tables**
```sql
-- Profile definitions
CREATE TABLE perfil_acesso (
    prf_id_perfil INT PRIMARY KEY AUTO_INCREMENT,
    prf_cd_codigo VARCHAR(20) UNIQUE NOT NULL,
    prf_nm_nome VARCHAR(100) NOT NULL,
    prf_ds_descricao TEXT,
    prf_st_ativo BOOLEAN DEFAULT TRUE,
    prf_nr_prioridade INT DEFAULT 5,
    prf_cor_hex VARCHAR(7) DEFAULT '#666666',
    prf_icone_classe VARCHAR(50),
    prf_dt_criacao DATETIME DEFAULT NOW()
);

-- Permission definitions
CREATE TABLE permissao (
    per_id_permissao INT PRIMARY KEY AUTO_INCREMENT,
    per_cd_codigo VARCHAR(50) UNIQUE NOT NULL,
    per_nm_nome VARCHAR(100) NOT NULL,
    per_ds_descricao TEXT,
    per_id_modulo INT,
    per_st_ativo BOOLEAN DEFAULT TRUE
);

-- Profile-permission assignments
CREATE TABLE perfil_permissao (
    ppr_id_perfil_permissao INT PRIMARY KEY AUTO_INCREMENT,
    ppr_id_perfil INT NOT NULL,
    ppr_id_permissao INT NOT NULL,
    ppr_st_concedida BOOLEAN DEFAULT TRUE,
    ppr_dt_inicio DATE,
    ppr_dt_fim DATE,
    FOREIGN KEY (ppr_id_perfil) REFERENCES perfil_acesso(prf_id_perfil),
    FOREIGN KEY (ppr_id_permissao) REFERENCES permissao(per_id_permissao)
);
```

#### **Schema Modifications**
```sql
-- Enhance grupo table with profile relationship
ALTER TABLE grupo ADD COLUMN gru_id_perfil_acesso INT;
ALTER TABLE grupo ADD FOREIGN KEY (gru_id_perfil_acesso) REFERENCES perfil_acesso(prf_id_perfil);

-- Maintain backward compatibility
UPDATE grupo SET gru_id_perfil_acesso = 1 WHERE gru_st_contratante = 1; -- Contratante
UPDATE grupo SET gru_id_perfil_acesso = 2 WHERE gru_st_contratante = 2; -- Contratada
```

### **API Enhancements**

#### **New Controllers**
- `ProfileController` - Manage profile types and assignments
- `PermissionController` - Handle permission matrix operations
- `ComplianceController` - Government and audit-specific endpoints

#### **Enhanced Existing Controllers**
- `ObraController` - Profile-based data filtering
- `AuthController` - Profile-aware authentication
- `UserController` - Multi-profile user management

### **Frontend Requirements**

#### **New Components**
- Profile selector component
- Permission matrix management interface
- Profile-specific navigation menus
- Compliance dashboard for government users

#### **Enhanced Existing Components**
- Dynamic icon system supporting 10+ profile types
- Profile-aware obra cards
- Context-sensitive UI elements

---

## 🎨 **UI/UX REQUIREMENTS**

### **Profile Visual Identity**

#### **Core Profiles**
- **Contratante**: 🏢 Blue (#2E86AB) - Existing
- **Contratada**: 🏗️ Red (#C73E1D) - Existing
- **Fiscalização**: 🔍 Orange (#FF6B35) - New
- **Governo**: 🏛️ Navy (#2E86AB) - New

#### **Extended Profiles**
- **Consultoria**: 💼 Purple (#A23B72)
- **Fornecedor**: 📦 Orange (#F18F01)
- **Subempreiteiro**: 🔧 Dark Red (#C73E1D)
- **Engenharia**: 📐 Blue (#3F88C5)
- **Segurança**: 🦺 Red (#FF4444)
- **Meio Ambiente**: 🌱 Green (#52B788)

### **Responsive Design**
- Profile icons scale appropriately on mobile devices
- Profile-specific navigation adapts to screen size
- Touch-friendly profile selection interface

---

## 🔒 **SECURITY REQUIREMENTS**

### **Access Control**
- Users can only access data relevant to their assigned profiles
- Profile permissions are validated on both frontend and backend
- Audit trail for all profile-based access attempts

### **Data Isolation**
- Government users cannot access financial data
- Suppliers cannot see other suppliers' information
- Subcontractors only see their assigned tasks

### **Permission Inheritance**
- Profile hierarchy supports permission inheritance
- Admin profiles can override standard restrictions
- Time-based permissions for temporary access

---

## 🧪 **TESTING REQUIREMENTS**

### **Functional Testing**
- [ ] Profile creation and management
- [ ] Permission assignment and validation
- [ ] Icon display for all profile types
- [ ] Data filtering by profile permissions
- [ ] Cross-profile collaboration workflows

### **Security Testing**
- [ ] Unauthorized access prevention
- [ ] Permission boundary validation
- [ ] Data isolation verification
- [ ] Audit trail accuracy

### **Performance Testing**
- [ ] Permission checking performance (<100ms)
- [ ] Large-scale multi-profile scenarios
- [ ] Database query optimization
- [ ] Frontend rendering with multiple profiles

---

## 📊 **SUCCESS CRITERIA**

### **Phase 1 (Weeks 1-2)**
- [ ] 4 core profiles implemented (Contratante, Contratada, Fiscalização, Governo)
- [ ] Basic permission system operational
- [ ] Backward compatibility maintained
- [ ] Icon system supports new profiles

### **Phase 2 (Weeks 3-4)**
- [ ] 6 additional specialized profiles implemented
- [ ] Granular permission matrix operational
- [ ] Profile-specific UI elements functional
- [ ] Cross-profile workflows tested

### **Phase 3 (Weeks 5-6)**
- [ ] Enterprise administration tools complete
- [ ] Compliance reporting functional
- [ ] Performance benchmarks met
- [ ] Production deployment ready

---

## 🚀 **IMPLEMENTATION PRIORITY**

### **High Priority (Must Have)**
1. Core 4 profiles (Contratante, Contratada, Fiscalização, Governo)
2. Basic permission system
3. Profile-based icon display
4. Data access control

### **Medium Priority (Should Have)**
1. Specialized contractor profiles (Subempreiteiro, Fornecedor)
2. Professional services profiles (Consultoria, Engenharia)
3. Advanced permission matrix
4. Profile management interface

### **Low Priority (Could Have)**
1. Custom profile creation
2. Advanced audit features
3. External system integration
4. Mobile-specific optimizations

---

## 📋 **ACCEPTANCE CRITERIA SUMMARY**

### **Functional Acceptance**
- [ ] All profile types display correct icons and colors
- [ ] Users see only data relevant to their profile permissions
- [ ] Profile assignments can be managed through admin interface
- [ ] System maintains backward compatibility with existing users

### **Technical Acceptance**
- [ ] Database schema supports extensible profile system
- [ ] API endpoints handle profile-based requests efficiently
- [ ] Frontend components adapt to user's assigned profiles
- [ ] Security measures prevent unauthorized access

### **Business Acceptance**
- [ ] Government users can perform compliance monitoring
- [ ] Specialized contractors have focused interfaces
- [ ] System supports complex multi-stakeholder projects
- [ ] Client satisfaction maintained during transition

---

## 🔄 **MIGRATION STRATEGY**

### **Data Migration**
1. Create new profile tables with initial data
2. Map existing grupo.gru_st_contratante values to profiles
3. Preserve all existing user assignments and permissions
4. Validate data integrity after migration

### **User Migration**
1. Communicate changes to existing users
2. Provide training on new profile features
3. Offer gradual adoption path for advanced features
4. Maintain support for legacy workflows during transition

### **System Migration**
1. Deploy database changes during maintenance window
2. Update application code with backward compatibility
3. Test all existing functionality after deployment
4. Monitor system performance and user feedback

---

**STATUS**: 📋 **REQUIREMENTS SPECIFICATION COMPLETE**
**NEXT STEP**: Begin Phase 1 implementation after current RBAC icon fix validation
**ESTIMATED EFFORT**: 6-8 weeks across 3 phases
**BUSINESS VALUE**: High - enables market expansion and premium feature pricing