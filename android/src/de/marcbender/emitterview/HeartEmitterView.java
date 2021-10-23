package de.marcbender.emitterview.layout;

import android.content.Context;
import android.util.AttributeSet;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.AnimationUtils;
import android.view.animation.AlphaAnimation;
import android.view.animation.TranslateAnimation;
import android.view.animation.LinearInterpolator;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.graphics.Bitmap;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.util.TiConvert;
import java.util.concurrent.ThreadLocalRandom;
import android.view.MotionEvent;
import de.marcbender.emitterview.R;
import java.util.Random;


/**
 * Created by thangn on 3/7/17.
 * Modified and adapted to iOS equality by Marc Bender
 */

public class HeartEmitterView extends RelativeLayout {
    private int mHeartHeight;
    private int mHeartWidth;

    private int startoffset;
    private int centerX;
    private float density;

    private int maxAmplitude;
    private int amplitude;
    private float duration;
    private float maxDuration;

    private long transYDur;
    private int bottomoffset;
    private int buttonHeight;
    private float buttonViewElevation;

    private static final String TAG = "HeartEmitterView";



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


    public void startOffset(int offset, int center) {
        this.startoffset = offset;
        this.centerX = center;
    }


    public void maxAmplitude(int aRange) {
        this.maxAmplitude = aRange;
    }

    public void amplitude(int a) {
        this.amplitude = a;
    }

    public void duration(float d) {
        this.duration = d;
    }

    public void maxDuration(float dR) {
        this.maxDuration = dR;
    }


    public void buttonViewElevation(float elevation) {
        this.buttonViewElevation = elevation;
    }


    public void bottomOffset(int offsetBottom) {
        this.bottomoffset = offsetBottom;
    }


    public void buttonHeight(int height) {
        this.buttonHeight = height;
    }



    public void emitImage(Bitmap resId) {
        try {
            this.mHeartHeight = resId.getHeight();
            this.mHeartWidth = resId.getWidth();

            final ImageView img = generateHeartView(resId);
            if (img != null) {

                AnimationSet animation = (AnimationSet) AnimationUtils.loadAnimation(getContext(), R.anim.anim_image);


                Double milliseconds = (this.duration * 1000.0);
                Double milliseconds2 = (this.maxDuration * 1000.0);

                int randomInt = TiConvert.toInt(milliseconds);
                int randomIntRange = TiConvert.toInt(milliseconds2);


                if (randomInt <= 1000){
                    randomInt = 1000;
                }
                if (randomIntRange <= 1000){
                    randomIntRange = 1000;
                }

                transYDur = Math.max(randomInt, new Random().nextInt(randomIntRange));                 

                addView(img, getParams(this.bottomoffset-this.mHeartHeight/2,this.centerX-this.mHeartWidth/2));

                generateTranslateAnim(animation);

                generateAmplitudeAnim(animation);


                AlphaAnimation animationFadeOut = new AlphaAnimation(img.getAlpha(), 0.0f);
                animationFadeOut.setDuration((transYDur/3)-200);
                animationFadeOut.setStartOffset((transYDur/3)+((transYDur/3)/2));
                animationFadeOut.setFillAfter(false);
                animation.addAnimation(animationFadeOut);

                img.startAnimation(animation);

                animation.setAnimationListener(new Animation.AnimationListener() {
                    @Override
                    public void onAnimationStart(Animation animation) {
                    }

                    @Override
                    public void onAnimationEnd(Animation animation) {
                        removeHeart(img);
                    }

                    @Override
                    public void onAnimationRepeat(Animation animation) {
                    }
                });
            }
        } catch (OutOfMemoryError e) {
            e.printStackTrace();
        }
    }



    private void init(Context context) {
        this.density = context.getResources().getDisplayMetrics().density;
    }

     public float dpToPx(float dp) 
          {
          // return (dp * this.density);
           return (dp * density + 0.5f);
      }


     public float pxToDp(float px) 
          {
           return (px / this.density - 0.5f);
      }


    private void removeHeart(final ImageView img) {
        post(new Runnable() {
            @Override
            public void run() {
                removeView(img);
            }
        });
    }

    private void generateTranslateAnim(AnimationSet animationSet) {

        Animation first = new TranslateAnimation(0, 0, 0, -(this.bottomoffset+dpToPx(this.buttonHeight/2+this.mHeartHeight/2)));

        first.setDuration(transYDur);
        first.setStartOffset(0);
        first.setInterpolator(new LinearInterpolator());
        animationSet.addAnimation(first);
    }



    private void generateAmplitudeAnim(AnimationSet animationSet) {

        Random random = new Random();
        boolean firstLeft = random.nextInt() % 2 == 0;

        float deltaX = dpToPx(ThreadLocalRandom.current().nextInt(this.amplitude, this.maxAmplitude))/1.6f;

        Animation first = new TranslateAnimation((firstLeft ? 0 : 0), (firstLeft ? -(deltaX) : deltaX), 0, 0);

        first.setStartTime(750);
        first.setDuration(ThreadLocalRandom.current().nextInt(450, 650));
        first.setStartOffset(0);
        first.setRepeatCount(-1);
        first.setRepeatMode(Animation.REVERSE);
        first.setInterpolator(new LinearInterpolator());
        animationSet.addAnimation(first);
    }




    private ImageView generateHeartView(Bitmap resId) {
        try {
            ImageView view = new ImageView(getContext());

            view.setImageBitmap(resId);
          
            return view;
        } catch (OutOfMemoryError e) {
            e.printStackTrace();
            return null;
        }
    }

    private LayoutParams getParams(int bottom, int left) {

        LayoutParams params = new LayoutParams(this.mHeartWidth,this.mHeartHeight);

        params.leftMargin = left;
        params.topMargin = bottom;


        return params;
    }

}
