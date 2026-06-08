/**
 * titanium-emitterview — Complete Feature Demo App
 * 
 * Demonstrates ALL features of the particle emitter module.
 */

var emitterModule = require('de.marcbender.emitterview');

// ── Window Setup ─────────────────────────────────────────
var win = Ti.UI.createWindow({
    title: 'Emitter View Demo',
    backgroundColor: '#0a0a15'
});

// ── Header ───────────────────────────────────────────────
var headerLabel = Ti.UI.createLabel({
    text: 'EMITTER VIEW DEMO',
    color: '#ffffff',
    font: { fontSize: 28, fontWeight: 'bold' },
    textAlign: 'center',
    top: 20,
    width: Ti.UI.FILL,
    height: Ti.UI.SIZE
});
win.add(headerLabel);

var statusLabel = Ti.UI.createLabel({
    text: 'Status: Ready',
    color: '#4ecdc4',
    font: { fontSize: 16 },
    textAlign: 'center',
    top: 55,
    width: Ti.UI.FILL,
    height: Ti.UI.SIZE
});
win.add(statusLabel);

// ── Global Arrays for Temporary Emitters ────────────────
var multiDirectionEmitters = [];  // Track explosion emitters
var tempEmitters = [];            // Track auto-remove emitters

// ── Emitter View (fullscreen overlay) ────────────────────
var emitterView = emitterModule.createView({
    top: 0, left: 0, right: 0, bottom: 0,
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    particleType: emitterModule.PARTICLE_CONFETTI,
    direction: emitterModule.DIRECTION_DOWN,
    intensity: 0.7,
    velocity: 350,
    velocityRange: 80,
    spin: 360,
    spinRange: 180,
    scaleRange: 0.5,
    scaleSpeed: -0.05,
    lifetime: 7.0,
    amplitude: 8,
    maxAmplitude: 14
});
win.add(emitterView);

// ── Scrollable Container for Buttons ─────────────────────
var scroll = Ti.UI.createScrollView({
    top: 90,
    bottom: 0,
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    contentWidth: Ti.UI.FILL,
    contentHeight: 2000,
    showsVerticalScrollIndicator: true
});
win.add(scroll);

var buttonContainer = Ti.UI.createView({
    width: Ti.UI.FILL - 30,
    height: Ti.UI.SIZE,
    layout: 'vertical',
    left: 15,
    right: 15
});
scroll.add(buttonContainer);

// ── Button Factory ───────────────────────────────────────
function createButton(title, color) {
    var button = Ti.UI.createView({
        width: Ti.UI.FILL,
        height: 48,
        backgroundColor: color,
        borderRadius: 8,
        top: 8
    });

    var label = Ti.UI.createLabel({
        text: title,
        color: '#ffffff',
        font: { fontSize: 16, fontWeight: 'medium' },
        textAlign: 'center',
        width: Ti.UI.FILL,
        height: Ti.UI.SIZE,
        top: 0, bottom: 0
    });

    button.add(label);

    button.addEventListener('click', function(e) {
        button.animate({ scale: 0.95, duration: 80 }, function() {
            button.animate({ scale: 1.0, duration: 80 });
        });
    });

    return button;
}

function createSectionTitle(text) {
    var title = Ti.UI.createLabel({
        text: text,
        color: '#ffffff',
        font: { fontSize: 20, fontWeight: 'bold' },
        textAlign: 'left',
        top: 16,
        left: 0,
        width: Ti.UI.FILL,
        height: Ti.UI.SIZE
    });
    return title;
}

// ── SECTION: Particle Types ──────────────────────────────
buttonContainer.add(createSectionTitle('PARTICLE TYPES'));

var confettiButton = createButton('Confetti (Rectangles)', '#007AFF');
buttonContainer.add(confettiButton);
confettiButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_CONFETTI;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF3B30', '#007AFF', '#34C759', '#FFCC00', '#AF52DE'];
    emitterView.intensity = 0.7;
    emitterView.velocity = 350;
    emitterView.start();
    statusLabel.text = 'Status: Confetti particles falling';
});

var triangleButton = createButton('Triangle', '#34C759');
buttonContainer.add(triangleButton);
triangleButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_TRIANGLE;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF9500', '#FF2D55', '#5AC8FA'];
    emitterView.intensity = 0.7;
    emitterView.start();
    statusLabel.text = 'Status: Triangle particles falling';
});

var starButton = createButton('Star (5-point)', '#FFCC00');
buttonContainer.add(starButton);
starButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_STAR;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FFCC00', '#FF9500', '#FF3B30', '#FFFFFF'];
    emitterView.intensity = 0.7;
    emitterView.start();
    statusLabel.text = 'Status: Star particles falling';
});

