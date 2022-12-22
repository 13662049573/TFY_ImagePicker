//
//  TFY_PickerCollectionViewCell.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_BaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@class TFY_PickerCollectionViewCell;

@protocol TFYCollectionViewDelegate <NSObject>

@optional
- (void)picker_didSelectData:(nullable NSData *)data thumbnailImage:(nullable UIImage *)thumbnailImage index:(NSInteger)index;

- (void)picker_didEndReloadData:(TFY_PickerCollectionViewCell *)cell;

@end

@interface TFY_PickerCollectionViewCell : TFY_BaseCollectionViewCell
@property (weak, nonatomic) id<TFYCollectionViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
