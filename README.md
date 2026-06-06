# Titanium Emitter View Module

A cross-platform Titanium module for creating beautiful particle emission effects (like "Like" animations on social media).

![iOS Demo](./ios-demo.gif) | ![Android Demo](./android-demo.gif)

## Installation

Add the module to your `tiapp.xml`:

```xml
<modules>
    <module platform="iphone">de.marcbender.emitterview</module>
    <module platform="android">de.marcbender.emitterview</module>
</modules>
```

## Quick Start

```javascript
var emitterModule = require('de.marcbender.emitterview');

// Create emitter view
var emitterView = emitterModule.createView({
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    
    // Particle configuration
    amplitude: 8,              // Minimum horizontal sway (default: 8)
    maxAmplitude: 14,          // Maximum horizontal sway (default: 14)
    duration: 3.0,             // Minimum animation duration in seconds (default: 3.0)
    maxDuration: 3.5,          // Maximum animation duration in seconds (default: 3.5)
    direction: 0,              // Emission direction: 0=up, 1=down, 2=left, 3=right (default: 0)
    
    // Particle images (array of image paths, Ti.Blob, or Ti.Filesystem.File)
    particleImages: [
        '/images/heart.png',
        Ti.UI.createLabel({
            text: '❤️',
            font: { fontSize: 40 }
        }).toImage()
    ]
});

win.add(emitterView);

// Emit particles from a button
button.addEventListener('touchstart', function(e) {
    emitterView.emitImage({
        sourceView: button
    });
});
```

---

## API Reference

### Module Methods

#### `createView(properties)`

Creates a new emitter view that can be added to any window or container view.

**Returns:** `Ti.UI.View` — The emitter view instance

---

### Emitter View Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `amplitude` | Number | No | 8 | Minimum horizontal/vertical sway amplitude in pixels. Particles oscillate between this and `maxAmplitude`. |
| `maxAmplitude` | Number | No | 14 | Maximum horizontal/vertical sway amplitude in pixels. |
| `duration` | Number | No | 3.0 | Minimum animation duration in seconds. Each particle gets a random duration between `duration` and `maxDuration`. |
| `maxDuration` | Number | No | 3.5 | Maximum animation duration in seconds. |
| `direction` | Number | No | 0 | Emission direction: `0`=up, `1`=down, `2`=left, `3`=right. |
| `particleImages` | Array | Yes | — | Array of particle images. Accepts: image file paths (String), `Ti.Blob`, `Ti.Filesystem.File`, or `Ti.UI.Image`. |

#### Standard Titanium View Properties

The emitter view supports all standard Titanium view properties:

| Property | Type | Description |
|----------|------|-------------|
| `top` | Number/Dimension | Distance from top edge |
| `left` | Number/Dimension | Distance from left edge |
| `right` | Number/Dimension | Distance from right edge |
| `bottom` | Number/Dimension | Distance from bottom edge |
| `width` | Number/Dimension | View width (use `Ti.UI.FILL` to fill parent) |
| `height` | Number/Dimension | View height (use `Ti.UI.FILL` to fill parent) |
| `zIndex` | Number | Stacking order |
| `visible` | Boolean | Visibility toggle |
| `opacity` | Number | Opacity from 0.0 to 1.0 |
| `backgroundColor` | String | Background color (hex, rgb, rgba) |

---

### Emitter View Methods

#### `emitImage(options)`

Emits a single particle from the specified source view. The particle animates from the center of the source view in the configured direction with sinusoidal sway.

**Parameters:**

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `sourceView` | `Ti.UI.View` | **Yes** | — | The view to emit particles from. Particles originate from the center of this view. |
| `id` | Number | No | — | Emit a specific image from `particleImages` array. **1-based index.** Mutually exclusive with `startId`/`endId`. |
| `startId` | Number | No | — | Start of random image selection range (1-based). Must be used with `endId`. |
| `endId` | Number | No | — | End of random image selection range (1-based). Must be used with `startId`. |

**Behavior:**
- If `id` is specified → emit that specific image
- If `startId` + `endId` are specified → emit random image from that range
- If neither is specified → emit random image from entire `particleImages` array

---

## Direction Constants

| Value | Direction | Use Case |
|-------|-----------|----------|
| `0` | **Up** (default) | Social media reactions, likes, celebrations |
| `1` | **Down** | Rain, snow, falling leaves |
| `2` | **Left** | Wind effects, particles moving left |
| `3` | **Right** | Wind effects, particles moving right |

---

## Comprehensive Examples

### Example 1: Social Media "Like" Button

Classic floating hearts when user taps a like button.

