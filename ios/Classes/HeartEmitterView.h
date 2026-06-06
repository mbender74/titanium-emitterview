//
//  HeartEmitterView.h
//  Heart-Emitter-View-iOS
//
//  Created by Ngo Than Phong on 3/11/17.
//  Copyright © 2017 kthangtd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EmitterDirection) {
    EmitterDirectionUp    = 0,  // Default: particles float upward
    EmitterDirectionDown  = 1,  // Particles fall downward
    EmitterDirectionLeft  = 2,  // Particles move left
    EmitterDirectionRight = 3   // Particles move right
};

@interface HeartEmitterView : UIView

@property (nonatomic, assign) CGFloat maxAmplitude;

@property (nonatomic, assign) CGPoint tapPoint;

@property (nonatomic, assign) CGFloat amplitude;

@property (nonatomic, assign) CFTimeInterval duration;

@property (nonatomic, assign) CFTimeInterval maxDuration;

@property (nonatomic, assign) NSInteger maximumCount;

@property (nonatomic, assign) NSInteger currentCount;

@property (nonatomic, assign) UIView *buttonView;

@property (nonatomic, assign) EmitterDirection direction;


- (void)emitImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
