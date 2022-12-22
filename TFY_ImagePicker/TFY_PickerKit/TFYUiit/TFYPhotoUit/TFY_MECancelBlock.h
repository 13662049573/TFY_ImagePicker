//
//  TFY_MECancelBlock.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^picker_me_dispatch_cancelable_block_t)(BOOL cancel);

OBJC_EXTERN picker_me_dispatch_cancelable_block_t picker_dispatch_block_t(NSTimeInterval delay, void(^block)(void));

OBJC_EXTERN void picker_me_dispatch_cancel(picker_me_dispatch_cancelable_block_t block);

NS_ASSUME_NONNULL_END
