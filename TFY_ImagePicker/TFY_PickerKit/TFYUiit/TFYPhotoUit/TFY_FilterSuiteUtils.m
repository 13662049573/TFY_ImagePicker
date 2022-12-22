//
//  TFY_FilterSuiteUtils.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_FilterSuiteUtils.h"
#import "TFY_Filter.h"
#import "TFY_Filter+Initialize.h"
#import "TFY_MutableFilter.h"
#import "TFY_Filter+Image.h"

NSString *picker_descWithType(TFYFilterNameType type)
{
    NSString *desc = @"Original";
    switch (type) {
        case TFYFilterNameType_None:
            break;
        case TFYFilterNameType_LinearCurve:
            desc = @"Curve";
            break;
        case TFYFilterNameType_Chrome:
            desc = @"Chrome";
            break;
        case TFYFilterNameType_Fade:
            desc = @"Fade";
            break;
        case TFYFilterNameType_Instant:
            desc = @"Instant";
            break;
        case TFYFilterNameType_Mono:
            desc = @"Mono";
            break;
        case TFYFilterNameType_Noir:
            desc = @"Noir";
            break;
        case TFYFilterNameType_Process:
            desc = @"Process";
            break;
        case TFYFilterNameType_Tonal:
            desc = @"Tonal";
            break;
        case TFYFilterNameType_Transfer:
            desc = @"Transfer";
            break;
        case TFYFilterNameType_CurveLinear:
            desc = @"Linear";
            break;
        case TFYFilterNameType_Invert:
            desc = @"Invert";
            break;
        case TFYFilterNameType_Monochrome:
            desc = @"Monochrome";
            break;
    }
    return desc;
}

NSString *picker_filterNameWithType(TFYFilterNameType type)
{
    NSString *filterName = nil;
    switch (type) {
        case TFYFilterNameType_None:
            break;
        case TFYFilterNameType_LinearCurve:
            filterName = @"CILinearToSRGBToneCurve";
            break;
        case TFYFilterNameType_Chrome:
            filterName = @"CIPhotoEffectChrome";
            break;
        case TFYFilterNameType_Fade:
            filterName = @"CIPhotoEffectFade";
            break;
        case TFYFilterNameType_Instant:
            filterName = @"CIPhotoEffectInstant";
            break;
        case TFYFilterNameType_Mono:
            filterName = @"CIPhotoEffectMono";
            break;
        case TFYFilterNameType_Noir:
            filterName = @"CIPhotoEffectNoir";
            break;
        case TFYFilterNameType_Process:
            filterName = @"CIPhotoEffectProcess";
            break;
        case TFYFilterNameType_Tonal:
            filterName = @"CIPhotoEffectTonal";
            break;
        case TFYFilterNameType_Transfer:
            filterName = @"CIPhotoEffectTransfer";
            break;
        case TFYFilterNameType_CurveLinear:
            filterName = @"CISRGBToneCurveToLinear";
            break;
        case TFYFilterNameType_Invert:
            filterName = @"CIColorInvert";
            break;
        case TFYFilterNameType_Monochrome:
            filterName = @"CIColorMonochrome";
            break;
    }
    return filterName;
}

TFY_Filter *picker_filterWithType(TFYFilterNameType type)
{
    TFY_Filter *filter = nil;
    NSString *name = picker_filterNameWithType(type);
    if ([name containsString:@"|"]) {
        //组合滤镜
        TFY_MutableFilter *mutableFilter = nil;
        for (NSString *subName in [name componentsSeparatedByString:@"|"]) {
            if (mutableFilter == nil) {
                mutableFilter = [TFY_MutableFilter filterWithCIFilterName:subName];
            } else {
                [mutableFilter addSubFilter:[TFY_Filter filterWithCIFilterName:subName]];
            }
        }
        filter = mutableFilter;
    } else {
        filter = [TFY_Filter filterWithCIFilterName:name];
    }
    return filter;
}

UIImage *picker_filterImageWithType(UIImage *image, TFYFilterNameType type)
{
    TFY_Filter *filter = picker_filterWithType(type);
    if (filter) {
        return [filter UIImageByProcessingUIImage:image];
    } else {
        return image;
    }
}

