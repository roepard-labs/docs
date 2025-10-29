# Homelab VR App - Technical Specification

## Core Technologies
- **A-Frame**: Main WebVR framework
- **AR.js**: Augmented reality capabilities
- **Three.js**: 3D rendering foundation
- **WebXR**: Web standard for XR experiences
- **Alertify.js & SweetAlert.js**: Notification systems

## Scene Setup

### Environment
```html
<a-scene>
  <!-- Sky environment with multiple options -->
  <a-entity id="environment-wrapper" position="0 0 0">
    <!-- Active background is visible, others are hidden -->
    <a-entity id="monument-valley" gltf-model="../assets/models/sky_pano_monument_valley_lookout/scene.gltf" visible="false"></a-entity>
    <a-entity id="helipad-sky" gltf-model="../assets/models/sky_pano_helipad/scene.gltf" visible="false"></a-entity>
    <a-entity id="fantasy-sky" gltf-model="../assets/models/fantasy_sky_background/scene.gltf" visible="true"></a-entity>
  </a-entity>
  
  <!-- Soft cloud floor with shadow receiving -->
  <a-entity id="cloud-floor" position="0 -1.5 0" scale="5 0.1 5" shadow="receive: true"></a-entity>
</a-scene>
```

### Floating UI Elements
All UI panels should be implemented as `<a-entity>` objects with:
- Position in 3D space appropriate to function
- Subtle animation using `animation` component
- Interaction via gaze-based or controller-based input
- Semi-transparent materials with bloom/glow effects

Example panel:
```html
<a-entity 
  id="audio-panel" 
  position="-0.8 1.2 -1.5" 
  rotation="0 15 0"
  animation="property: position; dir: alternate; dur: 4000; easing: easeInOutSine; loop: true; to: -0.8 1.25 -1.5"
  class="interactive-panel">
  <!-- Panel content -->
</a-entity>
```

## UI Components

### Central Cursor System
```javascript
// Selection indicator with timer functionality
const cursor = document.querySelector('.selection-indicator');
let timerInterval;

function startSelectionTimer(duration, isSecondary = false) {
  clearInterval(timerInterval);
  cursor.classList.add('active');
  if (isSecondary) cursor.classList.add('secondary');
  
  const startTime = Date.now();
  const endTime = startTime + duration;
  
  timerInterval = setInterval(() => {
    const remaining = endTime - Date.now();
    if (remaining <= 0) {
      clearInterval(timerInterval);
      cursor.classList.remove('active', 'secondary');
      // Trigger selection complete action
      return;
    }
    
    // Update visual progress (could be CSS animation or canvas)
    const progress = 1 - (remaining / duration);
    updateCursorProgress(progress);
  }, 16);
}
```

### Background Selector
```javascript
const backgrounds = {
  'monument_valley': {
    element: document.getElementById('monument-valley'),
    thumbnail: '../assets/thumbnails/monument-valley.jpg',
    name: 'Monument Valley',
    icon: '🏜️'
  },
  'helipad': {
    element: document.getElementById('helipad-sky'),
    thumbnail: '../assets/thumbnails/helipad.jpg',
    name: 'Helipad Sky',
    icon: '🚁'
  },
  'fantasy_sky': {
    element: document.getElementById('fantasy-sky'),
    thumbnail: '../assets/thumbnails/fantasy-sky.jpg',
    name: 'Fantasy Sky',
    icon: '🌈'
  }
};

function switchBackground(id) {
  Object.keys(backgrounds).forEach(key => {
    backgrounds[key].element.setAttribute('visible', key === id);
  });
  
  // Trigger transition effect
  createBackgroundTransitionEffect();
}
```

### Audio System
```javascript
const audioManager = {
  context: new (window.AudioContext || window.webkitAudioContext)(),
  currentTrack: null,
  tracks: [],
  volume: 0.5,
  muted: false,
  
  init() {
    // Load tracks from ../assets/sounds/
    this.loadTrackList();
    
    // Set up visualizer
    this.setupVisualizer();
    
    // Create UI controls
    this.createAudioControls();
  },
  
  loadTrackList() {
    // Fetch available tracks
    const basePath = '../assets/sounds/';
    const sfxPath = '../assets/';
    
    // Add main tracks
    this.tracks = [
      { id: 'track1', path: `${basePath}ambient1.mp3`, name: 'Ambient 1', type: 'music' },
      { id: 'track2', path: `${basePath}ambient2.mp3`, name: 'Ambient 2', type: 'music' },
      // ...more tracks
      
      // Add SFX tracks
      { id: 'sfx1', path: `${sfxPath}background_sfx_track-001.mp3`, name: 'SFX 1', type: 'sfx' },
      { id: 'sfx2', path: `${sfxPath}background_sfx_track-002.mp3`, name: 'SFX 2', type: 'sfx' }
    ];
  }
  
  // Additional methods for play, pause, visualization, etc.
}
```

