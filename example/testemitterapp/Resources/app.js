/**
 * titanium-emitterview — RainConfetti Demo App
 *
 * Demonstrates all particle types with animation lifecycle control
 */

var emitterViewModule = require('de.marcbender.emitterview');

var win = Ti.UI.createWindow({
    title: 'Rain Confetti Demo',
    backgroundColor: '#1a1a2e'
});

// ── Header Label ──────────────────────────────────────────
var headerLabel = Ti.UI.createLabel({
    text: 'Rain Confetti Demo',
    color: '#fff',
    font: { fontSize: 24, fontWeight: 'bold' },
    textAlign: 'center',
    top: 40,
    width: Ti.UI.FILL,
    height: Ti.UI.SIZE
});
win.add(headerLabel);

// ── Emitter View (fullscreen overlay) ────────────────────
var emitterView = emitterViewModule.createView({
    top: 0, left: 0, right: 0, bottom: 0,
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: emitterViewModule.PARTICLE_CONFETTI,
    direction: emitterViewModule.DIRECTION_DOWN,
    intensity: 0.7,
    velocity: 350,
    velocityRange: 80,
    spin: 360,
    spinRange: 180,
    scaleRange: 0.5,
    scaleSpeed: -0.05,
    lifetime: 7.0
});
win.add(emitterView);

// ── Button Container ─────────────────────────────────────
var buttonContainer = Ti.UI.createView({
    top: 100,
    width: Ti.UI.FILL - 40,
    height: Ti.UI.SIZE,
    layout: 'vertical',
    left: 20
});
win.add(buttonContainer);

// ── Button Factory ───────────────────────────────────────
function createButton(title, color, callback) {
    var button = Ti.UI.createView({
        width: Ti.UI.FILL,
        height: 50,
        backgroundColor: color,
        borderRadius: 10
    });

    var label = Ti.UI.createLabel({
        text: title,
        color: '#fff',
        font: { fontSize: 18, fontWeight: 'medium' },
        textAlign: 'center',
        width: Ti.UI.FILL,
        height: Ti.UI.SIZE,
        top: 0, bottom: 0
    });

    button.add(label);

    button.addEventListener('click', function () {
        button.animate({
            scale: 0.95,
            duration: 100
        }, function () {
            button.animate({
                scale: 1.0,
                duration: 100
            });
        });

        if (callback) callback();
    });

    return button;
}

// ── Particle Type Buttons ────────────────────────────────
var confettiButton = createButton('Confetti', '#007AFF', function () {
    emitterView.stop();
    emitterView.particleType = emitterViewModule.PARTICLE_CONFETTI;
    emitterView.direction = emitterViewModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF3B30', '#007AFF', '#34C759', '#FFCC00', '#AF52DE'];
    emitterView.intensity = 0.7;
    emitterView.velocity = 350;
    emitterView.velocityRange = 80;
    emitterView.start();
});
buttonContainer.add(confettiButton);

var triangleButton = createButton('Triangle', '#34C759', function () {
    emitterView.stop();
    emitterView.particleType = emitterViewModule.PARTICLE_TRIANGLE;
    emitterView.direction = emitterViewModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF9500', '#FF2D55', '#5AC8FA'];
    emitterView.intensity = 0.7;
    emitterView.start();
});
buttonContainer.add(triangleButton);

var starButton = createButton('Star', '#FFCC00', function () {
    emitterView.stop();
    emitterView.particleType = emitterViewModule.PARTICLE_STAR;
    emitterView.direction = emitterViewModule.DIRECTION_DOWN;
    emitterView.colors = ['#FFCC00', '#FF9500', '#FF3B30'];
    emitterView.intensity = 0.7;
    emitterView.start();
});
buttonContainer.add(starButton);

var diamondButton = createButton('Diamond', '#AF52DE', function () {
    emitterView.stop();
    emitterView.particleType = emitterViewModule.PARTICLE_DIAMOND;
    emitterView.direction = emitterViewModule.DIRECTION_DOWN;
    emitterView.colors = ['#007AFF', '#AF52DE', '#5856D6'];
    emitterView.intensity = 0.7;
    emitterView.start();
});
buttonContainer.add(diamondButton);

var textButton = createButton('Text "HAPPY"', '#FF2D55', function () {
    emitterView.stop();
    emitterView.particleType = emitterViewModule.PARTICLE_TEXT;
    emitterView.text = 'HAPPY';
    emitterView.direction = emitterViewModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF3B30', '#FFCC00', '#007AFF'];
    emitterView.intensity = 0.7;
    emitterView.start();
});
buttonContainer.add(textButton);

// ── Direction Buttons ────────────────────────────────────
var upButton = createButton('Up (from bottom)', '#5AC8FA', function () {
    emitterView.stop();
    emitterView.particleType = emitterViewModule.PARTICLE_CONFETTI;
    emitterView.direction = emitterViewModule.DIRECTION_UP;
    emitterView.colors = ['#FF3B30', '#007AFF', '#34C759', '#FFCC00', '#AF52DE'];
    emitterView.intensity = 0.7;
    emitterView.start();
});
buttonContainer.add(upButton);

// ── Stop Button ──────────────────────────────────────────
var stopButton = createButton('Stop', '#FF3B30', function () {
    emitterView.stop();
});
buttonContainer.add(stopButton);

// ── Info Label ───────────────────────────────────────────
var infoLabel = Ti.UI.createLabel({
    text: 'Tap a button to start particles.\nTap Stop to end the animation.',
    color: '#8e8e93',
    font: { fontSize: 14 },
    textAlign: 'center',
    bottom: 40,
    width: Ti.UI.FILL - 40,
    height: Ti.UI.SIZE
});
win.add(infoLabel);

// ── Open Window ──────────────────────────────────────────
win.open();