/**
 * Require emitterView Module
 */
 var emitterViewModule = require('de.marcbender.emitterview');

/**
 * Require IconicFont and FontAwesome
 */
 var fontawesome = require('/lib/IconicFont').IconicFont({font: '/lib/FontAwesome',ligature: false});



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

var buttonViewIsAnimating = false;
var buttonView2IsAnimating = false;

function generateThumbColorImage(color,icon,height){

    return Ti.UI.createLabel({
        width:Ti.UI.SIZE,
        height:Ti.UI.SIZE,
        color: color,
        textAlign:Titanium.UI.TEXT_ALIGNMENT_CENTER,
        font: {
            fontSize:(!height) ? 38 : (Ti.Platform.osname === 'android') ? (height/Ti.Platform.displayCaps.logicalDensityFactor) : height-2,
            fontFamily:fontawesome.fontfamily()
        },
        text: (!icon) ? fontawesome.icon('icon-thumbs-up') : fontawesome.icon(icon) 
     }).toImage(null,false);

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
    label.addEventListener("click",function(e){
        alert("asdfasdf");
    });

    win.add(label);


    /**
     * Add images to an array that is needed for the emitterView
     */
    var emitterImages = [];
    emitterImages.push("/images/heart2.png");
    emitterImages.push(generateThumbColorImage('red','fa-heart',40));
    emitterImages.push(generateThumbColorImage('red',null,40));
    emitterImages.push(generateThumbColorImage('yellow',null,40));
    emitterImages.push(generateThumbColorImage('orange',null,40));
    emitterImages.push(generateThumbColorImage('blue',null,40));
    emitterImages.push(generateThumbColorImage('purple',null,40));
    emitterImages.push(generateThumbColorImage('green',null,40));
    emitterImages.push(generateThumbColorImage('magenta',null,40));
    emitterImages.push(generateThumbColorImage('#16c7cd',null,40));

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
		amplitude:8, // Integer
        maxAmplitude:14, // Integer
        duration:(Ti.Platform.osname === 'android') ? 2.5 : 3.0, // Float - in seconds
        maxDuration:(Ti.Platform.osname === 'android') ? 3.0 : 3.5, // Float - in seconds
        particleImages:emitterImages, // array of images or imageBlobs
    })

    win.add(emitterView);

     /**
     * create a buttonView where the images to emit will be emitted from
     */
    var buttonView = Ti.UI.createView({
        width: Ti.UI.SIZE,
        height: Ti.UI.SIZE,
        bottom:70,
        left:20
     });

    var buttonLabel = Ti.UI.createLabel({
        width: Ti.UI.SIZE,
        height: Ti.UI.SIZE,
        color: 'blue',
        textAlign:Titanium.UI.TEXT_ALIGNMENT_CENTER,
        font: {
            fontSize: 36,
            fontFamily: fontawesome.fontfamily()
        },
        text:fontawesome.icon('icon-thumbs-up')
    });
    buttonView.add(buttonLabel);

    var buttonView2 = Ti.UI.createView({
        width: Ti.UI.SIZE,
        height: Ti.UI.SIZE,
        bottom:100,
        right:20
     });

    var buttonLabel2 = Ti.UI.createLabel({
        width: Ti.UI.SIZE,
        height: Ti.UI.SIZE,
        color: 'red',
        textAlign:Titanium.UI.TEXT_ALIGNMENT_CENTER,
        font: {
            fontSize: 36,
            fontFamily: fontawesome.fontfamily()
        },
        text:fontawesome.icon('fa-heart')
    });
    buttonView2.add(buttonLabel2);


 /**
 * Define Buttons touch animations
 */
    var touchStartAnim = Titanium.UI.createAnimation({
        duration: 90,
        opacity: 0.3,
        autoreverse:true
    });
    touchStartAnim.addEventListener('complete', function() {
        buttonViewIsAnimating = false;
    });

    var touchStartAnim2 = Titanium.UI.createAnimation({
        duration: 90,
        opacity: 0.3,
        autoreverse:true
    });
    touchStartAnim2.addEventListener('complete', function() {
        buttonView2IsAnimating = false;
    });


    /**
     * create an eventLister for the buttonView which will call the 'emitterView.emitImage({PARAMS})' method
     * for iOS 'singletap' is the prefered listener, for Android 'touchstart' is prefered
     * 'click' listener is to slow to emit the images fast... but you decide what you do... just a proposal....
     */
     buttonView.addEventListener("touchstart",function(e){
        if (buttonViewIsAnimating == false){
            buttonViewIsAnimating = true;
            buttonView.animate(touchStartAnim);
        }
            // the emitImage method can also be called without the button 'singletap' listener, it´s important that the parameter 'sourceView' is set to a view where the images will be emitted from
            emitterView.emitImage({
                sourceView:buttonView, // obligatory!!!
                startId:3, // optional
                endId:emitterImages.length, // optional
                // id:1 // optional - select a specific image from the 'particleImages' array to be emitted
            });

    });


    buttonView2.addEventListener("touchstart",function(e){
        if (buttonView2IsAnimating == false){
            buttonView2IsAnimating = true;
            buttonView2.animate(touchStartAnim2);
        } 
            // the emitImage method can also be called without the button 'singletap' listener, it´s important that the parameter 'sourceView' is set to a view where the images will be emitted from
            emitterView.emitImage({
                sourceView:buttonView2, // obligatory!!!
               // startId:1, // optional - start by 1
               // endId:2, // optional - ends by particleImages.length
                id:2 // optional - select a specific image from the 'particleImages' array to be emitted
            });

    });
    win.add(buttonView);
    win.add(buttonView2);

    var tab = Ti.UI.createTab({
        title: title,
        icon: icon,
        window: win
    });

    return tab;
}
