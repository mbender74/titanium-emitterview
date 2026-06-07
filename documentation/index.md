# titanium-emitterview Module

## Description

A cross-platform Titanium module for creating beautiful particle emission effects. Particles are emitted from a source view and float in the configured direction with natural sinusoidal sway animations.

Built with advanced RainConfetti-style features: native shape generation (confetti, triangles, stars, diamonds), text particles, velocity/spin control, intensity-based birth rates, and full animation lifecycle management.

**Common use cases:**
- Social media "Like" reactions (hearts floating up)
- Celebration effects (confetti bursts)
- Weather effects (rain, snow, falling leaves)
- Ambient particle backgrounds
- Interactive feedback animations
- Text-based particle spells/quotes

## Accessing the Module

```javascript
var emitterModule = require('de.marcbender.emitterview');
```

---

## Reference

### `createView(properties)`

Creates a new emitter view that can be added to any window or container view.

**Returns:** `Ti.UI.View` — The emitter view instance

#### Core Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `amplitude` | Number | No | 8 | Minimum horizontal/vertical sway in pixels. Particles oscillate between this and `maxAmplitude`. |
| `maxAmplitude` | Number | No | 14 | Maximum horizontal/vertical sway in pixels. Larger values create wider oscillation. |
| `duration` | Number | No | 3.0 | Minimum animation duration in seconds. Each particle gets a random duration between `duration` and `maxDuration`. |
| `maxDuration` | Number | No | 3.5 | Maximum animation duration in seconds. |
| `direction` | Number | No | 0 | Emission direction: `0`=up, `1`=down, `2`=left, `3`=right |
| `particleImages` | Array | *See below* | — | Array of images to use as particles. Accepts: String (file path), `Ti.Blob`, `Ti.Filesystem.File`, `Ti.UI.Image`. |

#### RainConfetti-style Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `particleType` | Number | No | 0 | Particle rendering mode (see table below) |
| `intensity` | Number | No | 0.5 | Emission birth rate: `0.0` (slow) → `1.0` (fast). Controls particles emitted per frame. |
| `colors` | Array | No | 7-color palette | Array of hex color strings (e.g. `['#FF0000', '#00FF00']`). Used for native shape generation. |
| `velocity` | Number | No | 350 | Base particle fall/travel speed in px/s. |
| `velocityRange` | Number | No | 80 | Speed variance range. Actual velocity = `velocity ± velocityRange/2`. |
| `spin` | Number | No | 0 | Rotation angle in degrees per particle lifecycle. `0` = no rotation. |
| `spinRange` | Number | No | 0 | Spin variance range. Actual spin = `spin ± spinRange/2`. |
| `text` | String | No | `""` | Text string split into individual character particles. |
| `fontSize` | Number | No | 24 | Font size for text-based particles (when `particleType=5`). |
| `autoStopDuration` | Number | No | 0 | Auto-stop emission after N seconds. `0` = disabled. |
| `autoRemove` | Boolean | No | `false` | Automatically remove emitter view from hierarchy when stopped. |

#### Particle Types

| Value | Constant | Description |
|-------|----------|-------------|
| `0` | `PARTICLE_CUSTOM` | Custom images from `particleImages` array |
| `1` | `PARTICLE_CONFETTI` | Rectangular confetti pieces (native shape) |
| `2` | `PARTICLE_TRIANGLE` | Triangle shapes (native shape) |
| `3` | `PARTICLE_STAR` | 5-point star shapes (native shape) |
| `4` | `PARTICLE_DIAMOND` | Diamond shapes (native shape) |
| `5` | `PARTICLE_TEXT` | Individual characters from `text` property |

> **Note:** For types 1–5, `particleImages` is not required. Particles are generated natively using `colors` array.

#### Standard View Properties

All standard Titanium view properties are supported: `top`, `left`, `right`, `bottom`, `width`, `height`, `zIndex`, `visible`, `opacity`, `backgroundColor`, etc.

---

### `emitImage(options)`

