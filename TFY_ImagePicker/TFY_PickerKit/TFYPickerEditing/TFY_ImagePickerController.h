//
//  TFY_ImagePickerController.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_LayoutPickerController.h"
#import "TFYPickerUit.h"

@class TFY_PickerAsset,TFY_ImagePickerController;

NS_ASSUME_NONNULL_BEGIN

typedef void(^picker_takePhotoCallback)(TFY_ImagePickerController *picker, NSError * _Nullable error);
typedef void(^picker_takePhotoHandler)(id media, NSString *mediaType, picker_takePhotoCallback _Nullable callback);

@protocol TFYImagePickerControllerDelegate <NSObject> /** 每个代理方法都有对应的block回调 */
@optional

/**
 当allowTakePicture=YES,点击拍照会执行
 方案1：如果不实现这个代理方法,执行内置拍照模块,拍照完成后会保存到相册,并选中它。
 方案2：实现这个代理方法,则由开发者自己处理拍照模块,完毕后手动dismiss或其他操作。
 */
- (void)picker_imagePickerController:(TFY_ImagePickerController *)picker takePhotoHandler:(picker_takePhotoHandler)handler;

/**
 
 Click cancel to trigger it.
 当选择器点击取消的时候,会执行回调
 */
- (void)picker_imagePickerControllerDidCancel:(TFY_ImagePickerController *)picker;


/**
 1.2.6 replace all old interfaces with unique callback to avoid interface diversification
 👍🎉1.2.6_取代所有旧接口,唯一回调,避免接口多样化
 picker 选择器/picker
  results 回调对象/callback object
 */
- (void)picker_imagePickerController:(TFY_ImagePickerController *)picker didFinishPickingResult:(NSArray <TFY_ResultObject /* <TFY_ResultImage/TFY_ResultVideo> */*> *)results;

@end

@interface TFY_ImagePickerController : TFY_LayoutPickerController

/// Use this init method / 用这个初始化方法
- (instancetype)initWithMaxImagesCount:(NSUInteger)maxImagesCount delegate:(id<TFYImagePickerControllerDelegate>)delegate;
- (instancetype)initWithMaxImagesCount:(NSUInteger)maxImagesCount columnNumber:(NSUInteger)columnNumber delegate:(id<TFYImagePickerControllerDelegate>)delegate;

#pragma mark - preview model,self.isPreview = YES.
/// This init method just for previewing photos,pickerDelegate = self; / 用这个初始化方法以预览图片,pickerDelegate = self;
- (instancetype)initWithSelectedAssets:(NSArray /**<PHAsset/ALAsset *>*/*)selectedAssets index:(NSUInteger)index;
/// This init method just for previewing photos,complete block call back  (The delegate didCancelHandle only valid)/ 用这个初始化方法以预览图片 complete => 完成后返回全新数组 （代理仅lf_imagePickerControllerDidCancel有效）
- (instancetype)initWithSelectedImageObjects:(NSArray <id<TFY_AssetImageProtocol>>*)selectedPhotos index:(NSUInteger)index complete:(void (^)(NSArray <id<TFY_AssetImageProtocol>>* photos))complete;
/// New custom media selector (Speed Dial) / 全新自定义图片选择器(带宫格) complete => 完成后返回全新数组 （代理仅lf_imagePickerControllerDidCancel有效）
- (instancetype)initWithSelectedPhotoObjects:(NSArray <id/* <TFY_AssetPhotoProtocol/TFY_AssetVideoProtocol> */>*)selectedPhotos complete:(void (^)(NSArray <id/* <TFY_AssetPhotoProtocol/TFY_AssetVideoProtocol> */>* photos))complete;


/// Preview mode or not
/// 是否预览模式
@property (nonatomic,readonly) BOOL isPreview;

#pragma mark - UI

/// 每行的数量 默认4（2～6）
@property (nonatomic,assign) NSUInteger columnNumber;

/// Default is 9 / 默认最大可选9张图片
@property (nonatomic,assign) NSUInteger maxImagesCount;

/// 最小照片必选张数,默认是0
@property (nonatomic,assign) NSUInteger minImagesCount;

/// 默认与maxImagesCount同值,如果不同值,不能混合选择图片与视频（类似微信朋友圈）
@property (nonatomic,assign) NSUInteger maxVideosCount;

/// 最小视频必选张数,默认与minImagesCount同值,只有maxVideosCount不等于maxImagesCount才有效
@property (nonatomic,assign) NSUInteger minVideosCount;

/// 是否选择原图
@property (nonatomic,assign) BOOL isSelectOriginalPhoto;

/// 没有选中的情况下,自动选中当前张,默认是YES
@property (nonatomic,assign) BOOL autoSelectCurrentImage;

