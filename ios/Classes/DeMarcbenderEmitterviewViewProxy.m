#import "DeMarcbenderEmitterviewViewProxy.h"
#import "TiUtils.h"

@implementation DeMarcbenderEmitterviewViewProxy

- (id)init
{
    return [super init];
}
- (void)_destroy
{
    // This method is called from the dealloc method and is good place to
    // release any objects and memory that have been allocated for the view proxy.

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] _destroy");

    [super _destroy];
}

- (id)_initWithPageContext:(id<TiEvaluator>)context
{
    // This method is one of the initializers for the view proxy class. If the
    // proxy is created without arguments then this initializer will be called.
    // This method is also called from the other _initWithPageContext method.
    // The superclass method calls the init and _configure methods.

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] _initWithPageContext (no arguments)");

    return [super _initWithPageContext:context];
}

- (id)_initWithPageContext:(id<TiEvaluator>)context_ args:(NSArray *)args
{
    // This method is one of the initializers for the view proxy class. If the
    // proxy is created with arguments then this initializer will be called.
    // The superclass method calls the _initWithPageContext method without
    // arguments.

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] _initWithPageContext %@", args);

    return [super _initWithPageContext:context_ args:args];
}

- (void)_configure
{
    // This method is called from _initWithPageContext to allow for
    // custom configuration of the module before startup. The superclass
    // method calls the startup method.

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] _configure");

    [super _configure];
}

- (void)_initWithProperties:(NSDictionary *)properties
{
    // This method is called from _initWithPageContext if arguments have been
    // used to create the view proxy. It is called after the initializers have completed
    // and is a good point to process arguments that have been passed to the
    // view proxy create method since most of the initialization has been completed
    // at this point.

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] _initWithProperties %@", properties);

    [super _initWithProperties:properties];
}

- (void)viewWillAttach
{
    // This method is called right before the view is attached to the proxy

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] viewWillAttach");
}

- (void)viewDidAttach
{
    // View attached to proxy
}

- (void)viewDidDetach
{
    // This method is called right before the view is detached from the proxy

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] viewDidDetach");
}

- (void)viewWillDetach
{
    // This method is called right after the view has detached from the proxy

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] viewWillDetach");
}

- (void)emitImage:(id)args
{
    [self makeViewPerformSelector:@selector(emitHeart:) withObject:args createIfNeeded:YES waitUntilDone:NO];
}

- (void)start:(id)args
{
    [self makeViewPerformSelector:@selector(start) withObject:nil createIfNeeded:YES waitUntilDone:NO];
}

- (void)stop:(id)args
{
    [self makeViewPerformSelector:@selector(stop) withObject:nil createIfNeeded:YES waitUntilDone:NO];
}

- (void)pause:(id)args
{
    [self makeViewPerformSelector:@selector(pause) withObject:nil createIfNeeded:YES waitUntilDone:NO];
}

- (void)resume:(id)args
{
    [self makeViewPerformSelector:@selector(resume) withObject:nil createIfNeeded:YES waitUntilDone:NO];
}

- (NSNumber *)isActive
{
    if (![self viewAttached]) {
        return @NO;
    }
    return [(DeMarcbenderEmitterviewView *)[self view] isActive];
}

@end
