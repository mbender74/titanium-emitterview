package de.marcbender.emitterview.layout;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Typeface;
import android.util.AttributeSet;
import android.util.FloatProperty;
import android.view.Choreographer;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Optimized particle emitter with RainConfetti-style features.
 * Supports: intensity, colors, velocity, spin, particle types, text particles, animation control.
 */
public class HeartEmitterView extends RelativeLayout {

    private static final String TAG = "HeartEmitterView";
    private static final int MAX_PARTICLES = 200;
    private static final int POOL_SIZE = 30;

    // Particle types
    public static final int PARTICLE_TYPE_CUSTOM    = 0;
    public static final int PARTICLE_TYPE_CONFETTI  = 1;
    public static final int PARTICLE_TYPE_TRIANGLE  = 2;
    public static final int PARTICLE_TYPE_STAR      = 3;
    public static final int PARTICLE_TYPE_DIAMOND   = 4;
    public static final int PARTICLE_TYPE_TEXT      = 5;

    // Direction
    public static final int DIRECTION_UP    = 0;
    public static final int DIRECTION_DOWN  = 1;
    public static final int DIRECTION_LEFT  = 2;
    public static final int DIRECTION_RIGHT = 3;

    // Configuration
    private int maxAmplitude = 14;
    private int amplitude = 8;
    private float duration = 3.0f;
    private float maxDuration = 3.5f;
    private int direction = DIRECTION_DOWN;
    private int particleType = PARTICLE_TYPE_CUSTOM;

    // RainConfetti-style properties
    private float intensity = 0.5f;
    private int[] colors = {
        Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW,
        Color.MAGENTA, 0xFFFFA500, 0xFF00FFFF
    };
    private float velocity = 350;
    private float velocityRange = 80;
    private float spin = 0;
    private float spinRange = 0;
    private float lifetime = 7.0f;
    private float scaleRange = 0.5f;
    private float scaleSpeed = -0.05f;
    private float emissionRange = 45.0f; // degrees

    // Text particles
    private String particleText = "";
    private float textFontSize = 24;
    private Typeface textTypeface = Typeface.DEFAULT_BOLD;

    // Auto-stop
    private float autoStopDuration = 0;
    private boolean autoRemove = false;

    // State
    private int currentCount = 0;
    private float density = 1.0f;
    private boolean isRunning = false;
    private boolean isPaused = false;

    // Position
    private float startOffsetY = 0;
    private float centerX = 0;
    private float bottomOffset = 0;
    private float buttonHeight = 0;

    // ImageView Pool
    private final ArrayList<ImageView> imageViewPool = new ArrayList<>(POOL_SIZE);
    private final ArrayList<Bitmap> generatedBitmaps = new ArrayList<>();
    private final ArrayList<Animator> activeAnimations = new ArrayList<>();

    // Choreographer for continuous emission
    private Choreographer choreographer;
    private Choreographer.FrameCallback frameCallback;

    public HeartEmitterView(Context context) {
        super(context);
        init(context);
    }

