//
//  TFY_VideoClipToolbar.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

@class TFY_VideoClipToolbar;

NS_ASSUME_NONNULL_BEGIN

@protocol TFYVideoClipToolbarDelegate <NSObject>
/** 取消 */
- (void)picker_videoClipToolbarDidCancel:(TFY_VideoClipToolbar *_Nonnull)clipToolbar;
/** 完成 */
- (void)picker_videoClipToolbarDidFinish:(TFY_VideoClipToolbar *_Nonnull)clipToolbar;

@end

@interface TFY_VideoClipToolbar : UIView
@property (nonatomic, weak) id<TFYVideoClipToolbarDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
