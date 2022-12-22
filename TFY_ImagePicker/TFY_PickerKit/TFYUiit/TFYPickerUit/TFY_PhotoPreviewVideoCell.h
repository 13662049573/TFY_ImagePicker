//
//  TFY_PhotoPreviewVideoCell.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PhotoPreviewCell.h"
#import <AVFoundation/AVFoundation.h>

@class TFY_PhotoPreviewVideoCell;
NS_ASSUME_NONNULL_BEGIN

@protocol TFYPhotoPreviewVideoCellDelegate <NSObject, TFYPhotoPreviewCellDelegate>
@optional
- (void)picker_photoPreviewVideoCellDidPlayHandler:(TFY_PhotoPreviewVideoCell *)cell;
- (void)picker_photoPreviewVideoCellDidStopHandler:(TFY_PhotoPreviewVideoCell *)cell;
@end

@interface TFY_PhotoPreviewVideoCell : TFY_PhotoPreviewCell
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) AVAsset *asset;
@property (nonatomic, weak) id<TFYPhotoPreviewVideoCellDelegate> delegate;

- (void)didPlayCell;
- (void)didPauseCell;
@end

NS_ASSUME_NONNULL_END
