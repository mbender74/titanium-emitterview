#import "TiViewProxy.h"
#import "DeMarcbenderEmitterviewModule.h"
#import "DeMarcbenderEmitterviewView.h"
#import <TitaniumKit/TiViewProxy.h>
#import <TitaniumKit/TiProxy.h>
#import <TitaniumKit/TitaniumKit.h>

@interface DeMarcbenderEmitterviewViewProxy: TiViewProxy
{
}
@property (weak, nonatomic) DeMarcbenderEmitterviewView *myView;

- (void)start:(id)args __attribute__((TiMethod(start)));
- (void)stop:(id)args __attribute__((TiMethod(stop)));
- (void)pause:(id)args __attribute__((TiMethod(pause)));
- (void)resume:(id)args __attribute__((TiMethod(resume)));
- (NSNumber *)isActive __attribute__((TiMethod(isActive)));
- (void)emitImage:(id)args __attribute__((TiMethod(emitImage)));

@end
