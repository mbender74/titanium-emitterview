#import "TiUIView.h"
#import "HeartEmitterView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeMarcbenderEmitterviewView: TiUIView

@property (nonatomic, strong, readonly) NSMutableArray<UIImage *> *imagesList;

#pragma mark Public APIs
- (void)emitHeart:(id)args;

@end

NS_ASSUME_NONNULL_END
