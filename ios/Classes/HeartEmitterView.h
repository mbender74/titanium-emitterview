//
//  HeartEmitterView.h
//  Heart-Emitter-View-iOS
//
//  Created by Ngo Than Phong on 3/11/17.
//  Copyright © 2017 kthangtd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartEmitterView : UIView

@property (nonatomic, assign) NSInteger maxAmplitude;

@property (nonatomic, assign) CGPoint tapPoint;

@property (nonatomic, assign) NSInteger amplitude;

@property (nonatomic, assign) CFTimeInterval duration;

@property (nonatomic, assign) CFTimeInterval maxDuration;

@property (nonatomic, assign) NSInteger maximumCount;

@property (nonatomic, assign) NSInteger currentCount;

@property (nonatomic, strong) NSMutableArray * unusedLayers;

@property (nonatomic, assign) UIView *buttonView;


- (void)emitImage:(UIImage *)image;

@end
