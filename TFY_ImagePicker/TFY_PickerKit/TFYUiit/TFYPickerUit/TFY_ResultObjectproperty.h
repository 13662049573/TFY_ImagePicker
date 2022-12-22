//
//  TFY_ResultObjectproperty.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#ifndef TFY_ResultObjectproperty_h
#define TFY_ResultObjectproperty_h

#import "TFY_ResultObject.h"
#import "TFY_ResultImage.h"
#import "TFY_ResultVideo.h"
#import "TFY_PickerResultInfo.h"

@interface TFY_ResultObject ()

/** PHAsset or ALAsset 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象 */
@property (nonatomic, strong) id asset;
/** 详情 */
@property (nonatomic, strong) TFY_PickerResultInfo *info;
/** 错误 */
@property (nonatomic, strong) NSError *error;

@end


@interface TFY_ResultImage ()

/** 缩略图 */
@property (nonatomic, strong) UIImage *thumbnailImage;
/** 缩略图数据 */
@property (nonatomic, strong) NSData *thumbnailData;
/** 原图／标清图 */
@property (nonatomic, strong) UIImage *originalImage;
/** 原图／标清图数据 */
@property (nonatomic, strong) NSData *originalData;

/** 子类型 */
@property (nonatomic, assign) TFYImagePickerSubMediaType subMediaType;

@end


@interface TFY_ResultVideo ()

/** 封面图片 */
@property (nonatomic, strong) UIImage *coverImage;
/** 视频数据 */
@property (nonatomic, strong) NSData *data;
/** 视频地址 */
@property (nonatomic, strong) NSURL *url;
/** 视频时长 */
@property (nonatomic, assign) NSTimeInterval duration;

@end

@interface TFY_PickerResultInfo ()

/** 名称 */
@property (nonatomic, copy) NSString *name;
/** 大小［长、宽］ */
@property (nonatomic, assign) CGSize size;
/** 大小［字节］ */
@property (nonatomic, assign) CGFloat byte;

@end


#endif /* TFY_ResultObjectproperty_h */
