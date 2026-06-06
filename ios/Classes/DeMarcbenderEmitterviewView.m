#import "DeMarcbenderEmitterviewView.h"
#import <TitaniumKit/ImageLoader.h>
#import <TitaniumKit/TiBase.h>
#import <TitaniumKit/TiBlob.h>
#import <TitaniumKit/TiFile.h>
#import <TitaniumKit/TiProxy.h>
#import <TitaniumKit/TiUtils.h>
#import <TitaniumKit/TiViewProxy.h>

@interface DeMarcbenderEmitterviewView () {
    HeartEmitterView *emitterView;
    UIView *buttonView;
    NSMutableArray *imagesList;
    NSCache *imageCache;
}

@end

@implementation DeMarcbenderEmitterviewView

#pragma mark - Lifecycle

- (void)initializeState {
    imagesList = [NSMutableArray array];
    imageCache = [[NSCache alloc] init];
    imageCache.countLimit = 50;
    
    // Create and configure the emitter view
    emitterView = [[HeartEmitterView alloc] initWithFrame:self.bounds];
    emitterView.layer.masksToBounds = NO;
    emitterView.userInteractionEnabled = NO;
    
    [self addSubview:emitterView];
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    emitterView.clipsToBounds = NO;
    
    // Configure proxy properties
    [self.proxy replaceValue:@(YES) forKey:@"bubbleParent" notification:YES];
    [self.proxy replaceValue:@(NO) forKey:@"touchEnabled" notification:YES];
    
    [super initializeState];
}

- (void)configurationSet {
    [super configurationSet];
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds {
    if (emitterView) {
        emitterView.frame = bounds;
    }
}

#pragma mark - Property Setters

- (void)setMaxAmplitude_:(id)args {
    if (args) {
        CGFloat value = [TiUtils floatValue:args];
        if (value > 0) {
            emitterView.maxAmplitude = value;
        }
    }
}

- (void)setAmplitude_:(id)args {
    if (args) {
        CGFloat value = [TiUtils floatValue:args];
        if (value > 0) {
            emitterView.amplitude = value;
        }
    }
}

- (void)setDuration_:(id)args {
    if (args) {
        CGFloat value = [TiUtils floatValue:args];
        if (value > 0.1) {
            emitterView.duration = value;
        }
    }
}

- (void)setMaxDuration_:(id)args {
    if (args) {
        CGFloat value = [TiUtils floatValue:args];
        if (value > 0.1) {
            emitterView.maxDuration = value;
        }
    }
}

- (void)setParticleImages_:(id)args {
    if (!args || ![args count]) {
        return;
    }
    
    // Safely copy the array to avoid mutation issues
    NSArray *argsList = [args copy];
    [imagesList setArray:[NSMutableArray array]];
    
    for (id imageObject in argsList) {
        if (!imageObject) {
            continue;
        }
        
        UIImage *image = [self loadImage:imageObject];
        if (image) {
            [imagesList addObject:image];
        }
    }
}

- (void)setButtonViewToEmitFrom_:(id)args {
    if (!args) {
        return;
    }
    
    buttonView = [(TiViewProxy *)args view];
    
    if (buttonView) {
        emitterView.buttonView = buttonView;
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emitImageTouch:)];
        [buttonView addGestureRecognizer:singleFingerTap];
    }
}

#pragma mark - Image Loading

- (UIImage *)loadImage:(id)imageObject {
    // Try cache first for URL/string objects
    if ([imageObject isKindOfClass:[NSString class]]) {
        NSString *key = (NSString *)imageObject;
        UIImage *cachedImage = [imageCache objectForKey:key];
        if (cachedImage) {
            return cachedImage;
        }
        
        UIImage *image = [[ImageLoader sharedLoader] loadImmediateImage:[NSURL URLWithString:key]];
        if (image) {
            [imageCache setObject:image forKey:key];
        }
        return image;
    }
    
    // Handle URL objects
    NSURL *imageURL = [imageObject isKindOfClass:[NSURL class]] ? imageObject : [[self.proxy sanitizeURL:imageObject] isKindOfClass:[NSURL class]] ? [self.proxy sanitizeURL:imageObject] : nil;
    
    if (imageURL) {
        NSString *key = imageURL.absoluteString;
        UIImage *cachedImage = [imageCache objectForKey:key];
        if (cachedImage) {
            return cachedImage;
        }
        
        UIImage *image = [[ImageLoader sharedLoader] loadImmediateImage:imageURL];
        if (image) {
            [imageCache setObject:image forKey:key];
        }
        return image;
    }
    
    // Handle TiBlob
    if ([imageObject isKindOfClass:[TiBlob class]]) {
        return [(TiBlob *)imageObject image];
    }
    
    // Handle TiFile
    if ([imageObject isKindOfClass:[TiFile class]]) {
        TiFile *file = (TiFile *)imageObject;
        NSURL *fileUrl = [NSURL fileURLWithPath:[file path]];
        return [[ImageLoader sharedLoader] loadImmediateImage:fileUrl];
    }
    
    return nil;
}

#pragma mark - Touch Handling

- (void)emitImageTouch:(UITapGestureRecognizer *)recognizer {
    if (self.superview) {
        emitterView.tapPoint = [recognizer locationInView:self.superview];
    }
    [self emitHeart:nil];
}

#pragma mark - Public APIs

- (void)emitHeart:(id)args {
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    if (!args) {
        args = @{};
    }
    
    // Handle sourceView
    if ([args valueForKey:@"sourceView"]) {
        TiViewProxy *sourceViewProxy = [args valueForKey:@"sourceView"];
        if (sourceViewProxy.view) {
            emitterView.buttonView = sourceViewProxy.view;
            
            CGRect pointRect = [sourceViewProxy.view convertRect:sourceViewProxy.view.bounds toView:self.superview];
            emitterView.tapPoint = CGPointMake(pointRect.origin.x + ceilf(sourceViewProxy.view.bounds.size.width / 2.0f),
                                               pointRect.origin.y);
        }
    }
    
    // Ensure we're on the main thread for layer operations
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self emitImageFromArgs:args];
        });
        return;
    }
    
    [self emitImageFromArgs:args];
}

- (void)emitImageFromArgs:(NSDictionary *)args {
    if (imagesList.count == 0) {
        return;
    }
    
    NSUInteger imageIndex = [self calculateImageIndexFromArgs:args];
    
    if (imageIndex < imagesList.count) {
        UIImage *image = imagesList[imageIndex];
        [emitterView emitImage:image];
    }
}

- (NSUInteger)calculateImageIndexFromArgs:(NSDictionary *)args {
    if ([args valueForKey:@"id"]) {
        int imageIndex = [TiUtils intValue:[args valueForKey:@"id"]] - 1;
        return MAX(0, imageIndex);
    }
    
    if ([args valueForKey:@"startId"] && [args valueForKey:@"endId"]) {
        int startIndex = [TiUtils intValue:[args valueForKey:@"startId"]] - 1;
        int endIndex = [TiUtils intValue:[args valueForKey:@"endId"]] - 1;
        
        if (startIndex < imagesList.count && endIndex < imagesList.count) {
            return (NSUInteger)(startIndex + arc4random_uniform((uint32_t)(endIndex - startIndex + 1)));
        }
    }
    
    return arc4random_uniform((uint32_t)imagesList.count);
}

@end
