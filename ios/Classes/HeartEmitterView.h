//
//  HeartEmitterView.h
//  titanium-emitterview
//
//  CAEmitterLayer-based particle emitter view.
//  Based on RainConfetti by linghugoogle.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EmitterDirection) {
    EmitterDirectionUp    = 0,
    EmitterDirectionDown  = 1,
    EmitterDirectionLeft  = 2,
    EmitterDirectionRight = 3
};

typedef NS_ENUM(NSInteger, ParticleType) {
    ParticleTypeCustom    = 0,
    ParticleTypeConfetti  = 1,
    ParticleTypeTriangle  = 2,
    ParticleTypeStar      = 3,
    ParticleTypeDiamond   = 4,
    ParticleTypeText      = 5
};

@interface HeartEmitterView : UIView

// Direction & Type
@property (nonatomic, assign) EmitterDirection direction;
@property (nonatomic, assign) ParticleType particleType;

// Emitter parameters (CAEmitterCell properties)
@property (nonatomic, assign) CGFloat intensity;         // 0.0 - 1.0, birthRate = intensity * 10
@property (nonatomic, strong) NSArray<UIColor *> *colors;
@property (nonatomic, assign) CGFloat velocity;
@property (nonatomic, assign) CGFloat velocityRange;
@property (nonatomic, assign) CGFloat spin;              // stored in radians/sec internally
@property (nonatomic, assign) CGFloat spinRange;         // stored in radians/sec internally
@property (nonatomic, assign) CGFloat lifetime;
@property (nonatomic, assign) CGFloat scaleRange;
@property (nonatomic, assign) CGFloat scaleSpeed;
@property (nonatomic, assign) CGFloat emissionRange;     // radians, spread angle

// Text particles
@property (nonatomic, copy) NSString *particleText;
@property (nonatomic, strong) UIFont *particleFont;

// Auto-stop
@property (nonatomic, assign) CFTimeInterval autoStopDuration; // 0 = never
@property (nonatomic, assign) BOOL autoRemove;

// Sway (used by emitImage for bezier path wobble)
@property (nonatomic, assign) CGFloat amplitude;
@property (nonatomic, assign) CGFloat maxAmplitude;

// Position override for emitImage (sourceView support)
@property (nonatomic, assign) CGPoint emitterPosition;

// State
@property (nonatomic, readonly) BOOL isActive;

// Control
- (void)start;
- (void)stop;
- (void)pause;
- (void)resume;

// Legacy: single-burst emission of a custom image
- (void)emitImage:(UIImage *)image;

// Emit count particles from a single image with lateral spread and scale variation
- (void)emitImage:(UIImage *)image count:(NSInteger)count spread:(CGFloat)spread scaleRange:(CGFloat)scaleRange;

@end

NS_ASSUME_NONNULL_END