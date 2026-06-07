# RainConfetti Feature Integration Plan

## Overview

Integrate features from [RainConfetti](https://github.com/linghugoogle/RainConfetti) into titanium-emitterview for enhanced particle effects.

---

## New Properties

### Core Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `mode` | String | `'layer'` | `'layer'` (current) or `'emitter'` (CAEmitterLayer on iOS) |
| `particleType` | String | `'custom'` | `'confetti'`, `'triangle'`, `'star'`, `'diamond'`, `'text'`, `'custom'` |
| `intensity` | Number | `0.5` | Particle birth rate (0.0-1.0) |
| `colors` | Array | `[]` | Array of color hex strings for multi-color particles |
| `text` | String | `''` | Text to use as particles (each character = one particle) |
| `font` | Object | `{}` | `{ fontSize: 24, fontFamily: 'Arial', fontWeight: 'bold' }` |
| `velocity` | Number | `350` | Particle fall speed |
| `velocityRange` | Number | `80` | Random velocity variation |
| `spin` | Number | `0` | Rotation speed (degrees per second) |
| `spinRange` | Number | `0` | Random rotation variation |
| `duration` | Number | `0` | Auto-stop duration in seconds (0 = never stop) |
| `autoRemove` | Boolean | `false` | Remove view from parent after duration |

### Animation Methods

| Method | Description |
|--------|-------------|
| `start()` | Start/confetti emission |
| `stop()` | Stop emission |
| `pause()` | Pause animation |
| `resume()` | Resume animation |
| `isActive()` | Returns true if currently emitting |

---

## Implementation Phases

### Phase 1: Core Properties (iOS + Android)

- [x] Add `intensity` property (controls birth rate)
- [x] Add `colors` array property
- [x] Add `spin` and `spinRange` for rotation
- [x] Add `velocity` and `velocityRange`
- [x] Add `duration` for auto-stop

### Phase 2: Particle Types (iOS + Android)

- [x] Add `particleType` enum
- [x] Generate built-in shapes programmatically:
  - `confetti` — rectangular with random aspect ratio
  - `triangle` — isosceles triangle
  - `star` — 5-pointed star
  - `diamond` — rhombus shape
- [x] Use shapes when `particleType` != `'custom'`

### Phase 3: Text Particles (iOS + Android)

- [x] Add `text` property
- [x] Add `font` property
- [x] Split text into individual characters
- [x] Each character = one particle with independent animation
- [x] Support emoji and Unicode

### Phase 4: Animation Control (iOS + Android)

- [x] Add `start()` method
- [x] Add `stop()` method
- [x] Add `pause()` method
- [x] Add `resume()` method
- [x] Add `isActive()` method
- [x] Add `autoRemove` property

### Phase 5: Documentation + Examples

- [x] Update README with new properties
- [x] Add comprehensive examples
- [x] Update API documentation

---

## Platform Notes

### iOS
- Uses `CAEmitterLayer` + `CAEmitterCell` for emitter mode
- Built-in shapes drawn with `UIGraphicsImageRenderer`
- Text particles use `NSAttributedString`

### Android
- Uses `ObjectAnimator` + View Pooling (already optimized)
- Built-in shapes drawn with `Bitmap` + `Canvas` + `Paint`
- Text particles use `Paint` + `StaticLayout`

---

## Example Usage

```javascript
var emitterModule = require('de.marcbender.emitterview');

// Classic confetti with colors
var confetti = emitterModule.createView({
    particleType: 'confetti',
    colors: ['#ff0000', '#00ff00', '#0000ff', '#ffff00'],
    intensity: 0.7,
    velocity: 400,
    spin: 5,
    spinRange: 3,
    duration: 5.0
});

win.add(confetti);
confetti.start();

// Text confetti
var textEmitter = emitterModule.createView({
    particleType: 'text',
    text: '🎉🎊🥳🎈',
    font: { fontSize: 32 },
    intensity: 0.5,
    duration: 3.0
});

win.add(textEmitter);
textEmitter.start();

// Star shower
var stars = emitterModule.createView({
    particleType: 'star',
    colors: ['#ffd700', '#ff6b6b', '#4ecdc4'],
    intensity: 0.8,
    velocity: 500,
    spin: 10
});

win.add(stars);
stars.start();

// Animation control
setTimeout(function() {
    confetti.pause();
}, 2000);

setTimeout(function() {
    confetti.resume();
}, 4000);
```

---

## Status: ✅ COMPLETE

All phases implemented and tested on iOS and Android.
