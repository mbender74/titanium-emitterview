//
//  HeartEmitterView.m
//  titanium-emitterview
//
//  CAEmitterLayer-based particle emitter.
//  Based on RainConfetti by linghugoogle.
//

#import "HeartEmitterView.h"

@interface HeartEmitterView ()

@property (nonatomic, strong) CAEmitterLayer *emitterLayer;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, strong) NSTimer *autoStopTimer;
@property (nonatomic, assign) CGFloat savedBirthRate;

// Shape image caching (Task #4 optimization)
@property (nonatomic, strong) NSCache<NSString *, UIImage *> *shapeImageCache;
@property (nonatomic, strong) NSCache<NSString *, UIImage *> *textImageCache;

@end

@implementation HeartEmitterView

#pragma mark - Init

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
    self.direction = EmitterDirectionDown;
    self.particleType = ParticleTypeConfetti;

    self.intensity = 0.5;
    self.colors = @[
        [UIColor systemRedColor],
        [UIColor systemBlueColor],
        [UIColor systemGreenColor],
        [UIColor systemYellowColor],
        [UIColor systemPurpleColor],
        [UIColor systemOrangeColor],
        [UIColor systemPinkColor]
    ];
    self.velocity = 350;
    self.velocityRange = 80;
    self.spin = 2;
    self.spinRange = 3;
    self.lifetime = 7.0;
    self.scaleRange = 0.5;
    self.scaleSpeed = -0.05;
    self.emissionRange = M_PI / 4;
    self.amplitude = 8;
    self.maxAmplitude = 14;

    self.particleText = @"";
    self.particleFont = [UIFont systemFontOfSize:8 weight:UIFontWeightBold];

    self.autoStopDuration = 0;
    self.autoRemove = NO;

    self.isRunning = NO;
    self.isPaused = NO;

    self.userInteractionEnabled = NO;
    
    // Initialize shape and text image caches (Task #4 optimization)
    _shapeImageCache = [[NSCache alloc] init];
    _shapeImageCache.countLimit = 100;  // Cache up to 100 shape images
    _textImageCache = [[NSCache alloc] init];
    _textImageCache.countLimit = 200;  // Cache up to 200 text images
    
    [self setupEmitterLayer];
}

- (void)setupEmitterLayer {
    _emitterLayer = [CAEmitterLayer layer];
    _emitterLayer.emitterShape = kCAEmitterLayerLine;
    _emitterLayer.emitterPosition = CGPointMake(self.bounds.size.width / 2, -10);
    _emitterLayer.emitterSize = CGSizeMake(self.bounds.size.width, 1);
    [self.layer addSublayer:_emitterLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _emitterLayer.frame = self.bounds;
    _emitterLayer.emitterPosition = CGPointMake(self.bounds.size.width / 2, -10);
    _emitterLayer.emitterSize = CGSizeMake(self.bounds.size.width, 1);
}

- (void)dealloc {
    [self stop];
}

#pragma mark - Direction Mapping

- (CGFloat)emissionLongitudeForDirection {
    // CAEmitterCell emissionLongitude: 0 = right, π/2 = down, π = left, -π/2 = up
    switch (self.direction) {
        case EmitterDirectionUp:    return -M_PI_2;
        case EmitterDirectionDown:  return M_PI_2;
        case EmitterDirectionLeft:  return M_PI;
        case EmitterDirectionRight: return 0;
    }
    return M_PI_2; // default: down
}

- (CGFloat)emitterPositionYForDirection {
    switch (self.direction) {
        case EmitterDirectionDown:  return -10;
        case EmitterDirectionUp:    return self.bounds.size.height + 10;
        case EmitterDirectionLeft:  return self.bounds.size.height / 2;
        case EmitterDirectionRight: return self.bounds.size.height / 2;
    }
    return -10;
}

- (CGFloat)emitterPositionXForDirection {
    switch (self.direction) {
        case EmitterDirectionDown:  return self.bounds.size.width / 2;
        case EmitterDirectionUp:    return self.bounds.size.width / 2;
        case EmitterDirectionLeft:  return self.bounds.size.width + 10;
        case EmitterDirectionRight: return -10;
    }
    return self.bounds.size.width / 2;
}

- (void)updateEmitterPosition {
    // Use custom position if set (from emitImage sourceView), otherwise use direction default
    if (!CGPointEqualToPoint(self.emitterPosition, CGPointZero)) {
        _emitterLayer.emitterPosition = self.emitterPosition;
        _emitterLayer.emitterSize = CGSizeMake(1, 1);
        _emitterLayer.emitterShape = kCAEmitterLayerPoint;
    } else {
        CGFloat posX = [self emitterPositionXForDirection];
        CGFloat posY = [self emitterPositionYForDirection];
        _emitterLayer.emitterPosition = CGPointMake(posX, posY);

        if (self.direction == EmitterDirectionLeft || self.direction == EmitterDirectionRight) {
            _emitterLayer.emitterSize = CGSizeMake(1, self.bounds.size.height);
        } else {
            _emitterLayer.emitterSize = CGSizeMake(self.bounds.size.width, 1);
        }
        _emitterLayer.emitterShape = kCAEmitterLayerLine;
    }
}

#pragma mark - Shape Generation (with caching - Task #4 optimization)

// Helper: Create cache key from shape type and color hex string
- (NSString *)cacheKeyForShape:(NSString *)shapeType color:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"%@_%.0f_%.0f_%.0f", shapeType, 
            (NSInteger)(g * 255), (NSInteger)(b * 255), (NSInteger)(a * 255)];
}

