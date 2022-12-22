//
//  TFY_BrushCache.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_BrushCache.h"
#import <UIKit/UIKit.h>

@interface TFY_BrushCache ()
@property (nonatomic, strong) NSMutableDictionary *forceCache;
@end

@implementation TFY_BrushCache
static TFY_BrushCache *picker_BrushCacheShare = nil;
+ (instancetype)share
{
    if (picker_BrushCacheShare == nil) {
        picker_BrushCacheShare = [[TFY_BrushCache alloc] init];
        picker_BrushCacheShare.name = @"BrushCache";
    }
    return picker_BrushCacheShare;
}

+ (void)free
{
    [picker_BrushCacheShare removeAllObjects];
    picker_BrushCacheShare = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _forceCache = [NSMutableDictionary dictionary];
        //收到系统内存警告后直接调用 removeAllObjects 删除所有缓存对象
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)setForceObject:(id)obj forKey:(id)key
{
    [self.forceCache setObject:obj forKey:key];
}

- (void)removeObjectForKey:(id)key
{
    [self.forceCache removeObjectForKey:key];
    [super removeObjectForKey:key];
}

- (id)objectForKey:(id)key
{
    id obj = [self.forceCache objectForKey:key];
    if (obj) {
        return obj;
    }
    return [super objectForKey:key];
}

- (void)removeAllObjects
{
    [self.forceCache removeAllObjects];
    [super removeAllObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}
@end
