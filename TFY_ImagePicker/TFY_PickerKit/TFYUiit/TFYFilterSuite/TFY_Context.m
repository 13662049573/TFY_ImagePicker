//
//  TFY_Context.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Context.h"

NSString *__nonnull const TFYContextOptionsCGContextKey = @"CGContext";
NSString *__nonnull const TFYContextOptionsEAGLContextKey = @"EAGLContext";
NSString *__nonnull const TFYContextOptionsMTLDeviceKey = @"MTLDevice";

static NSDictionary *TFYContextCreateCIContextOptions() {
    return @{kCIContextWorkingColorSpace : [NSNull null], kCIContextOutputColorSpace : [NSNull null]};
}

@implementation TFY_Context

- (instancetype)initWithSoftwareRenderer:(BOOL)softwareRenderer {
    self = [super init];
    if (self) {
        NSMutableDictionary *options = TFYContextCreateCIContextOptions().mutableCopy;
        options[kCIContextUseSoftwareRenderer] = @(softwareRenderer);
        _CIContext = [CIContext contextWithOptions:options];
        _type = TFYContextTypeDefault;
    }
    return self;
}

- (instancetype)initWithCGContextRef:(CGContextRef)contextRef {
    self = [super init];
    
    if (self) {
#ifdef NSFoundationVersionNumber_iOS_9_0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            _CGContext = contextRef;
            _CIContext = [CIContext contextWithCGContext:contextRef options:TFYContextCreateCIContextOptions()];
            _type = TFYContextTypeCoreGraphics;
#pragma clang diagnostic pop
#endif
    }
    
    return self;
}

- (instancetype)initWithEAGLContext:(EAGLContext *)context {
    self = [super init];
    if (self) {
        _EAGLContext = context;
        _CIContext = [CIContext contextWithEAGLContext:_EAGLContext options:TFYContextCreateCIContextOptions()];
        _type = TFYContextTypeEAGL;
    }
    return self;
}

- (instancetype)initWithLargeImage {
    self = [self initWithSoftwareRenderer:NO];
    if (self) {
        _type = TFYContextTypeLargeImage;
    }
    return self;
}

#ifdef NSFoundationVersionNumber_iOS_9_0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (instancetype)initWithMTLDevice:(id<MTLDevice>)device {
    self = [super init];
    
    if (self) {
        _MTLDevice = device;
        _CIContext = [CIContext contextWithMTLDevice:device options:TFYContextCreateCIContextOptions()];
        _type = TFYContextTypeMetal;
    }
    
    return self;
}
#pragma clang diagnostic pop
#endif

- (void)dealloc
{
    if (_EAGLContext) {
        [EAGLContext setCurrentContext:nil];
        _EAGLContext = nil;
    }
    _CGContext = nil;
    _MTLDevice = nil;
    _CIContext = nil;
}

+ (TFYContextType)suggestedContextType {
    if ([self supportsType:TFYContextTypeEAGL]) {
        return TFYContextTypeEAGL;
    } else
    
#ifdef NSFoundationVersionNumber_iOS_9_0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        if ([self supportsType:TFYContextTypeCoreGraphics]) {
            return TFYContextTypeCoreGraphics;
#pragma clang diagnostic pop
#endif
    } else {
        return TFYContextTypeDefault;
    }
}

+ (BOOL)supportsType:(TFYContextType)contextType {
    id CIContextClass = [CIContext class];
    switch (contextType) {
#ifdef NSFoundationVersionNumber_iOS_9_0
        case TFYContextTypeMetal:
            return [CIContextClass respondsToSelector:@selector(contextWithMTLDevice:options:)] && MTLCreateSystemDefaultDevice();
#endif
        case TFYContextTypeEAGL:
            return [CIContextClass respondsToSelector:@selector(contextWithEAGLContext:options:)];
        case TFYContextTypeCoreGraphics:
            return [CIContextClass respondsToSelector:@selector(contextWithCGContext:options:)];
        case TFYContextTypeAuto:
        case TFYContextTypeDefault:
        case TFYContextTypeLargeImage:
            return YES;
    }
    return NO;
}

+ (TFY_Context *__nonnull)contextWithType:(TFYContextType)type options:(NSDictionary *__nullable)options {
    switch (type) {
        case TFYContextTypeAuto:
            return [self contextWithType:[self suggestedContextType] options:options];
#if !(TARGET_IPHONE_SIMULATOR)
#ifdef NSFoundationVersionNumber_iOS_9_0
        case TFYContextTypeMetal: {
            if (@available(iOS 8.0, *)) {
                id<MTLDevice> device = options[TFYContextOptionsMTLDeviceKey];
                if (device == nil) {
                    device = MTLCreateSystemDefaultDevice();
                }
                if (device == nil) {
                    [NSException raise:@"Metal Error" format:@"Metal is available on iOS 8 and A7 chips. Or higher."];
                }
                
                return [[self alloc] initWithMTLDevice:device];
            }
        }
#endif
#endif
        case TFYContextTypeCoreGraphics: {
            CGContextRef context = (__bridge CGContextRef)(options[TFYContextOptionsCGContextKey]);
            
            if (context == nil) {
                [NSException raise:@"MissingCGContext" format:@"LFContextTypeCoreGraphics needs to have a CGContext attached to the LFContextOptionsCGContextKey in the options"];
            }
            
            return [[self alloc] initWithCGContextRef:context];
        }
        case TFYContextTypeDefault:
            return [[self alloc] initWithSoftwareRenderer:NO];
        case TFYContextTypeLargeImage:
            return [[self alloc] initWithLargeImage];
        case TFYContextTypeEAGL:
        {
            EAGLContext *context = options[TFYContextOptionsEAGLContextKey];
            if (context == nil) {
                static dispatch_once_t onceToken;
                static EAGLSharegroup *lf_EAGLShareGroup ;
                dispatch_once(&onceToken, ^{
                    lf_EAGLShareGroup = [EAGLSharegroup new];
                    lf_EAGLShareGroup.debugLabel = @"TFY_Context";
                });
                context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:lf_EAGLShareGroup];
            }
            return [[self alloc] initWithEAGLContext:context];
        }
        default:
            [NSException raise:@"InvalidContextType" format:@"Invalid context type %d", (int)type];
            break;
    }
    return nil;
}


@end