```javascript
var emitterModule = require('de.marcbender.emitterview');

var win = Ti.UI.createWindow({
    title: 'Like Demo',
    backgroundColor: '#fff'
});

// Create emitter
var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    amplitude: 6,
    maxAmplitude: 12,
    duration: 2.5,
    maxDuration: 3.5,
    direction: 0, // up
    particleImages: [
        '/images/heart_red.png',
        '/images/heart_pink.png',
        '/images/star_gold.png'
    ]
});

win.add(emitterView);

// Create like button
var likeButton = Ti.UI.createView({
    width: 80,
    height: 80,
    bottom: 100,
    right: 20,
    borderRadius: 40,
    backgroundColor: '#f0f0f0'
});

var likeLabel = Ti.UI.createLabel({
    text: '❤️',
    font: { fontSize: 40 },
    width: Ti.UI.SIZE,
    height: Ti.UI.SIZE,
    left: 20,
    top: 20
});

likeButton.add(likeLabel);
win.add(likeButton);

// Emit on touch
likeButton.addEventListener('touchstart', function(e) {
    emitterView.emitImage({
        sourceView: likeButton
        // Random image from particleImages array
    });
    
    // Optional: animate button
    var anim = Ti.UI.createAnimation({
        duration: 200,
        scale: 0.8
    });
    likeButton.animate(anim);
});

win.open();
```

---

### Example 2: Rain Effect

Create a rain effect with multiple water drops.

```javascript
var emitterModule = require('de.marcbender.emitterview');

var win = Ti.UI.createWindow({
    title: 'Rain Effect',
    backgroundColor: '#1a1a2e'
});

// Create rain drop images programmatically
var rainDrops = [];
for (var i = 0; i < 5; i++) {
    var dropLabel = Ti.UI.createLabel({
        text: '💧',
        font: { fontSize: 16 + (i * 4) },
        width: Ti.UI.SIZE,
        height: Ti.UI.SIZE
    });
    rainDrops.push(dropLabel.toImage());
}

var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    amplitude: 2,
    maxAmplitude: 4,
    duration: 2.0,
    maxDuration: 3.0,
    direction: 1, // down
    particleImages: rainDrops
});

win.add(emitterView);

// Emit rain periodically
var rainInterval = setInterval(function() {
    // Emit from random x position at top of screen
    var sourceView = Ti.UI.createView({
        width: 20,
        height: 20,
        top: 0,
        left: Math.random() * win.width
    });
    win.add(sourceView);
    
    emitterView.emitImage({
        sourceView: sourceView
    });
    
    // Clean up source view after emission
    setTimeout(function() {
        win.remove(sourceView);
    }, 100);
}, 200);

win.open();
```

---

### Example 3: Confetti Celebration

Multi-direction confetti burst for celebrations.

```javascript
var emitterModule = require('de.marcbender.emitterview');

var win = Ti.UI.createWindow({
    title: 'Celebration',
    backgroundColor: '#16213e'
});

// Create colorful confetti
var confettiColors = ['#e94560', '#f5d060', '#06d6a0', '#118ab2', '#8338ec'];
var confettiImages = [];

confettiColors.forEach(function(color) {
    var confetti = Ti.UI.createView({
        width: 10,
        height: 10,
        backgroundColor: color,
        borderRadius: 2
    });
    confettiImages.push(confetti.toImage());
});

// Create 4 emitters for each direction
var directions = [0, 1, 2, 3]; // up, down, left, right
var emitters = [];

directions.forEach(function(direction) {
    var emitter = emitterModule.createView({
        width: Ti.UI.FILL,
        height: Ti.UI.FILL,
        amplitude: 10,
        maxAmplitude: 20,
        duration: 2.0,
        maxDuration: 4.0,
        direction: direction,
        particleImages: confettiImages
    });
    win.add(emitter);
    emitters.push(emitter);
});

// Create center button
var burstButton = Ti.UI.createView({
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: '#e94560',
    left: (win.width - 120) / 2,
    top: (win.height - 120) / 2
});

var burstLabel = Ti.UI.createLabel({
    text: '🎉',
    font: { fontSize: 50 },
    width: Ti.UI.SIZE,
    height: Ti.UI.SIZE,
    left: 35,
    top: 35
});

burstButton.add(burstLabel);
win.add(burstButton);

// Burst on touch
burstButton.addEventListener('touchstart', function() {
    emitters.forEach(function(emitter) {
        for (var i = 0; i < 3; i++) {
            setTimeout(function() {
                emitter.emitImage({
                    sourceView: burstButton,
                    // Random confetti piece
                });
            }, i * 100);
        }
    });
});

win.open();
```

