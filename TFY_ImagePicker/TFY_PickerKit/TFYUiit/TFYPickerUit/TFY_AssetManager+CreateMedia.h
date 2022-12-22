//
//  TFY_AssetManager+CreateMedia.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_AssetManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_AssetManager (CreateMedia)

/**
 Create Gif
 
  images The array must contain UIImages
  size image size
  duration Provides an estimate of the maximum duration of exported media
  loopCount loop count
  error error message
 @return image Data
 */
- (NSData *)createGifDataWithImages:(NSArray <UIImage *>*)images
                               size:(CGSize)size
                           duration:(NSTimeInterval)duration
                          loopCount:(NSUInteger)loopCount
                              error:(NSError **)error;

/**
 Create Gif

  images The array must contain UIImages
  duration Provides an estimate of the maximum duration of exported media
  loopCount loop count
  error error message
 @return image Data
 */
- (NSData *)createGifDataWithImages:(NSArray <UIImage *>*)images
                           duration:(NSTimeInterval)duration
                          loopCount:(NSUInteger)loopCount
                              error:(NSError **)error;

/**
 Create Gif
 
  images The array must contain UIImages
  size image size
  duration Provides an estimate of the maximum duration of exported media
  loopCount loop count
  error error message
 @return image
 */
- (UIImage *)createGifWithImages:(NSArray <UIImage *>*)images
                            size:(CGSize)size
                        duration:(NSTimeInterval)duration
                       loopCount:(NSUInteger)loopCount
                           error:(NSError **)error;

/**
 Create Gif
 
  images The array must contain UIImages
  duration Provides an estimate of the maximum duration of exported media
  loopCount loop count
  error error message
 @return image
 */
- (UIImage *)createGifWithImages:(NSArray <UIImage *>*)images
                        duration:(NSTimeInterval)duration
                       loopCount:(NSUInteger)loopCount
                           error:(NSError **)error;



/**
 Create MP4

  images The array must contain UIImages
  size Video image size
  fps The image frames per second (30.fps)
  duration Provides an estimate of the maximum duration of exported media
  audioPath Background music
  complete data and error message
 */
- (void)createMP4WithImages:(NSArray <UIImage *>*)images
                       size:(CGSize)size
                        fps:(NSUInteger)fps
                   duration:(NSTimeInterval)duration
                  audioPath:(NSString *)audioPath
                   complete:(void (^)(NSData *data, NSError *error))complete;

/**
 Create MP4
 
  images The array must contain UIImages
  size Video image size
  audioPath Background music
  complete data and error message
 */
- (void)createMP4WithImages:(NSArray <UIImage *>*)images
                       size:(CGSize)size
                  audioPath:(NSString *)audioPath
                   complete:(void (^)(NSData *data, NSError *error))complete;

/**
 Create MP4
 
  images The array must contain UIImages
  size Video image size
  complete data and error message
 */
- (void)createMP4WithImages:(NSArray <UIImage *>*)images
                       size:(CGSize)size
                   complete:(void (^)(NSData *data, NSError *error))complete;


@end

NS_ASSUME_NONNULL_END
