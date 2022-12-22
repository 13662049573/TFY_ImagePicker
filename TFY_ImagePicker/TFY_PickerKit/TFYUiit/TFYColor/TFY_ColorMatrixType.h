//
//  TFY_ColorMatrixType.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYColorMatrixType) {
    /** 原图 */
    TFYColorMatrixType_None = 0,
    /** LOMO */
    TFYColorMatrixType_LOMO,
    /** 黑白 */
    TFYColorMatrixType_Heibai,
    /** 复古 */
    TFYColorMatrixType_Fugu,
    /** 哥特 */
    TFYColorMatrixType_Gete,
    /** 锐化 */
    TFYColorMatrixType_Ruise,
    /** 淡雅 */
    TFYColorMatrixType_Danya,
    /** 酒红 */
    TFYColorMatrixType_Jiuhong,
    /** 清宁 */
    TFYColorMatrixType_Qingning,
    /** 浪漫 */
    TFYColorMatrixType_Langman,
    /** 怀旧 */
    TFYColorMatrixType_Huaijiu,
    /** 蓝调 */
    TFYColorMatrixType_Landiao,
    /** 梦幻 */
    TFYColorMatrixType_Menghuan,
    /** 夜色 */
    TFYColorMatrixType_Yese,
    /** 灰度 */
    TFYColorMatrixType_Huidu,
    /** 图片旋转 */
    TFYColorMatrixType_Imagerevolve,
    /** 高饱和度 */
    TFYColorMatrixType_Heighsaturatedcolour,
    /** 去色 */
    TFYColorMatrixType_Cleancolor,
};

OBJC_EXTERN NSString *picker_colorMatrixName(TFYColorMatrixType type);
OBJC_EXTERN UIImage * picker_colorMatrixImage(UIImage *image, TFYColorMatrixType type);


NS_ASSUME_NONNULL_END
