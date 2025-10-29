# 🚀 HomeLab AR - Quick Reference Guide

## 📋 Essential Commands & Patterns

### 🔐 Authentication
```javascript
// Login
LoginUser('username@email.com', 'password');

// Check session
$.get("../api/check_session.php", function(resp) {
    if (resp.logged) { /* User is logged in */ }
}, "json");

// Register
RegisterUser({
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com',
    password: 'password123'
});
```

### 🎯 AR Operations
```javascript
// Deploy item
deployItem('service', {x: 0, y: 1, z: 0});

// Get AR system
const homelabSystem = document.querySelector('[scene]').systems.homelab;

// Detect surfaces
homelabSystem.detectSurfaces();

// Clear items
homelabSystem.clearDeployedItems();
```

### 🛠️ Utility Functions
```javascript
// Haptic feedback
Utils.vibrate([100, 50, 100]);

// Random position
const pos = Utils.getRandomSurfacePosition(surfacePos, 2.5);

// Visual effects
Utils.showDeploymentEffect(position, '#00ff88');
Utils.applyGlitchEffect(element, 500);

// Formatting
Utils.formatItemCount(5);      // "5 elementos desplegados"
Utils.formatSurfaceCount(3);   // "3 superficies"
```

---

## 🎮 A-Frame Components

### Basic Usage
```html
<!-- Gaze activation -->
<a-entity gaze-activator="onActivate: myFunction; gazeTime: 2000">
    <a-box geometry="primitive: box; width: 1; height: 1; depth: 1"></a-box>
</a-entity>

<!-- Floating menu -->
<a-entity floating-menu="radius: 3; height: 2; buttonCount: 4"></a-entity>

<!-- Surface detection -->
<a-entity surface-detector="scanInterval: 100; maxSurfaces: 3"></a-entity>

<!-- Item deployment -->
<a-entity item-deployer="category: networking; maxItems: 10"></a-entity>
```

### Component Events
```javascript
// Surface events
document.addEventListener('surface-detected', (event) => {
    const surface = event.detail;
    console.log('Surface:', surface);
});

// Item events
document.addEventListener('item-deployed', (event) => {
    const item = event.detail;
    console.log('Item deployed:', item);
});

// Gaze events
document.addEventListener('gaze-activate', (event) => {
    console.log('Gaze activated on:', event.target);
});
```

---

## ⚙️ Configuration

### Performance Tuning
```javascript
// Adjust limits
HomeLabConfig.performance.maxDeployedItems = 15;
HomeLabConfig.performance.maxSurfaces = 3;
HomeLabConfig.performance.shadowQuality = 'low';

// AR settings
HomeLabConfig.ar.surfaceDetectionTimeout = 15000;
HomeLabConfig.ar.webxr.enableHitTest = false;

// UI customization
HomeLabConfig.ui.colors.primary = '#ff6b6b';
HomeLabConfig.ui.animationDuration.menu = 500;
```

### Default Values
```javascript
// Performance
maxDeployedItems: 20
maxSurfaces: 5
maxParticleCount: 50
maxLights: 8

// AR
surfaceDetectionTimeout: 10000
surfaceScanInterval: 120
hitTestTimeout: 5000

// UI
menuAnimation: 300ms
surfaceAnimation: 1500ms
itemAnimation: 800ms
```

---

## 🔧 Backend APIs

### Endpoints
```
POST /api/auth_user.php          # Login
GET  /api/check_session.php      # Check session
POST /api/reg_user.php           # Register
POST /api/logout.php             # Logout
GET  /api/list_users.php         # List users (admin)
```

### Request/Response Format
```javascript
// Login request
{
    "username": "user@example.com",
    "password": "password123"
}

// Login response
{
    "status": "success|error",
    "message": "string",
    "user_data": {
        "user_id": 1,
        "first_name": "John",
        "email": "john@example.com"
    }
}
```

---

## 📱 User Management

### Modal Operations
```javascript
// Show message modal
showModal('Operation completed successfully!');

// Fill user modal
rellenarCamposUsuario({
    user_id: 1,
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com'
});

// Phone input setup
var iti = window.intlTelInput(element, {
    separateDialCode: true,
    initialCountry: "auto"
});
```