- (UIImage *)generateConfettiImageWithColor:(UIColor *)color {
    NSString *cacheKey = [self cacheKeyForShape:@"confetti" color:color];
    UIImage *cached = [_shapeImageCache objectForKey:cacheKey];
    if (cached) return cached;
    
    CGSize size = CGSizeMake(12, 8);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [color setFill];
        CGContextRef cgCtx = ctx.CGContext;
        CGContextFillRect(cgCtx, CGRectMake(0, 0, size.width, size.height));
    }];
    [_shapeImageCache setObject:image forKey:cacheKey];
    return image;
}

- (UIImage *)generateTriangleImageWithColor:(UIColor *)color {
    NSString *cacheKey = [self cacheKeyForShape:@"triangle" color:color];
    UIImage *cached = [_shapeImageCache objectForKey:cacheKey];
    if (cached) return cached;
    
    CGSize size = CGSizeMake(12, 12);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [color setFill];
        CGContextRef cgCtx = ctx.CGContext;
        CGContextMoveToPoint(cgCtx, size.width / 2, 0);
        CGContextAddLineToPoint(cgCtx, size.width, size.height);
        CGContextAddLineToPoint(cgCtx, 0, size.height);
        CGContextClosePath(cgCtx);
        CGContextFillPath(cgCtx);
    }];
    [_shapeImageCache setObject:image forKey:cacheKey];
    return image;
}

- (UIImage *)generateStarImageWithColor:(UIColor *)color {
    NSString *cacheKey = [self cacheKeyForShape:@"star" color:color];
    UIImage *cached = [_shapeImageCache objectForKey:cacheKey];
    if (cached) return cached;
    
    CGSize size = CGSizeMake(16, 16);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [color setFill];
        CGContextRef cgCtx = ctx.CGContext;
        CGFloat outerRadius = size.width / 2;
        CGFloat innerRadius = size.width / 5;
        CGFloat centerX = size.width / 2;
        CGFloat centerY = size.height / 2;

        CGContextMoveToPoint(cgCtx, centerX, centerY - outerRadius);
        for (NSInteger i = 0; i < 5; i++) {
            CGFloat outerAngle = -M_PI / 2 + (i * 2 * M_PI / 5);
            CGFloat innerAngle = outerAngle + M_PI / 5;
            CGContextAddLineToPoint(cgCtx,
                centerX + cos(outerAngle) * outerRadius,
                centerY + sin(outerAngle) * outerRadius);
            CGContextAddLineToPoint(cgCtx,
                centerX + cos(innerAngle) * innerRadius,
                centerY + sin(innerAngle) * innerRadius);
        }
        CGContextClosePath(cgCtx);
        CGContextFillPath(cgCtx);
    }];
    [_shapeImageCache setObject:image forKey:cacheKey];
    return image;
}

