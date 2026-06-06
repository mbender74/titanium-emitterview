/**
 * Require emitterView Module
 */
 var emitterViewModule = require('de.marcbender.emitterview');

/**
 * Require IconicFont and FontAwesome
 */
 var fontawesome = require('/lib/IconicFont').IconicFont({font: '/lib/FontAwesome',ligature: false});


 /**
 * Define Button touch animation
 */
 var isAnimating = false;
 var touchStartAnim = Titanium.UI.createAnimation({
    duration: 90,
    opacity: 0.3,
    autoreverse:true
});
touchStartAnim.addEventListener('complete', function() {
    isAnimating = false;
 });

/**
 * Create a new `Ti.UI.TabGroup`.
 */
var tabGroup = Ti.UI.createTabGroup();

/**
 * Add the two created tabs to the tabGroup object.
 */
tabGroup.addTab(createTab("Tab 1", "I am Window 1", "assets/images/tab1.png"));
tabGroup.addTab(createTab("Tab 2", "I am Window 2", "assets/images/tab2.png"));

/**
 * Open the tabGroup
 */
tabGroup.open();

var emitterImages = [];



function generateThumbColorImage(color,icon){
    var buttonImage = Ti.UI.createLabel({
        width: Ti.UI.SIZE,
        height: Ti.UI.SIZE,
        color: color,
        textAlign:'center',
        font: {
            fontSize: 36,
            fontFamily: fontawesome.fontfamily()
        },
        text: (!icon) ? fontawesome.icon('icon-thumbs-up') : fontawesome.icon(icon) 
     });
     return buttonImage.toImage(null,true);
}






/**
 * Creates a new Tab and configures it.
 *
 * @param  {String} title The title used in the `Ti.UI.Tab` and it's included `Ti.UI.Window`
 * @param  {String} message The title displayed in the `Ti.UI.Label`
 * @return {String} icon The icon used in the `Ti.UI.Tab`
 */

function createTab(title, message, icon) {
    var win = Ti.UI.createWindow({
        title: title,
        backgroundColor: '#fff',
        top:0,
        bottom:0,
        left:0,
        right:0,
        height:Ti.UI.FILL,
        width:Ti.UI.FILL,
    });

    var label = Ti.UI.createLabel({
        text: message,
        color: "#333",
        font: {
            fontSize: 20
        }
    });

    win.add(label);


    /**
     * Add images to an array that is needed for the emitterView
     */
    var emitterImages = [];
    emitterImages.push(generateThumbColorImage('red','fa-heart'));
    emitterImages.push(generateThumbColorImage('red'));
    emitterImages.push(generateThumbColorImage('yellow'));
    emitterImages.push(generateThumbColorImage('orange'));
    emitterImages.push(generateThumbColorImage('blue'));
    emitterImages.push(generateThumbColorImage('purple'));
    emitterImages.push(generateThumbColorImage('green'));
    emitterImages.push(generateThumbColorImage('magenta'));
    emitterImages.push(generateThumbColorImage('#16c7cd'));

    /**
     * create an emitterView
     */
    var emitterView = emitterViewModule.createView({
        top:0,
        left:0,
        right:0,
        bottom:0,
        backgroundColor:'#55b55e5e',
        height:Ti.UI.FILL,
        width:Ti.UI.FILL,
		amplitude:16, // Integer
        maxAmplitude:32, // Integer
        duration:2.0, // Float - in seconds
        maxDuration:3.5, // Float - in seconds
        particleImages:emitterImages, // array of images or imageBlobs
    })

    win.add(emitterView);

     /**
     * create a buttonView where the images to emit will be emitted from
     */
    var buttonView = Ti.UI.createView({
        width: Ti.UI.SIZE,
        height: Ti.UI.SIZE,
        bottom:50,
        right:120,
        backgroundColor:'yellow'
     });

    var buttonLabel = Ti.UI.createLabel({
        left:10,
        right:10,
        width: Ti.UI.SIZE,
        height: Ti.UI.SIZE,
        color: 'black',
        textAlign:Titanium.UI.TEXT_ALIGNMENT_CENTER,
        font: {
            fontSize: 36,
            fontFamily: fontawesome.fontfamily()
        },
        text:fontawesome.icon('icon-thumbs-up')
    });
    buttonView.add(buttonLabel);
    win.add(buttonView);

    /**
     * create an eventLister for the buttonView which will call the 'emitterView.emitImage({PARAMS})' method
     * for iOS 'singletap' is the prefered listener, for Android 'touchstart' is prefered
     * 'click' listener is to slow to emit the images fast... but you decide what you do... just a proposal....
     */
    buttonView.addEventListener("touchstart",function(e){
        if (!isAnimating){
            isAnimating = true;
            buttonView.animate(touchStartAnim);
        }
 
        // the emitImage method can also be called without the button 'singletap' listener, it´s important that the parameter 'sourceView' is set to a view where the images will be emitted from
        emitterView.emitImage({
            sourceView:buttonView, // obligatory!!!
            startId:1, // optional
    		endId:(emitterImages.length - 1), // optional
            // id:0 // optional - select a specific image from the 'particleImages' array to be emitted
       });
    });

    var tab = Ti.UI.createTab({
        title: title,
        icon: icon,
        window: win
    });

    return tab;
}
