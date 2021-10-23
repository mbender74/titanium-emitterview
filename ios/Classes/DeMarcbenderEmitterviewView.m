#import "DeMarcbenderEmitterviewView.h"
#import <CommonCrypto/CommonDigest.h>
#import <TitaniumKit/ImageLoader.h>
#import <TitaniumKit/OperationQueue.h>
#import <TitaniumKit/TiBase.h>
#import <TitaniumKit/TiBlob.h>
#import <TitaniumKit/TiFile.h>
#import <TitaniumKit/TiProxy.h>
#import <TitaniumKit/TiUtils.h>
#import <TitaniumKit/TiViewProxy.h>
#import <TitaniumKit/TiUIViewProxy.h>
#import <TitaniumKit/UIImage+Resize.h>


@implementation DeMarcbenderEmitterviewView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    //NSLog(@"[SVGVIEW LIFECYCLE EVENT] willMoveToSuperview");
}

- (void)initializeState
{
    // This method is called right after allocating the view and
    // is useful for initializing anything specific to the view
    imagesList = [NSMutableArray array];
    // Creates and keeps a reference to the view upon initialization
    emitterView = [[HeartEmitterView alloc] initWithFrame:[self bounds]];
    emitterView.maxAmplitude = 4;
    emitterView.amplitude = 16;
    emitterView.duration = 4;
    emitterView.maxDuration = 4;
    emitterView.layer.masksToBounds = NO;
    emitterView.tapPoint = CGPointZero;
    emitterView.userInteractionEnabled = NO;
    emitterView.buttonView = nil;
    
    self.thisEmitterView = emitterView;
    [self addSubview:emitterView];
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    emitterView.clipsToBounds = NO;
    
    [self.proxy replaceValue:@"true" forKey:@"bubbleParent" notification:YES];
    [self.proxy replaceValue:@"false" forKey:@"touchEnabled" notification:YES];
    
    [super initializeState];
}

- (void)configurationSet
{
    [super configurationSet];
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    boundsWidth = bounds.size.width;
    boundsHeight = bounds.size.height;

    if (emitterView != nil) {
        [TiUtils setView:emitterView positionRect:bounds];
        emitterView.clipsToBounds = NO;
    }

}

- (UIImage *)rotatedImage:(UIImage *)originalImage
{
 //If autorotate is set to false and the image orientation is not UIImageOrientationUp create new image
 if (![TiUtils boolValue:[[self proxy] valueForUndefinedKey:@"autorotate"] def:YES] && (originalImage.imageOrientation != UIImageOrientationUp)) {
   UIImage *theImage = [UIImage imageWithCGImage:[originalImage CGImage] scale:[originalImage scale] orientation:UIImageOrientationUp];
   return theImage;
 } else {
   return originalImage;
 }
}

- (UIImage *)convertToUIImage:(id)arg
{
 UIImage *image = nil;

 if ([arg isKindOfClass:[TiBlob class]]) {
   TiBlob *blob = (TiBlob *)arg;
   image = [blob image];
 } else if ([arg isKindOfClass:[TiFile class]]) {
   TiFile *file = (TiFile *)arg;
   NSURL *fileUrl = [NSURL fileURLWithPath:[file path]];
   image = [[ImageLoader sharedLoader] loadImmediateImage:fileUrl];
 } else if ([arg isKindOfClass:[UIImage class]]) {
   // called within this class
   image = (UIImage *)arg;
 }
 return image;
}


- (NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max {
    return (int) min + arc4random_uniform((int)max - (int)min + 1);
}


- (void)setMaxAmplitude_:(id)args {
    emitterView.maxAmplitude = [TiUtils floatValue:args];
}

- (void)setAmplitude_:(id)args {
    emitterView.amplitude = [TiUtils floatValue:args];
}
- (void)setDuration_:(id)args {
    emitterView.duration = [TiUtils floatValue:args];
}
- (void)setMaxDuration_:(id)args {
    emitterView.maxDuration = [TiUtils floatValue:args];
}




- (void)setParticleImages_:(id)args {
    
    NSMutableArray *argsList = args;

    if (imagesList.count > 0){
        imagesList = [NSMutableArray array];
    }
    

    for (id imageObject in argsList){
        
        NSURL *imageURL = [[self proxy] sanitizeURL:imageObject];

        if (![imageURL isKindOfClass:[NSURL class]]) {
            if ([imageObject isKindOfClass:[TiBlob class]]) {
              TiBlob *blob = (TiBlob *)imageObject;
                [imagesList addObject:[blob image]];
            } else if ([imageObject isKindOfClass:[TiFile class]]) {
              TiFile *file = (TiFile *)imageObject;
              NSURL *fileUrl = [NSURL fileURLWithPath:[file path]];
                [imagesList addObject:[[ImageLoader sharedLoader] loadImmediateImage:fileUrl]];
            }
        }
        else {
            [imagesList addObject:[[ImageLoader sharedLoader] loadImmediateImage:imageURL]];
        }
    }
}

- (void)setButtonViewToEmitFrom_:(id)args {
    buttonView = [(TiViewProxy *)args view];
    
    if (buttonView != nil){
        emitterView.buttonView = buttonView;
    }
    
    UITapGestureRecognizer *singleFingerTap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(emitImageTouch:)];
    [buttonView addGestureRecognizer:singleFingerTap];
}

#pragma Public APIs


- (void)emitImageTouch:(UITapGestureRecognizer *)recognizer {
    emitterView.tapPoint = [recognizer locationInView:self.superview];
    [self emitHeart:nil];
}


- (void)emitHeart:(id)args {
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

    if([args valueForKey:@"sourceView"]){
            TiViewProxy *sourceViewProxy = [args valueForKey:@"sourceView"];
            self->emitterView.buttonView = (TiUIView*)sourceViewProxy.view;
            
            CGRect pointRect = [sourceViewProxy.view convertRect:sourceViewProxy.view.bounds toView:self.superview];
            self->emitterView.tapPoint = CGPointMake(pointRect.origin.x + ceilf(sourceViewProxy.view.bounds.size.width/2),pointRect.origin.y);
        }
    

        if (self->imagesList.count > 0){
            
            if([args valueForKey:@"id"]){
                int imageIndex = [TiUtils intValue:[args valueForKey:@"id"]]-1;
                if (imageIndex < self->imagesList.count){
                    [self.thisEmitterView emitImage:[self->imagesList objectAtIndex:imageIndex]];
                }
            }
            else {
                if([args valueForKey:@"startId"] && [args valueForKey:@"endId"]){
                    int startIndex = [TiUtils intValue:[args valueForKey:@"startId"]]-1;
                    int endIndex = [TiUtils intValue:[args valueForKey:@"endId"]]-1;
                    if (startIndex < self->imagesList.count && endIndex < self->imagesList.count){
                        [self.thisEmitterView emitImage:[self->imagesList objectAtIndex:[self randomNumberBetween:startIndex maxNumber:endIndex]]];
                    }
                }
                else {
                    [self.thisEmitterView emitImage:[self->imagesList objectAtIndex:[self randomNumberBetween:0 maxNumber:self->imagesList.count-1]]];
                }
            }
        }
    });
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  return [super hitTest:point withEvent:event];
}

@end