var diamondButton = createButton('Diamond', '#AF52DE');
buttonContainer.add(diamondButton);
diamondButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_DIAMOND;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#007AFF', '#AF52DE', '#5856D6', '#9C75E8'];
    emitterView.intensity = 0.7;
    emitterView.start();
    statusLabel.text = 'Status: Diamond particles falling';
});

var textButton = createButton('Text "EMITTER"', '#FF2D55');
buttonContainer.add(textButton);
textButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_TEXT;
    emitterView.text = 'EMITTER';
    emitterView.fontSize = 36;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF3B30', '#FFCC00', '#007AFF', '#34C759', '#AF52DE'];
    emitterView.intensity = 0.5;
    emitterView.velocity = 250;
    emitterView.spin = 720;
    emitterView.start();
    statusLabel.text = 'Status: Text particles falling';
});

// ── SECTION: Directions ──────────────────────────────────
buttonContainer.add(createSectionTitle('DIRECTIONS'));

var upButton = createButton('Up (Social Media Like)', '#5AC8FA');
buttonContainer.add(upButton);
upButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_CONFETTI;
    emitterView.direction = emitterModule.DIRECTION_UP;
    emitterView.colors = ['#FF3B30', '#007AFF', '#34C759', '#FFCC00'];
    emitterView.intensity = 0.8;
    emitterView.velocity = 400;
    emitterView.start();
    statusLabel.text = 'Status: Particles rising (Like effect)';
});

var downButton = createButton('Down (Rain/Ceiling)', '#6B4C9F');
buttonContainer.add(downButton);
downButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_CONFETTI;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#87CEEB', '#B0E0E6', '#ADD8E6', '#E0FFFF'];
    emitterView.intensity = 0.6;
    emitterView.velocity = 500;
    emitterView.start();
    statusLabel.text = 'Status: Particles falling (Rain effect)';
});

var leftButton = createButton('Left (Wind)', '#FF8B94');
buttonContainer.add(leftButton);
leftButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_DIAMOND;
    emitterView.direction = emitterModule.DIRECTION_LEFT;
    emitterView.colors = ['#00CED1', '#20B2AA', '#3CB371', '#48D1CC'];
    emitterView.intensity = 0.7;
    emitterView.velocity = 600;
    emitterView.spin = 360;
    emitterView.start();
    statusLabel.text = 'Status: Particles moving left (Wind effect)';
});

var rightButton = createButton('Right (Wind)', '#FFE66D');
buttonContainer.add(rightButton);
rightButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_STAR;
    emitterView.direction = emitterModule.DIRECTION_RIGHT;
    emitterView.colors = ['#FFD700', '#FFF8DC', '#FFFFE0', '#F0E68C'];
    emitterView.intensity = 0.7;
    emitterView.velocity = 550;
    emitterView.spin = -360;
    emitterView.start();
    statusLabel.text = 'Status: Particles moving right (Wind effect)';
});

// ── SECTION: Intensity Levels ────────────────────────────
buttonContainer.add(createSectionTitle('INTENSITY LEVELS'));

var lowIntensityButton = createButton('Low Intensity (Subtle)', '#555555');
buttonContainer.add(lowIntensityButton);
lowIntensityButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_CONFETTI;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#888888', '#AAAAAA', '#CCCCCC'];
    emitterView.intensity = 0.2;
    emitterView.velocity = 300;
    emitterView.start();
    statusLabel.text = 'Status: Low intensity (ambient effect)';
});

var mediumIntensityButton = createButton('Medium Intensity', '#777777');
buttonContainer.add(mediumIntensityButton);
mediumIntensityButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_CONFETTI;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF6B6B', '#4ECDC4', '#FFE66D'];
    emitterView.intensity = 0.5;
    emitterView.velocity = 350;
    emitterView.start();
    statusLabel.text = 'Status: Medium intensity';
});

var highIntensityButton = createButton('High Intensity (Celebration)', '#FF3B30');
buttonContainer.add(highIntensityButton);
highIntensityButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_CONFETTI;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF3B30', '#007AFF', '#34C759', '#FFCC00', '#AF52DE', '#FF2D55'];
    emitterView.intensity = 1.0;
    emitterView.velocity = 450;
    emitterView.velocityRange = 150;
    emitterView.spin = 360;
    emitterView.spinRange = 180;
    emitterView.start();
    statusLabel.text = 'Status: High intensity (celebration!)';
});

// ── SECTION: Animation Control ───────────────────────────
buttonContainer.add(createSectionTitle('ANIMATION CONTROL'));

