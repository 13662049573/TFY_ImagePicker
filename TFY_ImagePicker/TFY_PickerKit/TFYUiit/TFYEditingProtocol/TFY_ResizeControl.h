//
//  TFY_ResizeControl.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

@class TFY_ResizeControl;

NS_ASSUME_NONNULL_BEGIN

@protocol TFYresizeConrolDelegate <NSObject>

- (void)picker_resizeConrolDidBeginResizing:(TFY_ResizeControl *_Nullable)resizeConrol;
- (void)picker_resizeConrolDidResizing:(TFY_ResizeControl *_Nullable)resizeConrol;
- (void)picker_resizeConrolDidEndResizing:(TFY_ResizeControl *_Nullable)resizeConrol;

@end

@interface TFY_ResizeControl : UIView

@property (weak, nonatomic) id<TFYresizeConrolDelegate> delegate;
@property (nonatomic, readonly) CGPoint translation;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

NS_ASSUME_NONNULL_END