Emits a single particle from the specified source view. The particle appears at the center of `sourceView` and animates in the configured direction.

**Parameters:**

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `sourceView` | `Ti.UI.View` | **Yes** | — | The view to emit particles from. Particles originate from the center of this view. |
| `id` | Number | No | — | Emit a specific image (1-based index from `particleImages`). Mutually exclusive with `startId`/`endId`. |
| `startId` | Number | No | — | Start of random image range (1-based). Must be used with `endId`. |
| `endId` | Number | No | — | End of random image range (1-based). Must be used with `startId`. |

**Behavior:**
- If `id` is specified → emit that specific image only
- If `startId` + `endId` are specified → emit random image from that range
- If neither is specified → emit random image from entire `particleImages` array

**Returns:** `void`

---

### Animation Control Methods

Full lifecycle management for continuous particle emission.

#### `start()`

Starts continuous particle emission based on `intensity` setting. Emits particles every frame using the native animation engine.

```javascript
emitterView.start();
```

#### `stop()`

Stops emission and cleans up active particles. If `autoRemove` is `true`, the emitter view is removed from its parent.

```javascript
emitterView.stop();
```

#### `pause()`

Pauses emission temporarily. Active particles continue their animations but no new particles are emitted.

```javascript
emitterView.pause();
```

#### `resume()`

Resumes emission after a pause.

```javascript
emitterView.resume();
```

#### `isActive()`

Returns `true` if the emitter is currently running and not paused.

```javascript
if (emitterView.isActive()) {
    Ti.API.info('Emitter is active');
}
```

---

### Direction Constants

| Value | Name | Description |
|-------|------|-------------|
| `0` | **UP** (default) | Particles float upward. Ideal for social media reactions. |
| `1` | **DOWN** | Particles fall downward. Use for rain, snow, falling effects. |
| `2` | **LEFT** | Particles move left. Use for wind effects. |
| `3` | **RIGHT** | Particles move right. Use for wind effects. |

---

## Usage

### Example 1: Classic Heart Emitter

```javascript
var emitterModule = require('de.marcbender.emitterview');

var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleImages: ['/images/heart.png'],
    direction: 0, // up
    amplitude: 6,
    maxAmplitude: 12,
    duration: 2.5,
    maxDuration: 3.5
});

win.add(emitterView);

// Emit from a button
likeButton.addEventListener('click', function() {
    emitterView.emitImage({
        sourceView: likeButton
    });
});
```

---

### Example 2: Confetti Celebration (Native Shapes)

```javascript
var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: 1, // confetti
    direction: 1, // down
    intensity: 0.8,
    colors: ['#FF6B6B', '#4ECDC4', '#FFE66D', '#A8E6CF', '#FF8B94'],
    velocity: 400,
    velocityRange: 120,
    spin: 360,
    spinRange: 180,
    autoStopDuration: 5 // auto-stops after 5 seconds
});

win.add(emitterView);

celebrateButton.addEventListener('click', function() {
    emitterView.start();
});
```

---

### Example 3: Star Shower with Custom Colors

```javascript
var starEmitter = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: 3, // star
    direction: 1, // down
    intensity: 0.6,
    colors: ['#FFD700', '#FFF8DC', '#FFFFE0', '#F0E68C'],
    velocity: 300,
    velocityRange: 60,
    spin: 180,
    spinRange: 90,
    amplitude: 4,
    maxAmplitude: 8
});

win.add(starEmitter);

// Control manually
startButton.addEventListener('click', function() {
    if (!starEmitter.isActive()) {
        starEmitter.start();
    }
});

pauseButton.addEventListener('click', function() {
    if (starEmitter.isActive()) {
        starEmitter.pause();
    } else {
        starEmitter.resume();
    }
});

stopButton.addEventListener('click', function() {
    starEmitter.stop();
});
```

---

### Example 4: Text Particle Spell