var startButton = createButton('START', '#34C759');
buttonContainer.add(startButton);
startButton.addEventListener('click', function(e) {
    emitterView.start();
    statusLabel.text = 'Status: Running';
});

var pauseButton = createButton('PAUSE', '#FF9500');
buttonContainer.add(pauseButton);
pauseButton.addEventListener('click', function(e) {
    emitterView.pause();
    statusLabel.text = 'Status: Paused';
});

var resumeButton = createButton('RESUME', '#007AFF');
buttonContainer.add(resumeButton);
resumeButton.addEventListener('click', function(e) {
    emitterView.resume();
    statusLabel.text = 'Status: Running (resumed)';
});

var stopButton = createButton('STOP', '#FF3B30');
buttonContainer.add(stopButton);
stopButton.addEventListener('click', function(e) {
    emitterView.stop();
    statusLabel.text = 'Status: Stopped';
});

// ── SECTION: Auto Features ───────────────────────────────
buttonContainer.add(createSectionTitle('AUTO FEATURES'));

var autoStopButton = createButton('Auto-Stop (5 seconds)', '#AF52DE');
buttonContainer.add(autoStopButton);
autoStopButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_CONFETTI;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF6B6B', '#4ECDC4', '#FFE66D', '#A8E6CF'];
    emitterView.intensity = 0.8;
    emitterView.autoStopDuration = 5;
    emitterView.start();
    statusLabel.text = 'Status: Auto-stop in 5 seconds...';
});

var autoRemoveButton = createButton('Auto-Remove (on stop)', '#5856D6');
buttonContainer.add(autoRemoveButton);
autoRemoveButton.addEventListener('click', function(e) {
    var tempEmitter = emitterModule.createView({
        top: 0, left: 0, right: 0, bottom: 0,
        width: Ti.UI.FILL,
        height: Ti.UI.FILL,
        particleType: emitterModule.PARTICLE_STAR,
        direction: emitterModule.DIRECTION_DOWN,
        colors: ['#FFD700', '#FFF8DC', '#FFFFE0'],
        intensity: 0.9,
        autoRemove: true
    });
    win.add(tempEmitter);
    tempEmitter.start();
    statusLabel.text = 'Status: Auto-remove emitter created';
    
    setTimeout(function() {
        tempEmitter.stop();
        statusLabel.text = 'Status: Emitter auto-removed';
    }, 3000);
});

// ── SECTION: Multi-Direction Burst ───────────────────────
buttonContainer.add(createSectionTitle('MULTI-DIRECTION BURST'));

var allDirectionsButton = createButton('EXPLOSION (All Directions)', '#FF2D55');
buttonContainer.add(allDirectionsButton);
allDirectionsButton.addEventListener('click', function(e) {
    emitterView.stop();
    
    // Clear any existing multi-direction emitters
    multiDirectionEmitters.forEach(function(emitter) {
        try { emitter.stop(); } catch(e) {}
    });
    multiDirectionEmitters = [];
    
    var directions = [
        emitterModule.DIRECTION_UP,
        emitterModule.DIRECTION_DOWN,
        emitterModule.DIRECTION_LEFT,
        emitterModule.DIRECTION_RIGHT
    ];
    
    directions.forEach(function(dir) {
        var newEmitter = emitterModule.createView({
            top: 0, left: 0, right: 0, bottom: 0,
            width: Ti.UI.FILL,
            height: Ti.UI.FILL,
            particleType: emitterModule.PARTICLE_CONFETTI,
            direction: dir,
            intensity: 0.8,
            colors: ['#FF3B30', '#007AFF', '#34C759', '#FFCC00'],
            velocity: 500,
            velocityRange: 100,
            spin: 360
        });
        win.add(newEmitter);
        multiDirectionEmitters.push(newEmitter);
    });
    
    multiDirectionEmitters.forEach(function(emitter) { emitter.start(); });
    statusLabel.text = 'Status: Multi-direction explosion!';
});

// Stop all multi-direction emitters
var stopMultiButton = Ti.UI.createView({
    width: Ti.UI.FILL,
    height: 48,
    backgroundColor: '#FF3B30',
    borderRadius: 8,
    top: 8
});
var stopMultiLabel = Ti.UI.createLabel({
    text: 'STOP EXPLOSION',
    color: '#ffffff',
    font: { fontSize: 16, fontWeight: 'medium' },
    textAlign: 'center',
    width: Ti.UI.FILL,
    height: Ti.UI.SIZE,
    top: 0, bottom: 0
});
stopMultiButton.add(stopMultiLabel);
buttonContainer.add(stopMultiButton);
stopMultiButton.addEventListener('click', function(e) {
    multiDirectionEmitters.forEach(function(emitter) {
        try { emitter.stop(); } catch(err) {}
    });
    multiDirectionEmitters = [];
    statusLabel.text = 'Status: Explosion stopped';
});

