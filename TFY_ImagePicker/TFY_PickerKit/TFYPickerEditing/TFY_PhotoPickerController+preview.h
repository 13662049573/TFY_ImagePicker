//
//  TFY_PhotoPickerController+preview.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PhotoPickerController.h"

@class TFY_PickerAsset;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PhotoPickerController ()
/** 图片预览模式 */
- (instancetype)initWithPhotos:(NSArray <TFY_PickerAsset *>*)photos completeBlock:(void (^)(void))completeBlock;
@end

NS_ASSUME_NONNULL_END
