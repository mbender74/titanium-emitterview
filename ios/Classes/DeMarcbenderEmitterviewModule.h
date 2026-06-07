/**
 * titanium-emitterview
 *
 * Created by Marc Bender
 * Copyright (c) 2026 marc_bender. All rights reserved.
 */

#import "TiModule.h"

@interface DeMarcbenderEmitterviewModule : TiModule
{
}

// Particle Type Constants
@property (nonatomic, readonly) NSNumber *PARTICLE_CUSTOM;
@property (nonatomic, readonly) NSNumber *PARTICLE_CONFETTI;
@property (nonatomic, readonly) NSNumber *PARTICLE_TRIANGLE;
@property (nonatomic, readonly) NSNumber *PARTICLE_STAR;
@property (nonatomic, readonly) NSNumber *PARTICLE_DIAMOND;
@property (nonatomic, readonly) NSNumber *PARTICLE_TEXT;

// Direction Constants
@property (nonatomic, readonly) NSNumber *DIRECTION_UP;
@property (nonatomic, readonly) NSNumber *DIRECTION_DOWN;
@property (nonatomic, readonly) NSNumber *DIRECTION_LEFT;
@property (nonatomic, readonly) NSNumber *DIRECTION_RIGHT;

@end