/// 对照片排序,按创建时间升序,默认是YES。如果设置为NO,最新的照片会显示在最前面,内部的拍照按钮会排在第一个
@property (nonatomic,assign) BOOL sortAscendingByCreateDate;

/// 默认为TFYPickingMediaTypePhoto|LFPickingMediaTypeVideo.
@property (nonatomic,assign) TFYPickingMediaType allowPickingType;

/// 默认为YES,如果设置为NO,拍照按钮将隐藏
@property (nonatomic,assign) BOOL allowTakePicture;

/// 默认为YES,如果设置为NO,预览按钮将隐藏,用户将不能去预览照片
@property (nonatomic,assign) BOOL allowPreview;

/// 默认为YES,如果设置为NO,原图按钮将隐藏,用户不能选择发送原图
@property (nonatomic,assign) BOOL allowPickingOriginalPhoto;

/// 默认为YES,如果设置为NO,编辑按钮将隐藏,用户将不能去编辑照片
@property (nonatomic,assign) BOOL allowEditing;

/// 显示的相册名称,默认为相机胶卷
@property (nonatomic,copy,nullable) NSString *defaultAlbumName;

/// 默认为NO,如果设置为YES,显示图片文件名称
@property (nonatomic,assign) BOOL displayImageFilename;

#pragma mark - option

#pragma mark photo option
/// 压缩标清图的大小（没有勾选原图的情况有效）,默认为100 单位KB （只能压缩到接近该值的大小）,不建议修改它
@property (nonatomic,assign) float imageCompressSize;

/// 压缩缩略图的大小,默认为10 单位KB ,不建议修改它. 如果为0则不会生成缩略图
@property (nonatomic,assign) float thumbnailCompressSize;

/// 选择图片的最大大小,默认为6MB (6x1024*1024) 单位 B
@property (nonatomic,assign) NSUInteger maxPhotoBytes;

#pragma mark video option
/// 压缩视频大小的参数,只支持H.264。默认为AVAssetExportPreset1280x720(AVAssetExportSession.m)
@property (nonatomic,copy) NSString *videoCompressPresetName;

/// 选择视频的最大时长,默认为5分钟 (5x60) 单位 秒
@property (nonatomic,assign) NSTimeInterval maxVideoDuration;

#pragma mark other option
/// 默认为YES,如果设置为NO,选择视频不会读取缓存
@property (nonatomic,assign) BOOL autoVideoCache;

/// 默认为YES,如果设置为NO,编辑后的图片/视频不会保存到系统相册
@property (nonatomic,assign) BOOL autoSavePhotoAlbum;

/// 默认为YES,如果设置为NO,选择器将不会自己dismiss
@property (nonatomic,assign) BOOL autoDismiss;

/// 默认为NO,如果设置为YES,选择器将会适配横屏
@property (nonatomic,assign) BOOL supportAutorotate;

/// 默认为NO,如果设置为YES,同步系统相册 （相册发生变化时,界面会重置UI）
/// 默认为YES（相册发生变化时,界面会重置UI），如果设置为NO,不同步系统相册
@property (nonatomic,assign) BOOL syncAlbum NS_AVAILABLE_IOS(8_0);

/// 默认为YES，预览时自动播放live photo；否则需要长按照片才会播放。
@property (nonatomic,assign) BOOL autoPlayLivePhoto;

/// 设置默认选中的图片或视频,仅初始化时有效
@property (nonatomic,nullable,setter=setSelectedAssets:) NSArray /**<PHAsset/ALAsset/id<TFY_AssetImageProtocol>/id<TFY_AssetPhotoProtocol>> 任意一种 */*selectedAssets;

/// 用户选中的对象列表
@property (nonatomic,readonly) NSArray<TFY_PickerAsset *> *selectedObjects;

#pragma mark - delegate & block

//- (void)cancelButtonClick;
/** 代理/Delegate */
@property (nonatomic,weak,nullable) id<TFYImagePickerControllerDelegate> pickerDelegate;

/// block回调,具体使用见LFImagePickerControllerDelegate代理描述
@property (nonatomic,copy) void (^imagePickerControllerTakePhotoHandle)(picker_takePhotoHandler handler);
@property (nonatomic,copy) void (^imagePickerControllerDidCancelHandle)(void);

/**
 👍🎉1.2.6_取代所有旧接口,唯一回调,避免接口多样化
 */
@property (nonatomic,copy) void (^didFinishPickingResultHandle)(NSArray <TFY_ResultObject /* <TFY_ResultImage/TFY_ResultVideo> */*> *results);

@end

NS_ASSUME_NONNULL_END