- (UIImage *)generateDiamondImageWithColor:(UIColor *)color {
    NSString *cacheKey = [self cacheKeyForShape:@"diamond" color:color];
    UIImage *cached = [_shapeImageCache objectForKey:cacheKey];
    if (cached) return cached;
    
    CGSize size = CGSizeMake(12, 12);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [color setFill];
        CGContextRef cgCtx = ctx.CGContext;
        CGContextMoveToPoint(cgCtx, size.width / 2, 0);
        CGContextAddLineToPoint(cgCtx, size.width, size.height / 2);
        CGContextAddLineToPoint(cgCtx, size.width / 2, size.height);
        CGContextAddLineToPoint(cgCtx, 0, size.height / 2);
        CGContextClosePath(cgCtx);
        CGContextFillPath(cgCtx);
    }];
    [_shapeImageCache setObject:image forKey:cacheKey];
    return image;
}

- (UIImage *)generateTextImageForCharacter:(unichar)character color:(UIColor *)color {
    // Create cache key from character, color, and font
    NSString *charStr = [[NSString alloc] initWithCharacters:&character length:1];
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    NSString *cacheKey = [NSString stringWithFormat:@"text_%@_%.0f_%.0f_%.0f_%.0f",
            charStr, (NSInteger)(g * 255), (NSInteger)(b * 255), (NSInteger)(a * 255),
            self.particleFont.pointSize];
    
    UIImage *cached = [_textImageCache objectForKey:cacheKey];
    if (cached) return cached;
    
    NSDictionary *attrs = @{
        NSFontAttributeName: self.particleFont,
        NSForegroundColorAttributeName: color
    };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:charStr attributes:attrs];
    CGSize textSize = [attributedText size];

    CGSize imageSize = CGSizeMake(textSize.width + 4, textSize.height + 4);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [attributedText drawAtPoint:CGPointMake(2, 2)];
    }];
    [_textImageCache setObject:image forKey:cacheKey];
    return image;
}

#pragma mark - Emitter Cell Configuration

- (UIImage *)imageForParticleType {
    switch (self.particleType) {
        case ParticleTypeConfetti:
            return [self generateConfettiImageWithColor:[UIColor whiteColor]];
        case ParticleTypeTriangle:
            return [self generateTriangleImageWithColor:[UIColor whiteColor]];
        case ParticleTypeStar:
            return [self generateStarImageWithColor:[UIColor whiteColor]];
        case ParticleTypeDiamond:
            return [self generateDiamondImageWithColor:[UIColor whiteColor]];
        case ParticleTypeText:
        case ParticleTypeCustom:
            return nil;
    }
    return nil;
}

- (CAEmitterCell *)createCellWithImage:(UIImage *)image color:(UIColor *)color birthRate:(CGFloat)birthRate {
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (__bridge id _Nullable)(image.CGImage);
    cell.birthRate = birthRate;
    cell.lifetime = self.lifetime;
    cell.velocity = self.velocity;
    cell.velocityRange = self.velocityRange;
    cell.emissionLongitude = [self emissionLongitudeForDirection];
    cell.emissionRange = self.emissionRange;
    cell.spin = self.spin;
    cell.spinRange = self.spinRange;
    cell.scaleRange = self.scaleRange;
    cell.scaleSpeed = self.scaleSpeed;
    cell.color = color.CGColor;
    return cell;
}

- (void)updateEmitterCells {
    NSMutableArray<CAEmitterCell *> *cells = [NSMutableArray array];
    CGFloat birthRate = self.isRunning ? self.intensity * 10 : 0;

    if (self.particleType == ParticleTypeText && self.particleText.length > 0) {
        NSUInteger colorCount = self.colors.count;
        NSUInteger charCount = self.particleText.length;
        CGFloat charBirthRate = self.isRunning ? self.intensity * 10 / charCount : 0;

        for (NSUInteger i = 0; i < charCount; i++) {
            unichar character = [self.particleText characterAtIndex:i];
            UIColor *color = self.colors[i % colorCount];
            UIImage *image = [self generateTextImageForCharacter:character color:color];
            if (image) {
                CAEmitterCell *cell = [self createCellWithImage:image color:color birthRate:charBirthRate];
                [cells addObject:cell];
            }
        }
    } else if (self.particleType != ParticleTypeCustom) {
        UIImage *baseImage = [self imageForParticleType];
        if (baseImage) {
            for (UIColor *color in self.colors) {
                CAEmitterCell *cell = [self createCellWithImage:baseImage color:color birthRate:birthRate];
                [cells addObject:cell];
            }
        }
    }
    // ParticleTypeCustom: cells added via emitImage:

    _emitterLayer.emitterCells = cells.count > 0 ? cells : nil;
}

