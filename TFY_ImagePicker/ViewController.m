//
//  ViewController.m
//  TFY_ImagePicker
//
//  Created by 田风有 on 2022/12/21.
//

#import "ViewController.h"
#import "TFY_PickerKit.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface TFY_CustomObject : NSObject <TFY_AssetImageProtocol>

@property (nonatomic, strong) UIImage *assetImage;

+ (instancetype)picker_CustomObjectWithImage:(UIImage *)image;

@end

@implementation TFY_CustomObject

+ (instancetype)picker_CustomObjectWithImage:(UIImage *)image
{
    TFY_CustomObject *object = [[[self class] alloc] init];
    object.assetImage = image;
    return object;
}

@end

@interface TFY_PhotoObject : NSObject <TFY_AssetPhotoProtocol>

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, strong) UIImage *thumbnailImage;

+ (instancetype)picker_PhotoObjectWithImage:(UIImage *)image thumbnailImage:(UIImage *)thumbnailImage;

@end

@implementation TFY_PhotoObject

+ (instancetype)picker_PhotoObjectWithImage:(UIImage *)image thumbnailImage:(UIImage *)thumbnailImage
{
    TFY_PhotoObject *object = [[[self class] alloc] init];
    object.originalImage = image;
    object.thumbnailImage = thumbnailImage;
    return object;
}

@end