---

### Example 4: Dynamic Image Generation

Generate particle images from labels with icons (no external files needed).

```javascript
var emitterModule = require('de.marcbender.emitterview');

var win = Ti.UI.createWindow({
    title: 'Dynamic Particles',
    backgroundColor: '#fff'
});

// Generate emoji particles
var emojis = ['❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎'];
var particleImages = [];

emojis.forEach(function(emoji) {
    var label = Ti.UI.createLabel({
        text: emoji,
        font: { fontSize: 30 },
        width: Ti.UI.SIZE,
        height: Ti.UI.SIZE,
        color: 'transparent' // Hide the label
    });
    particleImages.push(label.toImage());
});

var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    amplitude: 8,
    maxAmplitude: 16,
    duration: 2.0,
    maxDuration: 3.5,
    direction: 0, // up
    particleImages: particleImages
});

win.add(emitterView);

// Create button
var button = Ti.UI.createButton({
    title: 'Tap Me!',
    width: Ti.UI.SIZE,
    height: Ti.UI.SIZE,
    font: { fontSize: 18 },
    bottom: 100,
    left: 20
});

win.add(button);

button.addEventListener('click', function() {
    emitterView.emitImage({
        sourceView: button,
        // Random emoji from array
    });
});

win.open();
```

---

### Example 5: Selective Image Emission

Use `id`, `startId`, and `endId` to control which particles emit.

```javascript
var emitterModule = require('de.marcbender.emitterview');

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

// Create particle images
var particles = [
    '/images/star.png',   // id: 1
    '/images/heart.png',  // id: 2
    '/images/diamond.png',// id: 3
    '/images/crown.png',  // id: 4
    '/images/ring.png'    // id: 5
];

var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    amplitude: 8,
    maxAmplitude: 14,
    duration: 3.0,
    maxDuration: 4.0,
    direction: 0,
    particleImages: particles
});

win.add(emitterView);

// Create source button
var button = Ti.UI.createView({
    width: 100,
    height: 100,
    bottom: 100,
    left: 20,
    borderRadius: 50,
    backgroundColor: '#333'
});

win.add(button);

// Example 1: Emit specific image (always a star)
button.addEventListener('touchstart', function() {
    emitterView.emitImage({
        sourceView: button,
        id: 1  // Always emits particles[0] (star.png)
    });
});

// Example 2: Random from specific range (hearts and diamonds only)
function emitHeartsAndDiamonds() {
    emitterView.emitImage({
        sourceView: button,
        startId: 2,  // particles[1] (heart.png)
        endId: 3     // particles[2] (diamond.png)
        // Randomly picks between heart and diamond
    });
}

// Example 3: Random from entire array (default behavior)
function emitRandomParticle() {
    emitterView.emitImage({
        sourceView: button
        // No id, startId, or endId specified
        // Randomly picks from all 5 particles
    });
}

win.open();
```

---

### Example 6: Multiple Buttons with Different Emitters

Each button has its own emitter with unique configuration.

```javascript
var emitterModule = require('de.marcbender.emitterview');

var win = Ti.UI.createWindow({
    title: 'Multi-Button Demo',
    backgroundColor: '#f5f5f5'
});

// Heart button (red, floats up)
var heartEmitter = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    amplitude: 6,
    maxAmplitude: 10,
    duration: 2.5,
    maxDuration: 3.5,
    direction: 0,
    particleImages: [Ti.UI.createLabel({
        text: '❤️',
        font: { fontSize: 30 }
    }).toImage()]
});
win.add(heartEmitter);

var heartButton = Ti.UI.createLabel({
    text: '❤️ Like',
    font: { fontSize: 18, fontWeight: 'bold' },
    width: Ti.UI.SIZE,
    height: Ti.UI.SIZE,
    bottom: 150,
    left: 20
});

heartButton.addEventListener('click', function() {
    heartEmitter.emitImage({
        sourceView: heartButton
    });
});
win.add(heartButton);

// Star button (gold, floats up with more sway)
var starEmitter = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    amplitude: 12,
    maxAmplitude: 20,
    duration: 3.0,
    maxDuration: 5.0,
    direction: 0,
    particleImages: [Ti.UI.createLabel({
        text: '⭐',
        font: { fontSize: 30 }
    }).toImage()]
});
win.add(starEmitter);

var starButton = Ti.UI.createLabel({
    text: '⭐ Favorite',
    font: { fontSize: 18, fontWeight: 'bold' },
    width: Ti.UI.SIZE,
    height: Ti.UI.SIZE,
    bottom: 100,
    left: 20
});

starButton.addEventListener('click', function() {
    starEmitter.emitImage({
        sourceView: starButton
    });
});
win.add(starButton);

// Snow button (downward)
var snowEmitter = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    amplitude: 3,
    maxAmplitude: 6,
    duration: 3.0,
    maxDuration: 4.0,
    direction: 1, // down
    particleImages: [Ti.UI.createLabel({
        text: '❄️',
        font: { fontSize: 24 }
    }).toImage()]
});
win.add(snowEmitter);

var snowButton = Ti.UI.createLabel({
    text: '❄️ Snow',
    font: { fontSize: 18, fontWeight: 'bold' },
    width: Ti.UI.SIZE,
    height: Ti.UI.SIZE,
    bottom: 50,
    left: 20
});

snowButton.addEventListener('click', function() {
    snowEmitter.emitImage({
        sourceView: snowButton
    });
});
win.add(snowButton);

win.open();
```

