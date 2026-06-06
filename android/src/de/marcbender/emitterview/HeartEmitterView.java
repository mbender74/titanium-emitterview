package de.marcbender.emitterview.layout;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.util.AttributeSet;
import android.util.FloatProperty;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.graphics.Bitmap;

import java.util.ArrayList;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Optimized particle emitter using Property Animators for hardware acceleration.
 * Supports 4 directions: up, down, left, right.
 */
public class HeartEmitterView extends RelativeLayout {

    private static final String TAG = "HeartEmitterView";
    private static final int MAX_PARTICLES = 100;
    private static final int POOL_SIZE = 20;
    private static final int PATH_POINTS = 40;

    // Configuration
    private int maxAmplitude = 14;
    private int amplitude = 8;
    private float duration = 3.0f;
    private float maxDuration = 3.5f;

    // Direction: 0=up, 1=down, 2=left, 3=right
    private int direction = 0;

    // State
    private int currentCount = 0;
    private float density = 1.0f;

    // Start position
    private int startOffsetY = 0;
    private int centerX = 0;
    private int bottomOffset = 0;
    private int buttonHeight = 0;

    // ImageView Pool
    private final ArrayList<ImageView> imageViewPool = new ArrayList<>(POOL_SIZE);

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
    }

    // Property setters
    public void maxAmplitude(int value) {
        this.maxAmplitude = value;
    }

    public void amplitude(int value) {
        this.amplitude = value;
    }

    public void duration(float value) {
        this.duration = value;
    }

    public void maxDuration(float value) {
        this.maxDuration = value;
    }

    public void direction(int value) {
        this.direction = Math.max(0, Math.min(3, value));
    }

    public void startOffset(int offsetY, int center) {
        this.startOffsetY = offsetY;
        this.centerX = center;
    }

    public void bottomOffset(int offsetBottom) {
        this.bottomOffset = offsetBottom;
    }

    public void buttonHeight(int height) {
        this.buttonHeight = height;
    }

    public void buttonViewElevation(float elevation) {
        // Not needed for Property Animator approach
    }

    public float dpToPx(float dp) {
        return (dp * density + 0.5f);
    }

    /**
     * Emit a particle image with hardware-accelerated animation.
     */
    public void emitImage(Bitmap bitmap) {
        if (bitmap == null) {
            return;
        }

        // Check maximum count
        if (currentCount >= MAX_PARTICLES) {
            return;
        }

        currentCount++;

        // Get ImageView from pool or create new
        ImageView imageView = getImageViewFromPool();
        if (imageView == null) {
            imageView = createImageView();
        }
        final ImageView finalImageView = imageView;

        int imageWidth = bitmap.getWidth();
        int imageHeight = bitmap.getHeight();
        imageView.setImageBitmap(bitmap);

        // Setup layout params
        LayoutParams params = new LayoutParams(imageWidth, imageHeight);
        params.addRule(CENTER_HORIZONTAL);
        params.addRule(ALIGN_PARENT_BOTTOM);
        params.leftMargin = centerX - imageWidth / 2;
        params.bottomMargin = bottomOffset - imageHeight / 2;
        params.topMargin = 0;
        params.rightMargin = 0;
        imageView.setLayoutParams(params);

        // Reset view state
        imageView.setAlpha(1.0f);
        imageView.setScaleX(0.3f);
        imageView.setScaleY(0.3f);
        imageView.setVisibility(VISIBLE);

        addView(imageView);

        // Calculate animation parameters
        long animDuration = ThreadLocalRandom.current().nextLong(
            (long)(duration * 1000),
            (long)(maxDuration * 1000) + 1
        );
        animDuration = Math.max(1000, animDuration);

        // Random amplitude
        int finalAmplitude = amplitude + ThreadLocalRandom.current().nextInt(maxAmplitude);
        float deltaX = dpToPx(finalAmplitude);

        // Calculate end position based on direction
        final float endX;
        final float endY;
        switch (direction) {
            case 0: // up
                endX = 0;
                endY = -(getHeight() * 0.8f);
                break;
            case 1: // down
                endX = 0;
                endY = getHeight() * 0.8f;
                break;
            case 2: // left
                endX = -(getWidth() * 0.8f);
                endY = 0;
                break;
            case 3: // right
                endX = getWidth() * 0.8f;
                endY = 0;
                break;
            default:
                endX = 0;
                endY = -(getHeight() * 0.8f);
        }

        // Create animation set
        AnimatorSet animatorSet = new AnimatorSet();

        // Scale animation: 0.3 → 1.0
        ObjectAnimator scaleX = ObjectAnimator.ofFloat(imageView, "scaleX", 0.3f, 1.0f);
        scaleX.setDuration(animDuration * 3 / 4);
        ObjectAnimator scaleY = ObjectAnimator.ofFloat(imageView, "scaleY", 0.3f, 1.0f);
        scaleY.setDuration(animDuration * 3 / 4);

        // Translate animation with sinusoidal sway
        final float swayX, swayY;
        if (direction == 0 || direction == 1) {
            // Horizontal sway for up/down
            swayX = -deltaX;
            swayY = 0;
        } else {
            // Vertical sway for left/right
            swayX = 0;
            swayY = -deltaX;
        }

        ObjectAnimator translateX = ObjectAnimator.ofFloat(imageView, "translationX",
            0f, swayX, -swayX, 0f, endX);
        translateX.setDuration(animDuration);

        ObjectAnimator translateY = ObjectAnimator.ofFloat(imageView, "translationY",
            0f, swayY, -swayY, 0f, endY);
        translateY.setDuration(animDuration);

        // Fade out animation
        ObjectAnimator fadeOut = ObjectAnimator.ofFloat(imageView, "alpha", 1.0f, 0.0f);
        fadeOut.setStartDelay((long)(animDuration / 2));
        fadeOut.setDuration(animDuration / 2);

        // Play all animations together
        animatorSet.playTogether(scaleX, scaleY, translateX, translateY, fadeOut);

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

    /**
     * Cleanup: remove all views and clear pool.
     */
    public void cleanup() {
        removeAllViews();
        synchronized (this) {
            imageViewPool.clear();
        }
        currentCount = 0;
    }
}
