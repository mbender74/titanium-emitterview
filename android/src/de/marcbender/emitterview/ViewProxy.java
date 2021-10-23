/**
 * This file was auto-generated by the Titanium Module SDK helper for Android
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package de.marcbender.emitterview;
import android.app.Activity;
import android.view.View;

import android.view.LayoutInflater;
import android.view.View;
import android.graphics.drawable.Drawable;
import android.view.ViewGroup;
import android.content.res.Resources;
import android.widget.ImageView;
import org.appcelerator.kroll.common.Log;

import android.widget.RelativeLayout;
import java.util.Random;
import java.util.ArrayList;
import android.app.Activity;

import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.util.DisplayMetrics;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.graphics.Color;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.common.TiConfig;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiCompositeLayout;
import org.appcelerator.titanium.view.TiCompositeLayout.LayoutArrangement;
import org.appcelerator.titanium.view.TiCompositeLayout.LayoutParams;
import org.appcelerator.titanium.view.TiUIView;
import org.appcelerator.titanium.util.TiConvert;
import java.util.concurrent.ThreadLocalRandom;


import org.appcelerator.kroll.common.AsyncResult;
import org.appcelerator.kroll.common.TiMessenger;
import org.appcelerator.titanium.TiApplication;

import org.appcelerator.titanium.TiDimension;

import org.appcelerator.titanium.TiBlob;
import org.appcelerator.titanium.io.TiBaseFile;
import org.appcelerator.titanium.io.TiFileFactory;
import org.appcelerator.titanium.view.TiDrawableReference;
import ti.modules.titanium.platform.DisplayCapsProxy;
import de.marcbender.emitterview.layout.HeartEmitterView;

@Kroll.proxy(creatableInModule = TiEmitterViewModule.class)
public class ViewProxy extends TiViewProxy
{
	// Standard Debugging variables
	private static final String LCAT = "EmitterViewProxy";
	private static final boolean DBG = TiConfig.LOGD;
	private int mHeartSize;
	private static final String TAG = "DeMarcbenderEmitterView";
	private static final int FRAME_QUEUE_SIZE = 5;

	private HeartEmitterView mEmitterView;
    private int[] mImages;
    private TiDrawableReference key;
    private Activity context;
	private Resources resources;
	private String packageName;
    private Object imageArray;
	private TiViewProxy myProxy;
	private ArrayList<Object> imageSources;
	private ArrayList<TiDrawableReference> imageReferences;
	private TiViewProxy buttonView;
	private float density;
	private TiCompositeLayout compositeView;
	private DisplayMetrics metrics;
	private int densityDpi;

	public static final String PROPERTY_PARTICLEIMAGES = "particleImages";
	public static final String PROPERTY_SOURCEEVENT = "event";
	public static final String PROPERTY_SOURCEVIEW = "sourceView";


	private class EmitterView extends TiUIView
	{

		public EmitterView(TiViewProxy proxy)
		{
			super(proxy);

			myProxy = proxy;

			packageName = proxy.getActivity().getPackageName();
			resources = proxy.getActivity().getResources();

			context = proxy.getActivity();

            LayoutArrangement arrangement = LayoutArrangement.DEFAULT;

            if (proxy.hasProperty(TiC.PROPERTY_LAYOUT)) {
                String layoutProperty = TiConvert.toString(proxy.getProperty(TiC.PROPERTY_LAYOUT));
                if (layoutProperty.equals(TiC.LAYOUT_HORIZONTAL)) {
                    arrangement = LayoutArrangement.HORIZONTAL;
                } else if (layoutProperty.equals(TiC.LAYOUT_VERTICAL)) {
                    arrangement = LayoutArrangement.VERTICAL;
                }
            }
            
             compositeView = new TiCompositeLayout(proxy.getActivity(),arrangement);

			 setNativeView(compositeView);     
	      
		}

		


		@Override
		public void processProperties(KrollDict d)
		{
			d.put(TiC.PROPERTY_TOUCH_ENABLED, false);
			d.put(TiC.PROPERTY_BUBBLE_PARENT, true);


			super.processProperties(d);


			if (d.containsKey(PROPERTY_PARTICLEIMAGES)) {
				 imageSources = new ArrayList<Object>();
				 for (Object o : (Object[]) d.get(PROPERTY_PARTICLEIMAGES)) {
				 	imageSources.add(o);
				 }


 				imageReferences = new ArrayList<TiDrawableReference>();
				 for (Object o : imageSources) {

				 	imageReferences.add(TiDrawableReference.fromObject(myProxy, o));
				 }


			}

			if (d.containsKey("maxAmplitude")) {
					mEmitterView.maxAmplitude(TiConvert.toInt(d.get("maxAmplitude")));
			}
			else {
					mEmitterView.maxAmplitude(TiConvert.toInt(2));
			}


			if (d.containsKey("amplitude")) {
					mEmitterView.amplitude(TiConvert.toInt(d.get("amplitude")));
			}
			else {
					mEmitterView.amplitude(TiConvert.toInt(2));
			}


			if (d.containsKey("duration")) {
					mEmitterView.duration(TiConvert.toFloat(d.get("duration")));
			}
			else {
					mEmitterView.duration(TiConvert.toFloat(1.0));
			}


			if (d.containsKey("maxDuration")) {
					mEmitterView.maxDuration(TiConvert.toFloat(d.get("maxDuration")));
			}
			else {
					mEmitterView.maxDuration(TiConvert.toFloat(1.0));
			}


		}
		 
	}

	// Constructor
	public ViewProxy()
	{
		super();
	}

	@Override
	public TiUIView createView(Activity activity)
	{
		TiUIView view = new EmitterView(this);
		view.getLayoutParams().autoFillsHeight = true;
		view.getLayoutParams().autoFillsWidth = true;


		density = activity.getResources().getDisplayMetrics().density;
		densityDpi  =  activity.getResources().getDisplayMetrics().densityDpi;


        if (view != null) {
                            View cv = view.getOuterView();
                            if (cv != null) {
                                View nv = view.getNativeView();

                                if (nv instanceof ViewGroup) {
                                    if (cv.getParent() == null) {
                                        ((ViewGroup) nv).setClipChildren(false);
                                        ((ViewGroup) nv).setClipToPadding(false);
                                    }
                                }
                            }

        }


		 	int resId_viewHolder = resources.getIdentifier("layout_main", "layout", packageName);
			int resId_emitterView = resources.getIdentifier("emitter_view", "id", packageName);

			View viewWrapper;

			LayoutInflater inflater = LayoutInflater.from(context);
			viewWrapper = inflater.inflate(resId_viewHolder, null);

			mEmitterView = (HeartEmitterView) viewWrapper.findViewById(resId_emitterView);
			
			compositeView.addView(viewWrapper);


		return view;
	}


	 public float dpToPx(int dp) 
	      {
	      // return (dp * density);
   	       return (dp * density + 0.5f);
	  }


	public KrollDict getViewRect(View v)
	{
		KrollDict d = new KrollDict();
		if (v != null) {
			int[] position = new int[2];
			v.getLocationInWindow(position);

			TiDimension nativeWidth = new TiDimension(v.getWidth(), TiDimension.TYPE_WIDTH);
			TiDimension nativeHeight = new TiDimension(v.getHeight(), TiDimension.TYPE_HEIGHT);
			TiDimension nativeLeft = new TiDimension(position[0], TiDimension.TYPE_LEFT);
			TiDimension nativeTop = new TiDimension(position[1], TiDimension.TYPE_TOP);
			TiDimension localLeft = new TiDimension(v.getX(), TiDimension.TYPE_LEFT);
			TiDimension localTop = new TiDimension(v.getY(), TiDimension.TYPE_TOP);

			// TiDimension needs a view to grab the window manager.
			d.put(TiC.PROPERTY_WIDTH, nativeWidth.getAsDefault(v));
			d.put(TiC.PROPERTY_HEIGHT, nativeHeight.getAsDefault(v));
			d.put(TiC.PROPERTY_X, localLeft.getAsDefault(v));
			d.put(TiC.PROPERTY_Y, localTop.getAsDefault(v));
			d.put(TiC.PROPERTY_X_ABSOLUTE, nativeLeft.getAsDefault(v));
			d.put(TiC.PROPERTY_Y_ABSOLUTE, nativeTop.getAsDefault(v));


		}
		if (!d.containsKey(TiC.PROPERTY_WIDTH)) {
			d.put(TiC.PROPERTY_WIDTH, 0);
			d.put(TiC.PROPERTY_HEIGHT, 0);
			d.put(TiC.PROPERTY_X, 0);
			d.put(TiC.PROPERTY_Y, 0);

		}


		return d;
	}


	@Kroll.method
	public void emitImage(KrollDict options) {



		if (options.containsKey(PROPERTY_SOURCEVIEW)) {

			Object sourceViewObject = options.get(PROPERTY_SOURCEVIEW);
			if (sourceViewObject instanceof TiViewProxy) {
				buttonView = (TiViewProxy) sourceViewObject;
	
				TiUIView thatView = buttonView.peekView();
				

				mEmitterView.buttonViewElevation(thatView.getNativeView().getElevation());


				KrollDict emitterViewRect = getViewRect(mEmitterView);



				int emitterViewHeight = TiConvert.toInt(emitterViewRect.get("height"));
				int emitterViewWidth = TiConvert.toInt(emitterViewRect.get("width"));

				int emitterViewAbsoluteY = TiConvert.toInt(emitterViewRect.get("absoluteY"));


				KrollDict buttonViewDict = getViewRect(thatView.getOuterView());
				int buttonViewHeight = TiConvert.toInt(buttonViewDict.get("height"));
				int buttonViewWidth = TiConvert.toInt(buttonViewDict.get("width"));
				int relativeY = TiConvert.toInt(buttonViewDict.get("y"));
				int relativeX = TiConvert.toInt(buttonViewDict.get("x"));

				int newOffset = TiConvert.toInt(buttonViewDict.get("absoluteY"));
				int newOffsetX = TiConvert.toInt(buttonViewDict.get("absoluteX"));

				mEmitterView.buttonHeight(buttonViewHeight);
				mEmitterView.startOffset((int)dpToPx(relativeY+(buttonViewHeight/2)),(int)dpToPx(relativeX+(buttonViewWidth/2)));
				mEmitterView.bottomOffset((int) dpToPx(relativeY+(buttonViewHeight/2)));

			}
		}


		int idx;

		if (options.containsKey("startId") && options.containsKey("endId")) {

			int startId = TiConvert.toInt(options.get("startId"));
			int endId = TiConvert.toInt(options.get("endId"));

			idx = Math.max(startId, new Random().nextInt(endId+1)) - 1;
		}
	
		else if (options.containsKey("id")) {

			idx = (TiConvert.toInt(options.get("id"))) - 1;
		}
		else {
	 		Random r = new Random();

	        idx = (r.nextInt(imageReferences.size()))-1;			
		}

	 	Bitmap b = imageReferences.get(idx).getBitmap(false,true);


        mEmitterView.emitImage(b);
   	}


	// Handle creation options
	@Override
	public void handleCreationDict(KrollDict options)
	{
		super.handleCreationDict(options);

	}

}
