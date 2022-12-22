//
//  TFY_ImageUtil.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ImageUtil : NSObject
+ (UIImage *)picker_imageWithImage:(UIImage*)inImage withColorMatrix:(const float*)f;
@end

NS_ASSUME_NONNULL_END
