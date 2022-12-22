//
//  TFY_ImageCoder.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import "NSBundle+picker.h"

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN UIWindow* TFYAppWindow(void);

#define isiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define isiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define bundleEditImageNamed(name) [NSBundle picker_imageNamed:name]
#define bundleAudioTrackImageNamed(name) [NSBundle picker_audioTrackImageNamed:name]
#define bundleBrushImageNamed(name) [NSBundle picker_brushImageNamed:name]

#define kCustomTopbarHeight CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
#define kCustomTopbarHeight_iOS11 CGRectGetHeight(self.navigationController.navigationBar.frame) + self.navigationController.view.safeAreaInsets.top
#define hasSafeArea (TFYAppWindow().window.safeAreaInsets.bottom > 0)

#define kSliderColors @[[UIColor whiteColor]/*白色*/\
, [UIColor blackColor]/*黑色*/\
, [UIColor colorWithRed:235.f/255.f green:51.f/255.f blue:16.f/255.f alpha:1.f]/*红色*/\
, [UIColor colorWithRed:245.f/255.f green:181.f/255.f blue:71.f/255.f alpha:1.f]/*浅黄色*/\
, [UIColor colorWithRed:248.f/255.f green:229.f/255.f blue:7.f/255.f alpha:1.f]/*黄色*/\
, [UIColor colorWithRed:185.f/255.f green:243.f/255.f blue:46.f/255.f alpha:1.f]/*浅绿色*/\
, [UIColor colorWithRed:4.f/255.f green:170.f/255.f blue:11.f/255.f alpha:1.f]/*墨绿色*/\
, [UIColor colorWithRed:36.f/255.f green:199.f/255.f blue:243.f/255.f alpha:1.f]/*天蓝色*/\
, [UIColor colorWithRed:24.f/255.f green:117.f/255.f blue:243.f/255.f alpha:1.f]/*海洋蓝色*/\
, [UIColor colorWithRed:1.f/255.f green:53.f/255.f blue:190.f/255.f alpha:1.f]/*深蓝色*/\
, [UIColor colorWithRed:141.f/255.f green:87.f/255.f blue:240.f/255.f alpha:1.f]/*紫色*/\
, [UIColor colorWithRed:244.f/255.f green:147.f/255.f blue:244.f/255.f alpha:1.f]/*浅粉色*/\
, [UIColor colorWithRed:242.f/255.f green:102.f/255.f blue:139.f/255.f alpha:1.f]/*紫罗兰红色*/\
, [UIColor colorWithRed:236.f/255.f green:36.f/255.f blue:179.f/255.f alpha:1.f]/*粉红色*/\
]


// get方法
#define TFYSticker_bind_var_getter(varType, varName, target) \
- (varType)varName \
{ \
    return target.varName; \
}

// set方法
#define TFYSticker_bind_var_setter(varType, varName, setterName, target) \
- (void)setterName:(varType)varName \
{ \
    [target setterName:varName]; \
}

#define picker_NotSupperGif

OBJC_EXTERN double const TFYMediaEditMinRate;
OBJC_EXTERN double const TFYMediaEditMaxRate;

OBJC_EXTERN CGRect TFYMediaEditProundRect(CGRect rect);

/**
图片解码

imageRef 图片
size 图片大小（根据大小与contentMode缩放图片，传入CGSizeZero不处理大小）
contentMode 内容布局（仅支持UIViewContentModeScaleAspectFill与UIViewContentModeScaleAspectFit，与size搭配）
orientation 图片方向（imageRef的方向，会自动更正为up，如果传入up则不更正）
返回解码后的图片，如果失败，则返回NULL
*/
CG_EXTERN CGImageRef _Nullable picker_CGImageScaleDecodedFromCopy(CGImageRef imageRef, CGSize size, UIViewContentMode contentMode, UIImageOrientation orientation);
/**
图片解码
imageRef 图片
返回解码后的图片，如果失败，则返回NULL
*/
CG_EXTERN CGImageRef _Nullable picker_CGImageDecodedFromCopy(CGImageRef imageRef);

/**
 图片解码
 image 图片
 返回解码后的图片，如果失败，则返回NULL
 */
CG_EXTERN CGImageRef _Nullable picker_CGImageDecodedCopy(UIImage *image);

/**
 图片解码
 image 图片
 返回解码后的图片，如果失败，则返回自身
 */
UIKIT_EXTERN UIImage * picker_UIImageDecodedCopy(UIImage *image);


NS_ASSUME_NONNULL_END
