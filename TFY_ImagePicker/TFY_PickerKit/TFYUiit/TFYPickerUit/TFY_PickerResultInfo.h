//
//  TFY_PickerResultInfo.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_PickerResultInfo : NSObject
/** 名称 */
@property (nonatomic, copy, readonly) NSString *name;
/** 大小［长、宽］ */
@property (nonatomic, assign, readonly) CGSize size;
/** 大小［字节］ */
@property (nonatomic, assign, readonly) CGFloat byte;
@end

NS_ASSUME_NONNULL_END
