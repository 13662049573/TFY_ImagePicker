//
//  TFY_LView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_LView : UIView
- (instancetype)initWithImage:(nullable UIImage *)image;

@property (nonatomic, assign) CGSize tileSize;

@property (nullable, nonatomic, strong) UIImage *image; // default is nil

@end

NS_ASSUME_NONNULL_END
