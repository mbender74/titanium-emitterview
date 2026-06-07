#import "TiUIView.h"
#import "HeartEmitterView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeMarcbenderEmitterviewView : TiUIView

#pragma mark Public APIs
- (void)emitHeart:(id)args;
- (void)start;
- (void)stop;
- (void)pause;
- (void)resume;
- (NSNumber *)isActive;

@end

NS_ASSUME_NONNULL_END