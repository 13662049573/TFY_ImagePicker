//
//  TFY_PickerAlbumTitleView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <UIKit/UIKit.h>
#import "TFY_ImagePickerPublic.h"
#import "TFY_PickerAlbum.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYAlbumTitleViewState) {
    TFYAlbumTitleViewStateInactive,
    TFYAlbumTitleViewStateActivity,
};

@interface TFY_PickerAlbumTitleView : UIView

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController;
- (instancetype)initWithContentViewController:(UIViewController *)contentViewController index:(NSInteger)index;

@property (nonatomic, strong) NSArray <TFY_PickerAlbum *>*albumArr;
@property (nonatomic, readonly) TFY_PickerAlbum *selectedAlbum;

/** 自定义title */
@property (nonatomic, copy) NSString *title;
/** 选中图标 */
@property (nonatomic, copy) NSString *selectImageName;

/** 文字字体 boldSystemFontOfSize 18 */
@property(nonatomic, strong) UIFont *titleFont;
/** 文字颜色 灰色 */
@property(nonatomic, strong) UIColor *titleColor;
/** 当前序列 default -1 */
@property(nonatomic, assign, readonly) NSInteger index;
/** 点击背景隐藏 default YES */
@property(nonatomic, assign, getter=isTapBackgroundHidden) BOOL tapBackgroundHidden;
/** 状态 */
@property (nonatomic, assign) TFYAlbumTitleViewState state;
/** 点击回调 */
@property (nonatomic, copy) void(^didSelected)(TFY_PickerAlbum *album, NSInteger index);

@end

NS_ASSUME_NONNULL_END
