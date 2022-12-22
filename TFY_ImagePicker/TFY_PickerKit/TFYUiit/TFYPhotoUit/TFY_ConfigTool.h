//
//  TFY_ConfigTool.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TFY_ConfigTool : NSObject

@property (nonatomic) UIColor *selectTitleColor;

@property (nonatomic) UIColor *normalTitleColor;

@property (nonatomic) CGSize itemSize;

@property (nonatomic) CGFloat itemMargin;

@property (nonatomic) dispatch_queue_t concurrentQueue;

/** 占位图，为nil不显示 */
@property (nonatomic, nullable) UIImage *normalImage;

/** 加载失败图，为nil不显示 */
@property (nonatomic, nullable) UIImage *failureImage;

+ (instancetype)shareInstance;

+ (void)free;

@end

NS_ASSUME_NONNULL_END
