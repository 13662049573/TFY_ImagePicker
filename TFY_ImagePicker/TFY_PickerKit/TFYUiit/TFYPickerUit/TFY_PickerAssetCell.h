//
//  TFY_PickerAssetCell.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class TFY_PickerAsset;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PickerAssetCell : UICollectionViewCell

@property (nonatomic, strong) TFY_PickerAsset *model;

@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL isSelected, TFY_PickerAsset *model, TFY_PickerAssetCell *weakCell);
/** 只能选中 */
@property (nonatomic, assign) BOOL onlySelected;
/** 只能点击；但优先级低于只能选中onlySelected */
@property (nonatomic, assign) BOOL onlyClick;
/** 不能选中 */
@property (nonatomic, assign) BOOL noSelected;

@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;

@property (nonatomic, assign) BOOL displayGif;
@property (nonatomic, assign) BOOL displayLivePhoto;
@property (nonatomic, assign) BOOL displayPhotoName;

/** 设置选中 */
- (void)selectPhoto:(BOOL)isSelected index:(NSUInteger)index animated:(BOOL)animated;
@end

/// 拍照视图
@interface TFY_PickerAssetCameraCell : UICollectionViewCell
@property (nonatomic, copy) UIImage *posterImage;
@end

NS_ASSUME_NONNULL_END
