//
//  TFY_FileUtility.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_FileUtility : NSObject

+ (BOOL)createFile:(NSString *)path;
+ (BOOL)createFolder:(NSString *)path errStr:(nullable NSString *)errStr;
+ (BOOL)fileExist:(NSString *)path;
+ (BOOL)directoryExist:(NSString *)path;
+ (BOOL)moveFileAtPath:(NSString *)atPath toPath:(NSString *)toPath;
+ (BOOL)copyFileAtPath:(NSString *)atPath toPath:(NSString *)toPath;
+ (BOOL)removeFile:(NSString *)path;
+ (void)writeLogToFile:(NSString *)filePath appendTxt:(NSString *)txt;
+ (u_int64_t)fileSizeForPath:(NSString *)path;
+ (NSArray *)findFile:(NSString *)path;
+ (NSString*)getFileSizeString:(float)aSize;

@end

NS_ASSUME_NONNULL_END
