package de.marcbender.emitterview;

import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;
import android.content.res.Resources;
import java.util.Random;
import java.util.ArrayList;
import android.graphics.Bitmap;
import android.util.DisplayMetrics;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.TiConfig;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiCompositeLayout;
import org.appcelerator.titanium.view.TiCompositeLayout.LayoutArrangement;
import org.appcelerator.titanium.view.TiUIView;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.TiDimension;
import org.appcelerator.titanium.view.TiDrawableReference;
import de.marcbender.emitterview.layout.HeartEmitterView;
import java.util.concurrent.ThreadLocalRandom;

@Kroll.proxy(creatableInModule = TiEmitterViewModule.class)
public class ViewProxy extends TiViewProxy {

	private static final String TAG = "DeMarcbenderEmitterView";

	private HeartEmitterView mEmitterView;
	private Activity context;
	private Resources resources;
	private String packageName;
	private TiViewProxy myProxy;
	private ArrayList<Object> imageSources;
	private ArrayList<TiDrawableReference> imageReferences;
	private ArrayList<Bitmap> cachedBitmaps;
	private TiViewProxy buttonView;
	private float density;
	private TiCompositeLayout compositeView;

	public static final String PROPERTY_PARTICLEIMAGES = "particleImages";
	public static final String PROPERTY_SOURCEVIEW = "sourceView";

	private class EmitterView extends TiUIView {

		public EmitterView(TiViewProxy proxy) {
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
			compositeView = new TiCompositeLayout(proxy.getActivity(), arrangement);
			setNativeView(compositeView);
		}

		@Override
		public void processProperties(KrollDict d) {
			d.put(TiC.PROPERTY_TOUCH_ENABLED, false);
			d.put(TiC.PROPERTY_BUBBLE_PARENT, true);
			super.processProperties(d);

			if (d.containsKey(PROPERTY_PARTICLEIMAGES)) {
				imageSources = new ArrayList<Object>();
				for (Object o : (Object[]) d.get(PROPERTY_PARTICLEIMAGES)) {
					imageSources.add(o);
				}
				imageReferences = new ArrayList<TiDrawableReference>();
				cachedBitmaps = new ArrayList<Bitmap>();
				for (Object o : imageSources) {
					TiDrawableReference ref = TiDrawableReference.fromObject(myProxy, o);
					imageReferences.add(ref);
					// Cache bitmap once to avoid repeated decoding (HWUI warnings)
					Bitmap b = ref.getBitmap(false, true);
					if (b != null) {
						cachedBitmaps.add(b);
					} else {
						cachedBitmaps.add(null);
					}
				}
			}

			if (d.containsKey("maxAmplitude")) {
				mEmitterView.maxAmplitude(TiConvert.toInt(d.get("maxAmplitude")));
			} else {
				mEmitterView.maxAmplitude(14);
			}

			if (d.containsKey("amplitude")) {
				mEmitterView.amplitude(TiConvert.toInt(d.get("amplitude")));
			} else {
				mEmitterView.amplitude(8);
			}

			if (d.containsKey("duration")) {
				mEmitterView.duration(TiConvert.toFloat(d.get("duration")));
			} else {
				mEmitterView.duration(TiConvert.toFloat(3.0f));
			}

			if (d.containsKey("maxDuration")) {
				mEmitterView.maxDuration(TiConvert.toFloat(d.get("maxDuration")));
			} else {
				mEmitterView.maxDuration(TiConvert.toFloat(3.5f));
			}

			if (d.containsKey("direction")) {
				mEmitterView.direction(TiConvert.toInt(d.get("direction")));
			}

			if (d.containsKey("particleType")) {
				mEmitterView.particleType(TiConvert.toInt(d.get("particleType")));
			}

			if (d.containsKey("intensity")) {
				mEmitterView.intensity(TiConvert.toFloat(d.get("intensity")));
			}

			if (d.containsKey("colors")) {
				Object[] colorArray = (Object[]) d.get("colors");
				if (colorArray != null && colorArray.length > 0) {
					int[] colors = new int[colorArray.length];
					for (int i = 0; i < colorArray.length; i++) {
						colors[i] = TiConvert.toColor(TiConvert.toString(colorArray[i]));
					}
					mEmitterView.colors(colors);
				}
			}

			if (d.containsKey("velocity")) {
				// iOS Core Animation uses points (density-independent).
				// Android ObjectAnimator uses raw pixels. Multiply by density
				// so velocity:350 means ~350 points/s on both platforms.
				mEmitterView.velocity(TiConvert.toFloat(d.get("velocity")) * density);
			}

			if (d.containsKey("velocityRange")) {
				mEmitterView.velocityRange(TiConvert.toFloat(d.get("velocityRange")) * density);
			}

			if (d.containsKey("spin")) {
				mEmitterView.spin(TiConvert.toFloat(d.get("spin")));
			}

			if (d.containsKey("spinRange")) {
				mEmitterView.spinRange(TiConvert.toFloat(d.get("spinRange")));
			}

			if (d.containsKey("text")) {
				mEmitterView.particleText(TiConvert.toString(d.get("text")));
			}

			if (d.containsKey("fontSize")) {
				mEmitterView.textFontSize(TiConvert.toFloat(d.get("fontSize")));
			}

			if (d.containsKey("autoStopDuration")) {
				mEmitterView.autoStopDuration(TiConvert.toFloat(d.get("autoStopDuration")));
			}

			if (d.containsKey("autoRemove")) {
				mEmitterView.autoRemove(TiConvert.toBoolean(d.get("autoRemove")));
			}

			if (d.containsKey("lifetime")) {
				mEmitterView.lifetime(TiConvert.toFloat(d.get("lifetime")));
			}

			if (d.containsKey("scaleRange")) {
				mEmitterView.scaleRange(TiConvert.toFloat(d.get("scaleRange")));
			}

			if (d.containsKey("scaleSpeed")) {
				mEmitterView.scaleSpeed(TiConvert.toFloat(d.get("scaleSpeed")));
			}

			if (d.containsKey("emissionRange")) {
				mEmitterView.emissionRange(TiConvert.toFloat(d.get("emissionRange")));
			}
		}
	}

