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
    NSMutableArray<UIImage *> *imagesList;
    NSCache *imageCache;
}

@end

@implementation DeMarcbenderEmitterviewView

#pragma mark - Lifecycle

- (void)initializeState {
    imagesList = [NSMutableArray array];
    imageCache = [[NSCache alloc] init];
    imageCache.countLimit = 50;

    emitterView = [[HeartEmitterView alloc] initWithFrame:self.bounds];
    emitterView.userInteractionEnabled = NO;

    [self addSubview:emitterView];
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    emitterView.clipsToBounds = NO;

    [self.proxy replaceValue:@(YES) forKey:@"bubbleParent" notification:YES];
    [self.proxy replaceValue:@(NO) forKey:@"touchEnabled" notification:YES];

    [super initializeState];
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds {
    if (emitterView) {
        emitterView.frame = bounds;
    }
}

#pragma mark - Color Helper

- (UIColor *)hexStringToUIColor:(NSString *)hex {
    unsigned int rgb = 0;
    NSScanner *scanner = [NSScanner scannerWithString:[hex stringByReplacingOccurrencesOfString:@"#" withString:@""]];
    [scanner scanHexInt:&rgb];
    return [UIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0
                           green:((rgb >> 8) & 0xFF) / 255.0
                            blue:(rgb & 0xFF) / 255.0
                           alpha:1.0];
}

#pragma mark - Property Setters

- (void)setDirection_:(id)args {
    if (args) {
        NSInteger direction = [TiUtils intValue:args];
        if (direction >= 0 && direction <= 3) {
            emitterView.direction = (EmitterDirection)direction;
        }
    }
}

- (void)setParticleType_:(id)args {
    if (args) {
        NSInteger type = [TiUtils intValue:args];
        if (type >= 0 && type <= 5) {
            emitterView.particleType = (ParticleType)type;
        }
    }
}

- (void)setIntensity_:(id)args {
    if (args) {
        emitterView.intensity = MAX(0.0f, MIN(1.0f, [TiUtils floatValue:args]));
    }
}

- (void)setColors_:(id)args {
    if ([args isKindOfClass:[NSArray class]]) {
        NSMutableArray<UIColor *> *colors = [NSMutableArray array];
        for (id colorObj in args) {
            UIColor *color = nil;
            if ([colorObj isKindOfClass:[NSString class]]) {
                NSString *hex = (NSString *)colorObj;
                if ([hex hasPrefix:@"#"] || [hex hasPrefix:@"0x"]) {
                    color = [self hexStringToUIColor:hex];
                }
            }
            if (!color) {
                color = [TiUtils colorValue:colorObj];
            }
            if (color) {
                [colors addObject:color];
            }
        }
        if (colors.count > 0) {
            emitterView.colors = colors;
        }
    }
}

- (void)setVelocity_:(id)args {
    if (args) {
        emitterView.velocity = [TiUtils floatValue:args];
    }
}

- (void)setVelocityRange_:(id)args {
    if (args) {
        emitterView.velocityRange = [TiUtils floatValue:args];
    }
}

- (void)setSpin_:(id)args {
    if (args) {
        // JS API uses degrees, CAEmitterCell uses radians/sec
        emitterView.spin = [TiUtils floatValue:args] * M_PI / 180.0;
    }
}

- (void)setSpinRange_:(id)args {
    if (args) {
        // JS API uses degrees, CAEmitterCell uses radians/sec
        emitterView.spinRange = [TiUtils floatValue:args] * M_PI / 180.0;
    }
}

- (void)setLifetime_:(id)args {
    if (args) {
        CGFloat value = [TiUtils floatValue:args];
        if (value > 0) {
            emitterView.lifetime = value;
        }
    }
}

- (void)setScaleRange_:(id)args {
    if (args) {
        emitterView.scaleRange = [TiUtils floatValue:args];
    }
}

- (void)setScaleSpeed_:(id)args {
    if (args) {
        emitterView.scaleSpeed = [TiUtils floatValue:args];
    }
}

- (void)setEmissionRange_:(id)args {
    if (args) {
        // JS API uses degrees, CAEmitterCell uses radians
        emitterView.emissionRange = [TiUtils floatValue:args] * M_PI / 180.0;
    }
}

- (void)setAmplitude_:(id)args {
    if (args) {
        emitterView.amplitude = [TiUtils floatValue:args];
    }
}

- (void)setMaxAmplitude_:(id)args {
    if (args) {
        emitterView.maxAmplitude = [TiUtils floatValue:args];
    }
}

- (void)setText_:(id)args {
    if ([args isKindOfClass:[NSString class]]) {
        emitterView.particleText = (NSString *)args;
    }
}

- (void)setFont_:(id)args {
    if ([args isKindOfClass:[NSDictionary class]]) {
        NSDictionary *fontDict = (NSDictionary *)args;
        CGFloat size = [TiUtils floatValue:[fontDict objectForKey:@"fontSize"] def:8];
        NSString *family = [fontDict objectForKey:@"fontFamily"];

        UIFont *font = nil;
        if (family && ![family isEqualToString:@""]) {
            font = [UIFont fontWithName:family size:size];
        }
        if (!font) {
            font = [UIFont systemFontOfSize:size weight:UIFontWeightBold];
        }
        emitterView.particleFont = font;
    }
}

- (void)setAutoStopDuration_:(id)args {
    if (args) {
        emitterView.autoStopDuration = [TiUtils floatValue:args];
    }
}

- (void)setAutoRemove_:(id)args {
    if (args) {
        emitterView.autoRemove = [TiUtils boolValue:args];
    }
}

- (void)setParticleImages_:(id)args {
    if (!args || ![args count]) {
        return;
    }

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

#pragma mark - Image Loading

- (UIImage *)loadImage:(id)imageObject {
    if ([imageObject isKindOfClass:[NSString class]]) {
        NSString *key = (NSString *)imageObject;
        UIImage *cachedImage = [imageCache objectForKey:key];
        if (cachedImage) {
            return cachedImage;
        }

        // Use TiUtils toURL to resolve relative paths correctly (e.g. /images/heart2.png)
        NSURL *url = [TiUtils toURL:key proxy:self.proxy];
        UIImage *image = [[ImageLoader sharedLoader] loadImmediateImage:url];
        if (image) {
            [imageCache setObject:image forKey:key];
        }
        return image;
    }

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

    if ([imageObject isKindOfClass:[TiBlob class]]) {
        return [(TiBlob *)imageObject image];
    }

    if ([imageObject isKindOfClass:[TiFile class]]) {
        TiFile *file = (TiFile *)imageObject;
        NSURL *fileUrl = [NSURL fileURLWithPath:[file path]];
        return [[ImageLoader sharedLoader] loadImmediateImage:fileUrl];
    }

    return nil;
}

#pragma mark - Image Selection

- (NSUInteger)calculateImageIndexFromArgs:(NSDictionary *)args {
    if ([args valueForKey:@"id"]) {
        // 0-based: id:0 = first image, id:1 = second image, etc.
        NSInteger imageIndex = [TiUtils intValue:[args valueForKey:@"id"]];
        return (NSUInteger)MAX(0, imageIndex);
    }
    if ([args valueForKey:@"startId"] && [args valueForKey:@"endId"]) {
        // 0-based: startId=0 means first image
        NSInteger startIndex = MAX(0, [TiUtils intValue:[args valueForKey:@"startId"]]);
        NSInteger endIndex = MAX(startIndex, [TiUtils intValue:[args valueForKey:@"endId"]]);
        if ((NSUInteger)startIndex < imagesList.count && (NSUInteger)endIndex < imagesList.count) {
            return (NSUInteger)(startIndex + arc4random_uniform((uint32_t)(endIndex - startIndex + 1)));
        }
    }
    return arc4random_uniform((uint32_t)imagesList.count);
}

#pragma mark - Public APIs

- (void)emitHeart:(id)args {
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);

    if (imagesList.count == 0) {
        return;
    }

    if (!args) {
        args = @{};
    }

    // Handle direction parameter
    if ([args valueForKey:@"direction"]) {
        NSInteger direction = [TiUtils intValue:[args valueForKey:@"direction"]];
        if (direction >= 0 && direction <= 3) {
            emitterView.direction = (EmitterDirection)direction;
        }
    }

    // Handle sourceView for emission position
    if ([args valueForKey:@"sourceView"]) {
        TiViewProxy *sourceViewProxy = [args valueForKey:@"sourceView"];
        if ([sourceViewProxy isKindOfClass:[TiViewProxy class]]) {
            UIView *sourceView = sourceViewProxy.view;
            if (sourceView && self.superview) {
                CGRect sourceRect = [sourceView convertRect:sourceView.bounds toView:self];
                emitterView.emitterPosition = CGPointMake(
                    sourceRect.origin.x + sourceRect.size.width / 2,
                    sourceRect.origin.y
                );
            }
        }
    }

    // Select image(s) based on id/startId/endId
    NSUInteger imageIndex = [self calculateImageIndexFromArgs:args];
    if (imageIndex < imagesList.count) {
        NSInteger emitValue = [args valueForKey:@"emitValue"] ? MAX(1, [TiUtils intValue:[args valueForKey:@"emitValue"]]) : 1;
        CGFloat emitSpread = [args valueForKey:@"emitSpread"] ? [TiUtils floatValue:[args valueForKey:@"emitSpread"]] : 0;
        CGFloat emitScaleRange = [args valueForKey:@"emitScaleRange"] ? [TiUtils floatValue:[args valueForKey:@"emitScaleRange"]] : 0;
        [emitterView emitImage:imagesList[imageIndex] count:emitValue spread:emitSpread scaleRange:emitScaleRange];
    }
}

- (void)start {
    [emitterView start];
}

- (void)stop {
    [emitterView stop];
}

- (void)pause {
    [emitterView pause];
}

- (void)resume {
    [emitterView resume];
}

- (NSNumber *)isActive {
    return @(emitterView.isActive);
}

@end