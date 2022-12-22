//
//  TFY_ImagePickerController+property.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_ImagePickerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ImagePickerController ()

@property (nonatomic, readonly) NSMutableArray<TFY_PickerAsset *> *selectedModels;
@property (nonatomic, readonly) BOOL defaultSelectOriginalPhoto;

@end

NS_ASSUME_NONNULL_END
