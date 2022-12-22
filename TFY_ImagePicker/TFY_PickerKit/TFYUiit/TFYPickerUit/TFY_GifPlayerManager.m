//
//  TFY_GifPlayerManager.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_GifPlayerManager.h"

@interface TFY_GifSource : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *gifPath;
@property (nonatomic, strong) NSData *gifData;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, readonly) NSInteger frameCount;
@property (nonatomic, assign) CGFloat timestamp;
@property (nonatomic, assign) CGImageSourceRef gifSourceRef;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, copy) GifExecution execution;
@property (nonatomic, copy) GifFail fail;
@end

@implementation TFY_GifSource
@synthesize frameCount = _frameCount;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playing = YES;
    }
    return self;
}

- (NSInteger)frameCount
{
    if (_frameCount == 0) {
        _frameCount = CGImageSourceGetCount(self.gifSourceRef);
    }
    return _frameCount;
}

@end


@interface TFY_GifPlayerManager ()

@property (nonatomic, strong) CADisplayLink     *displayLink;
@property (nonatomic, strong) NSMapTable        *gifSourceMapTable;

@end

@implementation TFY_GifPlayerManager
static TFY_GifPlayerManager *_sharedInstance = nil;

+ (TFY_GifPlayerManager *)shared{
    if (_sharedInstance == nil) {
        _sharedInstance = [[TFY_GifPlayerManager alloc] init];
    }
    return _sharedInstance;
}

+ (void)free
{
    [_sharedInstance stopDisplayLink];
    _sharedInstance = nil;
}

- (id)init{
    self = [super init];
    if (self) {
        _gifSourceMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
    }
    return self;
}

- (void)dealloc
{
    for (NSString *key in self.gifSourceMapTable) {
        TFY_GifSource *ref = [self.gifSourceMapTable objectForKey:key];
        if (ref) {
            if (ref.gifSourceRef) {
                CFRelease(ref.gifSourceRef);
            }
            ref.execution = nil;
            ref.fail = nil;
            ref = nil;
        }
    }
    [_gifSourceMapTable removeAllObjects];
}

- (void)play{
    for (NSString *key in self.gifSourceMapTable) {
        TFY_GifSource *ref = [self.gifSourceMapTable objectForKey:key];
        if (ref.isPlaying) {
            [self playGif:ref];
        }
    }
    
}

- (void)stopDisplayLink{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}
- (void)stopGIFWithKey:(NSString *)key
{
    TFY_GifSource *ref = [self.gifSourceMapTable objectForKey:key];
    if (ref) {
        [self.gifSourceMapTable removeObjectForKey:key];
        if (ref.gifSourceRef) {
            CFRelease(ref.gifSourceRef);
        }
        ref.execution = nil;
        ref.fail = nil;
        ref = nil;
    }

    if (_gifSourceMapTable.count<1 && _displayLink) {
        [self stopDisplayLink];
    }
}

/** 暂停播放 */
- (void)suspendGIFWithKey:(NSString *)key
{
    TFY_GifSource *ref = [self.gifSourceMapTable objectForKey:key];
    if (ref) {
        ref.playing = NO;
    }
}
/** 恢复播放 */
- (void)resumeGIFWithKey:(NSString *)key execution:(GifExecution)executionBlock fail:(GifFail)failBlock
{
    TFY_GifSource *ref = [self.gifSourceMapTable objectForKey:key];
    if (ref) {
        ref.execution = [executionBlock copy];
        ref.fail = [failBlock copy];
        ref.playing = YES;
    }
}

- (BOOL)isGIFPlaying:(NSString *)key
{
    TFY_GifSource *ref = [self.gifSourceMapTable objectForKey:key];
    if (ref) {
        return ref.isPlaying;
    }
    return NO;
}

/** 是否存在 */
- (BOOL)containGIFKey:(NSString *)key
{
    TFY_GifSource *ref = [self.gifSourceMapTable objectForKey:key];
    return ref != nil;
}

- (TFY_GifSource *)imageSourceCreateWithData:(id)data
{
    TFY_GifSource *gifSource = [[TFY_GifSource alloc] init];
    if ([data isKindOfClass:[NSData class]]) {
        gifSource.gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
        gifSource.gifData = data;
    }else if ([data isKindOfClass:[NSString class]]) {
        gifSource.gifSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:data], NULL);
        gifSource.gifPath = data;
    } else {
        gifSource = nil;
    }
    return gifSource;
}

- (void)transformGifPathToSampBufferRef:(NSString *)gifPath key:(NSString *)key execution:(GifExecution)executionBlock fail:(GifFail)failBlock
{
    [self transformGifToSampBufferRef:gifPath key:key execution:executionBlock fail:failBlock];
}

- (void)transformGifDataToSampBufferRef:(NSData *)gifData key:(NSString *)key execution:(GifExecution)executionBlock fail:(GifFail)failBlock
{
    [self transformGifToSampBufferRef:gifData key:key execution:executionBlock fail:failBlock];
}

- (void)transformGifToSampBufferRef:(id)data key:(NSString *)key execution:(GifExecution)executionBlock fail:(GifFail)failBlock
{
    if (key && data && executionBlock && failBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            TFY_GifSource *existGifSource = [self.gifSourceMapTable objectForKey:key];
            if (!existGifSource) {
                TFY_GifSource *gifSource = [self imageSourceCreateWithData:data];
                gifSource.key = key;
                gifSource.execution = [executionBlock copy];
                gifSource.fail = [failBlock copy];
                if (!gifSource) {
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.gifSourceMapTable setObject:gifSource forKey:key];
                });
            } else {
                existGifSource.execution = [executionBlock copy];
                existGifSource.fail = [failBlock copy];
            }
        });
        if (!self.displayLink) {
            self.displayLink = [CADisplayLink displayLinkWithTarget:[TFY_PickerWeakProxy proxyWithTarget:self] selector:@selector(play)];
            [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        }
    }
}


- (void)playGif:(TFY_GifSource *)gifSource
{
    size_t sizeMin = MIN(gifSource.index+1, gifSource.frameCount-1);
    if (sizeMin == SIZE_MAX) {
        //若该Gif文件无法解释为图片，需要立即返回避免内存crash
        gifSource.fail(gifSource.key);
        [self stopGIFWithKey:gifSource.key];
        return;
    }
    
    float nextFrameDuration = [self frameDurationAtIndex:sizeMin ref:gifSource.gifSourceRef];
    if (gifSource.timestamp < nextFrameDuration) {
        gifSource.timestamp = gifSource.timestamp+self.displayLink.duration;
        return;
    }
    gifSource.index += 1;
    gifSource.index = gifSource.index % gifSource.frameCount;
    CGImageSourceRef ref = gifSource.gifSourceRef;
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(ref, gifSource.index, NULL);
    
    gifSource.execution(imageRef, gifSource.key);
    
    CGImageRelease(imageRef);
    gifSource.timestamp = 0.f;
}

- (float)frameDurationAtIndex:(size_t)index ref:(CGImageSourceRef)ref
{
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(ref, index, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
    NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
    if (dictRef) CFRelease(dictRef);
    if (unclampedDelayTime.floatValue) {
        return unclampedDelayTime.floatValue;
    }else if (delayTime.floatValue) {
        return delayTime.floatValue;
    }else{
        return .1;
    }
}

@end


@implementation TFY_PickerWeakProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[TFY_PickerWeakProxy alloc] initWithTarget:target];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}


@end
