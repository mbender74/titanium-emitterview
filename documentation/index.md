# titanium-emitterview Module

## Description

A cross-platform Titanium module for creating beautiful particle emission effects. Particles are emitted from a source view and float in the configured direction with natural sinusoidal sway animations.

Common use cases:
- Social media "Like" reactions (hearts floating up)
- Celebration effects (confetti bursts)
- Weather effects (rain, snow, falling leaves)
- Ambient particle backgrounds
- Interactive feedback animations

## Accessing the Module

```javascript
var emitterModule = require('de.marcbender.emitterview');
```

---

## Reference

### `createView(properties)`

Creates a new emitter view that can be added to any window or container view.

**Returns:** `Ti.UI.View` — The emitter view instance

**Properties:**

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `amplitude` | Number | No | 8 | Minimum horizontal/vertical sway in pixels. Particles oscillate between this and `maxAmplitude`. |
| `maxAmplitude` | Number | No | 14 | Maximum horizontal/vertical sway in pixels. Larger values create wider oscillation. |
| `duration` | Number | No | 3.0 | Minimum animation duration in seconds. Each particle gets a random duration between `duration` and `maxDuration`. |
| `maxDuration` | Number | No | 3.5 | Maximum animation duration in seconds. |
| `direction` | Number | No | 0 | Emission direction: `0`=up, `1`=down, `2`=left, `3`=right |
| `particleImages` | Array | **Yes** | — | Array of images to use as particles. Accepts: String (file path), `Ti.Blob`, `Ti.Filesystem.File`, `Ti.UI.Image`. |

**Standard View Properties:**

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

### Direction Constants

| Value | Name | Description |
|-------|------|-------------|
| `0` | **UP** (default) | Particles float upward. Ideal for social media reactions. |
| `1` | **DOWN** | Particles fall downward. Use for rain, snow, falling effects. |
| `2` | **LEFT** | Particles move left. Use for wind effects. |
| `3` | **RIGHT** | Particles move right. Use for wind effects. |

---

## Usage

### Basic Example

```javascript
var emitterModule = require('de.marcbender.emitterview');

var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleImages: ['/images/heart.png'],
    direction: 0 // up
});

win.add(emitterView);

// Emit from a button
button.addEventListener('click', function() {
    emitterView.emitImage({
        sourceView: button
    });
});
```

---

### Advanced Example with Random Images

```javascript
var particleImages = [];
for (var i = 1; i <= 5; i++) {
    particleImages.push('/images/emoji/' + i + '.png');
}

var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    amplitude: 10,
    maxAmplitude: 20,
    duration: 2.5,
    maxDuration: 4.0,
    direction: 0,
    particleImages: particleImages
});

// Emit random image from range
emitterView.emitImage({
    sourceView: button,
    startId: 1,
    endId: 5
});

// Emit specific image
emitterView.emitImage({
    sourceView: button,
    id: 3
});
```

---

### Rain Effect Example

```javascript
var rainDrops = [];
for (var i = 0; i < 10; i++) {
    rainDrops.push(Ti.UI.createLabel({
        text: '💧',
        font: { fontSize: 20 }
    }).toImage());
}

var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    amplitude: 2,
    maxAmplitude: 5,
    duration: 1.5,
    maxDuration: 2.5,
    direction: 1, // down
    particleImages: rainDrops
});

win.add(emitterView);

// Emit rain periodically
setInterval(function() {
    var drop = Ti.UI.createView({
        width: 10,
        height: 10,
        top: 0,
        left: Math.random() * win.width
    });
    win.add(drop);
    emitterView.emitImage({ sourceView: drop });
    setTimeout(function() { win.remove(drop); }, 100);
}, 200);
```

---

### Dynamic Emoji Particles

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
    direction: 0, // up
    particleImages: particleImages
});
```

---

### Multi-Direction Confetti

Create a burst effect with particles in all directions:

```javascript
var directions = [0, 1, 2, 3]; // up, down, left, right
var emitters = [];

directions.forEach(function(dir) {
    var emitter = emitterModule.createView({
        width: Ti.UI.FILL,
        height: Ti.UI.FILL,
        direction: dir,
        particleImages: confettiImages
    });
    win.add(emitter);
    emitters.push(emitter);
});

// Emit from all directions
emitters.forEach(function(emitter) {
    emitter.emitImage({ sourceView: burstButton });
});
```

---

### Selective Image Emission

Control which particles are emitted:

```javascript
// Always emit a specific image (id: 1 = star.png)
emitterView.emitImage({
    sourceView: button,
    id: 1
});

// Random from specific range (hearts and diamonds only)
emitterView.emitImage({
    sourceView: button,
    startId: 2,
    endId: 3
});

// Random from entire array (default behavior)
emitterView.emitImage({
    sourceView: button
});
```

---

## Platform Notes

### iOS

| Feature | Details |
|---------|---------|
| **Animation Engine** | Core Animation (`CAKeyframeAnimation`) |
| **Frame Rate** | 60fps (120fps on ProMotion devices) |
| **Particle Cap** | 100 concurrent particles |
| **Image Caching** | `NSCache` (max 50 images) |
| **Path Points** | 40 key points per path |
| **Memory** | Proper layer cleanup in `dealloc` |
| **Minimum iOS** | 12.0+ |

### Android

| Feature | Details |
|---------|---------|
| **Animation Engine** | Property Animators (`ObjectAnimator`) |
| **Hardware Accel** | `LAYER_TYPE_HARDWARE` for GPU rendering |
| **Particle Cap** | 100 concurrent particles |
| **View Pooling** | 20 `ImageView` instances reused |
| **Random** | `ThreadLocalRandom` (zero allocation) |
| **Minimum Android** | API 21+ (5.0 Lollipop) |

---

## Performance Tips

### Best Practices

1. **Pre-generate images** — Create all particle images once at startup
2. **Use small images** — 32x32 to 64x64 pixels is ideal
3. **Reuse image arrays** — Don't recreate `particleImages` on each emit
4. **Limit concurrent particles** — The 100-particle cap prevents issues
5. **Use `touchstart` over `click`** — Faster response for emission
6. **Consider direction** — Up/down animations are simpler than left/right

### What to Avoid

1. **Large images** — 200x200+ pixel images hurt performance
2. **Tight loops** — Use `setTimeout` for staggered emissions
3. **Recreating emitters** — Create once, reuse for all emissions
4. **Modifying `particleImages` at runtime** — Set once during init
5. **Exceeding 100 particles** — The cap exists for memory safety

---

## Troubleshooting

### Particles don't appear
- Ensure `sourceView` is a valid `Ti.UI.View` added to the hierarchy
- Check that `particleImages` array is not empty
- Verify the emitter view has non-zero width and height

### Particles appear distorted
- Use appropriately sized images for device pixel density
- iOS handles `contentsScale` automatically

### Performance issues
- Reduce `maxAmplitude` for simpler animations
- Use fewer unique images in `particleImages`
- Consider reducing `duration` for faster particle lifecycle

### Memory warnings
- Reduce the number of images in `particleImages`
- Use smaller image dimensions
- Avoid creating new images in event handlers

---

## Author

**Marc Bender**

- Module ID: `de.marcbender.emitterview`
- Platforms: iOS 12.0+, Android 5.0+

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
