# 🚀 HomeLab AR - API Documentation

## 📋 Table of Contents

1. [Overview](#overview)
2. [Backend APIs](#backend-apis)
3. [Frontend JavaScript APIs](#frontend-javascript-apis)
4. [A-Frame Components](#a-frame-components)
5. [Configuration](#configuration)
6. [Usage Examples](#usage-examples)
7. [Error Handling](#error-handling)

---

## 🌟 Overview

HomeLab AR is an augmented reality application built with PHP backend and JavaScript frontend, featuring WebXR support for immersive AR experiences. The system allows users to deploy virtual homelab services in real-world environments.

**Key Technologies:**
- **Backend**: PHP 8.4.7, MySQL/MariaDB
- **Frontend**: JavaScript (ES6+), A-Frame, WebXR
- **AR Framework**: A-Frame with custom components
- **Authentication**: Session-based PHP authentication

---

## 🔧 Backend APIs

### Authentication API

#### `POST /api/auth_user.php`
Authenticates a user with username/email/phone and password.

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "status": "success|error",
  "message": "string",
  "user_data": {
    "user_id": "int",
    "first_name": "string",
    "last_name": "string",
    "email": "string",
    "phone": "string"
  }
}
```

**Example Usage:**
```javascript
$.ajax({
    url: '../api/auth_user.php',
    method: 'POST',
    data: { username: 'user@example.com', password: 'password123' },
    dataType: 'json',
    success: function(response) {
        if (response.status === "success") {
            window.location.href = "../views/dashboard.php";
        }
    }
});
```

#### `GET /api/check_session.php`
Checks if a user is currently logged in.

**Response:**
```json
{
  "logged": true|false
}
```

#### `POST /api/reg_user.php`
Registers a new user.

**Request Body:**
```json
{
  "first_name": "string",
  "last_name": "string",
  "phone": "string",
  "username": "string",
  "email": "string",
  "password": "string"
}
```

#### `POST /api/logout.php`
Logs out the current user and destroys the session.

### User Management API

#### `GET /api/list_users.php`
Retrieves a list of all users (admin only).

**Response:**
```json
{
  "users": [
    {
      "user_id": "int",
      "first_name": "string",
      "last_name": "string",
      "email": "string",
      "phone": "string",
      "status_id": "int",
      "role_id": "int"
    }
  ]
}
```

---

## 🎯 Frontend JavaScript APIs

### Core System (`main.js`)

#### Global Variables
```javascript
let surfaceDetected = false;        // Surface detection status
let currentSurface = null;          // Currently active surface
let itemCount = 0;                 // Count of deployed items
let isDetecting = false;           // Detection mode status
let currentCategory = 'services';   // Current item category
let surfaces = [];                 // Array of detected surfaces
let menuExpanded = false;          // Menu expansion state
```

#### `setupConsoleFilters()`
Configures console filters to reduce noise from browser extensions.

**Usage:**
```javascript
// Automatically called on page load
setupConsoleFilters();
```

#### `setupEventListeners()`
Sets up all event listeners for UI interactions.

**Usage:**
```javascript
// Automatically called on page load
setupEventListeners();
```

#### `mostrarHoraColombia()`
Displays current time in Colombia timezone.

**Usage:**
```javascript
mostrarHoraColombia(); // Display once
setInterval(mostrarHoraColombia, 1000); // Update every second
```

### Authentication System (`auth.js`)

#### `LoginUser(username, password)`
Authenticates a user with the backend.

**Parameters:**
- `username` (string): Username, email, or phone
- `password` (string): User password

**Usage:**
```javascript
LoginUser('user@example.com', 'password123');
```

#### `RegisterUser(userData)`
Registers a new user.

**Parameters:**
- `userData` (object): User registration data

**Usage:**
```javascript
RegisterUser({
    first_name: 'John',
    last_name: 'Doe',
    phone: '+1234567890',
    username: 'johndoe',
    email: 'john@example.com',
    password: 'password123'
});
```

### AR System (`ar-system.js`)

#### `AFRAME.registerSystem('homelab')`
Main AR system for HomeLab functionality.

**Features:**
- Surface detection and management
- Item deployment tracking
- Performance monitoring
- WebXR integration

**Usage:**
```javascript
// Automatically registered when A-Frame loads
const homelabSystem = document.querySelector('[scene]').systems.homelab;
```

#### Surface Detection Methods
```javascript
// Detect surfaces in AR environment
homelabSystem.detectSurfaces();

// Get detected surfaces
const surfaces = homelabSystem.detectedSurfaces;

// Clear detected surfaces
homelabSystem.clearDetectedSurfaces();
```

#### Item Deployment Methods
```javascript
// Deploy item at position
homelabSystem.deployItem(itemType, position);

// Get deployed items
const items = homelabSystem.deployedItems;

// Clear deployed items
homelabSystem.clearDeployedItems();
```

### Utility Functions (`utils.js`)

#### `Utils.vibrate(pattern)`
Generates haptic feedback if available.

**Parameters:**
- `pattern` (array): Vibration pattern in milliseconds

**Usage:**
```javascript
Utils.vibrate([100, 50, 100]); // Short vibration pattern
Utils.vibrate([100]); // Single vibration
```

#### `Utils.getRandomSurfacePosition(surfacePos, radius)`
Generates random position on a surface.

**Parameters:**
- `surfacePos` (object): Surface position {x, y, z}
- `radius` (number): Maximum offset radius (default: 2.5)

**Returns:**
```javascript
{
  x: number,
  y: number,
  z: number
}
```

**Usage:**
```javascript
const randomPos = Utils.getRandomSurfacePosition(
    {x: 0, y: 0, z: 0}, 
    3.0
);
```

#### `Utils.showDeploymentEffect(position, color)`
Shows visual deployment effect.

**Parameters:**
- `position` (object): Effect position
- `color` (string): Effect color (hex or CSS color)

**Usage:**
```javascript
Utils.showDeploymentEffect(
    {x: 0, y: 1, z: 0}, 
    '#00ff88'
);
```

#### `Utils.applyGlitchEffect(element, duration)`
Applies glitch effect to DOM element.

**Parameters:**
- `element` (HTMLElement): Target element
- `duration` (number): Effect duration in milliseconds (default: 300)

**Usage:**
```javascript
const element = document.getElementById('myElement');
Utils.applyGlitchEffect(element, 500);
```

#### `Utils.getCategoryConfig(category)`
Gets configuration for specific category.

**Parameters:**
- `category` (string): Category name

**Returns:** Category configuration object or null

**Usage:**
```javascript
const config = Utils.getCategoryConfig('services');
```

#### `Utils.getRandomItem(category)`
Gets random item from category.

**Parameters:**
- `category` (string): Category name

**Returns:** Random item object or null

**Usage:**
```javascript
const randomItem = Utils.getRandomItem('services');
```

#### `Utils.formatItemCount(count)`
Formats item count for display.

**Parameters:**
- `count` (number): Item count

**Returns:** Formatted string

**Usage:**
```javascript
const displayText = Utils.formatItemCount(5); // "5 elementos desplegados"
```

#### `Utils.formatSurfaceCount(count)`
Formats surface count for display.

**Parameters:**
- `count` (number): Surface count

**Returns:** Formatted string

**Usage:**
```javascript
const displayText = Utils.formatSurfaceCount(3); // "3 superficies"
```

### User Management (`users.js`)

#### Global Variables
```javascript
var IS_ADMIN = true;        // Admin status flag
var itiDetalle, itiCrear;   // International telephone input instances
```

#### `showModal(message)`
Displays a modal with a message.

**Parameters:**
- `message` (string): Message to display

**Usage:**
```javascript
showModal('Operation completed successfully!');
```

#### `rellenarCamposUsuario(user)`
Fills user modal fields with user data.

**Parameters:**
- `user` (object): User data object

**Usage:**
```javascript
rellenarCamposUsuario({
    user_id: 1,
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com'
});
```

### Configuration (`homelab-config.js`)

#### `HomeLabConfig`
Global configuration object for the HomeLab AR system.

**Performance Configuration:**
```javascript
HomeLabConfig.performance = {
    enableFPSMonitoring: true,
    fpsLogInterval: 100,
    maxParticleCount: 50,
    maxLights: 8,
    shadowQuality: 'medium',
    maxDeployedItems: 20,
    maxSurfaces: 5
};
```

**AR Configuration:**
```javascript
HomeLabConfig.ar = {
    surfaceDetectionTimeout: 10000,
    surfaceScanInterval: 120,
    webxr: {
        enableHitTest: true,
        hitTestTimeout: 5000,
        referenceSpace: 'local'
    }
};
```

**UI Configuration:**
```javascript
HomeLabConfig.ui = {
    animationDuration: {
        menu: 300,
        surface: 1500,
        item: 800,
        notification: 3000
    },
    colors: {
        primary: '#00ff88',
        secondary: '#008866',
        accent: '#ffaa00'
    }
};
```

---

## 🎮 A-Frame Components (`aframe-components.js`)

### `gaze-activator`
Activates actions when user gazes at an element.

**Schema:**
```javascript
{
    onActivate: { type: 'string' } // Function name to call
}
```

**Usage:**
```html
<a-entity gaze-activator="onActivate: myFunction">
    <!-- Element content -->
</a-entity>
```

**Features:**
- 3-second gaze timer
- Visual feedback (color change)
- Automatic function execution

### `floating-menu`
Creates a 3D floating menu with interactive buttons.

**Features:**
- Circular button arrangement
- 3D positioning
- Camera-facing orientation
- Interactive cursor support

**Default Actions:**
- Add Object: Deploys new items
- Remove Objects: Clears deployed items
- Remove Surfaces: Clears detected surfaces

**Usage:**
```html
<a-entity floating-menu>
    <!-- Menu will be automatically generated -->
</a-entity>
```

### `surface-detector`
Detects and manages AR surfaces.

**Schema:**
```javascript
{
    scanInterval: { type: 'number', default: 120 },
    maxSurfaces: { type: 'number', default: 5 }
}
```

**Events:**
- `surface-detected`: Emitted when new surface is found
- `surface-lost`: Emitted when surface is lost

**Usage:**
```html
<a-entity surface-detector="scanInterval: 100; maxSurfaces: 3">
    <!-- Surface detection logic -->
</a-entity>
```

### `item-deployer`
Manages deployment of AR items.

**Schema:**
```javascript
{
    category: { type: 'string', default: 'services' },
    maxItems: { type: 'number', default: 20 }
}
```

**Methods:**
- `deployItem(type, position)`: Deploys item
- `removeItem(id)`: Removes specific item
- `clearAllItems()`: Removes all items

**Usage:**
```html
<a-entity item-deployer="category: networking; maxItems: 10">
    <!-- Item deployment logic -->
</a-entity>
```

---

## ⚙️ Configuration

### Performance Tuning
```javascript
// Adjust performance settings
HomeLabConfig.performance.maxDeployedItems = 15;
HomeLabConfig.performance.maxSurfaces = 3;
HomeLabConfig.performance.shadowQuality = 'low';
```

### AR Settings
```javascript
// Configure AR behavior
HomeLabConfig.ar.surfaceDetectionTimeout = 15000;
HomeLabConfig.ar.webxr.enableHitTest = false;
```

### UI Customization
```javascript
// Customize UI appearance
HomeLabConfig.ui.colors.primary = '#ff6b6b';
HomeLabConfig.ui.animationDuration.menu = 500;
```

---

## 📚 Usage Examples

### Basic AR Setup
```javascript
// Initialize AR system
document.addEventListener('DOMContentLoaded', function() {
    // System automatically initializes
    console.log('HomeLab AR ready');
    
    // Configure settings
    HomeLabConfig.performance.maxDeployedItems = 25;
});
```

### Surface Detection
```javascript
// Listen for surface detection
document.addEventListener('surface-detected', function(event) {
    const surface = event.detail;
    console.log('Surface detected at:', surface.position);
    
    // Deploy item on surface
    const randomPos = Utils.getRandomSurfacePosition(surface.position);
    deployItem('service', randomPos);
});
```

### User Authentication
```javascript
// Login user
function handleLogin() {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    LoginUser(username, password);
}

// Check session status
$.get("../api/check_session.php", function(response) {
    if (response.logged) {
        window.location.href = "../views/dashboard.php";
    }
}, "json");
```

### Item Deployment
```javascript
// Deploy service item
function deployService() {
    if (currentSurface) {
        const position = Utils.getRandomSurfacePosition(
            currentSurface.position, 
            2.0
        );
        
        // Show deployment effect
        Utils.showDeploymentEffect(position, '#00ff88');
        
        // Deploy item
        deployItem('service', position);
        
        // Haptic feedback
        Utils.vibrate([100, 50, 100]);
    }
}
```

---

## ❌ Error Handling

### Backend Errors
```javascript
$.ajax({
    url: '../api/auth_user.php',
    method: 'POST',
    data: { username: 'user', password: 'pass' },
    dataType: 'json',
    success: function(response) {
        if (response.status === "success") {
            // Handle success
        } else {
            console.error('Authentication failed:', response.message);
        }
    },
    error: function(xhr, status, error) {
        console.error('Request failed:', status, error);
        // Handle network/server errors
    }
});
```

### AR System Errors
```javascript
// Handle WebXR errors
if (!navigator.xr) {
    console.warn('WebXR not supported, falling back to camera mode');
    // Implement fallback behavior
}

// Handle surface detection errors
try {
    homelabSystem.detectSurfaces();
} catch (error) {
    console.error('Surface detection failed:', error);
    // Implement error recovery
}
```

### Validation Errors
```javascript
// Validate user input
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

## 🔧 Development Setup

### Prerequisites
- PHP 8.4.7+
- MySQL/MariaDB 10.6+
- Modern browser with WebXR support
- A-Frame library

### Installation
1. Clone the repository
2. Configure database connection in `api/core/DBConfig.php`
3. Import database schema
4. Configure web server (Apache/Nginx)
5. Set up SSL for WebXR functionality

### Testing
- Test AR functionality on AR-capable devices
- Verify authentication flows
- Check user management operations
- Validate WebXR compatibility

---

## 📖 Additional Resources

- [A-Frame Documentation](https://aframe.io/docs/)
- [WebXR Device API](https://immersive-web.github.io/webxr/)
- [PHP Session Management](https://www.php.net/manual/en/book.session.php)
- [MySQL Documentation](https://dev.mysql.com/doc/)

---

## 🤝 Contributing

When contributing to the HomeLab AR project:

1. Follow existing code style and patterns
2. Add comprehensive error handling
3. Include usage examples in documentation
4. Test AR functionality on multiple devices
5. Validate WebXR compatibility
6. Update this documentation for new features

---

*Last updated: January 2025*
*Version: 1.0.0*