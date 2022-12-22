//
//  TFY_ResultImage.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_ResultObject.h"
#import "TFY_ImagePickerPublic.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ResultImage : TFY_ResultObject

/** 缩略图 */
@property (nonatomic, readonly) UIImage *thumbnailImage;
/** 缩略图数据 */
@property (nonatomic, readonly) NSData *thumbnailData;
/** 原图／标清图 */
@property (nonatomic, readonly) UIImage *originalImage;
/** 原图／标清图数据 */
@property (nonatomic, readonly) NSData *originalData;

/** 子类型 */
@property (nonatomic, assign, readonly) TFYImagePickerSubMediaType subMediaType;

@end

NS_ASSUME_NONNULL_END