### Theme System
```javascript
const themeManager = {
  currentTheme: 'dark',
  availableThemes: ['dark', 'light', 'auto'],
  accentColor: '#00FF88',
  
  init() {
    this.loadSavedTheme();
    this.createThemeSelector();
    this.createColorPalette();
    this.applyTheme();
  },
  
  loadSavedTheme() {
    const savedTheme = localStorage.getItem('theme') || 'dark';
    const savedAccent = localStorage.getItem('accentColor') || '#00FF88';
    
    this.currentTheme = savedTheme;
    this.accentColor = savedAccent;
  },
  
  applyTheme() {
    // Remove existing theme classes
    document.body.classList.remove('theme-dark', 'theme-light');
    
    // Apply selected theme
    if (this.currentTheme === 'auto') {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      document.body.classList.add(prefersDark ? 'theme-dark' : 'theme-light');
    } else {
      document.body.classList.add(`theme-${this.currentTheme}`);
    }
    
    // Apply accent color
    document.documentElement.style.setProperty('--accent-color', this.accentColor);
  },
  
  // Additional methods for UI generation and interaction
}
```

## Animation Effects

### UI Bobbing Effect
```css
.floating-panel {
  animation: float 4s ease-in-out infinite;
}

@keyframes float {
  0% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-10px);
  }
  100% {
    transform: translateY(0px);
  }
}
```

### Selection Timer Animation
```css
.selection-timer {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 30px;
  height: 30px;
  border-radius: 50%;
  pointer-events: none;
}

.selection-timer::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.5);
}

.selection-timer::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: conic-gradient(transparent var(--progress, 0%), var(--timer-color, #00FF88) var(--progress, 0%));
  opacity: 0.7;
}

.selection-timer.active::after {
  animation: timer-progress 3s linear forwards;
}

.selection-timer.secondary::after {
  --timer-color: #FF4444;
  animation: timer-progress 6s linear forwards;
}

@keyframes timer-progress {
  0% { --progress: 0%; }
  100% { --progress: 100%; }
}
```

## Notification Systems

### Alertify.js Integration
```javascript
function showNotification(message, type = 'success') {
  // Map type to appropriate Alertify function
  const methodMap = {
    success: alertify.success,
    error: alertify.error,
    warning: alertify.warning,
    info: alertify.info
  };
  
  const method = methodMap[type] || alertify.message;
  
  // Configure and display notification
  alertify.set('notifier','position', 'top-right');
  method(message, 5); // 5 second duration
}
```

### SweetAlert.js Integration
```javascript
function showModal(title, message, type = 'success') {
  Swal.fire({
    title: title,
    text: message,
    icon: type,
    background: 'rgba(30, 30, 30, 0.8)',
    backdrop: `
      rgba(0,0,0,0.6)
      url("../assets/effects/particles.gif")
      center center
      no-repeat
    `,
    customClass: {
      popup: 'animated-popup',
      title: 'modal-title',
      content: 'modal-content'
    }
  });
}
```

## A-Frame Editor Integration

```javascript
// A-Frame Inspector toggle
function toggleInspector() {
  if (AFRAME.INSPECTOR && !AFRAME.INSPECTOR.opened) {
    AFRAME.INSPECTOR.open();
    showNotification('A-Frame Editor activated', 'info');
  } else if (AFRAME.INSPECTOR) {
    AFRAME.INSPECTOR.close();
    showNotification('A-Frame Editor closed', 'info');
  }
}

// A-Frame Watcher setup
const aframeWatcher = {
  active: false,
  
  init() {
    // Set up connection to watcher server
    this.setupConnection();
    
    // Create UI indicator
    this.createStatusIndicator();
  },
  
  setupConnection() {
    // WebSocket connection to watcher server
    // Event handling for file changes
  },
  
  // Additional methods
}
```

## Implementation Notes

1. **Performance Optimization:**
   - Use Level-of-Detail (LOD) for 3D models
   - Implement proper texture compression
   - Use object pooling for particle effects
   - Optimize shader complexity

2. **Accessibility:**
   - Ensure all interactions are possible via multiple input methods
   - Provide alternative control schemes
   - Add configurable timer durations
   - Include high-contrast mode option

3. **VR/AR Considerations:**
   - Design UI for optimal viewing at 1.5-2m distance
   - Keep critical UI elements within 60° FOV
   - Avoid rapid motion that could cause discomfort
   - Test on multiple VR headsets

4. **Responsive Design:**
   - Scale UI elements based on viewport size
   - Adjust layout for different aspect ratios
   - Provide fallback experience for non-VR devices

5. **Asset Preloading:**
   - Implement progressive loading strategy
   - Preload essential assets
   - Use placeholder/low-res versions during loading
   - Show loading progress indicator

6. **File Structure:**
   ```
   /homelab-vr/
   ├── js/
   │   ├── core/
   │   │   ├── audio-manager.js
   │   │   ├── theme-manager.js
   │   │   └── notification-system.js
   │   ├── ui/
   │   │   ├── background-selector.js
   │   │   ├── floating-panels.js
   │   │   └── cursor-system.js
   │   └── integration/
   │       ├── aframe-editor-integration.js
   │       ├── aframe-watcher.js
   │       └── webxr-controller.js
   ├── css/
   │   ├── themes/
   │   │   ├── dark.css
   │   │   └── light.css
   │   ├── animations.css
   │   └── ui-components.css
   └── assets/
       ├── models/
       ├── sounds/
       └── effects/
   ```