```javascript
var textEmitter = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: 5, // text
    text: 'MAGIC✨✨✨',
    fontSize: 32,
    direction: 0, // up
    intensity: 0.4,
    colors: ['#FF69B4', '#FF1493', '#DB7093', '#FFB6C1'],
    velocity: 250,
    velocityRange: 50,
    spin: 720,
    spinRange: 360,
    autoStopDuration: 8
});

win.add(textEmitter);

castSpellButton.addEventListener('click', function() {
    textEmitter.start();
});
```

---

### Example 5: Multi-Shape Particle Mix

```javascript
var diamondEmitter = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: 4, // diamond
    direction: 2, // left
    intensity: 0.7,
    colors: ['#00CED1', '#20B2AA', '#3CB371', '#48D1CC'],
    velocity: 500,
    velocityRange: 100,
    amplitude: 3,
    maxAmplitude: 6,
    duration: 2.0,
    maxDuration: 2.5
});

win.add(diamondEmitter);

diamondEmitter.start();
```

---

### Example 6: Triangle Rain Effect

```javascript
var triangleEmitter = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: 2, // triangle
    direction: 1, // down
    intensity: 0.9,
    colors: ['#87CEEB', '#B0E0E6', '#ADD8E6', '#E0FFFF'],
    velocity: 600,
    velocityRange: 150,
    amplitude: 1,
    maxAmplitude: 3,
    duration: 1.5,
    maxDuration: 2.0,
    autoRemove: true
});

// Add to a container that will be removed after animation
var rainContainer = Ti.UI.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL
});
rainContainer.add(triangleEmitter);
win.add(rainContainer);

rainButton.addEventListener('click', function() {
    triangleEmitter.start();
    // Auto-removes after stop due to autoRemove: true
});
```

---

### Example 7: Dynamic Emoji Particles (Legacy Mode)

Generate particles from emoji labels (no external files needed):

```javascript
var emojis = ['❤️', '🧡', '💛', '💚', '💙', '💜'];
var particleImages = emojis.map(function(emoji) {
    return Ti.UI.createLabel({
        text: emoji,
        font: { fontSize: 30 }
    }).toImage();
});

var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: 0, // custom (uses particleImages)
    direction: 0, // up
    particleImages: particleImages
});

win.add(emitterView);

likeButton.addEventListener('click', function() {
    emitterView.emitImage({ sourceView: likeButton });
});
```

---

### Example 8: Continuous Celebration with Auto-Stop

```javascript
var celebration = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: 1, // confetti
    direction: 1,
    intensity: 1.0, // maximum intensity
    colors: ['#FF0000', '#FF7F00', '#FFFF00', '#00FF00', '#0000FF', '#4B0082', '#9400D3'],
    velocity: 450,
    velocityRange: 150,
    spin: 720,
    spinRange: 360,
    autoStopDuration: 10 // stops after 10 seconds automatically
});

win.add(celebration);

celebration.start();
// No need to call stop() — it happens automatically
```

---

### Example 9: Selective Image Emission (Legacy)

Control which particles are emitted with custom images:

```javascript
var customEmitter = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleImages: ['/images/star.png', '/images/heart.png', '/images/diamond.png'],
    direction: 0
});

// Always emit a specific image (id: 1 = star.png)
customEmitter.emitImage({ sourceView: button, id: 1 });

// Random from specific range (hearts and diamonds only)
customEmitter.emitImage({ sourceView: button, startId: 2, endId: 3 });

// Random from entire array (default behavior)
customEmitter.emitImage({ sourceView: button });
```

---

### Example 10: Multi-Direction Burst

Create a burst effect with particles in all directions:

```javascript
var directions = [0, 1, 2, 3]; // up, down, left, right
var emitters = [];

directions.forEach(function(dir) {
    var emitter = emitterModule.createView({
        width: Ti.UI.FILL,
        height: Ti.UI.FILL,
        particleType: 1, // confetti
        direction: dir,
        intensity: 0.8,
        colors: ['#FF6B6B', '#4ECDC4', '#FFE66D'],
        velocity: 500,
        velocityRange: 100,
        spin: 360,
        spinRange: 180
    });
    win.add(emitter);
    emitters.push(emitter);
});

burstButton.addEventListener('click', function() {
    emitters.forEach(function(emitter) {
        emitter.start();
    });
    
    setTimeout(function() {
        emitters.forEach(function(emitter) {
            emitter.stop();
        });
    }, 3000);
});
```