- (void)updateIntensity {
    if (!self.isRunning) return;
    CGFloat birthRate = self.intensity * 10;
    for (CAEmitterCell *cell in _emitterLayer.emitterCells) {
        cell.birthRate = birthRate;
    }
}

#pragma mark - Control Methods

- (void)start {
    if (self.isRunning) return;

    self.isRunning = YES;
    self.isPaused = NO;

    // Reset emitter position from custom override back to default
    self.emitterPosition = CGPointZero;
    [self updateEmitterPosition];
    [self updateEmitterCells];

    if (self.autoStopDuration > 0) {
        self.autoStopTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoStopDuration
                                                           repeats:NO
                                                             block:^(NSTimer *timer) {
            [self stop];
        }];
    }
}

- (void)stop {
    if (!self.isRunning) return;

    self.isRunning = NO;

    for (CAEmitterCell *cell in _emitterLayer.emitterCells) {
        cell.birthRate = 0;
    }

    [self.autoStopTimer invalidate];
    self.autoStopTimer = nil;

    if (self.autoRemove) {
        [self removeFromSuperview];
    }
}

- (void)pause {
    if (!self.isRunning || self.isPaused) return;
    self.isPaused = YES;
    self.savedBirthRate = self.intensity * 10;
    for (CAEmitterCell *cell in _emitterLayer.emitterCells) {
        cell.birthRate = 0;
    }
}

- (void)resume {
    if (!self.isRunning || !self.isPaused) return;
    self.isPaused = NO;
    for (CAEmitterCell *cell in _emitterLayer.emitterCells) {
        cell.birthRate = self.savedBirthRate;
    }
}

- (BOOL)isActive {
    return self.isRunning && !self.isPaused;
}

#pragma mark - Legacy Method (single-particle emission)

- (void)emitImage:(UIImage *)image {
    [self emitImage:image count:1 spread:0 scaleRange:0];
}

- (void)emitImage:(UIImage *)image count:(NSInteger)count spread:(CGFloat)spread scaleRange:(CGFloat)scaleRange {
    if (!image || !image.CGImage) return;

    NSInteger n = MAX(1, count);
    for (NSInteger i = 0; i < n; i++) {
        CGFloat scale = (i == 0) ? 1.0 : (1.0 - scaleRange * ((CGFloat)arc4random_uniform(101) / 100.0));
        [self emitSingleParticle:image spread:spread targetScale:scale];
    }
}

