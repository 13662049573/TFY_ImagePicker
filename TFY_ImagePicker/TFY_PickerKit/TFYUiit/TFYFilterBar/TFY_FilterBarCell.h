//
//  TFY_FilterBarCell.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import "TFY_FilterModel.h"

extern CGFloat const TFY_LABEL_HEIGHT;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_FilterBarCell : UICollectionViewCell

/** 默认字体和框框颜色 */
@property (nonatomic, strong) UIColor *defaultColor;
/** 已选字体和框框颜色 */
@property (nonatomic, strong) UIColor *selectColor;

@property (nonatomic, assign) BOOL isSelectedModel;

- (void)setCellData:(TFY_FilterModel *)cellData;

+ (NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
