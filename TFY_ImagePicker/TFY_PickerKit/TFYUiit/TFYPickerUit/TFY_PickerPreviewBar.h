//
//  TFY_PickerPreviewBar.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <UIKit/UIKit.h>

@class TFY_PickerAsset;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PickerPreviewBar : UIView

@property (nonatomic, strong) NSArray <TFY_PickerAsset *>*dataSource;
/** 选择数据源 */
@property (nonatomic, strong) NSMutableArray <TFY_PickerAsset *>*selectedDataSource;

/** 显示与刷新游标 */
@property (nonatomic, strong) TFY_PickerAsset *selectAsset;

/** 选择框大小 2.f */
@property (nonatomic, assign) CGFloat borderWidth;
/** 选择框颜色 blackColor */
@property (nonatomic, strong) UIColor *borderColor;

/** 添加数据源 */
- (void)addAssetInDataSource:(TFY_PickerAsset *)asset;
/** 删除数据源 */
- (void)removeAssetInDataSource:(TFY_PickerAsset *)asset;

@property (nonatomic, copy) void(^didSelectItem)(TFY_PickerAsset *asset);
@property (nonatomic, copy) void(^didMoveItem)(TFY_PickerAsset *asset, NSInteger sourceIndex, NSInteger destinationIndex);

@end

NS_ASSUME_NONNULL_END