### User Operations
```javascript
// Create user
crearUsuario();

// Update user
actualizarUsuario();

// Delete user
eliminarUsuario();
```

---

## 🎨 UI Components

### Color Scheme
```css
/* Primary colors */
--primary: #00ff88;      /* Green */
--secondary: #008866;    /* Dark green */
--accent: #ffaa00;       /* Orange */
--error: #ff4444;        /* Red */
--success: #00ff88;      /* Green */
--warning: #ffaa00;      /* Orange */
--info: #0088ff;         /* Blue */
```

### Animation Durations
```css
/* Animation timing */
--menu-animation: 300ms;
--surface-animation: 1500ms;
--item-animation: 800ms;
--notification-animation: 3000ms;
```

---

## 🚨 Error Handling

### Common Patterns
```javascript
// AJAX error handling
$.ajax({
    url: '../api/endpoint.php',
    method: 'POST',
    data: data,
    dataType: 'json',
    success: function(response) {
        if (response.status === "success") {
            // Handle success
        } else {
            console.error('Operation failed:', response.message);
        }
    },
    error: function(xhr, status, error) {
        console.error('Request failed:', status, error);
    }
});

// Try-catch for AR operations
try {
    homelabSystem.detectSurfaces();
} catch (error) {
    console.error('Surface detection failed:', error);
    // Implement fallback
}
```

### Validation
```javascript
// Input validation
function validateUserInput(userData) {
    const errors = [];
    
    if (!userData.first_name) errors.push('First name required');
    if (!userData.email) errors.push('Email required');
    if (!userData.password) errors.push('Password required');
    
    if (errors.length > 0) {
        showModal('Validation errors: ' + errors.join(', '));
        return false;
    }
    
    return true;
}
```

---

## 🔍 Debugging

### Console Filters
```javascript
// Console noise reduction (already configured)
setupConsoleFilters();

// Performance monitoring
console.log('FPS:', getCurrentFPS());
console.log('Memory:', performance.memory?.usedJSHeapSize);
```

### AR Debug Info
```javascript
// Check WebXR support
if (navigator.xr) {
    navigator.xr.isSessionSupported('immersive-ar').then((supported) => {
        console.log('WebXR AR supported:', supported);
    });
}

// Surface count
console.log('Surfaces:', homelabSystem.detectedSurfaces.length);

// Item count
console.log('Items:', homelabSystem.deployedItems.length);
```

---

## 📚 File Structure

```
/workspace
├── api/                    # Backend APIs
│   ├── controllers/        # PHP controllers
│   ├── models/            # Data models
│   ├── services/          # Business logic
│   └── core/              # Database & config
├── js/                    # Frontend JavaScript
│   ├── main.js           # Core system
│   ├── ar-system.js      # AR functionality
│   ├── auth.js           # Authentication
│   ├── utils.js          # Utility functions
│   ├── users.js          # User management
│   └── homelab-config.js # Configuration
├── components/            # HTML components
├── pages/                 # Page templates
└── css/                   # Stylesheets
```

---

## 🚀 Getting Started

### 1. Setup
```bash
# Clone repository
git clone <repository-url>
cd homelab-ar

# Configure database in api/core/DBConfig.php
# Set up web server (Apache/Nginx)
# Ensure SSL for WebXR functionality
```

### 2. Test AR
```javascript
// Check AR support
if (navigator.xr) {
    console.log('WebXR available');
} else {
    console.log('WebXR not supported');
}

// Initialize system
document.addEventListener('DOMContentLoaded', function() {
    console.log('HomeLab AR ready');
});
```

### 3. Deploy First Item
```javascript
// Wait for surface detection
document.addEventListener('surface-detected', function(event) {
    const surface = event.detail;
    
    // Deploy item
    const position = Utils.getRandomSurfacePosition(surface.position);
    deployItem('service', position);
    
    // Add effects
    Utils.showDeploymentEffect(position, '#00ff88');
    Utils.vibrate([100]);
});
```

---

## 📖 Additional Resources

- **Full API Documentation**: `API_DOCUMENTATION.md`
- **Component Details**: `COMPONENT_DOCUMENTATION.md`
- **A-Frame Docs**: https://aframe.io/docs/
- **WebXR Spec**: https://immersive-web.github.io/webxr/

---

