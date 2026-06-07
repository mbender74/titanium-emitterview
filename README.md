# Titanium Mobile iOS and Android Emitter View Module
(https://titaniumsdk.com/)

A cross-platform Titanium Mobile SDK module for creating beautiful particle emission effects.

This module is adapted from [RainConfetti](https://github.com/linghugoogle/RainConfetti) by [linghugoogle](https://github.com/linghugoogle) — a Swift-based particle emitter for iOS. The core animation architecture, shape generation algorithms, and emission physics have been ported to native Objective-C (iOS) and Java (Android), then wrapped as a Titanium module for cross-platform use.

![iOS Demo](./ios-demo.gif) | ![Android Demo](./android-demo.gif)

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
  - [Module Constants](#module-constants)
    - [Particle Types](#particle-types)
    - [Direction Constants](#direction-constants)
  - [View Properties](#view-properties)
    - [Particle Configuration](#particle-configuration)
    - [Motion & Physics](#motion--physics)
    - [Scale & Rotation](#scale--rotation)
    - [Text Particles](#text-particles)
    - [Lifecycle Control](#lifecycle-control)
    - [Legacy Image Mode](#legacy-image-mode)
    - [Standard Titanium UI Properties](#standard-titanium-ui-properties)
  - [Instance Methods](#instance-methods)
  - [emitImage() Options](#emitimage-options)
- [Usage Modes](#usage-modes)
  - [Mode A: Continuous Emission (start/stop)](#mode-a-continuous-emission-startstop)
  - [Mode B: Burst Emission (emitImage)](#mode-b-burst-emission-emitimage)
- [Examples](#examples)
- [Platform-Specific Internals](#platform-specific-internals)
- [Performance Best Practices](#performance-best-practices)
- [Troubleshooting](#troubleshooting)
- [Requirements](#requirements)
- [Changelog](#changelog)
- [License](#license)
- [Author](#author)

---

## Installation

### 1. Add the Module

Place the compiled module in your project's `app/iphone/` and `app/android/` directories (or `Resources/` for classic projects).

### 2. Register in tiapp.xml

```xml
<modules>
    <module platform="iphone">de.marcbender.emitterview</module>
    <module platform="android">de.marcbender.emitterview</module>
</modules>
```

### 3. Require in JavaScript

```javascript
var emitterModule = require('de.marcbender.emitterview');
```

---

## Quick Start

```javascript
var emitterModule = require('de.marcbender.emitterview');

// Create an emitter view with native confetti shapes (no images needed)
var emitterView = emitterModule.createView({
    width:  Ti.UI.FILL,
    height: Ti.UI.FILL,

    particleType:   emitterModule.PARTICLE_CONFETTI,
    direction:      emitterModule.DIRECTION_DOWN,
    intensity:      0.8,
    colors:         ['#FF6B6B', '#4ECDC4', '#FFE66D', '#FF8B94'],
    velocity:       400,
    velocityRange:  120,
    spin:           360,
    spinRange:      180,
    autoStopDuration: 5   // stops automatically after 5 seconds
});

win.add(emitterView);

// Trigger emission
button.addEventListener('click', function() {
    emitterView.start();
});
```

---

## API Reference

### Module Constants

All constants are accessed via the module object returned by `require()`.

#### Particle Types

| Constant | Value | Description |
|----------|-------|-------------|
| `PARTICLE_CUSTOM`   | `0` | Custom images from the `particleImages` array. Each image in the array becomes one particle variant. |
| `PARTICLE_CONFETTI` | `1` | Small rectangular confetti pieces. Generated natively using the `colors` array — no images required. |
| `PARTICLE_TRIANGLE` | `2` | Equilateral triangle shapes. Generated natively from `colors`. |
| `PARTICLE_STAR`     | `3` | Five-pointed star shapes. Generated natively from `colors`. |
| `PARTICLE_DIAMOND`  | `4` | Diamond (rhombus) shapes. Generated natively from `colors`. |
| `PARTICLE_TEXT`     | `5` | Individual characters from the `text` property, each rendered as a separate particle. Colors cycle through the `colors` array. |

> **Important:** For types 1–5, the `particleImages` property is **not** required and is ignored. Particles are generated natively on each platform using vector drawing primitives.

#### Direction Constants

| Constant | Value | Emitter Position | Use Case |
|----------|-------|-----------------|----------|
| `DIRECTION_UP`    | `0` | Bottom → Top | Social media reactions, floating hearts, celebration effects |
| `DIRECTION_DOWN`  | `1` | Top → Bottom | Rain, snow, falling leaves, confetti showers |
| `DIRECTION_LEFT`  | `2` | Right → Left | Wind blowing left, particle streams |
| `DIRECTION_RIGHT` | `3` | Left → Right | Wind blowing right, particle streams |

The emitter source position is automatically placed at the appropriate edge of the view based on direction. For `UP` and `DOWN`, particles originate across the full width. For `LEFT` and `RIGHT`, they originate across the full height.

---

### View Properties

All properties are set during view creation via `createView({...})` or assigned after creation as instance properties.

#### Particle Configuration

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `particleType` | `Number` | `0` (`PARTICLE_CUSTOM`) | Determines how particles are rendered. Use values 0–5 (see [Particle Types](#particle-types)). For native shapes (1–5), particles are drawn using platform-native vector graphics — no image files needed. |
| `colors` | `Array<String>` | Platform default palette | Array of hex color strings (e.g., `'#FF6B6B'`) used to tint native shape particles. Each color in the array creates a separate emitter cell, so particles cycle through all provided colors. Ignored when `particleType` is `PARTICLE_CUSTOM`. For text particles, colors are assigned to characters in round-robin fashion. |
| `intensity` | `Number` | `0.5` | Controls the particle birth rate on a scale from `0.0` (no particles) to `1.0` (maximum density). Internally mapped to `birthRate = intensity × 10`. Higher values produce more particles per frame. Use lower values (0.2–0.4) for subtle background effects, higher values (0.7–1.0) for celebrations. |

#### Motion & Physics

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `direction` | `Number` | `1` (`DIRECTION_DOWN`) | Direction of particle travel. Use values 0–3 (see [Direction Constants](#direction-constants)). The emitter source is automatically positioned at the appropriate edge. |
| `velocity` | `Number` | `350` | Base speed of particles in pixels per second. This is the average speed — individual particles may vary based on `velocityRange`. Higher values produce faster-moving particles. |
| `velocityRange` | `Number` | `80` | Random variance added to the base velocity for each particle, in pixels per second. Each particle's actual speed = `velocity + random(0, velocityRange)`. Set to `0` for uniform speed, or higher values (100–200) for natural variation. |
| `amplitude` | `Number` | `8` | Minimum lateral sway (wobble) amplitude in density-independent pixels. Particles oscillate perpendicular to their travel direction, creating a natural drifting effect. |
| `maxAmplitude` | `Number` | `14` | Maximum lateral sway amplitude in density-independent pixels. Each particle gets a random sway value between `amplitude` and `maxAmplitude`. |
| `lifetime` | `Number` | `7.0` | Duration each individual particle exists on screen, in seconds. After this time, the particle is removed regardless of position. For continuous emission modes, this controls how long particles persist. |
| `emissionRange` | `Number` | `45` | Angular spread (in degrees) of the particle emission cone. A value of `0` means all particles travel in exactly the same direction. Higher values (30–90) create a wider, more natural spray pattern. On iOS, this maps to `CAEmitterCell.emissionRange` in radians. |

#### Scale & Rotation

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `spin` | `Number` | Platform default (~2 rad/s on iOS, `0` degrees on Android) | Base rotation amount applied to each particle. On Android, specified in total degrees of rotation over the particle's lifetime. On iOS, converted from degrees to radians per second for `CAEmitterCell.spin`. Set to `0` to disable rotation entirely. |
| `spinRange` | `Number` | Platform default (~3 rad/s on iOS, `0` degrees on Android) | Random variance added to the base spin value. Each particle gets a random rotation between `spin - spinRange/2` and `spin + spinRange/2`. |
| `scaleRange` | `Number` | `0.5` | Range of size variation across particles. Particles scale from their base size down by up to `scaleRange` fraction. A value of `0.5` means particles range from 50% to 100% of their original size. Set to `0` for uniform sizing. |
| `scaleSpeed` | `Number` | `-0.05` | Rate at which particle scale changes over time. Negative values cause particles to shrink as they travel (fade-out effect). Positive values cause them to grow. `0` means constant size throughout the particle's lifetime. |

#### Text Particles

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `String` | `''` | The text string whose individual characters are used as particles. Only active when `particleType` is set to `PARTICLE_TEXT` (5). Each character becomes a separate particle, rendered with colors cycling through the `colors` array. Example: `'HAPPY'` produces particles for 'H', 'A', 'P', 'P', 'Y'. |
| `fontSize` | `Number` | Platform default (~8pt iOS, 24dp Android) | Font size for text particles in points/density-independent pixels. Only active when `particleType` is `PARTICLE_TEXT`. Larger values produce bigger character particles. |

#### Lifecycle Control

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `autoStopDuration` | `Number` | `0` (disabled) | Automatically calls `stop()` after the specified number of seconds from when `start()` was called. Set to `0` or omit to disable. Useful for temporary effects like celebrations that should end on their own. |
| `autoRemove` | `Boolean` | `false` | When `true`, automatically removes the emitter view from its parent container when `stop()` is called (or when auto-stop triggers). Use this for one-shot effects where the view is no longer needed after the animation ends. |

#### Legacy Image Mode

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `particleImages` | `Array` | `[]` | Array of image sources used when `particleType` is `PARTICLE_CUSTOM` (0). Each element can be: a file path string (`'/images/heart.png'`), a `Ti.Blob`, a `Ti.File`, or a `Ti.Proxy.URL`. Images are cached on iOS via `NSCache` (max 50 entries). On Android, images are loaded as `TiDrawableReference` objects. This property is **ignored** for native shape types (1–5). |

#### Standard Titanium UI Properties

All standard Titanium view properties are supported:

| Property | Type | Description |
|----------|------|-------------|
| `width` / `height` | `Number` / `Ti.UI.FILL` / `Ti.UI.SIZE` | View dimensions. Typically set to `Ti.UI.FILL` for fullscreen overlay effects. |
| `top` / `left` / `right` / `bottom` | `Number` | Position constraints within the parent view. |
| `layout` | `String` | Layout mode (`'vertical'`, `'horizontal'`, `'none'`). |
| `backgroundColor` | `String` | Background color (typically transparent). |
| `visible` | `Boolean` | View visibility. |

---

### Instance Methods

All methods are called on the emitter view instance returned by `createView()`.

#### `start()`

Starts continuous particle emission. Particles are emitted at a rate determined by `intensity` until `stop()` is called or `autoStopDuration` elapses.

- **Platform behavior:**
  - **iOS:** Configures `CAEmitterCell` birth rates and activates the emitter layer.
  - **Android:** Posts a `Choreographer.FrameCallback` that emits particles each frame based on intensity.
- **Idempotent:** Calling `start()` when already running has no effect.
- **Resets position:** Clears any custom `emitterPosition` set by `emitImage()` and restores the default direction-based position.

```javascript
emitterView.start();
```

#### `stop()`

Stops particle emission immediately and begins cleanup.

- Sets birth rate to zero (iOS) or cancels the frame callback (Android).
- Existing particles continue their animation until completion, then are removed.
- If `autoRemove` is `true`, the view is removed from its parent after stopping.
- Cancels any pending `autoStopDuration` timer.

```javascript
emitterView.stop();
```

#### `pause()`

Pauses particle emission without resetting state. The emitter remains "running" but produces no new particles. Can be resumed with `resume()`.

- **iOS:** Saves the current birth rate and sets all cells to zero.
- **Android:** Sets a pause flag; the frame callback continues but skips emission.

```javascript
emitterView.pause();
```

#### `resume()`

Resumes a paused emitter. Restores the previous birth rate and continues emission where it left off.

- Has no effect if the emitter is not in a paused state.
- Has no effect if the emitter has been stopped (use `start()` instead).

```javascript
emitterView.resume();
```

#### `isActive()`

Returns a boolean indicating whether the emitter is currently running and actively producing particles.

- Returns `true` only when the emitter has been started and is not paused.
- Returns `false` if the emitter has never been started, has been stopped, or is currently paused.

```javascript
if (emitterView.isActive()) {
    emitterView.pause();
} else {
    emitterView.start();
}
```

#### `emitImage(options)`

Emits a single burst of particles from a custom image. This is the legacy emission method for `PARTICLE_CUSTOM` mode. Unlike `start()`, this emits a one-time burst rather than continuous emission.

- **options:** Object with emission parameters (see [emitImage() Options](#emitimage-options) below).
- Particles originate from the position of `sourceView` if provided, or from the default emitter position based on `direction`.
- Each emitted particle is animated individually with platform-native animation APIs.

```javascript
emitterView.emitImage({
    sourceView: likeButton,
    id: 1
});
```

---

### emitImage() Options

The `emitImage()` method accepts an options object with the following properties:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `sourceView` | `Ti.UI.View` / `Ti.UI.Label` / etc. | `null` | The view from which particles originate. The emitter calculates the center position of this view and uses it as the emission point. When set, overrides the default direction-based emitter position. On iOS, this changes the emitter shape to a point source. |
| `direction` | `Number` | Current `direction` property | Override the emission direction for this specific call only. Accepts values 0–3 (same as `DIRECTION_*` constants). This is only applied on iOS; Android uses the view's current direction. |
| `id` | `Number` | Random | Selects a specific image from the `particleImages` array by 0-based index. `id: 0` selects the first image, `id: 1` the second, etc. If omitted, a random image from the array is chosen. |
| `startId` | `Number` | — | Lower bound (0-based) for random image selection. Used together with `endId` to limit the pool of selectable images. |
| `endId` | `Number` | — | Upper bound (0-based) for random image selection. When both `startId` and `endId` are provided, a random image is selected from that range (inclusive). Values exceeding the array length are clamped to the last valid index. |
| `emitValue` | `Number` | `1` | Number of particles to emit in this burst. Each particle gets its own animation. Higher values produce denser bursts but increase CPU/GPU load. |
| `emitSpread` | `Number` | `0` | Lateral spread (in density-independent pixels) applied perpendicular to the travel direction. Creates a wider burst effect. For vertical directions, spreads horizontally; for horizontal directions, spreads vertically. |
| `emitScaleRange` | `Number` | `0` | Scale variation range for burst particles. The first particle uses full scale; subsequent particles are scaled down by up to this fraction. Creates a natural size variation in bursts. |

---

## Usage Modes

### Mode A: Continuous Emission (start/stop)

Use this mode for ongoing effects like rain, snow, or celebration confetti. Configure all properties at creation time, then control the lifecycle with `start()`, `pause()`, `resume()`, and `stop()`.

```javascript
var emitter = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: emitterModule.PARTICLE_CONFETTI,
    direction: emitterModule.DIRECTION_DOWN,
    intensity: 0.8,
    colors: ['#FF6B6B', '#4ECDC4', '#FFE66D'],
    velocity: 400,
    autoStopDuration: 10   // auto-stops after 10s
});

win.add(emitter);
emitter.start();
```

### Mode B: Burst Emission (emitImage)

Use this mode for on-demand particle bursts triggered by user interaction. Requires `particleImages` to be set at creation time. Each call to `emitImage()` produces a one-time burst.

```javascript
var emitter = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: emitterModule.PARTICLE_CUSTOM,
    direction: emitterModule.DIRECTION_UP,
    particleImages: ['/images/heart.png', '/images/star.png']
});

win.add(emitter);

button.addEventListener('touchstart', function() {
    emitter.emitImage({ sourceView: button });
});
```

---

## Examples

### Example 1: Social Media "Like" Button

Classic floating hearts when user taps a like button.

```javascript
var emitterModule = require('de.marcbender.emitterview');
var win = Ti.UI.createWindow({ backgroundColor: '#fff' });

var emitterView = emitterModule.createView({
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    amplitude: 6,
    maxAmplitude: 12,
    direction: emitterModule.DIRECTION_UP,
    particleImages: [
        '/images/heart_red.png',
        '/images/heart_pink.png',
        '/images/star_gold.png'
    ]
});
win.add(emitterView);

var likeButton = Ti.UI.createView({
    width: 80, height: 80,
    bottom: 100, right: 20,
    borderRadius: 40,
    backgroundColor: '#f0f0f0'
});
likeButton.add(Ti.UI.createLabel({
    text: '❤️', font: { fontSize: 40 },
    width: Ti.UI.SIZE, height: Ti.UI.SIZE,
    left: 20, top: 20
}));
win.add(likeButton);

likeButton.addEventListener('touchstart', function() {
    emitterView.emitImage({ sourceView: likeButton });
});

win.open();
```

### Example 2: Confetti Celebration (Native Shapes)

Continuous confetti using built-in shape generation — no images required.

```javascript
var confetti = emitterModule.createView({
    width: Ti.UI.FILL, height: Ti.UI.FILL,
    particleType: emitterModule.PARTICLE_CONFETTI,
    direction: emitterModule.DIRECTION_DOWN,
    intensity: 0.8,
    colors: ['#FF6B6B', '#4ECDC4', '#FFE66D', '#A8E6CF', '#FF8B94'],
    velocity: 400, velocityRange: 120,
    spin: 360, spinRange: 180,
    autoStopDuration: 5
});
win.add(confetti);

celebrateButton.addEventListener('click', function() {
    confetti.start();
});
```

### Example 3: Star Shower with Play/Pause/Stop Controls

Full animation lifecycle management.

```javascript
var starEmitter = emitterModule.createView({
    width: Ti.UI.FILL, height: Ti.UI.FILL,
    particleType: emitterModule.PARTICLE_STAR,
    direction: emitterModule.DIRECTION_DOWN,
    intensity: 0.6,
    colors: ['#FFD700', '#FFF8DC', '#FFFFE0', '#F0E68C'],
    velocity: 300, velocityRange: 60,
    spin: 180, spinRange: 90,
    amplitude: 4, maxAmplitude: 8
});
win.add(starEmitter);

startButton.addEventListener('click', function() {
    if (!starEmitter.isActive()) starEmitter.start();
});

pauseButton.addEventListener('click', function() {
    if (starEmitter.isActive()) starEmitter.pause();
    else starEmitter.resume();
});

stopButton.addEventListener('click', function() {
    starEmitter.stop();
});
```

### Example 4: Text Particle Spell

Spell out words with individual character particles.

```javascript
var textEmitter = emitterModule.createView({
    width: Ti.UI.FILL, height: Ti.UI.FILL,
    particleType: emitterModule.PARTICLE_TEXT,
    text: 'MAGIC',
    fontSize: 32,
    direction: emitterModule.DIRECTION_UP,
    intensity: 0.4,
    colors: ['#FF69B4', '#FF1493', '#DB7093', '#FFB6C1'],
    velocity: 250, velocityRange: 50,
    spin: 720, spinRange: 360,
    autoStopDuration: 8
});
win.add(textEmitter);

castSpellButton.addEventListener('click', function() {
    textEmitter.start();
});
```

### Example 5: Diamond Wind Effect

Horizontal particle stream from right to left.

```javascript
var diamondEmitter = emitterModule.createView({
    width: Ti.UI.FILL, height: Ti.UI.FILL,
    particleType: emitterModule.PARTICLE_DIAMOND,
    direction: emitterModule.DIRECTION_LEFT,
    intensity: 0.7,
    colors: ['#00CED1', '#20B2AA', '#3CB371', '#48D1CC'],
    velocity: 500, velocityRange: 100,
    amplitude: 3, maxAmplitude: 6,
    duration: 2.0, maxDuration: 2.5
});
win.add(diamondEmitter);
diamondEmitter.start();
```

### Example 6: Triangle Rain with Auto-Remove

Self-cleaning emitter view.

```javascript
var triangleEmitter = emitterModule.createView({
    width: Ti.UI.FILL, height: Ti.UI.FILL,
    particleType: emitterModule.PARTICLE_TRIANGLE,
    direction: emitterModule.DIRECTION_DOWN,
    intensity: 0.9,
    colors: ['#87CEEB', '#B0E0E6', '#ADD8E6', '#E0FFFF'],
    velocity: 600, velocityRange: 150,
    amplitude: 1, maxAmplitude: 3,
    autoRemove: true   // removes itself from parent on stop()
});

var container = Ti.UI.createView({ width: Ti.UI.FILL, height: Ti.UI.FILL });
container.add(triangleEmitter);
win.add(container);

rainButton.addEventListener('click', function() {
    triangleEmitter.start();
});
```

### Example 7: Dynamic Emoji Particles (Legacy Mode)

Generate particle images from emoji labels at runtime.

```javascript
var emojis = ['❤️', '🧡', '💛', '💚', '💙', '💜'];
var particleImages = emojis.map(function(emoji) {
    return Ti.UI.createLabel({
        text: emoji, font: { fontSize: 30 }
    }).toImage();
});

var emitterView = emitterModule.createView({
    width: Ti.UI.FILL, height: Ti.UI.FILL,
    particleType: emitterModule.PARTICLE_CUSTOM,
    direction: emitterModule.DIRECTION_UP,
    particleImages: particleImages
});
win.add(emitterView);

likeButton.addEventListener('click', function() {
    emitterView.emitImage({ sourceView: likeButton });
});
```

### Example 8: Continuous Celebration with Auto-Stop

Self-limiting celebration effect.

```javascript
var celebration = emitterModule.createView({
    width: Ti.UI.FILL, height: Ti.UI.FILL,
    particleType: emitterModule.PARTICLE_CONFETTI,
    direction: emitterModule.DIRECTION_DOWN,
    intensity: 1.0,
    colors: ['#FF0000', '#FF7F00', '#FFFF00', '#00FF00', '#0000FF', '#4B0082', '#9400D3'],
    velocity: 450, velocityRange: 150,
    spin: 720, spinRange: 360,
    autoStopDuration: 10
});
win.add(celebration);
celebration.start();
```

### Example 9: Selective Image Emission (Legacy)

Fine-grained control over which images are emitted.

```javascript
var customEmitter = emitterModule.createView({
    width: Ti.UI.FILL, height: Ti.UI.FILL,
    particleImages: ['/images/star.png', '/images/heart.png', '/images/diamond.png'],
    direction: emitterModule.DIRECTION_UP
});
win.add(customEmitter);

// Emit a specific image (1-based index)
customEmitter.emitImage({ sourceView: button, id: 1 });

// Random from a range
customEmitter.emitImage({ sourceView: button, startId: 2, endId: 3 });

// Random from entire array
customEmitter.emitImage({ sourceView: button });
```

### Example 10: Multi-Direction Burst

Create an explosive effect with particles in all directions simultaneously.

```javascript
var emitters = [];
[0, 1, 2, 3].forEach(function(dir) {
    var emitter = emitterModule.createView({
        width: Ti.UI.FILL, height: Ti.UI.FILL,
        particleType: emitterModule.PARTICLE_CONFETTI,
        direction: dir,
        intensity: 0.8,
        colors: ['#FF6B6B', '#4ECDC4', '#FFE66D'],
        velocity: 500, velocityRange: 100,
        spin: 360, spinRange: 180
    });
    win.add(emitter);
    emitters.push(emitter);
});

burstButton.addEventListener('click', function() {
    emitters.forEach(function(e) { e.start(); });
    setTimeout(function() {
        emitters.forEach(function(e) { e.stop(); });
    }, 3000);
});
```

---

## Platform-Specific Internals

### iOS

| Feature | Implementation Detail |
|---------|----------------------|
| **Animation Engine** | Core Animation — `CAEmitterLayer` with `CAEmitterCell` for continuous mode; `CAKeyframeAnimation` + `CABasicAnimation` for burst mode (`emitImage`) |
| **Emission Driver** | `CAEmitterLayer` birth rate (hardware-accelerated, GPU-driven) |
| **Shape Generation** | `UIGraphicsImageRenderer` — modern, thread-safe API. Generates vector shapes as `UIImage` at the device's native scale. |
| **Frame Rate** | 60fps baseline; 120fps on ProMotion displays (via `traitCollection.displayScale`) |
| **Image Caching** | `NSCache` with a limit of 50 entries for loaded particle images |
| **Text Rendering** | `NSAttributedString` with configurable `UIFont` |
| **Memory Management** | Proper layer cleanup in `dealloc`; animations removed via `CATransaction` completion blocks |
| **Display Scaling** | Uses `traitCollection.displayScale` — no deprecated `UIScreen.mainScreen.scale` API |
| **Minimum iOS** | 12.0+ |

### Android

| Feature | Implementation Detail |
|---------|----------------------|
| **Animation Engine** | Property Animators (`ObjectAnimator`, `AnimatorSet`) for translation, rotation, scale, and alpha |
| **Emission Driver** | `Choreographer.FrameCallback` — vsync-synced emission loop, called once per display refresh |
| **Hardware Acceleration** | `LAYER_TYPE_HARDWARE` on all particle `ImageView` instances for GPU compositing |
| **Shape Generation** | Native Android `Canvas`, `Path`, and `Paint` APIs. Bitmaps created at device density resolution. |
| **View Pooling** | Object pool of 30 `ImageView` instances — reused across emission cycles to minimize GC pressure |
| **Random Number Generation** | `ThreadLocalRandom` — zero-allocation, thread-safe PRNG (no `java.util.Random` overhead) |
| **Particle Cap** | Hard limit of 200 concurrent particles — prevents OOM on extended emission |
| **Bitmap Recycling** | All generated bitmaps are recycled in `cleanup()` |
| **Minimum Android** | API 21+ (5.0 Lollipop) |

---

## Performance Best Practices

### ✅ Do

1. **Prefer native shapes (types 1–5)** — They avoid image loading, decoding, and caching overhead entirely. Shapes are rendered as small vector bitmaps once and reused.
2. **Pre-generate custom images at startup** — Create all `particleImages` once when the app launches; never in event handlers.
3. **Use small image dimensions** — 32×32 to 64×64 pixels is the sweet spot. Larger images increase memory pressure and GPU texture costs.
4. **Reuse emitter instances** — Create the view once, then call `start()`/`stop()` as needed. Do not recreate the emitter for each emission cycle.
5. **Tune intensity appropriately** — Use 0.2–0.4 for ambient effects, 0.7–1.0 for celebrations. Higher intensity = more particles per frame = more CPU/GPU work.
6. **Use `touchstart` instead of `click`** — For burst emission (`emitImage`), `touchstart` fires earlier and provides a more responsive user experience.
7. **Enable `autoRemove` for one-shot effects** — If an emitter is only needed once, let it clean itself up automatically.
8. **Limit color array size** — Keep `colors` under 10 entries. Each color creates a separate emitter cell / bitmap, increasing memory usage.

### ❌ Don't

1. **Don't use large images** — 200×200+ pixel particle images cause significant performance degradation and memory pressure.
2. **Don't emit in tight loops** — Avoid `for` loops calling `emitImage()` rapidly. Use `setTimeout` or requestAnimationFrame for staggered emissions.
3. **Don't recreate the emitter view** — Creating new views in event handlers causes memory leaks and GC spikes. Create once, reuse always.
4. **Don't modify `particleImages` at runtime** — The array is processed during initialization. Changes after creation may not take effect.
5. **Don't exceed 200 concurrent particles** — The cap exists for a reason. High intensity + long lifetime combinations can cause frame drops.
6. **Don't use excessive spin values** — Rotation animation is computationally expensive. Values above 720 degrees per particle can impact performance on lower-end devices.

---

## Troubleshooting

### Particles don't appear

- **Check view dimensions:** The emitter must have non-zero width and height. Use `width: Ti.UI.FILL, height: Ti.UI.FILL` or explicit pixel values.
- **Verify `particleType`:** For types 1–5, ensure `colors` is a valid array of hex strings. For type 0 (`PARTICLE_CUSTOM`), ensure `particleImages` is populated.
- **For text particles:** Ensure `text` is non-empty and `particleType` is set to `PARTICLE_TEXT` (5).
- **Call `start()`:** Properties alone don't trigger emission. You must call `emitterView.start()` for continuous mode or `emitterView.emitImage(...)` for burst mode.
- **Z-order:** Ensure the emitter view is added after other content so particles render on top, or check that it's not obscured by sibling views.

### Particles appear distorted or blurry

- **Image resolution:** Use images sized appropriately for device pixel density. iOS handles `contentsScale` automatically; Android uses density-aware bitmap generation.
- **Shape rendering:** Native shapes are generated at the correct scale automatically — distortion is unlikely with types 1–5.
- **Scaling transforms:** Avoid applying `scaleX`/`scaleY` to the emitter view itself, as this can distort particle rendering.

### Performance issues or frame drops

- **Reduce `intensity`:** Lower values mean fewer particles per frame.
- **Shorten `lifetime`:** Particles that live shorter spend less time on screen simultaneously.
- **Reduce `maxAmplitude`:** Simpler sway paths are cheaper to animate.
- **Lower `spin` values:** Rotation is one of the most expensive animation properties.
- **Use fewer images:** Each unique image in `particleImages` adds memory and texture overhead.
- **Profile on device:** Simulator performance doesn't reflect real-world behavior, especially on Android.

### Memory warnings

- **Reduce `particleImages` count:** Fewer images = less memory.
- **Use native shapes:** Types 1–5 generate tiny vector bitmaps (8×8 to 16×16 pixels) instead of loading full image files.
- **Avoid runtime image creation:** Never call `.toImage()` or `Ti.UI.createImage()` inside event handlers.
- **Use `autoRemove: true`:** Ensures the view and all its resources are released after use.

### Animation control not working as expected

- **Call order matters:** `start()` must be called before `pause()`, `resume()`, or `stop()`. Calling them in the wrong order is a no-op.
- **Check `isActive()`:** Use this to verify the current state before calling control methods.
- **`autoStopDuration` overrides manual control:** If set, the timer will call `stop()` automatically regardless of other interactions.
- **`emitImage()` uses a different code path:** It doesn't interact with `start()`/`stop()` state. Burst emission always works independently.

---

## Requirements

| Platform | Minimum Version |
|----------|----------------|
| **iOS** | 12.0+ |
| **Android** | API 21+ (5.0 Lollipop) |
| **Titanium SDK** | 10.1.0+ |

---

## Changelog

### 2026-06-06 — RainConfetti Integration

- **Added:** Particle types: confetti, triangle, star, diamond, text (native shape generation)
- **Added:** `intensity` (0.0–1.0) for birth rate control
- **Added:** `colors` array for custom color palettes
- **Added:** `velocity` / `velocityRange` for speed control
- **Added:** `spin` / `spinRange` for rotation
- **Added:** `text` / `fontSize` for text-based particles
- **Added:** Animation lifecycle: `start()`, `stop()`, `pause()`, `resume()`, `isActive()`
- **Added:** `autoStopDuration` and `autoRemove` properties
- **Added:** `scaleRange`, `scaleSpeed`, `emissionRange`, `lifetime` properties
- **iOS:** Modernized with `UIGraphicsImageRenderer`, `CAEmitterLayer` architecture
- **Android:** `Choreographer`-driven emission, View pooling (30 instances), `ThreadLocalRandom`
- **Both:** iOS 26.0 ready, hardware acceleration, zero deprecated APIs

### 2026-06-05

- **iOS:** Optimized for ProMotion displays (120Hz support)
- **iOS:** Replaced deprecated `UIScreen.mainScreen` with `traitCollection.displayScale`
- **iOS:** Fixed path calculation bug in bezier curve animation
- **Android:** Complete rewrite using Property Animators (`ObjectAnimator`)
- **Android:** Added ImageView pooling (30 views) for memory efficiency
- **Both:** Added `direction` property (0=up, 1=down, 2=left, 3=right)
- **Documentation:** Comprehensive examples and API reference

---

## License

**MIT License**

Copyright (c) 2017–2026 Marc Bender

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

## Credits & Attribution

This module is built on the foundation of **[RainConfetti](https://github.com/linghugoogle/RainConfetti)** by [linghugoogle](https://github.com/linghugoogle).

RainConfetti is a Swift-based particle emitter library for iOS that introduced the concept of intensity-driven birth rates, native shape generation (confetti, triangles, stars, diamonds), text particles, and velocity/spin physics. The following aspects were ported from RainConfetti:

- **Shape generation algorithms** — confetti, triangle, star, diamond vector rendering
- **Emission physics model** — intensity-based birth rate, velocity variance, spin dynamics
- **Text particle system** — per-character rendering with color cycling
- **Animation architecture** — `CAEmitterLayer` / `CAEmitterCell` configuration patterns (iOS)
- **Property design** — the entire property surface (`intensity`, `velocityRange`, `spinRange`, `scaleSpeed`, etc.)

The Android implementation was built from scratch using Android-native APIs (`Choreographer`, `ObjectAnimator`, View pooling) to match the RainConfetti behavior on a platform that originally had no reference code.

RainConfetti is available under the [MIT License](https://github.com/linghugoogle/RainConfetti/blob/main/LICENSE).

## Author

**Marc Bender**

- Module ID: `de.marcbender.emitterview`
- Platforms: iOS 12.0+, Android 5.0+
