//
//  TFY_FilterVideoExportSession.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_FilterVideoExportSession.h"
#import "TFY_Filter+Initialize.h"
#import "TFY_Filter.h"
#import "TFY_MutableFilter.h"
#import "TFY_AssetExportSession.h"
#import <UIKit/UIKit.h>

@interface TFY_FilterVideoExportSession ()<TFYAssetExportSessionDelegate>

@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
@property (nonatomic, strong) AVMutableAudioMix *audioMix;

@property (nonatomic, strong) CIContext *context;

@property (nonatomic, strong) TFY_AssetExportSession *exportSession;
@property (nonatomic, copy) void (^progressHandler)(float progress);

@end

@implementation TFY_FilterVideoExportSession

- (id)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self) {
        _isOrignalSound = YES;
        _asset = asset;
        _timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
        _rate = 1.f;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    return [self initWithAsset:asset];
}

- (void)dealloc
{
    [self.exportSession cancelExport];
    self.exportSession = nil;
    self.composition = nil;
    self.videoComposition = nil;
}

- (void)setRate:(float)rate
{
    if (rate > 0) {
        _rate = rate;
    }
}

- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(NSError *error))handler
{
    [self exportAsynchronouslyWithCompletionHandler:handler progress:nil];
}
- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(NSError *error))handler progress:(void (^)(float progress))progress
{
    [self.exportSession cancelExport];
    self.progressHandler = nil;
    self.exportSession = nil;
    self.composition = nil;
    self.audioMix = nil;
    self.videoComposition = nil;
    
    self.progressHandler = progress;
    
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager new];
    NSURL *trimURL = self.outputURL;
    /** 删除原来剪辑的视频 */
    BOOL exist = [fm fileExistsAtPath:trimURL.path];
    if (exist) {
        if (![fm removeItemAtURL:trimURL error:&error]) {
            NSLog(@"removeTrimPath error: %@ \n",[error localizedDescription]);
        }
    }
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[self.asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [self.asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    CMTime insertionPoint = kCMTimeZero;
    
    // Step 1
    // Create a composition with the given asset and insert audio and video tracks into it from the asset
    // Check if a composition already exists, else create a composition using the input asset
    
    self.composition = [[AVMutableComposition alloc] init];
    
    CMTime totalTime = CMTimeMake(self.timeRange.duration.value/self.rate, self.timeRange.duration.timescale);
    
    // Insert the video and audio tracks from AVAsset
    if (assetVideoTrack != nil) {
        // 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
        AVMutableCompositionTrack *compositionVideoTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        // 视频方向
        [compositionVideoTrack setPreferredTransform:assetVideoTrack.preferredTransform];
        // 把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
        [compositionVideoTrack insertTimeRange:self.timeRange ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
        [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, self.timeRange.duration) toDuration:totalTime];
    }
    if (assetAudioTrack != nil && self.isOrignalSound) {
        AVMutableCompositionTrack *compositionAudioTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        compositionAudioTrack.preferredTransform = assetAudioTrack.preferredTransform;
        [compositionAudioTrack insertTimeRange:self.timeRange ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
        [compositionAudioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, self.timeRange.duration) toDuration:totalTime];
    }
    
    /** 创建额外音轨特效 */
    NSMutableArray<AVAudioMixInputParameters *> *inputParameters;
    if (self.audioUrls.count) {
        inputParameters = [@[] mutableCopy];
    }
    
    /** 添加其他音频 */
    for (NSURL *audioUrl in self.audioUrls) {
        /** 声音采集 */
        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
        
        NSArray *additional_audios = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
        
        if (additional_audios.count) {
            CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
            if (CMTIME_COMPARE_INLINE(audioAsset.duration, >, self.timeRange.duration)) {
                audio_timeRange = CMTimeRangeMake(kCMTimeZero, self.timeRange.duration);
            }
            
            NSInteger times = 0;
            if (CMTIME_COMPARE_INLINE(audio_timeRange.duration, <, self.timeRange.duration)) {
                times = ceil(CMTimeGetSeconds(self.timeRange.duration)/CMTimeGetSeconds(audioAsset.duration))-1;
            }
            
            AVAssetTrack *additional_assetAudioTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
            
            AVMutableCompositionTrack *additional_compositionAudioTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            additional_compositionAudioTrack.preferredTransform = additional_assetAudioTrack.preferredTransform;
            [additional_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:additional_assetAudioTrack atTime:insertionPoint error:&error];
            
            CMTime atTime = insertionPoint;
            for (NSInteger t=0; t<times; t++) {
                atTime = CMTimeAdd(atTime, audio_timeRange.duration);
                if (t == times-1) {
                    [additional_compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeSubtract(self.timeRange.duration, atTime)) ofTrack:additional_assetAudioTrack atTime:atTime error:&error];
                } else {
                    [additional_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:additional_assetAudioTrack atTime:atTime error:&error];
                }
            }
            [additional_compositionAudioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, self.timeRange.duration) toDuration:totalTime];
            
            AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:additional_compositionAudioTrack];
            mixParameters.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmTimeDomain;
            [mixParameters setVolumeRampFromStartVolume:1 toEndVolume:0.3 timeRange:CMTimeRangeMake(kCMTimeZero, totalTime)];
            [inputParameters addObject:mixParameters];
        }
    }
    if (inputParameters.count) {
        self.audioMix = [AVMutableAudioMix audioMix];
        self.audioMix.inputParameters = inputParameters;
    }
    
    UIImageOrientation orientation = [self orientationFromAVAssetTrack:assetVideoTrack];
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGSize renderSize = assetVideoTrack.naturalSize;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            //顺时针旋转270°
            //            NSLog(@"视频旋转270度，home按键在右");
            transform = CGAffineTransformTranslate(transform, 0.0, assetVideoTrack.naturalSize.width);
            transform = CGAffineTransformRotate(transform,M_PI_2*3.0);
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.height,assetVideoTrack.naturalSize.width);
            break;
        case UIImageOrientationRight:
            //顺时针旋转90°
            //            NSLog(@"视频旋转90度,home按键在左");
            transform = CGAffineTransformTranslate(transform, assetVideoTrack.naturalSize.height, 0.0);
            transform = CGAffineTransformRotate(transform,M_PI_2);
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.height,assetVideoTrack.naturalSize.width);
            break;
        case UIImageOrientationDown:
            //顺时针旋转180°
            //            NSLog(@"视频旋转180度，home按键在上");
            transform = CGAffineTransformTranslate(transform, assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
            transform = CGAffineTransformRotate(transform,M_PI);
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.width,assetVideoTrack.naturalSize.height);
            break;
        default:
            break;
    }
    
    if (@available(iOS 9.0, *)) {
        /** 创建滤镜 （水印也当成一种滤镜，效率更佳）iOS9 later */
        TFY_Filter *renderingFilter = [self _generateRenderingFilterForVideoSize:renderSize];
        if (renderingFilter == nil && orientation != UIImageOrientationUp) {
            renderingFilter = [TFY_Filter emptyFilter];
        }
        if (renderingFilter) {
            
            AVMutableVideoComposition *videoComposition = nil;
            if (renderingFilter && [[AVVideoComposition class] respondsToSelector:@selector(videoCompositionWithAsset:applyingCIFiltersWithHandler:)]) {
                if (self.context == nil) {
                    self.context = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace : [NSNull null], kCIContextOutputColorSpace : [NSNull null]}];
                }
                CIContext *context = self.context;
                videoComposition = [AVMutableVideoComposition videoCompositionWithAsset:self.composition applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
                    CIImage *image = [renderingFilter imageByProcessingImage:request.sourceImage atTime:CMTimeGetSeconds(request.compositionTime)];
                    
                    [request finishWithImage:image context:context];
                }];
            }
            self.videoComposition = videoComposition;
            self.videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
            self.videoComposition.renderSize = renderSize;
        }
    } else {
        /** iOS9之前的处理方法，之后使用CIFilter */
        if (orientation != UIImageOrientationUp || self.overlayView) {
            self.videoComposition = [AVMutableVideoComposition videoComposition];
            self.videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
            self.videoComposition.renderSize = renderSize;
            
            AVAssetTrack *videoTrack = [self.composition tracksWithMediaType:AVMediaTypeVideo][0];
            
            AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.composition.duration);
            AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            [roateLayerInstruction setTransform:transform atTime:kCMTimeZero];
            
            roateInstruction.layerInstructions = @[roateLayerInstruction];
            //将视频方向旋转加入到视频处理中
            self.videoComposition.instructions = @[roateInstruction];
            
            /** 水印 */
            if(self.overlayView) {
                CALayer *animatedLayer = [self _generateAnimatedTitleLayerForSize:renderSize];
                CALayer *parentLayer = [CALayer layer];
                CALayer *videoLayer = [CALayer layer];
                parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
                videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
                [parentLayer addSublayer:videoLayer];
                [parentLayer addSublayer:animatedLayer];
                
                self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            }
        }
        
    }
    
    self.exportSession = [[TFY_AssetExportSession alloc] initWithAsset:self.composition preset:TFYAssetExportSessionPreset4K];
    // Implementation continues.
    /** 创建混合视频时开始剪辑 */
    //    self.exportSession.timeRange = self.timeRange;
    self.exportSession.videoComposition = self.videoComposition;
    self.exportSession.outputURL = trimURL;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.audioMix = self.audioMix;
    self.exportSession.delegate = self;
    
    if (self.asset.duration.timescale == 0 || self.exportSession == nil) {
        /** 这个情况AVAssetExportSession会卡死 */
        NSError *failError = [NSError errorWithDomain:@"TFY_FilterVideoExportSessionError" code:(-100) userInfo:@{NSLocalizedDescriptionKey:@"exportSession init fail"}];
        if (handler) handler(failError);
        return;
    }
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Export completed");
                    break;
                default:
                    break;
            }
            if ([self.exportSession status] == AVAssetExportSessionStatusCompleted && [fm fileExistsAtPath:trimURL.path]) {
                if (handler) handler(nil);
            } else {
                if (handler) handler(self.exportSession.error);
            }
        });
    }];
}

