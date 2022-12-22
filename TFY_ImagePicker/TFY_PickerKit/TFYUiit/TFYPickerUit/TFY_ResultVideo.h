//
//  TFY_ResultVideo.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_ResultObject.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ResultVideo : TFY_ResultObject
/** 封面图片 */
@property (nonatomic, readonly) UIImage *coverImage;
/** 视频数据 */
@property (nonatomic, readonly) NSData *data;
/** 视频地址 */
@property (nonatomic, readonly) NSURL *url;
/** 视频时长 */
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@end

NS_ASSUME_NONNULL_END
