// RDO Login JavaScript Module - Single DNA Blazor Support
window.rdoLogin = {
    // Initialize login functionality
    initialize: function() {
        console.log('🚀 RDO Login: Initializing Blazor login component');
        
        // Apply CPF mask
        this.applyCpfMask();
        
        // Focus CPF field
        this.focusCpfField();
        
        // Setup keyboard shortcuts
        this.setupKeyboardShortcuts();
        
        // Development auto-fill (localhost only)
        this.setupDevelopmentHelpers();
        
        console.log('✅ RDO Login: Initialization complete');
    },
    
    // Apply CPF mask to input field
    applyCpfMask: function() {
        const cpfInput = document.getElementById('cpf');
        
        if (!cpfInput) {
            console.warn('⚠️ RDO Login: CPF input field not found');
            return;
        }
        
        cpfInput.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            
            // Apply CPF mask: 000.000.000-00
            if (value.length <= 11) {
                value = value.replace(/(\d{3})(\d)/, '$1.$2');
                value = value.replace(/(\d{3})(\d)/, '$1.$2');
                value = value.replace(/(\d{3})(\d{1,2})$/, '$1-$2');
            }
            
            e.target.value = value;
            
            // Trigger Blazor binding update
            e.target.dispatchEvent(new Event('change', { bubbles: true }));
        });
        
        // Prevent non-numeric input
        cpfInput.addEventListener('keypress', function(e) {
            const char = String.fromCharCode(e.which);
            if (!/[0-9]/.test(char) && e.which !== 8 && e.which !== 0) {
                e.preventDefault();
            }
        });
        
        console.log('✅ RDO Login: CPF mask applied');
    },
    
    // Focus CPF field on page load
    focusCpfField: function() {
        const cpfInput = document.getElementById('cpf');
        
        if (cpfInput) {
            // Delay focus to ensure Blazor rendering is complete
            setTimeout(() => {
                cpfInput.focus();
                console.log('✅ RDO Login: CPF field focused');
            }, 100);
        }
    },
    
    // Setup keyboard shortcuts
    setupKeyboardShortcuts: function() {
        document.addEventListener('keydown', function(e) {
            // Enter key on password field submits form
            if (e.key === 'Enter' && e.target.id === 'senha') {
                e.preventDefault();
                const submitButton = document.querySelector('.rdo-login-button');
                if (submitButton && !submitButton.disabled) {
                    submitButton.click();
                }
            }
            
            // Ctrl+L focuses CPF field
            if (e.ctrlKey && e.key === 'l') {
                e.preventDefault();
                const cpfInput = document.getElementById('cpf');
                if (cpfInput) {
                    cpfInput.focus();
                    cpfInput.select();
                }
            }
        });
        
        console.log('✅ RDO Login: Keyboard shortcuts enabled');
    },
    
    // Development helpers (localhost only)
    setupDevelopmentHelpers: function() {
        if (window.location.hostname !== 'localhost') {
            return;
        }
        
        // Double-click to auto-fill credentials
        document.addEventListener('dblclick', function() {
            const cpfInput = document.getElementById('cpf');
            const senhaInput = document.getElementById('senha');
            
            if (cpfInput && senhaInput) {
                cpfInput.value = '567.065.455-20';
                senhaInput.value = 'RXL8DjdYj6Y=';
                
                // Trigger Blazor binding updates
                cpfInput.dispatchEvent(new Event('change', { bubbles: true }));
                senhaInput.dispatchEvent(new Event('change', { bubbles: true }));
                
                console.log('🔧 DEV: Auto-filled login credentials');
            }
        });
        
        // Add development indicator
        const devIndicator = document.createElement('div');
        devIndicator.innerHTML = '🔧 DEV MODE: Double-click to auto-fill';
        devIndicator.style.cssText = `
            position: fixed;
            top: 10px;
            right: 10px;
            background: #fbbf24;
            color: #92400e;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 12px;
            z-index: 9999;
            font-family: monospace;
        `;
        document.body.appendChild(devIndicator);
        
        console.log('🔧 RDO Login: Development helpers enabled');
    },
    
    // Validate CPF format (basic validation)
    validateCpf: function(cpf) {
        // Remove formatting
        const cleanCpf = cpf.replace(/\D/g, '');
        
        // Check length
        if (cleanCpf.length !== 11) {
            return false;
        }
        
        // Check for repeated digits
        if (/^(\d)\1{10}$/.test(cleanCpf)) {
            return false;
        }
        
        return true;
    },
    
    // Show loading state
    showLoading: function(button) {
        if (button) {
            button.disabled = true;
            button.classList.add('loading');
            
            const spinner = button.querySelector('.rdo-spinner');
            if (!spinner) {
                const spinnerElement = document.createElement('span');
                spinnerElement.className = 'rdo-spinner';
                button.insertBefore(spinnerElement, button.firstChild);
            }
        }
    },
    
    // Hide loading state
    hideLoading: function(button) {
        if (button) {
            button.disabled = false;
            button.classList.remove('loading');
            
            const spinner = button.querySelector('.rdo-spinner');
            if (spinner) {
                spinner.remove();
            }
        }
    },
    
    // Show error message
    showError: function(message) {
        // Remove existing error messages
        const existingErrors = document.querySelectorAll('.rdo-error-message');
        existingErrors.forEach(error => error.remove());
        
        // Create new error message
        const errorDiv = document.createElement('div');
        errorDiv.className = 'rdo-error-message';
        errorDiv.textContent = message;
        
        // Insert after logo section
        const logoSection = document.querySelector('.rdo-logo-section');
        if (logoSection) {
            logoSection.insertAdjacentElement('afterend', errorDiv);
        }
        
        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (errorDiv.parentNode) {
                errorDiv.remove();
            }
        }, 5000);
    },
    
    // Clear error messages
    clearErrors: function() {
        const errorMessages = document.querySelectorAll('.rdo-error-message');
        errorMessages.forEach(error => error.remove());
    },
    
    // Accessibility helpers
    announceToScreenReader: function(message) {
        const announcement = document.createElement('div');
        announcement.setAttribute('aria-live', 'polite');
        announcement.setAttribute('aria-atomic', 'true');
        announcement.style.cssText = `
            position: absolute;
            left: -10000px;
            width: 1px;
            height: 1px;
            overflow: hidden;
        `;
        announcement.textContent = message;
        
        document.body.appendChild(announcement);
        
        setTimeout(() => {
            document.body.removeChild(announcement);
        }, 1000);
    }
};

// Auto-initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    // Delay initialization to ensure Blazor components are rendered
    setTimeout(() => {
        if (document.querySelector('.rdo-login-container')) {
            window.rdoLogin.initialize();
        }
    }, 100);
});

// Re-initialize after Blazor updates (for component re-renders)
if (window.Blazor) {
    window.Blazor.addEventListener('enhancedload', function() {
        if (document.querySelector('.rdo-login-container')) {
            console.log('🔄 RDO Login: Re-initializing after Blazor update');
            window.rdoLogin.initialize();
        }
    });
}

// Export for global access
window.rdoLogin = window.rdoLogin;