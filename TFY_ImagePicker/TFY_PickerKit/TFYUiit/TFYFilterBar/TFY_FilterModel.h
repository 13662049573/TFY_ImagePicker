//
//  TFY_FilterModel.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TFY_FilterModel : NSObject
@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) NSInteger effectType;
@end

NS_ASSUME_NONNULL_END
