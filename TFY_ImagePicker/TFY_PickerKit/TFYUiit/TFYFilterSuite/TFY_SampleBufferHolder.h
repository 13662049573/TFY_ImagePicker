//
//  TFY_SampleBufferHolder.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_SampleBufferHolder : NSObject
@property (assign, nonatomic, nullable) CMSampleBufferRef sampleBuffer;
+ (TFY_SampleBufferHolder *)sampleBufferHolderWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
