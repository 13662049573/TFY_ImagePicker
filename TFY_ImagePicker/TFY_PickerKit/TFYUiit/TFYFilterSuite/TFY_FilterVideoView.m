//
//  TFY_FilterVideoView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_FilterVideoView.h"
#import "TFY_ContextImageView+private.h"
#import "TFY_WeakSelectorTarget.h"

static char* TFYStatusChanged = "StatusContext";
static char* TFYItemChanged = "CurrentItemContext";

@interface TFY_FilterVideoView ()<AVPlayerItemOutputPullDelegate>
{
    CADisplayLink *_displayLink;
    AVPlayerItemVideoOutput *_videoOutput;
    AVPlayerItem *_oldItem;
}

@end

@implementation TFY_FilterVideoView

- (void)commonInit
{
    [super commonInit];
    _shouldSuppressPlayerRendering = YES;
}

- (void)dealloc {
    [self setPlayer:nil];
}

- (void)setPlayer:(AVPlayer *)player
{
    if (_player != player) {
        [self suspendDisplay];
        [_player removeObserver:self forKeyPath:@"currentItem"];
        _player = player;
        [_player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:TFYItemChanged];
        
        
        if (player == nil) {
            [self unsetupDisplayLink];
        } else {
            [self setupDisplayLink];
        }
        
        [self initObservers];
    }
}

- (void)setShouldSuppressPlayerRendering:(BOOL)shouldSuppressPlayerRendering
{
    _shouldSuppressPlayerRendering = shouldSuppressPlayerRendering;
    
    _videoOutput.suppressesPlayerRendering = shouldSuppressPlayerRendering;
}

- (BOOL)isPlaying {
    return self.player.rate > 0;
}

- (CMTime)itemDuration {
    return CMTimeMultiply(self.player.currentItem.duration, 1.f);
}

- (CMTime)playableDuration {
    AVPlayerItem * item = self.player.currentItem;
    CMTime playableDuration = kCMTimeZero;
    
    if (item.status != AVPlayerItemStatusFailed) {
        for (NSValue *value in item.loadedTimeRanges) {
            CMTimeRange timeRange = [value CMTimeRangeValue];
            
            playableDuration = CMTimeAdd(playableDuration, timeRange.duration);
        }
    }
    
    return playableDuration;
}

#pragma mark - AVPlayerItem
- (void)initObservers{
    [self removeOldObservers];
    
    if (self.player.currentItem != nil) {
        _oldItem = self.player.currentItem;
        
        [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:TFYStatusChanged];
        
        [self setupVideoOutputToItem:self.player.currentItem];
    }
}

- (void)removeOldObservers {
    if (_oldItem != nil) {
        [_oldItem removeObserver:self forKeyPath:@"status"];
        [self unsetupVideoOutputToItem:_oldItem];
        _oldItem = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == TFYItemChanged) {
        [self initObservers];
    } else
    if (context == TFYStatusChanged) {
        void (^block)(void) = ^{
            [self setupVideoOutputToItem:self.player.currentItem];
        };
        if ([NSThread isMainThread]) {
            block();
        } else {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}

#pragma mark - CADisplayLink

- (void)suspendDisplay {
    [_videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.1];
    _displayLink.paused = YES;
}

- (void)setupDisplayLink {
    if (_displayLink == nil) {
        TFY_WeakSelectorTarget *target = [[TFY_WeakSelectorTarget alloc] initWithTarget:self targetSelector:@selector(willRenderFrame:)];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:target selector:target.handleSelector];
        
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        [self suspendDisplay];
    }
}

- (void)unsetupDisplayLink {
    if (_displayLink != nil) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (void)willRenderFrame:(CADisplayLink *)sender {
    CFTimeInterval nextFrameTime = sender.timestamp + sender.duration;
    
    [self renderVideo:nextFrameTime];
}

- (void)renderVideo:(CFTimeInterval)hostFrameTime {
    CMTime outputItemTime = [_videoOutput itemTimeForHostTime:hostFrameTime];
    
    if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        
        CMTime time;
        CVPixelBufferRef pixelBuffer = [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:&time];
        
        if (pixelBuffer != nil) {
            CIImage *inputImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
            
            self.CIImageTime = CMTimeGetSeconds(outputItemTime);
            self.CIImage = inputImage;
            
            CVPixelBufferRelease(pixelBuffer);
        }
    }
}

#pragma mark - AVPlayerItemVideoOutput

- (void)setupVideoOutputToItem:(AVPlayerItem *)item {
    if (_displayLink != nil && item != nil && _videoOutput == nil && item.status == AVPlayerItemStatusReadyToPlay) {
        NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        [_videoOutput setDelegate:self queue:dispatch_get_main_queue()];
        _videoOutput.suppressesPlayerRendering = self.shouldSuppressPlayerRendering;
        
        [item addOutput:_videoOutput];
        
        _displayLink.paused = NO;
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        
        NSArray *videoTracks = [item.asset tracksWithMediaType:AVMediaTypeVideo];
        
        if (videoTracks.count > 0) {
            AVAssetTrack *track = videoTracks.firstObject;
            
            transform = track.preferredTransform;
            
            // Return the video if it is upside down
            if (transform.b == 1 && transform.c == -1) {
                transform = CGAffineTransformRotate(transform, M_PI);
            }
            
            if (self.autoRotate) {
                CGSize videoSize = track.naturalSize;
                CGSize viewSize =  [self frame].size;
                CGRect outRect = CGRectApplyAffineTransform(CGRectMake(0, 0, videoSize.width, videoSize.height), transform);
                
                BOOL viewIsWide = viewSize.width / viewSize.height > 1;
                BOOL videoIsWide = outRect.size.width / outRect.size.height > 1;
                
                if (viewIsWide != videoIsWide) {
                    transform = CGAffineTransformRotate(transform, M_PI_2);
                }
            }
        }
        self.preferredCIImageTransform = transform;
    }
}

- (void)unsetupVideoOutputToItem:(AVPlayerItem *)item {
    if (_videoOutput != nil && item != nil) {
        if ([item.outputs containsObject:_videoOutput]) {
            AVPlayerItemVideoOutput *videoOutput = _videoOutput;
            if (videoOutput.delegateQueue) {
                dispatch_async(videoOutput.delegateQueue, ^{
                    [item removeOutput:videoOutput];
                });
            } else {
                [item removeOutput:videoOutput];
            }
        }
        [_videoOutput setDelegate:nil queue:nil];
        _videoOutput = nil;
    }
}

#pragma mark - AVPlayerItemOutputPullDelegate
- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender {
    _displayLink.paused = NO;
}


@end