	public ViewProxy() {
		super();
	}

	@Override
	public TiUIView createView(Activity activity) {
		TiUIView view = new EmitterView(this);
		view.getLayoutParams().autoFillsHeight = true;
		view.getLayoutParams().autoFillsWidth = true;

		density = activity.getResources().getDisplayMetrics().density;

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
		android.view.LayoutInflater inflater = android.view.LayoutInflater.from(context);
		View viewWrapper = inflater.inflate(resId_viewHolder, null);
		mEmitterView = (HeartEmitterView) viewWrapper.findViewById(resId_emitterView);
		compositeView.addView(viewWrapper);

		return view;
	}

	public float dpToPx(int dp) {
		return (dp * density + 0.5f);
	}

	public KrollDict getViewRect(View v) {
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
		// Apply direction override if provided in options
		Object directionObj = options.get("direction");
		if (directionObj != null) {
			int dir = TiConvert.toInt(directionObj);
			if (dir >= 0 && dir <= 3) {
				mEmitterView.direction(dir);
			}
		}

		if (options.containsKey(PROPERTY_SOURCEVIEW)) {
			Object sourceViewObject = options.get(PROPERTY_SOURCEVIEW);
			if (sourceViewObject instanceof TiViewProxy) {
				buttonView = (TiViewProxy) sourceViewObject;
				TiUIView thatView = buttonView.peekView();
				View nativeSource = thatView.getNativeView();
				mEmitterView.buttonViewElevation(nativeSource.getElevation());

				// Both views are in the same window — get window-relative positions
				// and compute the offset of source center relative to mEmitterView
				int[] sourceWinPos = new int[2];
				int[] emitterWinPos = new int[2];
				nativeSource.getLocationInWindow(sourceWinPos);
				mEmitterView.getLocationInWindow(emitterWinPos);

				// Center of sourceView relative to mEmitterView
				float centerX = (sourceWinPos[0] - emitterWinPos[0]) + nativeSource.getWidth() / 2f;
				float centerY = (sourceWinPos[1] - emitterWinPos[1]) + nativeSource.getHeight() / 2f;

				mEmitterView.buttonHeight(nativeSource.getHeight());
				mEmitterView.startOffset(centerY, centerX);
				mEmitterView.bottomOffset(centerY);
			}
		}

		int idx;
		if (options.containsKey("startId") && options.containsKey("endId")) {
			int startId = TiConvert.toInt(options.get("startId"));
			int endId = TiConvert.toInt(options.get("endId"));
			// 0-based: startId=0 means first image. Clamp to valid range.
			int startIdx = Math.max(0, startId);
			int endIdx = Math.max(startIdx, endId);
			idx = startIdx + ThreadLocalRandom.current().nextInt(endIdx - startIdx + 1);
		} else if (options.containsKey("id")) {
			// 0-based: id:0 = first image, id:1 = second image, etc.
			int id = TiConvert.toInt(options.get("id"));
			idx = Math.max(0, id);
		} else {
			idx = ThreadLocalRandom.current().nextInt(imageReferences.size());
		}

		// Clamp to valid range
		if (idx < 0) idx = 0;
		if (idx >= imageReferences.size()) idx = imageReferences.size() - 1;

		// Use cached bitmap to avoid repeated decoding (prevents HWUI warnings)
		Bitmap b = cachedBitmaps != null ? cachedBitmaps.get(idx) : imageReferences.get(idx).getBitmap(false, true);
		int emitValue = options.containsKey("emitValue") ? Math.max(1, TiConvert.toInt(options.get("emitValue"))) : 1;
		float emitSpread = options.containsKey("emitSpread") ? TiConvert.toFloat(options.get("emitSpread")) : 0;
		float emitScaleRange = options.containsKey("emitScaleRange") ? TiConvert.toFloat(options.get("emitScaleRange")) : 0;
			mEmitterView.emitImage(b, emitValue, emitSpread, emitScaleRange);
	}

	@Kroll.method
	public void start() {
		mEmitterView.start();
	}

	@Kroll.method
	public void stop() {
		mEmitterView.stop();
	}

	@Kroll.method
	public void pause() {
		mEmitterView.pause();
	}

	@Kroll.method
	public void resume() {
		mEmitterView.resume();
	}

	@Kroll.method
	public boolean isActive() {
		return mEmitterView.isActive();
	}

	// Particle Type Constants
	@Kroll.constant public static final int PARTICLE_CUSTOM = 0;
	@Kroll.constant public static final int PARTICLE_CONFETTI = 1;
	@Kroll.constant public static final int PARTICLE_TRIANGLE = 2;
	@Kroll.constant public static final int PARTICLE_STAR = 3;
	@Kroll.constant public static final int PARTICLE_DIAMOND = 4;
	@Kroll.constant public static final int PARTICLE_TEXT = 5;

	// Direction Constants
	@Kroll.constant public static final int DIRECTION_UP = 0;
	@Kroll.constant public static final int DIRECTION_DOWN = 1;
	@Kroll.constant public static final int DIRECTION_LEFT = 2;
	@Kroll.constant public static final int DIRECTION_RIGHT = 3;

	@Override
	public void handleCreationDict(KrollDict options) {
		super.handleCreationDict(options);
	}
}