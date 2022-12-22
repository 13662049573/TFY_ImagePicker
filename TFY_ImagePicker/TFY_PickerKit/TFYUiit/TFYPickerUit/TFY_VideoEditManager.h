//
//  TFY_VideoEditManager.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>

@class TFY_VideoEdit, TFY_PickerAsset, TFY_ResultVideo;
NS_ASSUME_NONNULL_BEGIN

@interface TFY_VideoEditManager : NSObject

+ (instancetype)manager NS_SWIFT_NAME(default());
+ (void)free;

/** 设置编辑对象 */
- (void)setVideoEdit:(TFY_VideoEdit *)obj forAsset:(TFY_PickerAsset *)asset;
/** 获取编辑对象 */
- (TFY_VideoEdit *)videoEditForAsset:(TFY_PickerAsset *)asset;

/**
 通过asset解析视频
 
  asset TFY_PickerAsset
  presetName 压缩预设名称 nil则默认为AVAssetExportPreset1280x720
  completion 回调
 */
- (void)getVideoWithAsset:(TFY_PickerAsset *)asset
               presetName:(NSString *)presetName
               completion:(void (^)(TFY_ResultVideo *resultVideo))completion;
@end

NS_ASSUME_NONNULL_END