---

## Platform-Specific Notes

### iOS

- **Animation Engine:** Core Animation (`CAKeyframeAnimation`) for buttery-smooth 60/120fps
- **Particle Cap:** Maximum 100 concurrent particles
- **Image Caching:** `NSCache` for image reuse (max 50 cached images)
- **Path Optimization:** 40 key points per path (vs pixel-by-pixel)
- **ProMotion Support:** Automatically adapts to 120Hz on compatible devices
- **Memory Management:** Proper layer cleanup in `dealloc`
- **Minimum iOS:** 12.0+

### Android

- **Animation Engine:** Property Animators (`ObjectAnimator`) with hardware acceleration
- **Particle Cap:** Maximum 100 concurrent particles
- **View Pooling:** 20 `ImageView` instances reused to reduce allocations
- **Layer Type:** `LAYER_TYPE_HARDWARE` for GPU-accelerated rendering
- **Random Generation:** `ThreadLocalRandom` for thread-safe, zero-allocation randomness
- **Minimum Android:** API 21+ (Android 5.0 Lollipop)

---

## Performance Best Practices

### ✅ Do

1. **Pre-generate images** — Create all particle images once at app startup
2. **Use small images** — 32x32 to 64x64 pixels is ideal for particles
3. **Reuse image arrays** — Don't recreate `particleImages` on each emit
4. **Limit concurrent particles** — The 100-particle cap prevents memory issues
5. **Use `touchstart` over `click`** — Faster response for particle emission
6. **Consider `direction`** — Up/down animations are simpler than left/right

### ❌ Don't

1. **Don't create large images** — 200x200+ pixel images hurt performance
2. **Don't emit in tight loops** — Use `setTimeout` for staggered emissions
3. **Don't recreate the emitter** — Create once, reuse for all emissions
4. **Don't modify `particleImages` at runtime** — Set once during initialization
5. **Don't exceed 100 particles** — The cap exists for a reason

---

## Troubleshooting

### Particles don't appear
- Ensure `sourceView` is a valid `Ti.UI.View` that's been added to the view hierarchy
- Check that `particleImages` array is not empty
- Verify the emitter view has non-zero width and height

### Particles appear distorted
- Set `layer.contentsScale` properly (handled automatically on iOS)
- Use appropriately sized images for the device's pixel density

### Performance issues
- Reduce `maxAmplitude` for simpler animations
- Use fewer unique images in `particleImages`
- Consider reducing `duration` for faster particle lifecycle

### Memory warnings
- Reduce the number of images in `particleImages`
- Use smaller image dimensions
- Avoid creating new images in event handlers

---

## Requirements

| Platform | Minimum Version |
|----------|----------------|
| **iOS** | 12.0+ |
| **Android** | API 21+ (5.0 Lollipop) |
| **Titanium SDK** | 10.1.0+ |

---

## Changelog

### 2026-06-06
- **iOS:** Optimized for ProMotion displays (120Hz support)
- **iOS:** Replaced deprecated `UIScreen.mainScreen` with `traitCollection.displayScale`
- **iOS:** Fixed path calculation bug (particles now animate upward correctly)
- **Android:** Complete rewrite with Property Animators for hardware acceleration
- **Android:** Added ImageView pooling (20 views) for memory efficiency
- **Android:** Added `ThreadLocalRandom` for zero-allocation randomness
- **Both:** Added `direction` property (0=up, 1=down, 2=left, 3=right)
- **Both:** Fixed `idx` calculation bug in random image selection
- **Both:** Synchronized default values (amplitude=8, duration=3.0)
- **Documentation:** Comprehensive examples and API reference

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

---

## Author

**Marc Bender**

- Module: `de.marcbender.emitterview`
- Platforms: iOS 12.0+, Android 5.0+
