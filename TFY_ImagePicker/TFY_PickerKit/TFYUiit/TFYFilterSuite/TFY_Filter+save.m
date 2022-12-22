//
//  TFY_Filter+save.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Filter+save.h"

@implementation TFY_Filter (save)

- (BOOL)writeToFile:(NSURL *__nonnull)fileUrl error:(NSError *__nullable*__nullable)error {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [data writeToURL:fileUrl options:NSDataWritingAtomic error:error];
}

@end