- (void)cancelExport
{
    [self.exportSession cancelExport];
}

#pragma mark - TFYAssetExportSessionDelegate
- (void)assetExportSessionDidProgress:(TFY_AssetExportSession *)assetExportSession
{
    if (self.progressHandler) {
        self.progressHandler(assetExportSession.progress);
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (TFY_Filter *)_generateRenderingFilterForVideoSize:(CGSize)videoSize {
    
    TFY_Filter *watermarkFilter = [self _generateWaterFilterForVideoSize:videoSize];
    TFY_Filter *renderingFilter = nil;
    TFY_Filter *customFilter = self.filter;
    
    if (customFilter != nil) {
        if (watermarkFilter != nil) {
            TFY_MutableFilter *tempFilter = [TFY_MutableFilter emptyFilter];
            [tempFilter addSubFilter:customFilter];
            [tempFilter addSubFilter:watermarkFilter];
            renderingFilter = tempFilter;
        } else {
            renderingFilter = customFilter;
        }
    } else {
        renderingFilter = watermarkFilter;
    }
    
    if (renderingFilter.isEmpty) {
        renderingFilter = nil;
    }
    
    return renderingFilter;
}

- (TFY_Filter *)_generateWaterFilterForVideoSize:(CGSize)videoSize
{
    if (self.overlayView) {
        UIImage *watermarkImage = [self _generateWaterImageForVideoSize:videoSize];
        CIImage *watermarkCIImage = [CIImage imageWithCGImage:watermarkImage.CGImage];
        return [TFY_Filter filterWithCIImage:watermarkCIImage];
    }
    return nil;
}

#pragma clang diagnostic pop

- (UIImage *)_generateWaterImageForVideoSize:(CGSize)videoSize
{
    UIView *overlayView = self.overlayView;
    
    if (overlayView) {
        
        CGRect rect = overlayView.frame;
        /** 参数取整，否则可能会出现1像素偏差 */
        /** 有小数部分才调整差值 */
#define picker_export_fixDecimal(d) ((fmod(d, (int)d)) > 0.59f ? ((int)(d+0.5)*1.f) : (((fmod(d, (int)d)) < 0.59f && (fmod(d, (int)d)) > 0.1f) ? ((int)(d)*1.f+0.5f) : (int)(d)*1.f))
        rect.origin.x = picker_export_fixDecimal(rect.origin.x);
        rect.origin.y = picker_export_fixDecimal(rect.origin.y);
        rect.size.width = picker_export_fixDecimal(rect.size.width);
        rect.size.height = picker_export_fixDecimal(rect.size.height);
#undef picker_export_fixDecimal
        CGSize size = rect.size;
        //1.开启上下文
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        //2.绘制图层
        [overlayView.layer renderInContext: context];
        //3.从上下文中获取新图片
        UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
        //4.关闭图形上下文
        UIGraphicsEndImageContext();
        
        /** 缩放至视频大小 */
        UIGraphicsBeginImageContextWithOptions(videoSize, NO, 1);
        [watermarkImage drawInRect:CGRectMake(0, 0, videoSize.width, videoSize.height)];
        UIImage *generatedWatermarkImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return generatedWatermarkImage;
    }
    return nil;
}

- (CALayer *)_generateAnimatedTitleLayerForSize:(CGSize)size
{
    UIImage *watermarkImage = [self _generateWaterImageForVideoSize:size];
    // 1 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.contentsScale = [UIScreen mainScreen].scale;
    overlayLayer.contents = (__bridge id _Nullable)(watermarkImage.CGImage);
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    return overlayLayer;
}

- (UIImageOrientation)orientationFromAVAssetTrack:(AVAssetTrack *)videoTrack
{
    UIImageOrientation orientation = UIImageOrientationUp;
    
    CGAffineTransform t = videoTrack.preferredTransform;
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        // Portrait
        //        degress = 90;
        orientation = UIImageOrientationRight;
    }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        // PortraitUpsideDown
        //        degress = 270;
        orientation = UIImageOrientationLeft;
    }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        // LandscapeRight
        //        degress = 0;
        orientation = UIImageOrientationUp;
    }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        // LandscapeLeft
        //        degress = 180;
        orientation = UIImageOrientationDown;
    }
    
    return orientation;
}

@end
