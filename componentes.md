# 🎮 HomeLab AR - Component Documentation

## 📋 Table of Contents

1. [A-Frame Components](#a-frame-components)
2. [JavaScript Modules](#javascript-modules)
3. [Component Lifecycle](#component-lifecycle)
4. [Event System](#event-system)
5. [Performance Considerations](#performance-considerations)

---

## 🎮 A-Frame Components

### `gaze-activator`

A component that activates actions when a user gazes at an element for a specified duration.

**Schema:**
```javascript
{
    onActivate: { type: 'string' },     // Function name to call on activation
    gazeTime: { type: 'number', default: 3000 },  // Gaze duration in ms
    hoverColor: { type: 'string', default: '#00ff88' },  // Color when hovered
    defaultColor: { type: 'string', default: '#008866' }  // Default color
}
```

**Properties:**
- `onActivate`: String containing the name of the function to execute
- `gazeTime`: Time in milliseconds the user must gaze to activate (default: 3000ms)
- `hoverColor`: Color to show when element is being gazed at
- `defaultColor`: Default color of the element

**Events:**
- `gaze-start`: Emitted when user starts gazing
- `gaze-end`: Emitted when user stops gazing
- `gaze-activate`: Emitted when activation threshold is reached

**Usage:**
```html
<a-entity gaze-activator="onActivate: deployService; gazeTime: 2000; hoverColor: #ffaa00">
    <a-box geometry="primitive: box; width: 1; height: 1; depth: 1"
           material="color: #008866">
    </a-box>
</a-entity>
```

**JavaScript Integration:**
```javascript
// Function to be called on activation
function deployService() {
    console.log('Service deployment activated!');
    // Implementation here
}

// Listen for gaze events
document.addEventListener('gaze-start', function(event) {
    console.log('Gaze started on:', event.target);
});

document.addEventListener('gaze-activate', function(event) {
    console.log('Gaze activation on:', event.target);
});
```

---

### `floating-menu`

Creates a 3D floating menu with interactive buttons arranged in a circle.

**Schema:**
```javascript
{
    radius: { type: 'number', default: 2 },        // Menu radius
    height: { type: 'number', default: 1.5 },      // Menu height from ground
    buttonSize: { type: 'number', default: 0.25 }, // Button size
    buttonCount: { type: 'number', default: 3 }    // Number of buttons
}
```

**Default Button Actions:**
1. **Add Object** (`#00ffaa`): Deploys new items
2. **Remove Objects** (`#ff4444`): Clears deployed items  
3. **Remove Surfaces** (`#ffaa00`): Clears detected surfaces

**Features:**
- Circular button arrangement
- Camera-facing orientation
- Interactive cursor support
- Visual feedback on hover
- Automatic positioning

**Usage:**
```html
<a-entity floating-menu="radius: 3; height: 2; buttonCount: 4">
    <!-- Menu will be automatically generated -->
</a-entity>
```

**Custom Button Configuration:**
```javascript
// Override default buttons
AFRAME.registerComponent('floating-menu', {
    init: function () {
        const customButtons = [
            {
                label: 'Custom Action',
                color: '#ff6b6b',
                action: () => console.log('Custom action!')
            }
        ];
        
        this.createMenu(customButtons);
    }
});
```

---

### `surface-detector`

Detects and manages AR surfaces in the environment.

**Schema:**
```javascript
{
    scanInterval: { type: 'number', default: 120 },    // Scan interval in ms
    maxSurfaces: { type: 'number', default: 5 },      // Maximum surfaces to track
    detectionRadius: { type: 'number', default: 10 },  // Detection radius
    surfaceTimeout: { type: 'number', default: 10000 } // Surface timeout in ms
}
```

**Methods:**
- `detectSurfaces()`: Initiates surface detection
- `addSurface(position, size)`: Adds a new surface
- `removeSurface(id)`: Removes a specific surface
- `clearSurfaces()`: Removes all surfaces
- `getSurfaceById(id)`: Retrieves surface by ID

**Events:**
- `surface-detected`: New surface found
- `surface-lost`: Surface no longer detected
- `surface-updated`: Surface properties updated

**Usage:**
```html
<a-entity surface-detector="scanInterval: 100; maxSurfaces: 3; detectionRadius: 15">
    <!-- Surface detection logic -->
</a-entity>
```

**JavaScript Integration:**
```javascript
// Listen for surface events
document.addEventListener('surface-detected', function(event) {
    const surface = event.detail;
    console.log('Surface detected:', surface);
    
    // Add visual indicators
    addSurfaceMarkers(surface);
});

document.addEventListener('surface-lost', function(event) {
    const surfaceId = event.detail.id;
    console.log('Surface lost:', surfaceId);
    
    // Remove visual indicators
    removeSurfaceMarkers(surfaceId);
});

// Manual surface detection
const detector = document.querySelector('[surface-detector]').components['surface-detector'];
detector.detectSurfaces();
```

---

### `item-deployer`

Manages the deployment and removal of AR items.

**Schema:**
```javascript
{
    category: { type: 'string', default: 'services' },  // Item category
    maxItems: { type: 'number', default: 20 },         // Maximum items
    deployRadius: { type: 'number', default: 2.5 },     // Deployment radius
    itemHeight: { type: 'number', default: 0.15 }       // Height above surface
}
```

**Methods:**
- `deployItem(type, position)`: Deploys item at position
- `removeItem(id)`: Removes specific item
- `clearAllItems()`: Removes all items
- `getItemById(id)`: Retrieves item by ID
- `getItemsByCategory(category)`: Gets items by category

**Item Types:**
- `service`: Network services
- `database`: Database instances
- `monitoring`: Monitoring tools
- `storage`: Storage solutions
- `security`: Security tools

**Usage:**
```html
<a-entity item-deployer="category: networking; maxItems: 10; deployRadius: 3">
    <!-- Item deployment logic -->
</a-entity>
```

**JavaScript Integration:**
```javascript
// Deploy item
const deployer = document.querySelector('[item-deployer]').components['item-deployer'];
const position = { x: 0, y: 1, z: 0 };

deployer.deployItem('service', position);

// Listen for deployment events
document.addEventListener('item-deployed', function(event) {
    const item = event.detail;
    console.log('Item deployed:', item);
    
    // Add deployment effects
    Utils.showDeploymentEffect(item.position, '#00ff88');
});

// Get deployed items
const items = deployer.el.components['item-deployer'].deployedItems;
console.log('Deployed items:', items);
```

---

## 🔧 JavaScript Modules

### Core System (`main.js`)

**Global State Management:**
```javascript
// System state variables
let surfaceDetected = false;        // Surface detection status
let currentSurface = null;          // Currently active surface
let itemCount = 0;                 // Count of deployed items
let isDetecting = false;           // Detection mode status
let currentCategory = 'services';   // Current item category
let surfaces = [];                 // Array of detected surfaces
let menuExpanded = false;          // Menu expansion state
let menuIndicatorTimeout;          // Menu indicator timeout
```

**Initialization Functions:**
```javascript
// Console filter setup
function setupConsoleFilters() {
    // Filters out browser extension noise
    // Intercepts console.error, console.warn, console.log
}

// Event listener setup
function setupEventListeners() {
    // Sets up all UI interaction listeners
    // Handles button clicks, form submissions, etc.
}

// Page list initialization
function initializePagesList() {
    // Initializes navigation and page management
}
```

**Time Management:**
```javascript
// Colombia timezone display
function mostrarHoraColombia() {
    const now = new Date();
    const colombiaTime = new Date(now.toLocaleString("en-US", {timeZone: "America/Bogota"}));
    // Updates time display
}
```

---

### Authentication System (`auth.js`)

**Core Functions:**
```javascript
// User authentication
function LoginUser(username, password) {
    // Validates input
    // Sends AJAX request to auth_user.php
    // Handles response and redirects
}

// User registration
function RegisterUser(userData) {
    // Validates user data
    // Sends registration request
    // Handles response
}
```

**Form Handling:**
```javascript
// Login form submission
$('#LoginForm').submit(function (event) {
    event.preventDefault();
    const username = $('input[name="username"]').val().trim();
    const password = $('input[name="password"]').val().trim();
    LoginUser(username, password);
});

// Registration form submission
$('#RegisterForm').submit(function (event) {
    event.preventDefault();
    // Collects form data and calls RegisterUser
});
```

**Session Management:**
```javascript
// Check session status
$.get("../api/check_session.php", function (resp) {
    if (resp.logged) {
        window.location.href = "../views/dashboard.php";
    }
}, "json");
```

---

### AR System (`ar-system.js`)

**System Registration:**
```javascript
AFRAME.registerSystem('homelab', {
    init: function () {
        this.detectedSurfaces = [];
        this.deployedItems = [];
        this.cameraEl = document.querySelector('[camera]');
        this.isScanning = false;
        this.xrHitTestSource = null;
        this.xrRefSpace = null;
        this.performanceMetrics = { /* ... */ };
        
        this.initWebXR();
        this.setupPerformanceMonitoring();
    }
});
```

**WebXR Integration:**
```javascript
initWebXR: function() {
    if (!navigator.xr) {
        console.log('ℹ️ WebXR no disponible en este dispositivo');
        return;
    }
    
    // Sets up XR session handling
    // Configures hit testing
    // Manages XR lifecycle
}
```

**Performance Monitoring:**
```javascript
setupPerformanceMonitoring: function() {
    // Monitors frame times
    // Calculates average performance
    // Logs performance metrics
}
```

**Surface Detection:**
```javascript
detectSurfaces: function() {
    // Initiates surface scanning
    // Processes camera feed
    // Identifies flat surfaces
    // Emits surface events
}
```

**Item Management:**
```javascript
deployItem: function(type, position) {
    // Creates 3D item representation
    // Positions item in AR space
    // Adds to tracking system
    // Emits deployment events
}

removeItem: function(id) {
    // Removes item from scene
    // Updates tracking system
    // Emits removal events
}
```

---

### Utility Functions (`utils.js`)

**Haptic Feedback:**
```javascript
static vibrate(pattern = [100]) {
    if (navigator.vibrate) {
        navigator.vibrate(pattern);
    }
}
```

**Position Generation:**
```javascript
static getRandomSurfacePosition(surfacePos, radius = 2.5) {
    const offsetX = (Math.random() - 0.5) * radius;
    const offsetZ = (Math.random() - 0.5) * radius;
    
    return {
        x: surfacePos.x + offsetX,
        y: surfacePos.y + 0.15,
        z: surfacePos.z + offsetZ
    };
}
```

**Visual Effects:**
```javascript
static showDeploymentEffect(position, color) {
    // Creates radial gradient effect
    // Animates effect appearance
    // Auto-removes after duration
}

static applyGlitchEffect(element, duration = 300) {
    // Applies CSS glitch class
    // Removes after specified duration
}
```

**Configuration Access:**
```javascript
static getCategoryConfig(category) {
    if (typeof categoryConfig !== 'undefined') {
        return categoryConfig[category] || categoryConfig.services;
    }
    return null;
}

static getRandomItem(category) {
    if (typeof homelabItems !== 'undefined') {
        const items = homelabItems[category] || homelabItems.services;
        return items[Math.floor(Math.random() * items.length)];
    }
    return null;
}
```

**Text Formatting:**
```javascript
static formatItemCount(count) {
    if (count === 0) return '0 elementos desplegados';
    if (count === 1) return '1 elemento desplegado';
    return `${count} elementos desplegados`;
}

static formatSurfaceCount(count) {
    if (count === 0) return '0 superficies';
    if (count === 1) return '1 superficie';
    return `${count} superficies`;
}
```

**Surface Markers:**
```javascript
static createCornerMarkers(surface) {
    // Creates 4 corner markers
    // Adds animations and lighting
    // Positions around surface perimeter
}

static createGridHologram(surface) {
    // Creates holographic grid overlay
    // Adds scanning effect
    // Provides visual feedback
}
```

---

### User Management (`users.js`)

**Modal Management:**
```javascript
function showModal(message) {
    $('#modalMessageContent').text(message);
    $('#modalMessage').modal('show');
    // Hides other modals
    // Cleans up modal state
}

function rellenarCamposUsuario(user) {
    // Fills user modal fields
    // Handles phone number formatting
    // Sets profile picture
}
```

**Phone Number Handling:**
```javascript
// International phone input setup
var itiDetalle = window.intlTelInput(document.getElementById("modalUserPhone"), {
    utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js",
    separateDialCode: true,
    initialCountry: "auto"
});

// Phone number normalization
function normalizePhoneNumber(prefix, number) {
    // Removes country-specific prefixes
    // Normalizes format
    // Returns clean number
}
```

**User Operations:**
```javascript
// Create user
function crearUsuario() {
    // Validates form data
    // Sends creation request
    // Handles response
}

// Update user
function actualizarUsuario() {
    // Collects updated data
    // Sends update request
    // Handles response
}

// Delete user
function eliminarUsuario() {
    // Confirms deletion
    // Sends delete request
    // Handles response
}
```

---

### Configuration (`homelab-config.js`)

**Performance Settings:**
```javascript
performance: {
    enableFPSMonitoring: true,
    fpsLogInterval: 100,
    maxParticleCount: 50,
    maxLights: 8,
    shadowQuality: 'medium',
    maxDeployedItems: 20,
    maxSurfaces: 5,
    lodDistances: {
        near: 2,
        medium: 5,
        far: 10
    }
}
```

**AR Configuration:**
```javascript
ar: {
    surfaceDetectionTimeout: 10000,
    surfaceScanInterval: 120,
    webxr: {
        enableHitTest: true,
        hitTestTimeout: 5000,
        referenceSpace: 'local'
    },
    camera: {
        fov: 75,
        near: 0.1,
        far: 1000,
        position: { x: 0, y: 1.6, z: 0 }
    }
}
```

**UI Settings:**
```javascript
ui: {
    animationDuration: {
        menu: 300,
        surface: 1500,
        item: 800,
        notification: 3000
    },
    colors: {
        primary: '#00ff88',
        secondary: '#008866',
        accent: '#ffaa00',
        error: '#ff4444',
        success: '#00ff88',
        warning: '#ffaa00',
        info: '#0088ff'
    },
    notifications: {
        position: 'top-right',
        duration: 3000,
        maxVisible: 3
    }
}
```

**Effects Configuration:**
```javascript
effects: {
    particles: {
        enabled: true,
        maxCount: 100,
        defaultPreset: 'snow'
    },
    audio: {
        enabled: true,
        volume: 0.5,
        enableVibration: true
    },
    lighting: {
        ambient: true,
        directional: true,
        point: true,
        shadows: true
    }
}
```

---

## 🔄 Component Lifecycle

### A-Frame Component Lifecycle

1. **init()**: Component initialization
2. **update()**: Called when schema changes
3. **remove()**: Cleanup when component is removed
4. **tick()**: Called every frame (if defined)
5. **pause()**: Called when scene is paused
6. **play()**: Called when scene is resumed

### JavaScript Module Lifecycle

1. **DOM Ready**: Event listeners setup
2. **System Initialization**: AR system setup
3. **Configuration Loading**: Settings application
4. **Event Binding**: User interaction setup
5. **Runtime Operation**: Main functionality
6. **Cleanup**: Resource management

---

## 📡 Event System

### Custom Events

**Surface Events:**
- `surface-detected`: New surface found
- `surface-lost`: Surface no longer detected
- `surface-updated`: Surface properties changed

**Item Events:**
- `item-deployed`: Item successfully deployed
- `item-removed`: Item removed from scene
- `item-updated`: Item properties changed

**System Events:**
- `ar-ready`: AR system initialized
- `webxr-supported`: WebXR capability detected
- `performance-warning`: Performance issues detected

### Event Handling

```javascript
// Listen for custom events
document.addEventListener('surface-detected', function(event) {
    const surface = event.detail;
    handleNewSurface(surface);
});

// Emit custom events
document.dispatchEvent(new CustomEvent('item-deployed', {
    detail: { id: itemId, position: pos, type: itemType }
}));
```

---

## ⚡ Performance Considerations

### Optimization Strategies

1. **LOD (Level of Detail)**: Reduce complexity based on distance
2. **Object Pooling**: Reuse objects instead of creating new ones
3. **Frustum Culling**: Only render visible objects
4. **Texture Compression**: Use compressed texture formats
5. **Geometry Instancing**: Batch similar objects

### Memory Management

```javascript
// Clean up resources
function cleanupResources() {
    // Remove event listeners
    // Clear timeouts and intervals
    // Dispose of 3D objects
    // Clear arrays and objects
}

// Monitor memory usage
function monitorMemory() {
    if (performance.memory) {
        console.log('Memory usage:', performance.memory.usedJSHeapSize);
    }
}
```

### Frame Rate Optimization

```javascript
// Adaptive quality
function adjustQuality() {
    const fps = getCurrentFPS();
    if (fps < 30) {
        HomeLabConfig.performance.shadowQuality = 'low';
        HomeLabConfig.performance.maxParticleCount = 25;
    }
}
```

---

## 🧪 Testing Components

### Unit Testing

```javascript
// Test utility functions
describe('Utils', function() {
    it('should generate random positions', function() {
        const pos = Utils.getRandomSurfacePosition({x: 0, y: 0, z: 0}, 2);
        expect(pos.x).toBeGreaterThanOrEqual(-1);
        expect(pos.x).toBeLessThanOrEqual(1);
    });
});
```

### Integration Testing

```javascript
// Test AR system integration
describe('AR System', function() {
    it('should detect surfaces', function() {
        const system = document.querySelector('[scene]').systems.homelab;
        system.detectSurfaces();
        expect(system.detectedSurfaces.length).toBeGreaterThan(0);
    });
});
```

### Performance Testing

```javascript
// Test performance metrics
function testPerformance() {
    const start = performance.now();
    // Perform operation
    const end = performance.now();
    const duration = end - start;
    
    expect(duration).toBeLessThan(16); // 60 FPS target
}
```

---

*This documentation covers all major components and modules in the HomeLab AR project. For specific implementation details, refer to the source code files.*