@interface ViewController ()<TFYImagePickerControllerDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) UIImageView *thumbnailImageVIew;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (assign, nonatomic) BOOL isCreateGif;
@property (assign, nonatomic) BOOL isCreateMP4;
/** share */
@property (strong, nonatomic) UIDocumentInteractionController *documentInConVC;
@property (strong, nonatomic) NSString *sharePath;
@property (copy, nonatomic) picker_takePhotoHandler handler;
@property (weak, nonatomic) UIButton *shareButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat width_w = UIScreen.mainScreen.bounds.size.width;
    NSArray<NSString *> *titleArr = @[@"正常模式",@"朋友圈",@"浏览模式Asset对象",@"浏览模式TFY_PickerAsset对象",@"浏览模式iamge对象"];
    [titleArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(100, 80+idx * 50, width_w-200, 40);
        [btn setTitle:obj forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        btn.tag = idx;
        btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [btn addTarget:self action:@selector(viewClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }];
    
    NSArray<NSString *> *titleArr2 = @[@"创建GIF",@"分享",@"创建MP4"];
    [titleArr2 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(50+idx * ((width_w - 100)/3), 330, ((width_w - 100)/3), 50);
        [btn setTitle:obj forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        btn.tag = idx;
        btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [btn addTarget:self action:@selector(viewClick2:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        if (idx == 1) {
            self.shareButton = btn;
        }
    }];
    
    UILabel *lable1 = UILabel.new;
    lable1.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    lable1.text = @"缩略图";
    lable1.frame = CGRectMake(0, 400, width_w/2, 20);
    lable1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lable1];
    
    UILabel *lable2 = UILabel.new;
    lable2.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    lable2.text = @"原图";
    lable2.frame = CGRectMake(width_w/2, 400, width_w/2, 20);
    lable2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lable2];
    
    self.thumbnailImageVIew = [[UIImageView alloc] init];
    self.thumbnailImageVIew.frame = CGRectMake(20, CGRectGetMaxY(lable1.frame)+10, width_w/2-30, 300);
    self.thumbnailImageVIew.backgroundColor = UIColor.orangeColor;
    [self.view addSubview:self.thumbnailImageVIew];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = CGRectMake(width_w-(width_w/2-30)-20, CGRectGetMaxY(lable1.frame)+10, width_w/2-30, 300);
    self.imageView.backgroundColor = UIColor.orangeColor;
    [self.view addSubview:self.imageView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _playerLayer.bounds = self.imageView.bounds;
}


// @"正常模式",@"朋友圈",@"浏览模式Asset对象",@"浏览模式协议对象",@"浏览模式iamge对象"
- (void)viewClick:(UIButton *)btn {
    if (btn.tag == 0) {
        [self buttonActionNormal:btn];
    } else if (btn.tag == 1) {
        [self buttonActionFriendCircle:btn];
    } else if (btn.tag == 2) {
        [self buttonActionPreviewAsset:btn];
    } else if (btn.tag == 3) {
        [self buttonActionPreviewImage:btn];
    } else if (btn.tag == 4) {
        [self buttonActionPreviewPhoto:btn];
    }
}
// @"创建GIF",@"分享",@"创建MP4"
- (void)viewClick2:(UIButton *)btn {
    if (btn.tag == 0) {
        [self buttonAction4_c_gif:btn];
    } else if (btn.tag == 1) {
        [self buttonAction6_share:btn];
    } else if (btn.tag == 2) {
        [self buttonAction5_c_mp4:btn];
    }
}

// 正常模式
- (void)buttonActionNormal:(id)sender {
//    [LFAssetManager cleanCacheVideoPath];
    TFY_ImagePickerController *imagePicker = [[TFY_ImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
//    imagePicker.allowTakePicture = NO;
//    imagePicker.maxVideosCount = 1; /** 解除混合选择- 要么1个视频，要么9个图片 */
//    imagePicker.sortAscendingByCreateDate = NO;
//    imagePicker.allowEditing = NO;
    imagePicker.supportAutorotate = YES; /** 适配横屏 */
//    imagePicker.imageCompressSize = 200; /** 标清图压缩大小 */
//    imagePicker.thumbnailCompressSize = 20; /** 缩略图压缩大小 */
    imagePicker.allowPickingType = TFYPickingMediaTypeALL;
//    imagePicker.autoPlayLivePhoto = NO; /** 自动播放live photo */
//    imagePicker.autoSelectCurrentImage = NO; /** 关闭自动选中 */
//    imagePicker.defaultAlbumName = @"动图"; /** 指定默认显示相册 */
//    imagePicker.displayImageFilename = YES; /** 显示文件名称 */
//    imagePicker.thumbnailCompressSize = 0.f; /** 不需要缩略图 */
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
        imagePicker.syncAlbum = YES; /** 实时同步相册 */
    }
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}
// 朋友圈
- (void)buttonActionFriendCircle:(id)sender {
    TFY_ImagePickerController *imagePicker = [[TFY_ImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
//    imagePicker.allowTakePicture = NO;
    imagePicker.maxVideosCount = 1; /** 解除混合选择- 要么1个视频，要么9个图片 */
    imagePicker.supportAutorotate = YES; /** 适配横屏 */
    imagePicker.allowPickingType = TFYPickingMediaTypeALL;
    imagePicker.maxVideoDuration = 10; /** 10秒视频 */
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
        imagePicker.syncAlbum = YES; /** 实时同步相册 */
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}
// 预览模式Asset 对象
- (void)buttonActionPreviewAsset:(id)sender {
    int limit = 10;
    [[TFY_AssetManager manager] getCameraRollAlbum:TFYPickingMediaTypeALL fetchLimit:limit ascending:YES completion:^(TFY_PickerAlbum *model) {
        [[TFY_AssetManager manager] getAssetsFromFetchResult:model.result allowPickingType:TFYPickingMediaTypeALL fetchLimit:limit ascending:NO completion:^(NSArray<TFY_PickerAsset *> *models) {
            NSMutableArray *array = [@[] mutableCopy];
            for (TFY_PickerAsset *asset in models) {
                [array addObject:asset.asset];
            }
            TFY_ImagePickerController *imagePicker = [[TFY_ImagePickerController alloc] initWithSelectedAssets:array index:0];
            imagePicker.pickerDelegate = self;
            imagePicker.supportAutorotate = YES;
//            imagePicker.allowPickingGif = YES; /** 支持GIF */
//            imagePicker.maxVideosCount = 1; /** 解除混合选择- 要么1个视频，要么9个图片 */
            /** 全选 */
//            imagePicker.selectedAssets = array;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];
    }];
}

// 预览模式《TFY_PickerAsset对象》
- (void)buttonActionPreviewImage:(id)sender {
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"gif"];
//    [UIImage imageNamed:@"3.gif"] //这样加载是静态图片
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[TFY_CustomObject picker_CustomObjectWithImage:[UIImage imageNamed:@"1.jpeg"]]];
    [array addObject:[TFY_CustomObject picker_CustomObjectWithImage:[UIImage imageNamed:@"2.jpeg"]]];
    [array addObject:[TFY_CustomObject picker_CustomObjectWithImage:[UIImage picker_imageWithImagePath:gifPath]]];
    
    TFY_ImagePickerController *imagePicker = [[TFY_ImagePickerController alloc] initWithSelectedImageObjects:array index:0 complete:^(NSArray<id<TFY_AssetImageProtocol>> *photos) {
        [self.thumbnailImageVIew setImage:nil];
        [self.imageView setImage:photos.firstObject.assetImage];
    }];
    imagePicker.imagePickerControllerDidCancelHandle = ^{
        
    };
    /** 全选 */
    imagePicker.selectedAssets = array;
    /** 关闭自动选中 */
    imagePicker.autoSelectCurrentImage = NO;
    imagePicker.supportAutorotate = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
// 浏览模型inmae
- (void)buttonActionPreviewPhoto:(id)sender {
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"gif"];
    //    [UIImage imageNamed:@"3.gif"] //这样加载是静态图片
    NSMutableArray *array = [NSMutableArray array];
    // 这里测试代码，原图与缩略图为同一张图片，但为了运行流畅性，建议提供缩略图。
    UIImage *image1 = [UIImage imageNamed:@"1.jpeg"];
    [array addObject:[TFY_PhotoObject picker_PhotoObjectWithImage:image1 thumbnailImage:image1]];
    UIImage *image2 = [UIImage imageNamed:@"2.jpeg"];
    [array addObject:[TFY_PhotoObject picker_PhotoObjectWithImage:image2 thumbnailImage:image2]];
    [array addObject:[TFY_PhotoObject picker_PhotoObjectWithImage:[UIImage picker_imageWithImagePath:gifPath] thumbnailImage:[UIImage imageNamed:@"3.gif"]]];
    
    TFY_ImagePickerController *imagePicker = [[TFY_ImagePickerController alloc] initWithSelectedPhotoObjects:array complete:^(NSArray<id<TFY_AssetPhotoProtocol>> *photos) {
        [self.thumbnailImageVIew setImage:photos.firstObject.thumbnailImage];
        [self.imageView setImage:photos.firstObject.originalImage];
    }];
    imagePicker.imagePickerControllerDidCancelHandle = ^{
        
    };
    /** 全选 */
//    imagePicker.selectedAssets = array;
    /** 关闭自动选中 */
    imagePicker.autoSelectCurrentImage = NO;
    imagePicker.supportAutorotate = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
// 创建GIF
- (void)buttonAction4_c_gif:(id)sender {
    self.isCreateGif = YES;
    
    TFY_ImagePickerController *imagePicker = [[TFY_ImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePicker.allowPickingType = TFYPickingMediaTypePhoto;
    imagePicker.allowTakePicture = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

// 创建MP4
- (void)buttonAction5_c_mp4:(id)sender {
    self.isCreateMP4 = YES;
    
    TFY_ImagePickerController *imagePicker = [[TFY_ImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePicker.allowPickingType = TFYPickingMediaTypePhoto;
    imagePicker.allowTakePicture = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - TFYImagePickerControllerDelegate
- (void)picker_imagePickerController:(TFY_ImagePickerController *)picker takePhotoHandler:(picker_takePhotoHandler)handler
{
    self.handler = handler;
    
    BOOL onlyPhoto = NO;
    BOOL onlyVideo = NO;
    if (picker.selectedObjects.count) {
        onlyPhoto = picker.maxImagesCount != picker.maxVideosCount && picker.selectedObjects.firstObject.type == TFYAssetMediaTypePhoto;
        onlyVideo = picker.maxImagesCount != picker.maxVideosCount && picker.selectedObjects.firstObject.type == TFYAssetMediaTypeVideo;
    }
    
    UIImagePickerController *mediaPickerController = [[UIImagePickerController alloc] init];
    // set appearance / 改变相册选择页的导航栏外观
    {
        mediaPickerController.navigationBar.barTintColor = picker.navigationBar.barTintColor;
        mediaPickerController.navigationBar.tintColor = picker.navigationBar.tintColor;
        NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
        UIBarButtonItem *barItem;
        if (@available(iOS 9.0, *)){
            barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        }
        textAttrs[NSForegroundColorAttributeName] = picker.barItemTextColor;
        textAttrs[NSFontAttributeName] = picker.barItemTextFont;
        [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    }
    mediaPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    mediaPickerController.delegate = self;
    
    NSMutableArray *mediaTypes = [NSMutableArray array];
    
    if (picker.allowPickingType & TFYPickingMediaTypePhoto && picker.selectedObjects.count < picker.maxImagesCount && !onlyVideo) {
        [mediaTypes addObject:(NSString *)kUTTypeImage];
    }
    if (picker.allowPickingType & TFYPickingMediaTypeVideo && picker.selectedObjects.count < picker.maxVideosCount && !onlyPhoto) {
        [mediaTypes addObject:(NSString *)kUTTypeMovie];
        mediaPickerController.videoMaximumDuration = picker.maxVideoDuration;
    }
    
    mediaPickerController.mediaTypes = mediaTypes;
    
    /** warning：Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates. */
    [picker presentViewController:mediaPickerController animated:YES completion:nil];
}

- (void)picker_imagePickerController:(TFY_ImagePickerController *)picker didFinishPickingResult:(NSArray <TFY_ResultObject /* <TFY_ResultImage/TFY_ResultVideo> */*> *)results;
{
    self.sharePath = nil;
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *thumbnailFilePath = [documentPath stringByAppendingPathComponent:@"thumbnail"];
    NSString *originalFilePath = [documentPath stringByAppendingPathComponent:@"original"];
    
    NSFileManager *fileManager = [NSFileManager new];
    if (![fileManager fileExistsAtPath:thumbnailFilePath])
    {
        [fileManager createDirectoryAtPath:thumbnailFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:originalFilePath])
    {
        [fileManager createDirectoryAtPath:originalFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [_playerLayer removeFromSuperlayer];
    
    UIImage *thumbnailImage = nil;
    UIImage *originalImage = nil;
    AVPlayerLayer *playerLayer = [[AVPlayerLayer alloc] init];
    playerLayer.bounds = self.imageView.bounds;
    playerLayer.anchorPoint = CGPointZero;
    [self.imageView.layer addSublayer:playerLayer];
    _playerLayer = playerLayer;
    
    NSMutableArray <UIImage *>*images = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < results.count; i++) {
        TFY_ResultObject *result = results[i];
        if ([result isKindOfClass:[TFY_ResultImage class]]) {
            
            TFY_ResultImage *resultImage = (TFY_ResultImage *)result;
            
            if (playerLayer.player == nil) {
                thumbnailImage = resultImage.thumbnailImage;
                originalImage = resultImage.originalImage;
                NSString *name = resultImage.info.name;
                NSData *thumnailData = resultImage.thumbnailData;
                NSData *originalData = resultImage.originalData;
                CGFloat byte = resultImage.info.byte;
                CGSize size = resultImage.info.size;
                
                
                /** 缩略图保存到路径 */
                [thumnailData writeToFile:[thumbnailFilePath stringByAppendingPathComponent:name] atomically:YES];
                /** 原图保存到路径 */
                if ([originalData writeToFile:[originalFilePath stringByAppendingPathComponent:name] atomically:YES]) {
                    self.sharePath = [originalFilePath stringByAppendingPathComponent:name];
                }
                
                NSLog(@"🎉🚀Info name:%@ -- infoLength:%fK -- thumnailLength:%fK -- originalLength:%fK -- infoSize:%@", name, byte/1000.0, thumnailData.length/1000.0, originalData.length/1000.0, NSStringFromCGSize(size));
                
                [images addObject:originalImage];
            }
            
        } else if ([result isKindOfClass:[TFY_ResultVideo class]]) {
            
            TFY_ResultVideo *resultVideo = (TFY_ResultVideo *)result;
            if (playerLayer.player == nil && originalImage == nil) {
                /** 保存视频 */
                if ([resultVideo.data writeToFile:[originalFilePath stringByAppendingPathComponent:resultVideo.info.name] atomically:YES]) {
                    self.sharePath = [originalFilePath stringByAppendingPathComponent:resultVideo.info.name];
                }
                
                thumbnailImage = resultVideo.coverImage;
                
                AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:[originalFilePath stringByAppendingPathComponent:resultVideo.info.name]]];
                [playerLayer setPlayer:player];
                [player play];
            }
            NSLog(@"🎉🚀Info name:%@ -- infoLength:%fK -- videoLength:%fK -- infoSize:%@", resultVideo.info.name, resultVideo.info.byte/1000.0, resultVideo.data.length/1000.0, NSStringFromCGSize(resultVideo.info.size));
        } else {
            /** 无法处理的数据 */
            NSLog(@"%@", result.error);
        }
    }
    
    if (self.isCreateGif) {
        NSData *imageData = [[TFY_AssetManager manager] createGifDataWithImages:images size:[UIScreen mainScreen].bounds.size duration:images.count loopCount:0 error:nil];
        NSString *path = [originalFilePath stringByAppendingPathComponent:@"newGif.gif"];
        if ([imageData writeToFile:path atomically:YES]) {
            self.sharePath = path;
        }
        UIImage *gif = [UIImage picker_imageWithImageData:imageData];
        if (gif) {
            originalImage = gif;
        }
    } else if (self.isCreateMP4) {
        thumbnailImage = images.firstObject;
        originalImage = nil;
        [[TFY_AssetManager manager] createMP4WithImages:images size:[UIScreen mainScreen].bounds.size complete:^(NSData *data, NSError *error) {
            if (error) {
                NSLog(@"create MP4 error:%@", error);
            } else {
                NSString *path = [originalFilePath stringByAppendingPathComponent:@"newMP4.mp4"];
                if ([data writeToFile:path atomically:YES]) {
                    self.sharePath = path;
                }
                AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
                [playerLayer setPlayer:player];
                [player play];
            }
        }];
    }
    
    [self.thumbnailImageVIew setImage:thumbnailImage];
    [self.imageView setImage:originalImage];
    
    self.isCreateGif = NO;
    self.isCreateMP4 = NO;
}

- (void)picker_imagePickerControllerDidCancel:(TFY_ImagePickerController *)picker
{
    self.isCreateGif = NO;
    self.isCreateMP4 = NO;
}


#pragma mark - Share
- (void)buttonAction6_share:(id)sender {
    if (self.sharePath.length == 0) {
        NSLog(@"分享失败！");
        return;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        _documentInConVC = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.sharePath]];
        _documentInConVC.delegate = self;
        [_documentInConVC presentOptionsMenuFromRect:self.shareButton.frame inView:self.view animated:YES];
    }
}


#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller{
    return self.view.frame;
}

#pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    BOOL hasUsingMedia = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        if (chosenImage) {
            hasUsingMedia = YES;
            if (self.handler) {
                self.handler(chosenImage, (NSString *)kUTTypeImage, ^(TFY_ImagePickerController *picker, NSError * _Nullable error) {
                    [picker dismissViewControllerAnimated:YES completion:^{
                        if (error) {
                            [picker showAlertWithTitle:nil message:error.localizedDescription complete:nil];
                        }
                    }];
                });
            }
        }
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoUrl) {
            hasUsingMedia = YES;
            if (self.handler) {
                self.handler(videoUrl, (NSString *)kUTTypeMovie, ^(TFY_ImagePickerController *picker, NSError * _Nullable error) {
                    [picker dismissViewControllerAnimated:YES completion:^{
                        if (error) {
                            [picker showAlertWithTitle:nil message:error.localizedDescription complete:nil];
                        }
                    }];
                });
            }
        }
    }
    self.handler = nil;
    if (!hasUsingMedia) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
