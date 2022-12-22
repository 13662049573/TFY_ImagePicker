//
//  TFY_ClipToolbar.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

@class TFY_ClipToolbar;

NS_ASSUME_NONNULL_BEGIN

@protocol TFYClipToolbarDelegate <NSObject>
/** 取消 */
- (void)picker_clipToolbarDidCancel:(TFY_ClipToolbar *)clipToolbar;
/** 完成 */
- (void)picker_clipToolbarDidFinish:(TFY_ClipToolbar *)clipToolbar;
/** 重置 */
- (void)picker_clipToolbarDidReset:(TFY_ClipToolbar *)clipToolbar;
/** 旋转 */
- (void)picker_clipToolbarDidRotate:(TFY_ClipToolbar *)clipToolbar;
/** 长宽比例 */
- (void)picker_clipToolbarDidAspectRatio:(TFY_ClipToolbar *)clipToolbar;

@end

@protocol TFYEditToolbarDataSource <NSObject>

@optional
/** 允许旋转 默认YES */
- (BOOL)picker_clipToolbarCanRotate:(TFY_ClipToolbar *)clipToolbar;
/** 允许长宽比例 默认YES */
- (BOOL)picker_clipToolbarCanAspectRatio:(TFY_ClipToolbar *)clipToolbar;

@end

@interface TFY_ClipToolbar : UIView

/** 代理 */
@property (nonatomic, weak) id<TFYClipToolbarDelegate> delegate;
@property (nonatomic, weak) id<TFYEditToolbarDataSource> dataSource;

/** 开启重置按钮 default NO  */
@property (nonatomic, assign) BOOL enableReset;

/** 选中长宽比例按钮 default NO */
@property (nonatomic, assign) BOOL selectAspectRatio;

@property (nonatomic, readonly) CGRect clickViewRect;

@end

NS_ASSUME_NONNULL_END
