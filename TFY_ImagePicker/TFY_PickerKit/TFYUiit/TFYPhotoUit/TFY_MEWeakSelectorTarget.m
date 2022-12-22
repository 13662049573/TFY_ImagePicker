//
//  TFY_MEWeakSelectorTarget.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_MEWeakSelectorTarget.h"

@implementation TFY_MEWeakSelectorTarget

- (instancetype)initWithTarget:(id)target targetSelector:(SEL)sel {
    self = [super init];
    
    if (self) {
        _target = target;
        _targetSelector = sel;
    }
    
    return self;
}

- (BOOL)sendMessageToTarget:(id)param {
    id strongTarget = _target;
    
    if (strongTarget != nil) {
        if ([strongTarget respondsToSelector:_targetSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [strongTarget performSelector:_targetSelector withObject:param];
#pragma clang diagnostic pop
        }
        
        return YES;
    }
    
    return NO;
}

- (SEL)handleSelector {
    return @selector(sendMessageToTarget:);
}

@end
