//
//  HeartEmitterView.m
//  Heart-Emitter-View-iOS
//
//  Created by Ngo Than Phong on 3/11/17.
//  Copyright © 2017 kthangtd. All rights reserved.
//

#import "HeartEmitterView.h"
#import "DeMarcbenderEmitterviewViewProxy.h"

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
    self.maxAmplitude = 3;
    self.amplitude = 12;
    
    self.duration = 4;
    self.maxDuration = 4;
    
    self.maximumCount = 100;
    self.currentCount = 0;
    self.unusedLayers = [NSMutableArray array];
}

#pragma mark ---- < Deinit >

- (void)dealloc {
    [self.unusedLayers removeAllObjects];
    self.unusedLayers = nil;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

-(float)randomFloat:(float)min max:(float)max {
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(max-min)+min;
}


-(int)getRandomNumberBetween:(float)from and:(float)to {
   
    return (int)(from*1000) + arc4random() % ((int)(to*1000)-(int)(from*1000));
}

- (UIBezierPath *)getPathInRect:(CGRect)rect {
    CGFloat centerX;
    CGFloat y;
    CGFloat height = CGRectGetHeight(rect);

    if (!CGPointEqualToPoint(self.tapPoint, CGPointZero)){
        centerX = self.tapPoint.x;
//        centerX = self.tapPoint.x - rect.size.width/4;

        y = height;
    }
    else {
        centerX = CGRectGetMidX(rect);
        y = height;
    }
    UIBezierPath * path = [[UIBezierPath alloc] init];
    CGFloat offset = arc4random() % 1000;
    //CGFloat finalAmplitude = self.amplitude + arc4random() % self.maxAmplitude * 2 - self.maxAmplitude;

    CGFloat finalAmplitude = self.amplitude % arc4random_uniform((int)self.maxAmplitude);

    CGFloat delta = 0.0;
    while (y >= 0) {
        CGFloat x = finalAmplitude * sinf((y + offset) * ((float)M_PI)/180.0);
        if (y == height) {
            delta = x;
            
            y = self.buttonView.frame.origin.y + self.buttonView.frame.size.height/2;
            
            [path moveToPoint:CGPointMake(centerX, y)];
          //  y = y - ceilf(self.buttonView.frame.size.height/2);
        } else {
            [path addLineToPoint:CGPointMake(x + centerX - delta, y)];
            
        }
        y -= 1;
    }
    return path;
}

- (void)emitImage:(UIImage *)image {
    if (self.currentCount >= self.maximumCount) {
        return;
    }
    
    self.currentCount += 1;
    const CGFloat height = CGRectGetHeight(self.bounds);
    const CGFloat percen = (float)(arc4random() % 100) / 100.0;
    
    const CGFloat duration = ([self randomFloat:self.duration max:self.maxDuration]);
    CALayer * layer;
    layer = [[CALayer alloc] init];
    layer.contents = (__bridge id _Nullable)(image.CGImage);
    layer.opacity = 1;
    layer.frame = CGRectMake(0, 0, image.size.width, image.size.height);

    if (!CGPointEqualToPoint(self.tapPoint, CGPointZero)){
       layer.position = CGPointMake(self.tapPoint.x-(self.bounds.size.width/4), self.tapPoint.y-height/2);
    }
    else {
        layer.position = CGPointMake(self.tapPoint.x-(self.buttonView.frame.size.width/2), height);
    }
    
    [self.layer addSublayer:layer];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [layer removeFromSuperlayer];
        self.currentCount -= 1;
    }];
    
    
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D startingScale = CATransform3DScale (layer.transform, 0.3, 0.3, 0.3);
    CATransform3D fullScale = CATransform3DScale (layer.transform, 1.0, 1.0, 1.0);
   // CATransform3D endingScale = layer.transform;
    NSArray *boundsValues = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:startingScale],
                                                      [NSValue valueWithCATransform3D:fullScale],
                                                     // [NSValue valueWithCATransform3D:endingScale],
                             nil];
    [scale setValues:boundsValues];
    NSArray *times = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],
                      [NSNumber numberWithFloat:0.75f],
                       nil];
    [scale setKeyTimes:times];
    
    
    NSArray *timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                nil];
    [scale setTimingFunctions:timingFunctions];
    scale.fillMode = kCAFillModeForwards;
    scale.removedOnCompletion = NO;
    
    [layer addAnimation:scale forKey:@"transform"];

    
    
    CAKeyframeAnimation * position = [CAKeyframeAnimation animationWithKeyPath:@"position"];

    position.path = [self getPathInRect:self.bounds].CGPath;

    position.duration = duration;
    [layer addAnimation:position forKey:@"position"];
    
    const CGFloat delay = duration / 2;
    CABasicAnimation * opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = [NSNumber numberWithInt:1];
    opacity.toValue = [NSNumber numberWithInt:0];
    opacity.beginTime = CACurrentMediaTime() + delay;
    opacity.fillMode = kCAFillModeForwards;
    opacity.removedOnCompletion = NO;
    opacity.duration = duration - delay - 0.1;
    [layer addAnimation:opacity forKey:@"opacity"];
    
    [CATransaction commit];
}



//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//  return [super hitTest:point withEvent:event];
//}


@end