- (void)emitSingleParticle:(UIImage *)image spread:(CGFloat)spread targetScale:(CGFloat)targetScale {
    if (!image || !image.CGImage) return;

    CGFloat animDuration = self.lifetime > 0 ? self.lifetime : 3.0;
    CGFloat vel = self.velocity > 0 ? self.velocity : 350;
    // Each particle gets a slightly different velocity for natural spread
    CGFloat velocityVariance = self.velocityRange > 0 ? (arc4random_uniform((uint32_t)MAX(self.velocityRange, 1)) - self.velocityRange / 2) : 0;
    CGFloat computedVel = vel + velocityVariance;
    CGFloat swayAmount = self.amplitude + arc4random_uniform((uint32_t)MAX(self.maxAmplitude - self.amplitude, 1));

    CALayer *layer = [[CALayer alloc] init];
    layer.contents = (__bridge id _Nullable)(image.CGImage);
    layer.contentsScale = self.window ? self.window.screen.scale : self.traitCollection.displayScale;
    layer.frame = CGRectMake(0, 0, image.size.width, image.size.height);

    // Start position: use emitterPosition if set, otherwise use direction default
    CGFloat startX, startY;
    if (!CGPointEqualToPoint(self.emitterPosition, CGPointZero)) {
        startX = self.emitterPosition.x;
        startY = self.emitterPosition.y;
    } else {
        startX = arc4random_uniform((uint32_t)MAX(self.bounds.size.width, 1));
        switch (self.direction) {
            case EmitterDirectionDown:  startY = 0; break;
            case EmitterDirectionUp:    startY = self.bounds.size.height; break;
            case EmitterDirectionLeft:  startY = arc4random_uniform((uint32_t)MAX(self.bounds.size.height, 1)); startX = self.bounds.size.width; break;
            case EmitterDirectionRight: startY = arc4random_uniform((uint32_t)MAX(self.bounds.size.height, 1)); startX = 0; break;
            default: startY = 0; break;
        }
    }
    // Lateral spread: offset perpendicular to travel direction
    if (spread > 0) {
        if (self.direction == EmitterDirectionUp || self.direction == EmitterDirectionDown) {
            startX += ((CGFloat)arc4random_uniform((uint32_t)(spread * 2 + 1)) - spread);
        } else {
            startY += ((CGFloat)arc4random_uniform((uint32_t)(spread * 2 + 1)) - spread);
        }
    }
    layer.position = CGPointMake(startX, startY);
    [self.layer addSublayer:layer];

    // Calculate end position based on direction and velocity
    CGFloat distance = computedVel * animDuration;
    CGFloat endX = startX;
    CGFloat endY = startY;
    switch (self.direction) {
        case EmitterDirectionDown:  endY = startY + distance; break;
        case EmitterDirectionUp:    endY = startY - distance; break;
        case EmitterDirectionLeft:  endX = startX - distance; break;
        case EmitterDirectionRight: endX = startX + distance; break;
    }

    // Position animation with sway (bezier path for wobble)
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(startX, startY)];
    switch (self.direction) {
        case EmitterDirectionDown:
        case EmitterDirectionUp: {
            CGFloat midY = (startY + endY) / 2;
            [path addCurveToPoint:CGPointMake(endX, endY)
                    controlPoint1:CGPointMake(startX + swayAmount, midY)
                    controlPoint2:CGPointMake(endX - swayAmount, (startY + endY) * 0.75)];
            break;
        }
        case EmitterDirectionLeft:
        case EmitterDirectionRight: {
            CGFloat midX = (startX + endX) / 2;
            [path addCurveToPoint:CGPointMake(endX, endY)
                    controlPoint1:CGPointMake(midX, startY + swayAmount)
                    controlPoint2:CGPointMake((startX + endX) * 0.75, endY - swayAmount)];
            break;
        }
    }
    CAKeyframeAnimation *posAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    posAnim.path = path.CGPath;
    posAnim.duration = animDuration;

    // Scale animation: start small, grow to target scale
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D startScale = CATransform3DScale(CATransform3DIdentity, 0.3 * targetScale, 0.3 * targetScale, 1.0);
    CATransform3D fullScale = CATransform3DScale(CATransform3DIdentity, targetScale, targetScale, 1.0);
    scaleAnim.values = @[[NSValue valueWithCATransform3D:startScale], [NSValue valueWithCATransform3D:fullScale]];
    scaleAnim.keyTimes = @[@0.0, @0.75];
    scaleAnim.fillMode = kCAFillModeForwards;
    scaleAnim.removedOnCompletion = NO;

    // Opacity: fade out in second half
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = @1.0;
    opacityAnim.toValue = @0.0;
    opacityAnim.beginTime = CACurrentMediaTime() + animDuration * 0.5;
    opacityAnim.duration = animDuration * 0.5;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;

    // Rotation (wobble)
    if (self.spin > 0) {
        CGFloat spinAmount = self.spin + (arc4random_uniform((uint32_t)MAX(self.spinRange, 1)) - self.spinRange / 2) * 0.1;
        CABasicAnimation *rotAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotAnim.toValue = @(spinAmount * animDuration);
        rotAnim.duration = animDuration;
        [layer addAnimation:rotAnim forKey:@"rotation"];
    }

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [layer removeFromSuperlayer];
    }];
    [layer addAnimation:posAnim forKey:@"position"];
    [layer addAnimation:scaleAnim forKey:@"transform"];
    [layer addAnimation:opacityAnim forKey:@"opacity"];
    [CATransaction commit];
}

@end