//
//  TFY_ColorMatrixType.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_ColorMatrixType.h"
#import "TFY_ImageUtil.h"
#import "TFY_ColorMatrix.h"

NSString *picker_colorMatrixName(TFYColorMatrixType type)
{
    NSString *colorStr = @"原图";
    switch (type) {
        case TFYColorMatrixType_None:
            break;
        case TFYColorMatrixType_LOMO:
            colorStr = @"LOMO";
            break;
        case TFYColorMatrixType_Heibai:
            colorStr = @"黑白";
            break;
        case TFYColorMatrixType_Fugu:
            colorStr = @"复古";
            break;
        case TFYColorMatrixType_Gete:
            colorStr = @"哥特";
            break;
        case TFYColorMatrixType_Ruise:
            colorStr = @"锐化";
            break;
        case TFYColorMatrixType_Danya:
            colorStr = @"淡雅";
            break;
        case TFYColorMatrixType_Jiuhong:
            colorStr = @"酒红";
            break;
        case TFYColorMatrixType_Qingning:
            colorStr = @"清宁";
            break;
        case TFYColorMatrixType_Langman:
            colorStr = @"浪漫";
            break;
        case TFYColorMatrixType_Huaijiu:
            colorStr = @"怀旧";
            break;
        case TFYColorMatrixType_Landiao:
            colorStr = @"蓝调";
            break;
        case TFYColorMatrixType_Menghuan:
            colorStr = @"梦幻";
            break;
        case TFYColorMatrixType_Yese:
            colorStr = @"夜色";
            break;
        case TFYColorMatrixType_Huidu:
            colorStr = @"灰度";
            break;
        case TFYColorMatrixType_Imagerevolve:
            colorStr = @"高冷";
            break;
        case TFYColorMatrixType_Heighsaturatedcolour:
            colorStr = @"饱和";
            break;
        case TFYColorMatrixType_Cleancolor:
            colorStr = @"去色";
            break;
    }
    return colorStr;
}

UIImage * picker_colorMatrixImage(UIImage *image, TFYColorMatrixType type)
{
    UIImage *cmImage = image;
    switch (type) {
        case TFYColorMatrixType_None:
            break;
        case TFYColorMatrixType_LOMO:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_lomo];
            break;
        case TFYColorMatrixType_Heibai:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_heibai];
            break;
        case TFYColorMatrixType_Fugu:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_fugu];
            break;
        case TFYColorMatrixType_Gete:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_gete];
            break;
        case TFYColorMatrixType_Ruise:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_ruise];
            break;
        case TFYColorMatrixType_Danya:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_danya];
            break;
        case TFYColorMatrixType_Jiuhong:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_jiuhong];
            break;
        case TFYColorMatrixType_Qingning:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_qingning];
            break;
        case TFYColorMatrixType_Langman:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_langman];
            break;
        case TFYColorMatrixType_Huaijiu:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_huaijiu];
            break;
        case TFYColorMatrixType_Landiao:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_landiao];
            break;
        case TFYColorMatrixType_Menghuan:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_menghuan];
            break;
        case TFYColorMatrixType_Yese:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_yese];
            break;
        case TFYColorMatrixType_Huidu:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_huidu];
            break;
        case TFYColorMatrixType_Imagerevolve:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_imagerevolve];
            break;
        case TFYColorMatrixType_Heighsaturatedcolour:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_heighsaturatedcolour];
            break;
        case TFYColorMatrixType_Cleancolor:
            cmImage = [TFY_ImageUtil picker_imageWithImage:image withColorMatrix:picker_colormatrix_cleancolor];
            break;
    }
    return cmImage;
}