// ── SECTION: Physics & Effects ───────────────────────────
buttonContainer.add(createSectionTitle('PHYSICS & EFFECTS'));

var highSpinButton = createButton('High Spin (Rapid Rotation)', '#FFCC00');
buttonContainer.add(highSpinButton);
highSpinButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_STAR;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FFD700', '#FFF8DC', '#FFFFE0'];
    emitterView.intensity = 0.6;
    emitterView.spin = 1440;
    emitterView.spinRange = 360;
    emitterView.start();
    statusLabel.text = 'Status: High spin effect';
});

var lowSwayButton = createButton('Low Sway (Straight Path)', '#5AC8FA');
buttonContainer.add(lowSwayButton);
lowSwayButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_TRIANGLE;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF9500', '#FF2D55', '#5AC8FA'];
    emitterView.intensity = 0.7;
    emitterView.amplitude = 2;
    emitterView.maxAmplitude = 4;
    emitterView.start();
    statusLabel.text = 'Status: Low sway (straight path)';
});

var highSwayButton = createButton('High Sway (Wide Wobble)', '#FF8B94');
buttonContainer.add(highSwayButton);
highSwayButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_DIAMOND;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#00CED1', '#20B2AA', '#3CB371'];
    emitterView.intensity = 0.7;
    emitterView.amplitude = 15;
    emitterView.maxAmplitude = 25;
    emitterView.start();
    statusLabel.text = 'Status: High sway (wide wobble)';
});

var longLifetimeButton = createButton('Long Lifetime (8s)', '#AF52DE');
buttonContainer.add(longLifetimeButton);
longLifetimeButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_STAR;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FFD700', '#FF9500', '#FF3B30'];
    emitterView.intensity = 0.4;
    emitterView.lifetime = 8.0;
    emitterView.velocity = 200;
    emitterView.start();
    statusLabel.text = 'Status: Long lifetime particles';
});

// ── SECTION: Text Particles ──────────────────────────────
buttonContainer.add(createSectionTitle('TEXT PARTICLES'));

var textHappyButton = createButton('Text: HAPPY', '#FF2D55');
buttonContainer.add(textHappyButton);
textHappyButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_TEXT;
    emitterView.text = 'HAPPY';
    emitterView.fontSize = 40;
    emitterView.direction = emitterModule.DIRECTION_UP;
    emitterView.colors = ['#FF3B30', '#FFCC00', '#007AFF', '#34C759', '#AF52DE'];
    emitterView.intensity = 0.4;
    emitterView.velocity = 300;
    emitterView.spin = 720;
    emitterView.start();
    statusLabel.text = 'Status: Text particles (HAPPY)';
});

var textMagicButton = createButton('Text: MAGIC', '#AF52DE');
buttonContainer.add(textMagicButton);
textMagicButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_TEXT;
    emitterView.text = 'MAGIC';
    emitterView.fontSize = 48;
    emitterView.direction = emitterModule.DIRECTION_DOWN;
    emitterView.colors = ['#FF69B4', '#FF1493', '#DB7093', '#FFB6C1'];
    emitterView.intensity = 0.35;
    emitterView.velocity = 250;
    emitterView.spin = 1080;
    emitterView.start();
    statusLabel.text = 'Status: Text particles (MAGIC)';
});

var textWelcomeButton = createButton('Text: WELCOME', '#007AFF');
buttonContainer.add(textWelcomeButton);
textWelcomeButton.addEventListener('click', function(e) {
    emitterView.stop();
    emitterView.particleType = emitterModule.PARTICLE_TEXT;
    emitterView.text = 'WELCOME';
    emitterView.fontSize = 32;
    emitterView.direction = emitterModule.DIRECTION_UP;
    emitterView.colors = ['#007AFF', '#5AC8FA', '#B0E0E6', '#ADD8E6'];
    emitterView.intensity = 0.45;
    emitterView.velocity = 350;
    emitterView.start();
    statusLabel.text = 'Status: Text particles (WELCOME)';
});

// ── Footer Info ──────────────────────────────────────────
var footerLabel = Ti.UI.createLabel({
    text: 'titanium-emitterview v1.0.4',
    color: '#555555',
    font: { fontSize: 12 },
    textAlign: 'center',
    bottom: 10,
    width: Ti.UI.FILL,
    height: Ti.UI.SIZE
});
win.add(footerLabel);

// ── Open Window ──────────────────────────────────────────
win.open();