---

## Platform Notes

### iOS

| Feature | Details |
|---------|---------|
| **Animation Engine** | Core Animation (`CAKeyframeAnimation`) |
| **Frame Rate** | 60fps (120fps on ProMotion devices) |
| **Emission Driver** | `CADisplayLink` (frame-synced) |
| **Shape Generation** | `UIGraphicsImageRenderer` (modern, thread-safe) |
| **Particle Cap** | 200 concurrent particles |
| **Image Caching** | `NSCache` (max 50 images) |
| **Path Points** | 40 key points per trajectory |
| **Memory** | Proper layer cleanup in `dealloc` |
| **Scaling** | `traitCollection.displayScale` (no deprecated APIs) |
| **Minimum iOS** | 12.0+ |

### Android

| Feature | Details |
|---------|---------|
| **Animation Engine** | Property Animators (`ObjectAnimator`) |
| **Emission Driver** | `Choreographer` (vsync-synced) |
| **Hardware Accel** | `LAYER_TYPE_HARDWARE` for GPU rendering |
| **Shape Generation** | Native `Canvas`/`Path`/`Paint` |
| **Particle Cap** | 200 concurrent particles |
| **View Pooling** | 30 `ImageView` instances reused |
| **Random** | `ThreadLocalRandom` (zero allocation) |
| **Minimum Android** | API 21+ (5.0 Lollipop) |

---

## Performance Tips

### Best Practices

1. **Pre-generate images** — Create all particle images once at startup
2. **Use small images** — 32×32 to 64×64 pixels is ideal
3. **Reuse image arrays** — Don't recreate `particleImages` on each emit
4. **Limit concurrent particles** — The 200-particle cap prevents issues
5. **Use `touchstart` over `click`** — Faster response for emission
6. **Consider direction** — Up/down animations are simpler than left/right
7. **Use native shapes** — Types 1–5 avoid image loading overhead
8. **Tune intensity** — Lower values for background effects, higher for celebrations

### What to Avoid

1. **Large images** — 200×200+ pixel images hurt performance
2. **Tight loops** — Use `setTimeout` for staggered emissions
3. **Recreating emitters** — Create once, reuse for all emissions
4. **Modifying `particleImages` at runtime** — Set once during init
5. **Exceeding 200 particles** — The cap exists for memory safety
6. **Too many colors** — Keep color arrays under 10 items for shape rendering

---

## Troubleshooting

### Particles don't appear
- Ensure `sourceView` is a valid `Ti.UI.View` added to the hierarchy
- For native shapes (types 1–5), ensure `colors` array is valid
- For text (type 5), ensure `text` property is non-empty
- Verify the emitter view has non-zero width and height

### Particles appear distorted
- Use appropriately sized images for device pixel density
- iOS handles `contentsScale` automatically via `traitCollection`
- Android uses density-aware bitmap generation

### Performance issues
- Reduce `maxAmplitude` for simpler animations
- Use fewer unique images in `particleImages`
- Consider reducing `duration` for faster particle lifecycle
- Lower `intensity` for continuous emitters
- Reduce `spin` values (rotation is computationally expensive)

### Memory warnings
- Reduce the number of images in `particleImages`
- Use smaller image dimensions
- Avoid creating new images in event handlers
- Use `autoRemove: true` for temporary emitters

### Animation control not working
- Call `start()` before `pause()`/`resume()`/`stop()`
- Check `isActive()` before calling control methods
- `autoStopDuration` will call `stop()` automatically

---

## Author

**Marc Bender**

- Module ID: `de.marcbender.emitterview`
- Platforms: iOS 12.0+, Android 5.0+
- Based on RainConfetti design patterns

---

## License

MIT License

Copyright (c) 2017-2026 Marc Bender

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
