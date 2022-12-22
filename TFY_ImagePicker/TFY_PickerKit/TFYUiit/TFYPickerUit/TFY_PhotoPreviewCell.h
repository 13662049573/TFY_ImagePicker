//
//  TFY_PhotoPreviewCell.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <UIKit/UIKit.h>

@class TFY_PickerAsset,TFY_PhotoPreviewCell;

NS_ASSUME_NONNULL_BEGIN

@protocol TFYPhotoPreviewCellDelegate <NSObject>
@optional
- (void)picker_photoPreviewCellSingleTapHandler:(TFY_PhotoPreviewCell *)cell;
@end

@interface TFY_PhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) TFY_PickerAsset *model;
@property (nonatomic, weak) id<TFYPhotoPreviewCellDelegate> delegate;

/** 当前展示的图片 */
@property (nonatomic, readonly) UIImage *previewImage;

// 即将显示
- (void)willDisplayCell;
// 正式显示
- (void)didDisplayCell;
// 即将消失
- (void)willEndDisplayCell;
// 正式消失
- (void)didEndDisplayCell;

/** 子类重写 */
/** 创建显示视图 */
- (UIView *)subViewInitDisplayView;
/** 重置视图 */
- (void)subViewReset;
/** 设置数据 */
- (void)subViewSetModel:(TFY_PickerAsset *)model completeHandler:(void (^)(id data,NSDictionary *info,BOOL isDegraded))completeHandler progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

@end

NS_ASSUME_NONNULL_END
