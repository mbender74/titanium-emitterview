//
//  HeartEmitterView.m
//  Heart-Emitter-View-iOS
//
//  Created by Ngo Than Phong on 3/11/17.
//  Copyright © 2017 kthangtd. All rights reserved.
//

#import "HeartEmitterView.h"

@interface HeartEmitterView ()

@end

@implementation HeartEmitterView

#pragma mark ---- < Init >

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.maxAmplitude = 14;
    self.amplitude = 8;
    
    self.duration = 3.0;
    self.maxDuration = 3.5;
    
    self.maximumCount = 100;
    self.currentCount = 0;
}

#pragma mark ---- < Deinit >

- (void)dealloc {
    // Remove all animation layers
    NSArray<CALayer *> *layers = self.layer.sublayers;
    for (CALayer *layer in layers) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }
}

-(CGFloat)randomFloat:(CGFloat)min max:(CGFloat)max {
    return min + ((CGFloat)arc4random_uniform(UINT32_MAX) / UINT32_MAX) * (max - min);
}

- (UIBezierPath *)getPathInRect:(CGRect)rect startPoint:(CGPoint)start endPoint:(CGPoint)end amplitude:(CGFloat)amplitude offset:(CGFloat)offset {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    // Use ~40 key points instead of pixel-by-pixel for performance
    NSUInteger numPoints = 40;
    CGFloat totalDistance = end.y - start.y;
    CGFloat step = totalDistance / (CGFloat)numPoints;
    
    for (NSUInteger i = 0; i <= numPoints; i++) {
        CGFloat y = start.y - step * i;
        CGFloat normalizedY = (CGFloat)i / (CGFloat)numPoints;
        
        // Sinusoidal wave for natural sway
        CGFloat x = amplitude * sinf((normalizedY * M_PI * 2.0f) + offset);
        
        CGPoint point = CGPointMake(start.x + x, y);
        
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    
    return path;
}

- (void)emitImage:(UIImage *)image {
    if (!image || !image.CGImage) {
        return;
    }
    
    if (self.maximumCount > 0 && self.currentCount >= self.maximumCount) {
        return;
    }
    
    self.currentCount += 1;
    
    const CGFloat duration = [self randomFloat:self.duration max:self.maxDuration];
    
    CALayer *layer = [[CALayer alloc] init];
    layer.contents = (__bridge id _Nullable)(image.CGImage);
    layer.contentsScale = self.window.screen.scale;
    layer.opacity = 1.0f;
    layer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Calculate start position
    CGPoint startPoint;
    CGFloat height = CGRectGetHeight(self.bounds);
    
    if (self.buttonView && !CGPointEqualToPoint(self.tapPoint, CGPointZero)) {
        startPoint = CGPointMake(self.tapPoint.x - image.size.width / 2.0f, self.tapPoint.y - image.size.height / 2.0f);
    } else if (self.buttonView) {
        startPoint = CGPointMake(CGRectGetMidX(self.buttonView.frame) - image.size.width / 2.0f,
                                  CGRectGetMaxY(self.buttonView.frame) - image.size.height / 2.0f);
    } else {
        startPoint = CGPointMake(CGRectGetMidX(self.bounds) - image.size.width / 2.0f, height - image.size.height / 2.0f);
    }
    
    layer.position = startPoint;
    
    [self.layer addSublayer:layer];
    
    // Calculate end point (above the view with random vertical offset)
    CGPoint endPoint = CGPointMake(startPoint.x, startPoint.y - height * 0.8f);
    
    // Random amplitude between amplitude and amplitude + maxAmplitude
    CGFloat finalAmplitude = self.amplitude + arc4random_uniform((NSUInteger)self.maxAmplitude);
    CGFloat offset = (CGFloat)arc4random_uniform(1000) * ((CGFloat)M_PI / 500.0f);
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [layer removeFromSuperlayer];
        self.currentCount -= 1;
    }];
    
    // Scale animation: 0.3x → 1.0x
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D startingScale = CATransform3DScale(layer.transform, 0.3f, 0.3f, 1.0f);
    CATransform3D fullScale = CATransform3DIdentity;
    
    scale.values = @[[NSValue valueWithCATransform3D:startingScale],
                     [NSValue valueWithCATransform3D:fullScale]];
    scale.keyTimes = @[@0.0f, @0.75f];
    scale.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    scale.fillMode = kCAFillModeForwards;
    scale.removedOnCompletion = NO;
    [layer addAnimation:scale forKey:@"transform"];
    
    // Position animation with bezier path
    CAKeyframeAnimation *position = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    position.path = [self getPathInRect:self.bounds
                              startPoint:startPoint
                               endPoint:endPoint
                              amplitude:finalAmplitude
                               offset:offset].CGPath;
    position.duration = duration;
    [layer addAnimation:position forKey:@"position"];
    
    // Opacity fade-out starting at 50% of animation
    const CGFloat fadeDelay = duration * 0.5f;
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = @1.0f;
    opacity.toValue = @0.0f;
    opacity.beginTime = CACurrentMediaTime() + fadeDelay;
    opacity.fillMode = kCAFillModeForwards;
    opacity.removedOnCompletion = NO;
    opacity.duration = duration - fadeDelay;
    [layer addAnimation:opacity forKey:@"opacity"];
    
    [CATransaction commit];
}

@end