    public HeartEmitterView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public HeartEmitterView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        this.density = context.getResources().getDisplayMetrics().density;
        setWillNotDraw(false);
        choreographer = Choreographer.getInstance();
    }

    // Property setters
    public void maxAmplitude(int value) { this.maxAmplitude = value; }
    public void amplitude(int value) { this.amplitude = value; }
    public void duration(float value) { this.duration = value; }
    public void maxDuration(float value) { this.maxDuration = value; }
    public void direction(int value) { this.direction = Math.max(0, Math.min(3, value)); }
    public void particleType(int value) {
        this.particleType = Math.max(0, Math.min(5, value));
        generateParticleBitmaps();
    }

    public void intensity(float value) {
        this.intensity = Math.max(0f, Math.min(1f, value));
    }

    public void colors(int[] value) {
        if (value != null && value.length > 0) {
            this.colors = value;
            generateParticleBitmaps();
        }
    }

    public void velocity(float value) { this.velocity = value; }
    public void velocityRange(float value) { this.velocityRange = value; }
    public void spin(float value) { this.spin = value; }
    public void spinRange(float value) { this.spinRange = value; }
    public void lifetime(float value) { this.lifetime = value; }
    public void scaleRange(float value) { this.scaleRange = value; }
    public void scaleSpeed(float value) { this.scaleSpeed = value; }
    public void emissionRange(float value) { this.emissionRange = value; }

    public void particleText(String value) {
        this.particleText = value != null ? value : "";
        if (this.particleText.length() > 0) {
            this.particleType = PARTICLE_TYPE_TEXT;
        }
        generateParticleBitmaps();
    }

    public void textFontSize(float value) { this.textFontSize = value; }
    public void textTypeface(Typeface value) { this.textTypeface = value != null ? value : Typeface.DEFAULT_BOLD; }

    public void autoStopDuration(float value) { this.autoStopDuration = value; }
    public void autoRemove(boolean value) { this.autoRemove = value; }

    public void startOffset(float offsetY, float center) {
        this.startOffsetY = offsetY;
        this.centerX = center;
    }

    public void bottomOffset(float offsetBottom) { this.bottomOffset = offsetBottom; }
    public void buttonHeight(float height) { this.buttonHeight = height; }
    public void buttonViewElevation(float elevation) { /* Not needed */ }

    public float dpToPx(float dp) {
        return (dp * density + 0.5f);
    }

    // Control methods
    public void start() {
        if (isRunning) return;

        isRunning = true;
        isPaused = false;

        if (particleType != PARTICLE_TYPE_CUSTOM) {
            generateParticleBitmaps();
        }

        // Start frame callback for continuous emission
        frameCallback = new Choreographer.FrameCallback() {
            @Override
            public void doFrame(long frameTimeNanos) {
                if (!isPaused && !generatedBitmaps.isEmpty()) {
                    emitParticlesForFrame();
                }
                choreographer.postFrameCallback(this);
            }
        };
        choreographer.postFrameCallback(frameCallback);

        // Auto-stop timer
        if (autoStopDuration > 0) {
            postDelayed(new Runnable() {
                @Override
                public void run() {
                    stop();
                }
            }, (long)(autoStopDuration * 1000));
        }
    }

    public void stop() {
        if (!isRunning) return;

        isRunning = false;
        if (frameCallback != null) {
            choreographer.postFrameCallback(frameCallback);
        }

        if (autoRemove) {
            ((ViewGroup)getParent()).removeView(this);
        }
    }

    public void pause() {
        isPaused = true;
    }

    public void resume() {
        isPaused = false;
    }

    public boolean isActive() {
        return isRunning && !isPaused;
    }

    private void emitParticlesForFrame() {
        if (generatedBitmaps.isEmpty()) return;

        // Calculate birth rate based on intensity (particles per frame)
        int birthRate = Math.max(1, Math.round(intensity * 10));

        for (int i = 0; i < birthRate; i++) {
            if (currentCount >= MAX_PARTICLES) break;

            int idx = ThreadLocalRandom.current().nextInt(generatedBitmaps.size());
            Bitmap bitmap = generatedBitmaps.get(idx);
            emitParticle(bitmap, 0, 1);
        }
    }

    private void generateParticleBitmaps() {
        generatedBitmaps.clear();

        if (particleType == PARTICLE_TYPE_TEXT && particleText.length() > 0) {
            // Text mode: each character is a particle
            int colorCount = colors.length;
            for (int i = 0; i < particleText.length(); i++) {
                char character = particleText.charAt(i);
                int color = colors[i % colorCount];
                Bitmap bitmap = createTextBitmap(character, color);
                if (bitmap != null && !bitmap.isRecycled()) {
                    generatedBitmaps.add(bitmap);
                }
            }
        } else if (particleType != PARTICLE_TYPE_CUSTOM) {
            // Shape mode: generate colored shapes
            for (int color : colors) {
                Bitmap bitmap = createShapeBitmap(particleType, color);
                if (bitmap != null && !bitmap.isRecycled()) {
                    generatedBitmaps.add(bitmap);
                }
            }
        }
    }

    private Bitmap createShapeBitmap(int type, int color) {
        int size = (int)dpToPx(16);
        Bitmap bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(color);

        switch (type) {
            case PARTICLE_TYPE_CONFETTI:
                canvas.drawRect(0, size/3, size, 2*size/3, paint);
                break;

            case PARTICLE_TYPE_TRIANGLE:
                Path triangle = new Path();
                triangle.moveTo(size/2, 0);
                triangle.lineTo(size, size);
                triangle.lineTo(0, size);
                triangle.close();
                canvas.drawPath(triangle, paint);
                break;

            case PARTICLE_TYPE_STAR:
                Path star = new Path();
                float outerRadius = size / 2;
                float innerRadius = size / 5;
                float centerX = size / 2;
                float centerY = size / 2;
                star.moveTo(centerX, centerY - outerRadius);
                for (int i = 0; i < 5; i++) {
                    float outerAngle = -(float)Math.PI/2 + ((i * 2 * (float)Math.PI / 5));
                    float innerAngle = outerAngle + (float)Math.PI / 5;
                    star.lineTo(centerX + (float)Math.cos(outerAngle) * outerRadius, centerY + (float)Math.sin(outerAngle) * outerRadius);
                    star.lineTo(centerX + (float)Math.cos(innerAngle) * innerRadius, centerY + (float)Math.sin(innerAngle) * innerRadius);
                }
                star.close();
                canvas.drawPath(star, paint);
                break;

            case PARTICLE_TYPE_DIAMOND:
                Path diamond = new Path();
                diamond.moveTo(size/2, 0);
                diamond.lineTo(size, size/2);
                diamond.lineTo(size/2, size);
                diamond.lineTo(0, size/2);
                diamond.close();
                canvas.drawPath(diamond, paint);
                break;
        }

        return bitmap;
    }

    private Bitmap createTextBitmap(char character, int color) {
        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setTextSize(textFontSize * density);
        paint.setTypeface(textTypeface);
        paint.setColor(color);

        String text = String.valueOf(character);
        float textWidth = paint.measureText(text);
        int width = (int)(textWidth + 8);
        int height = (int)(textFontSize * density + 8);

        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        canvas.drawText(text, 4, textFontSize * density, paint);

        return bitmap;
    }

    public void emitImage(Bitmap bitmap) {
        if (bitmap == null) return;
        emitImage(bitmap, 1);
    }

    public void emitImage(Bitmap bitmap, int count) {
        emitImage(bitmap, count, 0, 0);
    }

    public void emitImage(Bitmap bitmap, int count, float spread) {
        emitImage(bitmap, count, spread, 0);
    }

    public void emitImage(Bitmap bitmap, int count, float spread, float scaleRange) {
        if (bitmap == null) return;
        int n = Math.max(1, count);
        for (int i = 0; i < n; i++) {
            float scale = (i == 0) ? 1.0f : 1.0f - scaleRange * ThreadLocalRandom.current().nextFloat();
            emitParticle(bitmap, spread, scale);
        }
    }

    private void emitParticle(Bitmap bitmap, float spread, float targetScale) {
        if (bitmap == null || bitmap.isRecycled()) return;
        if (currentCount >= MAX_PARTICLES) return;

        currentCount++;

        ImageView imageView = getImageViewFromPool();
        if (imageView == null) {
            imageView = createImageView();
        }

        int imageWidth = bitmap.getWidth();
        int imageHeight = bitmap.getHeight();
        imageView.setImageBitmap(bitmap);

        LayoutParams params = new LayoutParams(imageWidth, imageHeight);

        // Start position: use sourceView offset if set, otherwise random horizontal
        if (startOffsetY != 0 || centerX != 0) {
            // Explicit position — don't center horizontally
            params.addRule(ALIGN_PARENT_LEFT);
            params.addRule(ALIGN_PARENT_TOP);
            params.leftMargin = (int)(centerX - imageWidth / 2);
            params.topMargin = (int)(startOffsetY - imageHeight / 2);
        } else if (direction == DIRECTION_LEFT || direction == DIRECTION_RIGHT) {
            params.addRule(CENTER_HORIZONTAL);
            params.addRule(ALIGN_PARENT_TOP);
            params.leftMargin = 0;
            params.topMargin = ThreadLocalRandom.current().nextInt(Math.max(getHeight(), 1));
        } else {
            params.addRule(CENTER_HORIZONTAL);
            params.addRule(ALIGN_PARENT_TOP);
            params.leftMargin = ThreadLocalRandom.current().nextInt(Math.max(getWidth(), 1));
            params.topMargin = 0;
        }
        // Lateral spread: offset perpendicular to travel direction
        if (spread > 0) {
            float spreadPx = dpToPx(spread);
            if (direction == DIRECTION_UP || direction == DIRECTION_DOWN) {
                params.leftMargin += (int)(ThreadLocalRandom.current().nextFloat() * spreadPx * 2 - spreadPx);
            } else {
                params.topMargin += (int)(ThreadLocalRandom.current().nextFloat() * spreadPx * 2 - spreadPx);
            }
        }
        imageView.setLayoutParams(params);

        imageView.setAlpha(1.0f);
        imageView.setScaleX(0.3f);
        imageView.setScaleY(0.3f);
        imageView.setRotation(0);
        imageView.setVisibility(VISIBLE);

        addView(imageView);

        // Animation duration: use lifetime if set, otherwise duration..maxDuration range
        long animDuration;
        if (lifetime > 0) {
            animDuration = (long)(lifetime * 1000);
        } else {
            animDuration = ThreadLocalRandom.current().nextLong(
                (long)(duration * 1000),
                (long)(maxDuration * 1000) + 1
            );
        }
        animDuration = Math.max(1000, animDuration);

        // Calculate travel distance based on velocity
        float computedVelocity = velocity + ThreadLocalRandom.current().nextFloat() * velocityRange;
        float distance = computedVelocity * (animDuration / 1000.0f);

        float endX = 0;
        float endY = 0;
        switch (direction) {
            case DIRECTION_DOWN:
                endY = distance;
                break;
            case DIRECTION_UP:
                endY = -distance;
                break;
            case DIRECTION_LEFT:
                endX = -distance;
                break;
            case DIRECTION_RIGHT:
                endX = distance;
                break;
        }

        float swayAmount = dpToPx(amplitude + ThreadLocalRandom.current().nextInt(Math.max(maxAmplitude - amplitude + 1, 1)));

        AnimatorSet animatorSet = new AnimatorSet();

        // Scale: start small, grow to target scale
        ObjectAnimator scaleX = ObjectAnimator.ofFloat(imageView, "scaleX", 0.3f * targetScale, targetScale);
        scaleX.setDuration(animDuration * 3 / 4);
        ObjectAnimator scaleY = ObjectAnimator.ofFloat(imageView, "scaleY", 0.3f * targetScale, targetScale);
        scaleY.setDuration(animDuration * 3 / 4);

        // Position with sway
        ObjectAnimator translateX;
        ObjectAnimator translateY;

        if (direction == DIRECTION_UP || direction == DIRECTION_DOWN) {
            // Vertical: sway horizontally
            translateX = ObjectAnimator.ofFloat(imageView, "translationX",
                0f, swayAmount, -swayAmount, 0f, endX);
            translateY = ObjectAnimator.ofFloat(imageView, "translationY",
                0f, endY * 0.33f, endY * 0.66f, endY);
        } else {
            // Horizontal: sway vertically
            translateX = ObjectAnimator.ofFloat(imageView, "translationX",
                0f, endX * 0.33f, endX * 0.66f, endX);
            translateY = ObjectAnimator.ofFloat(imageView, "translationY",
                0f, swayAmount, -swayAmount, 0f);
        }
        translateX.setDuration(animDuration);
        translateY.setDuration(animDuration);

        // Rotation (spin)
        if (spin > 0) {
            float spinAmount = spin + (ThreadLocalRandom.current().nextFloat() - 0.5f) * spinRange;
            ObjectAnimator rotation = ObjectAnimator.ofFloat(imageView, "rotation", 0, spinAmount);
            rotation.setDuration(animDuration);
            animatorSet.playTogether(scaleX, scaleY, translateX, translateY, rotation);
        } else {
            animatorSet.playTogether(scaleX, scaleY, translateX, translateY);
        }

        // Fade out in second half
        ObjectAnimator fadeOut = ObjectAnimator.ofFloat(imageView, "alpha", 1.0f, 0.0f);
        fadeOut.setStartDelay((long)(animDuration / 2));
        fadeOut.setDuration(animDuration / 2);
        animatorSet.play(fadeOut).with(translateY);

        final ImageView finalImageView = imageView;
        animatorSet.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                removeView(finalImageView);
                returnImageViewToPool(finalImageView);
                currentCount--;
            }
        });

        animatorSet.start();
    }

    private ImageView createImageView() {
        ImageView view = new ImageView(getContext());
        view.setScaleType(ImageView.ScaleType.FIT_CENTER);
        view.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        return view;
    }

    private synchronized ImageView getImageViewFromPool() {
        if (!imageViewPool.isEmpty()) {
            return imageViewPool.remove(imageViewPool.size() - 1);
        }
        return null;
    }

    private synchronized void returnImageViewToPool(ImageView imageView) {
        if (imageViewPool.size() < POOL_SIZE) {
            imageView.setImageBitmap(null);
            imageViewPool.add(imageView);
        }
    }

    public void cleanup() {
        removeAllViews();
        synchronized (this) {
            imageViewPool.clear();
        }
        for (Bitmap bitmap : generatedBitmaps) {
            if (!bitmap.isRecycled()) {
                bitmap.recycle();
            }
        }
        generatedBitmaps.clear();
        currentCount = 0;
    }
}
