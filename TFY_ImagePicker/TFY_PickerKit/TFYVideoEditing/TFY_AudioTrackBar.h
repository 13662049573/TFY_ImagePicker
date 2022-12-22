//
//  TFY_AudioTrackBar.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class TFY_AudioTrackBar;

NS_ASSUME_NONNULL_BEGIN

@interface TFY_AudioItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, readonly) BOOL isOriginal;
@property (nonatomic, assign) BOOL isEnable;

+ (instancetype)defaultAudioItem;

@end

@protocol TFYAudioTrackBarDelegate <NSObject>

/** 完成回调 */
- (void)picker_audioTrackBar:(TFY_AudioTrackBar *)audioTrackBar didFinishAudioUrls:(NSArray <TFY_AudioItem *> *)audioUrls;
/** 取消回调 */
- (void)picker_audioTrackBarDidCancel:(TFY_AudioTrackBar *)audioTrackBar;

@end

@interface TFY_AudioTrackBar : UIView

@property (nonatomic, strong) NSArray <TFY_AudioItem *> *audioUrls;

/** 代理 */
@property (nonatomic, weak) UIViewController <TFYAudioTrackBarDelegate> *delegate;

- (instancetype)initWithFrame:(CGRect)frame layout:(void (^)(TFY_AudioTrackBar *audioTrackBar))layoutBlock;

/** 样式 */
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *cancelButtonTitleColorNormal;
@property (nonatomic, copy) NSString *oKButtonTitle;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, assign) CGFloat customTopbarHeight;
@property (nonatomic, assign) CGFloat naviHeight;
@property (nonatomic, assign) CGFloat customToolbarHeight;

@end

NS_ASSUME_NONNULL_END
