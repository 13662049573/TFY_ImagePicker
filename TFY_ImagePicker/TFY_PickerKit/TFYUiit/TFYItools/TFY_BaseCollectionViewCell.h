//
//  TFY_BaseCollectionViewCell.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_BaseCollectionViewCell : UICollectionViewCell
@property (readonly, nonatomic) id cellData;

+ (NSString *)identifier;

- (void)setCellData:(nullable id)data;
@end

NS_ASSUME_NONNULL_END
