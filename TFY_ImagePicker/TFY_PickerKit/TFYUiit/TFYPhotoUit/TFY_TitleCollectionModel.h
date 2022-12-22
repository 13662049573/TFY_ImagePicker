//
//  TFY_TitleCollectionModel.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TitleCollectionModel : NSObject

@property (nonatomic, readonly) NSString *title;

@property (nonatomic, assign, readonly) CGSize size;

@property (nonatomic, strong, readonly) UIFont *font;

- (instancetype)initWithTitle:(NSString *)title;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
