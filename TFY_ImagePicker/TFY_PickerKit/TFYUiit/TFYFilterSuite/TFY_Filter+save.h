//
//  TFY_Filter+save.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Filter.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_Filter (save)
/**
 Write this filter to a specific file.
 This filter can then be restored from this file using [TFY_Filter filterWithContentsOfUrl:].
 */
- (BOOL)writeToFile:(NSURL *__nonnull)fileUrl error:(NSError *__nullable*__nullable)error;
@end

NS_ASSUME_NONNULL_END
