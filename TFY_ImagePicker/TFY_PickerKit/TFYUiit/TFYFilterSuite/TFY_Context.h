//
//  TFY_Context.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <Metal/Metal.h>

typedef NS_ENUM(NSInteger, TFYContextType) {
    TFYContextTypeAuto,
    TFYContextTypeMetal NS_ENUM_AVAILABLE_IOS(9_0),
    TFYContextTypeCoreGraphics NS_ENUM_AVAILABLE_IOS(9_0),
    TFYContextTypeEAGL,
    TFYContextTypeLargeImage,
    TFYContextTypeDefault,
};

extern NSString *__nonnull const TFYContextOptionsCGContextKey;
extern NSString *__nonnull const TFYContextOptionsEAGLContextKey;
extern NSString *__nonnull const TFYContextOptionsMTLDeviceKey;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_Context : NSObject
/**
 The CIContext
 */
@property (readonly, nonatomic) CIContext *__nonnull CIContext;

/**
 The type with with which this TFY_Context was created
 */
@property (readonly, nonatomic) TFYContextType type;

/**
 Will be non null if the type is TFYContextTypeEAGL
 */
@property (readonly, nonatomic) EAGLContext *__nullable EAGLContext;

/**
 Will be non null if the type is LFContextTypeMetal
 */
@property (readonly, nonatomic) id<MTLDevice> __nullable MTLDevice NS_ENUM_AVAILABLE_IOS(9_0);

/**
 Will be non null if the type is LFContextTypeCoreGraphics
 */
@property (readonly, nonatomic) CGContextRef __nullable CGContext;

/**
 Create and returns a new context with the given type. You must check
 whether the contextType is supported by calling +[LFContext supportsType:] before.
 */
+ (TFY_Context *__nonnull)contextWithType:(TFYContextType)type options:(NSDictionary *__nullable)options;

/**
 Returns whether the contextType can be safely created and used using +[LFContext contextWithType:]
 */
+ (BOOL)supportsType:(TFYContextType)contextType;

/**
 The context that will be used when using an Auto context type;
 */
+ (TFYContextType)suggestedContextType;

@end

NS_ASSUME_NONNULL_END
