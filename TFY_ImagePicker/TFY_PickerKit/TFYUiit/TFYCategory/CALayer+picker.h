//
//  CALayer+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (picker)
/** 层级（区分不同的画笔所画的图层） */
@property (nonatomic, assign) NSInteger picker_level;
@end

NS_ASSUME_NONNULL_END
