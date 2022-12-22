//
//  TFY_LayoutPickerController.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import "TFYPhotoEditing.h"
#import "TFYVideoEditing.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_LayoutPickerController : UINavigationController
/// Custom photo
/// 自定义图片
@property (nonatomic, copy) NSString *takePictureImageName;
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, copy) NSString *photoOriginSelImageName;
@property (nonatomic, copy) NSString *photoOriginDefImageName;
@property (nonatomic, copy) NSString *videoPlayImageName;
@property (nonatomic, copy) NSString *videoPauseImageName;
@property (nonatomic, copy) NSString *ablumSelImageName;

/// Custom appearance color
/// 自定义外观颜色
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *oKButtonTitleColorDisabled;
@property (nonatomic, strong) UIColor *naviBgColor;
@property (nonatomic, strong) UIColor *naviTitleColor;
@property (nonatomic, strong) UIFont *naviTitleFont;
@property (nonatomic, strong) UIColor *naviTipsTextColor;
@property (nonatomic, strong) UIFont *naviTipsFont;
@property (nonatomic, strong) UIColor *barItemTextColor;
@property (nonatomic, strong) UIFont *barItemTextFont;
@property (nonatomic, strong) UIColor *contentBgColor;
@property (nonatomic, strong) UIColor *contentTipsTextColor;
@property (nonatomic, strong) UIFont *contentTipsFont;
@property (nonatomic, strong) UIColor *contentTipsTitleColorNormal;
@property (nonatomic, strong) UIFont *contentTipsTitleFont;
@property (nonatomic, strong) UIColor *toolbarBgColor;
@property (nonatomic, strong) UIColor *toolbarTitleColorNormal;
@property (nonatomic, strong) UIColor *toolbarTitleColorDisabled;
@property (nonatomic, strong) UIFont *toolbarTitleFont;
@property (nonatomic, strong) UIColor *previewNaviBgColor;


/// Copy TFY_ImagePickerController.strings to any location of your project and modify the corresponding value.
/// These property have the highest priority and use LFImagePickerController.strings as much as possible. Otherwise, some properties of LFImagePickerController.strings will be invalid.
/// 复制LFImagePickerController.strings到项目任意位置，修改对应的值。
/// 这些属性拥有最高的优先级，尽可能使用LFImagePickerController.strings。否则会导致LFImagePickerController.strings对应的属性失效。
@property (nonatomic, copy) NSString *doneBtnTitleStr;
@property (nonatomic, copy) NSString *cancelBtnTitleStr;
@property (nonatomic, copy) NSString *previewBtnTitleStr;
@property (nonatomic, copy) NSString *editBtnTitleStr;
@property (nonatomic, copy) NSString *fullImageBtnTitleStr;
@property (nonatomic, copy) NSString *settingBtnTitleStr;
@property (nonatomic, copy) NSString *processHintStr;

@property (nonatomic, copy) void (^photoEditLabrary)(TFY_PhotoEditingController *picker_photoEditingVC);
@property (nonatomic, copy) void (^videoEditLabrary)(TFY_VideoEditingController *picker_videoEditingVC);

- (void)showAlertWithTitle:(NSString *)title;
- (void)showAlertWithTitle:(NSString *)title complete:(nullable void (^)(void))complete;
- (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message complete:(nullable void (^)(void))complete;
- (void)showAlertWithTitle:(nullable NSString *)title cancelTitle:(nullable NSString *)cancelTitle message:(nullable NSString *)message complete:(nullable void (^)(void))complete;

- (void)showProgressHUDText:(nullable NSString *)text isTop:(BOOL)isTop;
- (void)showProgressHUDText:(nullable NSString *)text;
- (void)showProgressHUD;
- (void)hideProgressHUD;

- (void)showNeedProgressHUD;
- (void)setProcess:(CGFloat)process;

@end

NS_ASSUME_NONNULL_END
