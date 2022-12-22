//
//  TFY_StickerDisplayView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TFYDidSelectItemBlock)(NSData *data, UIImage *thumbnailImage);

@interface TFY_StickerDisplayView : UIView
/** 点击返回data */
@property (copy , nonatomic) TFYDidSelectItemBlock didSelectBlock;

@property (nonatomic) UIColor *selectTitleColor;

@property (nonatomic) UIColor *normalTitleColor;

@property (nonatomic) CGSize itemSize;

@property (nonatomic) CGFloat itemMargin;

/** 占位图，为nil不显示 */
@property (nonatomic, nullable) UIImage *normalImage;

/** 加载失败图，为nil不显示 */
@property (nonatomic, nullable) UIImage *failureImage;

@property (nonatomic, readonly, nullable) NSIndexPath *selectIndexPath;

/** 缓存，执行setTitles:contents:后才会有值 */
@property (nonatomic, strong, nullable) id cacheData;

/// 设置数据
- (void)setTitles:(nonnull NSArray <NSString *>*)titles contents:(nonnull NSArray <NSArray *>*)contents;

@end

NS_ASSUME_NONNULL_END
