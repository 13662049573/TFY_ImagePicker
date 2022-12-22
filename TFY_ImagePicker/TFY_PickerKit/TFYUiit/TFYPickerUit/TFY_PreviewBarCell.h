//
//  TFY_PreviewBarCell.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <UIKit/UIKit.h>

@class TFY_PickerAsset;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PreviewBarCell : UICollectionViewCell
+ (NSString *)identifier;
@property (nonatomic, strong) TFY_PickerAsset *asset;
@property (nonatomic, assign) BOOL isSelectedAsset;
@end

NS_ASSUME_NONNULL_END
