# titanium-emitterview Module

## Description

A cross-platform Titanium module for creating beautiful particle emission effects. Particles are emitted from a source view and float in the configured direction with natural sinusoidal sway animations.

Common use cases:
- Social media "Like" reactions (hearts floating up)
- Celebration effects (confetti)
- Weather effects (rain, snow)
- Ambient particle backgrounds

## Accessing the Module

```javascript
var emitterModule = require('de.marcbender.emitterview');
```

## Reference

### `createView(properties)`

Creates a new emitter view that can be added to any window or view.

**Parameters:**

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `amplitude` | Number | No | 8 | Minimum horizontal/vertical sway in pixels |
| `maxAmplitude` | Number | No | 14 | Maximum horizontal/vertical sway in pixels |
| `duration` | Number | No | 3.0 | Minimum animation duration in seconds |
| `maxDuration` | Number | No | 3.5 | Maximum animation duration in seconds |
| `direction` | Number | No | 0 | Emission direction (see Direction Constants) |
| `particleImages` | Array | Yes | - | Array of image paths, Ti.Blob, or Ti.Filesystem.File objects |

**Returns:** `Ti.UI.View` - The emitter view instance

### `emitImage(options)`

Emits a single particle from the source view.

**Parameters:**

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `sourceView` | Ti.UI.View | Yes | - | The view to emit particles from |
| `id` | Number | No | - | Specific image to emit (1-based index from particleImages) |
| `startId` | Number | No | - | Start of random image range (1-based) |
| `endId` | Number | No | - | End of random image range (1-based) |

**Returns:** `void`

### Direction Constants

| Value | Name | Description |
|-------|------|-------------|
| 0 | `UP` | Particles float upward (default) |
| 1 | `DOWN` | Particles fall downward |
| 2 | `LEFT` | Particles move left |
| 3 | `RIGHT` | Particles move right |

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
```

## Platform Notes

### iOS
- Uses Core Animation (CAKeyframeAnimation) for smooth 60fps
- Maximum 100 concurrent particles
- Images are cached using NSCache
- Path generation optimized to 40 key points

### Android
- Uses AnimationSet with TranslateAnimation and AlphaAnimation
- Maximum 100 concurrent particles
- Images loaded via TiDrawableReference
- View hierarchy managed via RelativeLayout

## Performance Tips

1. **Reuse images**: Pre-generate particle images and store in an array
2. **Limit concurrent particles**: The module caps at 100 particles by default
3. **Use small images**: Larger images consume more memory and CPU
4. **Direction matters**: Up/down animations are more performant than left/right
5. **Batch emissions**: Rapid tap events are handled efficiently

## Author

Marc Bender

## License

MIT
