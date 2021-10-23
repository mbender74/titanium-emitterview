#import "TiUIView.h"
#import "HeartEmitterView.h"


@interface DeMarcbenderEmitterviewView: TiUIView {

    HeartEmitterView *emitterView;
    UIView *buttonView;
    float boundsWidth;
    float boundsHeight;
    NSMutableArray *imagesList;
}
@property (weak, nonatomic) HeartEmitterView * thisEmitterView;
#pragma Public APIs
- (void)emitHeart:(id)args;
@end
