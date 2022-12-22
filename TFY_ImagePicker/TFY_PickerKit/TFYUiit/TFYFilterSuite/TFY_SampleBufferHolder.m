//
//  TFY_SampleBufferHolder.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_SampleBufferHolder.h"

@implementation TFY_SampleBufferHolder

- (void)dealloc {
    if (_sampleBuffer != nil) {
        CFRelease(_sampleBuffer);
    }
}

- (void)setSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (_sampleBuffer != nil) {
        CFRelease(_sampleBuffer);
        _sampleBuffer = nil;
    }
    _sampleBuffer = sampleBuffer;
    if (sampleBuffer != nil) {
        CFRetain(sampleBuffer);
    }
}

+ (TFY_SampleBufferHolder *)sampleBufferHolderWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    TFY_SampleBufferHolder *sampleBufferHolder = [TFY_SampleBufferHolder new];
    sampleBufferHolder.sampleBuffer = sampleBuffer;
    return sampleBufferHolder;
}

@end
