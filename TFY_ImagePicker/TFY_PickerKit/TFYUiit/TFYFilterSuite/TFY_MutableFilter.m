//
//  TFY_MutableFilter.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_MutableFilter.h"
#import "TFY_Filter+Initialize.h"

@interface TFY_MutableFilter ()
{
    NSMutableArray <TFY_Filter *>*_subFilters;
}
@end

@implementation TFY_MutableFilter

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _subFilters = [NSMutableArray new];
        
        self.enabled = YES;
    }
    
    return self;
}

- (void)resetToDefaults {
    [super resetToDefaults];
    for (TFY_Filter *subFilter in _subFilters) {
        [subFilter resetToDefaults];
    }
}

- (BOOL)isEmpty {
    BOOL isEmpty = [super isEmpty];
    
    for (TFY_Filter *filter in _subFilters) {
        isEmpty &= filter.isEmpty;
    }
    
    return isEmpty;
}

- (CIImage *)imageByProcessingImage:(CIImage *)image atTime:(CFTimeInterval)time {
    if (!self.enabled) {
        return image;
    }
    
    for (TFY_Filter *filter in _subFilters) {
        image = [filter imageByProcessingImage:image atTime:time];
    }
    
    return [super imageByProcessingImage:image atTime:time];
}


#pragma mark - options

- (void)addSubFilter:(TFY_Filter *)subFilter {
    [_subFilters addObject:subFilter];
}

- (void)removeSubFilter:(TFY_Filter *)subFilter {
    [_subFilters removeObject:subFilter];
}

- (void)insertSubFilter:(TFY_Filter *)subFilter atIndex:(NSUInteger)index {
    [_subFilters insertObject:subFilter atIndex:index];
}

- (void)removeSubFilterAtIndex:(NSUInteger)index {
    [_subFilters removeObjectAtIndex:index];
}

- (NSArray <TFY_Filter *>*)subFilters {
    return [_subFilters copy];
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.enabled = [aDecoder decodeBoolForKey:@"Enabled"];
        
        if ([aDecoder containsValueForKey:@"SubFilters"]) {
            _subFilters = [[aDecoder decodeObjectForKey:@"SubFilters"] mutableCopy];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:self.enabled forKey:@"Enabled"];
    [aCoder encodeObject:_subFilters forKey:@"SubFilters"];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    TFY_MutableFilter *filter = [super copyWithZone:zone];
    
    if (filter != nil) {
        filter->_subFilters = [_subFilters mutableCopy];
    }
    
    return filter;
}

#pragma mark - Initialize
+ (instancetype)filterWithFilters:(NSArray *)filters {
    TFY_MutableFilter *filter = [[self class] emptyFilter];
    for (TFY_Filter *subFilter in filters) {
        [filter addSubFilter:subFilter];
    }
    return filter;
}


@end
