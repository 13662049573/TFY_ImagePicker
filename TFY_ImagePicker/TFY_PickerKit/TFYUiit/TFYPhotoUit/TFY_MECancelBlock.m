//
//  TFY_MECancelBlock.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_MECancelBlock.h"

picker_me_dispatch_cancelable_block_t picker_dispatch_block_t(NSTimeInterval delay, void(^block)(void))
{
    __block picker_me_dispatch_cancelable_block_t cancelBlock = nil;
    picker_me_dispatch_cancelable_block_t delayBlcok = ^(BOOL cancel){
        if (!cancel) {
            if ([NSThread isMainThread]) {
                block();
            } else {
                dispatch_async(dispatch_get_main_queue(), block);
            }
        }
        if (cancelBlock) {
            cancelBlock = nil;
        }
    };
    cancelBlock = delayBlcok;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (cancelBlock) {
            cancelBlock(NO);
        }
    });
    return delayBlcok;
}

void picker_me_dispatch_cancel(picker_me_dispatch_cancelable_block_t block)
{
    if (block) {
        block(YES);
    }
}
