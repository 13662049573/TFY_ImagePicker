//
//  TFY_SafeAreaMaskView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_SafeAreaMaskView : UIView
@property (nonatomic, setter=setMaskRect:) CGRect maskRect;
@property (nonatomic, assign) BOOL showMaskLayer;
@end

NS_ASSUME_NONNULL_END
