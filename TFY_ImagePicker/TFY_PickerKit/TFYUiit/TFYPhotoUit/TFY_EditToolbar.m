//
//  TFY_EditToolbar.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_EditToolbar.h"
#import "TFYCategory.h"
#import "TFY_PickColorView.h"
#import "TFYDropMenu.h"
#import "TFYDrawView.h"
#import "TFYItools.h"

#define TFYEditToolbarButtonImageNormals @[@"EditImagePenToolBtn.png", @"EditImageEmotionToolBtn.png", @"EditImageTextToolBtn.png", @"EditImageMosaicToolBtn.png", @"EditImageCropToolBtn.png", @"EditImageAudioToolBtn.png", @"EditVideoCropToolBtn.png", @"EditImageFilterToolBtn.png", @"EditImageRateToolBtn.png"]
#define TFYEditToolbarButtonImageHighlighted @[@"EditImagePenToolBtn_HL.png", @"EditImageEmotionToolBtn_HL.png", @"EditImageTextToolBtn_HL.png", @"EditImageMosaicToolBtn_HL.png", @"EditImageCropToolBtn_HL.png", @"EditImageAudioToolBtn_HL.png", @"EditVideoCropToolBtn_HL.png", @"EditImageFilterToolBtn_HL.png", @"EditImageRateToolBtn_HL.png"]



#define TFYEditToolbarBrushTitles @[@"_LFME_brush_Paint", @"_LFME_brush_Highlight", @"_LFME_brush_Chalk", @"_LFME_brush_Fluorescent", @"_LFME_brush_Stamp", @"_LFME_brush_Eraser"]

#define TFYEditToolbarBrushImageNormals @[@"EditImagePenTool_Paint.png", @"EditImagePenTool_Highlight.png", @"EditImagePenTool_Chalk.png", @"EditImagePenTool_Fluorescent.png", @"EditImagePenTool_Stamp.png", @"EditImagePenTool_Eraser.png"]
#define TFYEditToolbarBrushImageHighlighted @[@"EditImagePenTool_Paint_HL.png", @"EditImagePenTool_Highlight_HL.png", @"EditImagePenTool_Chalk_HL.png", @"EditImagePenTool_Fluorescent_HL.png", @"EditImagePenTool_Stamp_HL.png", @"EditImagePenTool_Eraser_HL.png"]

#define TFYEditToolbarStampBrushImageNormals @[@"EditImageStampBrushAnimal.png", @"EditImageStampBrushFruit.png", @"EditImageStampBrushHeart.png"]

inline static TFY_StampBrush *TFYStampBrushAnimal(void)
{
    TFY_StampBrush *brush = [TFY_StampBrush new];
    brush.patterns = @[@"brush/animal/1@2x.png", @"brush/animal/2@2x.png", @"brush/animal/3@2x.png", @"brush/animal/4@2x.png", @"brush/animal/5@2x.png"];
    brush.scale = 10.0;
    return brush;
}

inline static TFY_StampBrush *TFYStampBrushFruit(void)
{
    TFY_StampBrush *brush = [TFY_StampBrush new];
    brush.patterns = @[@"brush/fruit/1@2x.png", @"brush/fruit/2@2x.png", @"brush/fruit/3@2x.png", @"brush/fruit/4@2x.png", @"brush/fruit/5@2x.png", @"brush/fruit/6@2x.png"];
    brush.scale = 8.0;
    return brush;
}

inline static TFY_StampBrush *TFYStampBrushHeart(void)
{
    TFY_StampBrush *brush = [TFY_StampBrush new];
    brush.patterns = @[@"brush/heart/1@2x.png", @"brush/heart/2@2x.png", @"brush/heart/3@2x.png", @"brush/heart/4@2x.png", @"brush/heart/5@2x.png"];
    brush.scale = 4.0;
    return brush;
}

CGFloat kToolbar_MainHeight = 44;
CGFloat kToolbar_SubHeight = 55;
NSUInteger kToolbar_MaxItems = 6;

#define kToolbar_RateTips(r) [NSString stringWithFormat:@"x %.1f", r]
#define kToolbar_SelectedColor [UIColor colorWithRed:(26/255.0) green:(173/255.0) blue:(25/255.0) alpha:1.0]
#define kToolbar_NormalsColor [UIColor whiteColor]

#pragma mark - TFY_ToolCollectionItem
@interface TFY_ToolCollectionItem : NSObject

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) int index;
@property(nonatomic,getter=isSelected) BOOL selected;

@end

@implementation TFY_ToolCollectionItem

@end

#pragma mark - TFY_ToolCollectionViewCell
@class TFY_ToolCollectionViewCell;

@protocol TFYToolCollectionViewCellDelegate <NSObject>

- (void)picker_edit_toolBar_buttonClick:(TFY_ToolCollectionViewCell *)cell;

@end

@interface TFY_ToolCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TFY_ToolCollectionItem *item;
@property (nonatomic, weak) UIButton *picker_button;
@property (nonatomic, weak) id<TFYToolCollectionViewCellDelegate> delegate;

+ (NSString *)identifier;
@end

@implementation TFY_ToolCollectionViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.contentView.frame.size.height;
    self.picker_button.frame = CGRectMake(0, 0, width, height);
}

- (void)customInit
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(picker_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    self.picker_button = button;
}

+ (NSString *)identifier
{
    return NSStringFromClass([self class]);
}

- (void)setItem:(TFY_ToolCollectionItem *)item
{
    _item = item;
    self.picker_button.tag = item.tag;
    self.picker_button.selected = item.isSelected;
}

- (void)picker_buttonClick:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(picker_edit_toolBar_buttonClick:)]) {
        [self.delegate picker_edit_toolBar_buttonClick:self];
    }
    self.item.selected = button.isSelected;
}

@end

@interface TFY_EditToolbar ()<TFYPickColorViewDelegate, TFYToolCollectionViewCellDelegate, TFYEditCollectionViewDelegate>

/** 一级菜单 */
@property (nonatomic, weak) UIView *edit_menu;
@property (nonatomic, weak) TFY_EditCollectionView *edit_scrollMenu;

/** 二级菜单 */
@property (nonatomic, weak) UIView *edit_drawMenu;
@property (nonatomic, weak) UIButton *edit_drawMenu_revoke;
/** 笔刷类型 */
@property (nonatomic, weak) UIButton *edit_drawMenu_brush;
/** 绘画拾色器 */
@property (nonatomic, weak) TFY_PickColorView *draw_colorSlider;
/** 图章类型 */
@property (nonatomic, weak) UIView *draw_stampView;
@property (nonatomic, assign) TFYEditToolbarBrushType edit_drawMenu_brushType;
@property (nonatomic, assign) TFYEditToolbarStampBrushType edit_drawMenu_stampBrushType;

@property (nonatomic, weak) UIView *edit_splashMenu;
@property (nonatomic, weak) UIButton *edit_splashMenu_revoke;
/** 进度条 */
@property (nonatomic, weak) UIView *edit_rateMenu;
@property (nonatomic, weak) UISlider *edit_rateMenu_slider;
@property (nonatomic, weak) UIButton *edit_rateMenu_tipsButton;

/** 当前激活绘画菜单按钮 */
@property (nonatomic, weak) UIButton *edit_drawMenu_action_button;
/** 当前激活模糊菜单按钮 */
@property (nonatomic, weak) UIButton *edit_splashMenu_action_button;

/** 当前显示菜单 */
@property (nonatomic, weak) UIView *selectMenu;
/** 当前点击按钮 */
@property (nonatomic, weak) UIButton *selectButton;


@property (nonatomic, assign) TFYEditToolbarType type;
@property (nonatomic, strong) NSArray *mainImageNormals;
@property (nonatomic, strong) NSArray *mainImageHighlighted;

@end

@implementation TFY_EditToolbar

- (instancetype)initWithType:(TFYEditToolbarType)type
{
    self = [self init];
    if (self) {
        _type = type;
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    CGFloat height = kToolbar_MainHeight+kToolbar_SubHeight;
    self = [super initWithFrame:(CGRect){{0, [UIScreen mainScreen].bounds.size.height-height}, {[UIScreen mainScreen].bounds.size.width, height}}];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = kToolbar_MainHeight+kToolbar_SubHeight;
    
    if (@available(iOS 11.0, *)) {
        height += self.safeAreaInsets.bottom;
    }
    
    self.frame = (CGRect){{0, self.superview.frame.size.height-height}, {self.superview.frame.size.width, height}};
    self.edit_menu.frame = CGRectMake(0, kToolbar_SubHeight, self.picker_width, height-kToolbar_SubHeight);
}

- (void)customInit
{
    _mainImageNormals = TFYEditToolbarButtonImageNormals;
    _mainImageHighlighted = TFYEditToolbarButtonImageHighlighted;
    [self mainBar];
    [self subBar];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    }
    return view;
}

#pragma mark - 菜单创建
- (void)mainBar
{
    CGFloat height = kToolbar_MainHeight;
    if (@available(iOS 11.0, *)) {
        height += self.safeAreaInsets.bottom;
    }
    UIView *edit_menu = [[UIView alloc] initWithFrame:CGRectMake(0, kToolbar_SubHeight, self.picker_width, height)];
    edit_menu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    CGFloat rgb = 34 / 255.0;
    edit_menu.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.85];
    
    NSInteger buttonCount = 0;
    NSMutableArray <NSNumber *>*_imageIndexs = [@[] mutableCopy];
    NSMutableArray <NSNumber *>*_selectIndexs = [@[] mutableCopy];
    
    if (self.type&TFYEditToolbarType_draw) {
        [_imageIndexs addObject:@0];
        [_selectIndexs addObject:@(TFYEditToolbarType_draw)];
        buttonCount ++;
    }
    if (self.type&TFYEditToolbarType_sticker) {
        [_imageIndexs addObject:@1];
        [_selectIndexs addObject:@(TFYEditToolbarType_sticker)];
        buttonCount ++;
    }
    if (self.type&TFYEditToolbarType_text) {
        [_imageIndexs addObject:@2];
        [_selectIndexs addObject:@(TFYEditToolbarType_text)];
        buttonCount ++;
    }
    if (self.type&TFYEditToolbarType_splash) {
        [_imageIndexs addObject:@3];
        [_selectIndexs addObject:@(TFYEditToolbarType_splash)];
        buttonCount ++;
    }
    if (self.type&TFYEditToolbarType_filter) {
        [_imageIndexs addObject:@7];
        [_selectIndexs addObject:@(TFYEditToolbarType_filter)];
        buttonCount ++;
    }
    if (self.type&TFYEditToolbarType_crop) {
        [_imageIndexs addObject:@4];
        [_selectIndexs addObject:@(TFYEditToolbarType_crop)];
        buttonCount ++;
    }
    if (self.type&TFYEditToolbarType_audio) {
        [_imageIndexs addObject:@5];
        [_selectIndexs addObject:@(TFYEditToolbarType_audio)];
        buttonCount ++;
    }
    if (self.type&TFYEditToolbarType_rate) {
        [_imageIndexs addObject:@8];
        [_selectIndexs addObject:@(TFYEditToolbarType_rate)];
        buttonCount ++;
    }
    if (self.type&TFYEditToolbarType_clip) {
        [_imageIndexs addObject:@6];
        [_selectIndexs addObject:@(TFYEditToolbarType_clip)];
        buttonCount ++;
    }
    _items = buttonCount;
    
    
    if (buttonCount > 0) {
        
        NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:buttonCount];
        
        for (NSInteger i=0; i<buttonCount; i++) {
            TFY_ToolCollectionItem *item = [TFY_ToolCollectionItem new];
            item.tag = [_selectIndexs[i] integerValue];
            item.index = [_imageIndexs[i] intValue];
            [dataSource addObject:item];
        }
        
        CGFloat width = CGRectGetWidth(self.frame)/(MIN(buttonCount, kToolbar_MaxItems));
  
        TFY_EditCollectionView *edit_scrollMenu = [[TFY_EditCollectionView alloc] initWithFrame:edit_menu.bounds];
        edit_scrollMenu.bounces = NO;
        edit_scrollMenu.showsVerticalScrollIndicator = NO;
        edit_scrollMenu.showsHorizontalScrollIndicator = NO;
        edit_scrollMenu.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        [edit_scrollMenu setBackgroundColor:[UIColor clearColor]];
        edit_scrollMenu.itemSize = CGSizeMake(width, kToolbar_MainHeight);
        edit_scrollMenu.sectionInset = UIEdgeInsetsZero;
        edit_scrollMenu.minimumInteritemSpacing = 0;
        edit_scrollMenu.minimumLineSpacing = 0;
        
        [edit_scrollMenu registerClass:[TFY_ToolCollectionViewCell class] forCellWithReuseIdentifier:[TFY_ToolCollectionViewCell identifier]];
        
        edit_scrollMenu.dataSources = @[dataSource];
        edit_scrollMenu.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        [edit_scrollMenu callbackCellIdentifier:^NSString * _Nonnull(NSIndexPath * _Nonnull indexPath) {
            return [TFY_ToolCollectionViewCell identifier];
        } configureCell:^(NSIndexPath * _Nonnull indexPath, TFY_ToolCollectionItem * _Nonnull item, UICollectionViewCell * _Nonnull cell) {
            
            ((TFY_ToolCollectionViewCell *)cell).item = item;
            ((TFY_ToolCollectionViewCell *)cell).delegate = self;
            int index = item.index;
            [((TFY_ToolCollectionViewCell *)cell).picker_button setImage:bundleEditImageNamed(weakSelf.mainImageNormals[index]) forState:UIControlStateNormal];
            [((TFY_ToolCollectionViewCell *)cell).picker_button setImage:bundleEditImageNamed(weakSelf.mainImageHighlighted[index]) forState:UIControlStateHighlighted];
            [((TFY_ToolCollectionViewCell *)cell).picker_button setImage:bundleEditImageNamed(weakSelf.mainImageHighlighted[index]) forState:UIControlStateSelected];
//            [((TFY_ToolCollectionViewCell *)cell).picker_button addTarget:weakSelf action:@selector(edit_toolBar_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
        } didSelectItemAtIndexPath:^(NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
            
        }];
        
        [edit_menu addSubview:edit_scrollMenu];
        self.edit_scrollMenu = edit_scrollMenu;
        
    }
    
    UIView *divide = [[UIView alloc] init];
    CGFloat rgb2 = 40 / 255.0;
    divide.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
    divide.frame = CGRectMake(0, 0, self.picker_width, 1);
    divide.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    [edit_menu addSubview:divide];
    self.edit_menu = edit_menu;
    
    [self addSubview:edit_menu];
}

- (void)subBar
{
    [self edit_drawMenu];
    [self edit_splashMenu];
    [self edit_rateMenu];
}

#pragma mark - 二级菜单栏(懒加载)
- (UIView *)edit_drawMenu
{
    if (_edit_drawMenu == nil && self.type&TFYEditToolbarType_draw) {
        UIView *edit_drawMenu = [[UIView alloc] initWithFrame:CGRectMake(_edit_menu.picker_x, _edit_menu.picker_y, _edit_menu.picker_width, kToolbar_SubHeight)];
        edit_drawMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        edit_drawMenu.backgroundColor = _edit_menu.backgroundColor;
        edit_drawMenu.alpha = 0.f;
        /** 添加按钮获取点击 */
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = edit_drawMenu.bounds;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [edit_drawMenu addSubview:button];
        
        UIButton *edit_drawMenu_revoke = [self revokeButtonWithType:TFYEditToolbarType_draw];
        [edit_drawMenu addSubview:edit_drawMenu_revoke];
        self.edit_drawMenu_revoke = edit_drawMenu_revoke;
        
        /** 分隔线 */
        UIView *separateView = [self separateView];
        separateView.frame = CGRectMake(CGRectGetMinX(edit_drawMenu_revoke.frame)-2-5, (CGRectGetHeight(edit_drawMenu.frame)-25)/2, 2, 25);
        separateView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [edit_drawMenu addSubview:separateView];
        
        CGFloat leftX = 0;
        NSArray *brushImages = TFYEditToolbarBrushImageNormals;
        /** 画笔选择 */
        UIButton *brush = [UIButton buttonWithType:UIButtonTypeCustom];
        brush.frame = CGRectMake(5, 0, 44, kToolbar_SubHeight);
        brush.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [brush setImage:bundleEditImageNamed(brushImages[self.edit_drawMenu_brushType]) forState:UIControlStateNormal];
        [brush addTarget:self action:@selector(brush_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [edit_drawMenu addSubview:brush];
        _edit_drawMenu_brush = brush;
        leftX = CGRectGetMaxX(brush.frame);
        
        /** 颜色显示 */
        CGFloat margin = isiPad ? 85.f : 25.f;
        
        /** 拾色器 */
        CGFloat surplusWidth = CGRectGetMinX(separateView.frame)-2*margin-leftX;
        CGFloat sliderHeight = 34.f, sliderWidth = MIN(surplusWidth, 350);
        TFY_PickColorView *_colorSlider = [[TFY_PickColorView alloc] initWithFrame:CGRectMake(leftX + margin + (surplusWidth - sliderWidth) / 2, (CGRectGetHeight(edit_drawMenu.frame)-sliderHeight)/2, sliderWidth, sliderHeight) colors:kSliderColors];
        _colorSlider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _colorSlider.delegate = self;
        [_colorSlider setMagnifierMaskImage:bundleEditImageNamed(@"EditImageWaterDrop.png")];
        [edit_drawMenu addSubview:_colorSlider];
        self.draw_colorSlider = _colorSlider;
        
        /** 图章类型 */
        UIView *draw_stampView = [[UIView alloc] initWithFrame:_colorSlider.frame];
        NSInteger stampCount = 3;
        CGFloat averageWidth = CGRectGetWidth(draw_stampView.frame)/(stampCount+1);
        NSArray *stampBrushImages = TFYEditToolbarStampBrushImageNormals;
        for (NSInteger i=0; i<stampCount; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(averageWidth*(i+1)-33/2, (CGRectGetHeight(draw_stampView.frame)-30)/2, 33, 33);
            button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [button setImage:bundleBrushImageNamed(stampBrushImages[i]) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(drawMenu_stampButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i+1;
            if (i == self.edit_drawMenu_stampBrushType) {
                button.selected = YES;
                _edit_drawMenu_action_button = button;
                button.layer.borderColor = kToolbar_SelectedColor.CGColor;
            } else {
                button.layer.borderColor = kToolbar_NormalsColor.CGColor;
            }
            button.layer.borderWidth = 2.0;
            [draw_stampView addSubview:button];
        }
        
        draw_stampView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        draw_stampView.hidden = YES;
        [edit_drawMenu addSubview:draw_stampView];
        self.draw_stampView = draw_stampView;
        
        _edit_drawMenu = edit_drawMenu;
        
        [self insertSubview:edit_drawMenu belowSubview:_edit_menu];
        
    }
    return _edit_drawMenu;
}

- (UIView *)edit_splashMenu
{
    if (_edit_splashMenu == nil && self.type&TFYEditToolbarType_splash) {
        UIView *edit_splashMenu = [[UIView alloc] initWithFrame:CGRectMake(_edit_menu.picker_x, _edit_menu.picker_y, _edit_menu.picker_width, kToolbar_SubHeight)];
        edit_splashMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        edit_splashMenu.backgroundColor = _edit_menu.backgroundColor;
        edit_splashMenu.alpha = 0.f;
        /** 添加按钮获取点击 */
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = edit_splashMenu.bounds;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [edit_splashMenu addSubview:button];
        
        UIButton *edit_splashMenu_revoke = [self revokeButtonWithType:TFYEditToolbarType_splash];
        [edit_splashMenu addSubview:edit_splashMenu_revoke];
        self.edit_splashMenu_revoke = edit_splashMenu_revoke;
        
        /** 分隔线 */
        UIView *separateView = [self separateView];
        separateView.frame = CGRectMake(CGRectGetMinX(edit_splashMenu_revoke.frame)-2-5, (CGRectGetHeight(edit_splashMenu.frame)-25)/2, 2, 25);
        separateView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [edit_splashMenu addSubview:separateView];
        
        /** 剩余长度 */
        CGFloat width = CGRectGetMinX(edit_splashMenu_revoke.frame);
        /** 按钮个数 */
        int count = 3;
        /** 平分空间 */
        CGFloat averageWidth = width/(count+1);
        
        NSArray *icons = @[@"EditImageTraditionalMosaicBtn.png", @"EditImageBrushBlurryBtn.png", @"EditImageBrushMosaicBtn.png"];
        NSArray *icons_HL = @[@"EditImageTraditionalMosaicBtn_HL.png", @"EditImageBrushBlurryBtn_HL.png", @"EditImageBrushMosaicBtn_HL.png"];
        
        for (NSInteger i=0; i<count; i++) {
            UIButton *action = [UIButton buttonWithType:UIButtonTypeCustom];
            action.frame = CGRectMake(averageWidth*(i+1)-44/2, (CGRectGetHeight(edit_splashMenu.frame)-30)/2, 44, 30);
            action.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [action addTarget:self action:@selector(splashMenu_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [action setImage:bundleEditImageNamed(icons[i]) forState:UIControlStateNormal];
            [action setImage:bundleEditImageNamed(icons_HL[i]) forState:UIControlStateHighlighted];
            [action setImage:bundleEditImageNamed(icons_HL[i]) forState:UIControlStateSelected];
            action.tag = i+1;
            [edit_splashMenu addSubview:action];
            
            if (i == 0) {
                /** 优先激活首个按钮 */
                _edit_splashMenu_action_button = action;
                action.selected = YES;
            }
        }
        
        _edit_splashMenu = edit_splashMenu;
        [self insertSubview:edit_splashMenu belowSubview:_edit_menu];
    }
    return _edit_splashMenu;
}

- (UIButton *)revokeButtonWithType:(NSInteger)type
{
    UIButton *revoke = [UIButton buttonWithType:UIButtonTypeCustom];
    revoke.frame = CGRectMake(_edit_menu.picker_width-44-5, 0, 44, kToolbar_SubHeight);
    revoke.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [revoke setImage:bundleEditImageNamed(@"EditImageRevokeBtn.png") forState:UIControlStateNormal];
    [revoke setImage:bundleEditImageNamed(@"EditImageRevokeBtn_HL.png") forState:UIControlStateHighlighted];
    [revoke setImage:bundleEditImageNamed(@"EditImageRevokeBtn_HL.png") forState:UIControlStateSelected];
    revoke.tag = type;
    [revoke addTarget:self action:@selector(revoke_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return revoke;
}

- (UIImageView *)separateView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bundleEditImageNamed(@"AlbumCommentLine.png")];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

- (UIView *)edit_rateMenu
{
    if (_edit_rateMenu == nil && self.type&TFYEditToolbarType_rate) {
        UIView *edit_rateMenu = [[UIView alloc] initWithFrame:CGRectMake(_edit_menu.picker_x, _edit_menu.picker_y, _edit_menu.picker_width, kToolbar_SubHeight)];
        edit_rateMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        edit_rateMenu.backgroundColor = _edit_menu.backgroundColor;
        edit_rateMenu.alpha = 0.f;
        /** 添加按钮获取点击 */
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = edit_rateMenu.bounds;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [edit_rateMenu addSubview:button];
        
        /** 间距 */
        CGFloat margin = isiPad ? 85.f : 25.f;
        
        /** 提示label */
        CGFloat labelWidth = 40.f;
        UIButton *tipsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tipsButton.frame = CGRectMake(margin, 0, labelWidth, edit_rateMenu.frame.size.height);
        [tipsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [tipsButton setTitle:kToolbar_RateTips(1.0) forState:UIControlStateNormal];
        [tipsButton addTarget:self action:@selector(sliderTipsOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [edit_rateMenu addSubview:tipsButton];
        _edit_rateMenu_tipsButton = tipsButton;
        
        /** slider */
        CGFloat sliderWidth = CGRectGetWidth(edit_rateMenu.frame)-CGRectGetMaxX(tipsButton.frame)-2*margin;
        CGFloat sliderHeight = 34.f;
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tipsButton.frame)+margin, (edit_rateMenu.frame.size.height-sliderHeight)/2, sliderWidth, sliderHeight)];
        slider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [slider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchUpOutside];
//        slider.continuous = NO;
        slider.maximumValue = TFYMediaEditMaxRate;
        slider.minimumValue = TFYMediaEditMinRate;
        slider.value = 1.0;
        [edit_rateMenu addSubview:slider];
        _edit_rateMenu_slider = slider;
        
        _edit_rateMenu = edit_rateMenu;
        
        [self insertSubview:edit_rateMenu belowSubview:_edit_menu];
    }
    return _edit_rateMenu;
}

- (void)sliderTipsOnClick:(UIButton *)button
{
    [_edit_rateMenu_tipsButton setTitle:kToolbar_RateTips(1.0) forState:UIControlStateNormal];
    _edit_rateMenu_slider.value = 1.0;
    if ([self.delegate respondsToSelector:@selector(picker_editToolbar:rateDidChange:)]) {
        [self.delegate picker_editToolbar:self rateDidChange:_edit_rateMenu_slider.value];
    }
}

- (void)sliderDidChange:(UISlider *)slider
{
    [_edit_rateMenu_tipsButton setTitle:kToolbar_RateTips(slider.value) forState:UIControlStateNormal];
}

- (void)sliderDidChangeEnd:(UISlider *)slider
{
    float value = [[NSString stringWithFormat:@"%.1f", slider.value] floatValue];
    if ([self.delegate respondsToSelector:@selector(picker_editToolbar:rateDidChange:)]) {
        [self.delegate picker_editToolbar:self rateDidChange:value];
    }
    slider.value = value;
}

#pragma mark - 一级菜单事件(action)
- (void)edit_toolBar_buttonClick:(UIButton *)button
{
    switch (button.tag) {
        case TFYEditToolbarType_draw:
        {
            [self showMenuView:self.edit_drawMenu];
            if (button.isSelected == NO) {
                if ([self.delegate respondsToSelector:@selector(picker_editToolbar:canRevokeAtIndex:)]) {
                    BOOL canRevoke = [self.delegate picker_editToolbar:self canRevokeAtIndex:button.tag];
                    _edit_drawMenu_revoke.enabled = canRevoke;
                }
            }
            [self changedButton:button];
        }
            break;
        case TFYEditToolbarType_splash:
        {
            [self showMenuView:self.edit_splashMenu];
            if (button.isSelected == NO) {
                if ([self.delegate respondsToSelector:@selector(picker_editToolbar:canRevokeAtIndex:)]) {
                    BOOL canRevoke = [self.delegate picker_editToolbar:self canRevokeAtIndex:button.tag];
                    _edit_splashMenu_revoke.enabled = canRevoke;
                }
            }
            [self changedButton:button];
        }
            break;
        case TFYEditToolbarType_rate:
        {
            [self showMenuView:self.edit_rateMenu];
            [self changedButton:button];
        }
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(picker_editToolbar:mainDidSelectAtIndex:)]) {
        [self.delegate picker_editToolbar:self mainDidSelectAtIndex:button.tag];
    }
}

#pragma mark - 二级菜单撤销（action）
- (void)revoke_buttonClick:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(picker_editToolbar:subDidRevokeAtIndex:)]) {
        [self.delegate picker_editToolbar:self subDidRevokeAtIndex:button.tag];
    }
    if ([self.delegate respondsToSelector:@selector(picker_editToolbar:canRevokeAtIndex:)]) {
        BOOL canRevoke = [self.delegate picker_editToolbar:self canRevokeAtIndex:button.tag];
        button.enabled = canRevoke;
    }
}

- (void)brush_buttonClick:(UIButton *)button
{
    NSArray *titles = TFYEditToolbarBrushTitles;
    NSArray *normals = TFYEditToolbarBrushImageNormals;
    NSArray *highlighted = TFYEditToolbarBrushImageHighlighted;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:4];
    __weak typeof(self) weakSelf = self;
    for (NSInteger i=0; i<titles.count; i++) {
        NSString *title = titles[i];
        if ([title isEqualToString:@"_LFME_brush_Eraser"]) {
            continue;
        }
        TFY_DropItem *item = [[TFY_DropItem alloc] init];
        item.title = [NSBundle picker_localizedStringForKey:title];
        [item setImage:bundleEditImageNamed(normals[i]) forState:TFYDropItemStateNormal];
        [item setImage:bundleEditImageNamed(highlighted[i]) forState:TFYDropItemStateSelected];
        [item setTitleColor:kToolbar_NormalsColor forState:TFYDropItemStateNormal];
        [item setTitleColor:kToolbar_SelectedColor forState:TFYDropItemStateSelected];
        if (i == self.edit_drawMenu_brushType) {
            item.selected = YES;
        }
        item.tapHandler = ^(TFY_DropItem * _Nonnull item) {
            weakSelf.edit_drawMenu_brushType = i;
        };
        [items addObject:item];
    }
    [TFY_DropMenu setDirection:TFYDropMainMenuDirectionTop];
    [TFY_DropMenu showInView:button items:items];
}

- (void)drawMenu_stampButtonClick:(UIButton *)button
{
    if (_edit_drawMenu_action_button != button) {
        _edit_drawMenu_action_button.selected = NO;
        _edit_drawMenu_action_button.layer.borderColor = kToolbar_NormalsColor.CGColor;
        button.selected = YES;
        button.layer.borderColor = kToolbar_SelectedColor.CGColor;
        _edit_drawMenu_action_button = button;
        self.edit_drawMenu_stampBrushType = (TFYEditToolbarStampBrushType)(button.tag-1);
        /** 触发代理 */
        self.edit_drawMenu_brushType = self.edit_drawMenu_brushType;
    }
}

- (void)splashMenu_buttonClick:(UIButton *)button
{
    if (_edit_splashMenu_action_button != button) {
        _edit_splashMenu_action_button.selected = NO;
        button.selected = YES;
        _edit_splashMenu_action_button = button;
        if ([self.delegate respondsToSelector:@selector(picker_editToolbar:subDidSelectAtIndex:)]) {
            [self.delegate picker_editToolbar:self subDidSelectAtIndex:[NSIndexPath indexPathForRow:button.tag-1 inSection:TFYEditToolbarType_splash]];
        }
    }
}

#pragma mark - 显示二级菜单栏
- (void)showMenuView:(UIView *)menu
{
    /** 将显示的菜单先关闭 */
    if (_selectMenu) {
        [self hidenMenuView];
    }
    if (_selectMenu != menu) {
        /** 显示新菜单 */
        _selectMenu = menu;
        [UIView animateWithDuration:0.25f animations:^{
            menu.picker_y = 0;
            menu.alpha = 1.f;
        }];
    } else {
        _selectMenu = nil;
    }
}
- (void)hidenMenuView
{
    [self sendSubviewToBack:_selectMenu];
    [UIView animateWithDuration:0.25f animations:^{
        self->_selectMenu.picker_y = self->_edit_menu.picker_y;
        self->_selectMenu.alpha = 0.f;
    }];
}

#pragma mark - 按钮激活切换
- (BOOL)changedButton:(UIButton *)button
{
    /** 选中按钮 */
    button.selected = !button.selected;
    if (_selectButton != button) {
        _selectButton.selected = !_selectButton.selected;
        _selectButton = button;
    } else {
        _selectButton = nil;
    }
    return (_selectButton != nil);
}

/** 当前激活主菜单 */
- (NSUInteger)mainSelectAtIndex
{
    return _selectButton ? _selectButton.tag : -1;
}

/** 允许撤销 */
- (void)setRevokeAtIndex:(NSUInteger)index
{
    switch (index) {
        case TFYEditToolbarType_draw:
        {
            _edit_drawMenu_revoke.enabled = YES;
        }
            break;
        case TFYEditToolbarType_splash:
        {
            _edit_splashMenu_revoke.enabled = YES;
        }
            break;
        default:
            break;
    }
}

/** 设置绘画拾色器默认颜色 */
- (void)setDrawSliderColorAtIndex:(NSUInteger)index
{
    self.draw_colorSlider.index = index;
    if ([self.delegate respondsToSelector:@selector(picker_editToolbar:drawColorDidChange:)]) {
        [self.delegate picker_editToolbar:self drawColorDidChange:self.draw_colorSlider.color];
    }
}

/** 设置绘画拾色器默认笔刷（会触发代理） */
- (void)setDrawBrushAtIndex:(TFYEditToolbarBrushType)index subIndex:(TFYEditToolbarStampBrushType)subIndex
{
    NSArray *normals = TFYEditToolbarBrushImageNormals;
    if (normals.count > index) {
        _edit_drawMenu_brushType = index;
        if (_edit_drawMenu_stampBrushType != subIndex) {
            /** 模拟点击按钮触发代理 */
            UIButton *button = [self.draw_stampView viewWithTag:(subIndex+1)];
            if (button) {
                _edit_drawMenu_stampBrushType = subIndex;
                [self drawMenu_stampButtonClick:button];
                return;
            }
        }
        /** 触发代理 */
        self.edit_drawMenu_brushType = self.edit_drawMenu_brushType;
    }
}

- (float)rate
{
    return self.edit_rateMenu_slider.value;
}

- (void)setRate:(float)rate
{
    self.edit_rateMenu_slider.value = rate;
    [_edit_rateMenu_tipsButton setTitle:kToolbar_RateTips(rate) forState:UIControlStateNormal];
}

- (void)setEdit_drawMenu_brushType:(TFYEditToolbarBrushType)edit_drawMenu_brushType
{
    _edit_drawMenu_brushType = edit_drawMenu_brushType;
    
    // changed view
    BOOL isStamp = (edit_drawMenu_brushType == TFYEditToolbarBrushTypeStamp);
    self.draw_colorSlider.hidden = isStamp;
    self.draw_stampView.hidden = !isStamp;
    
    TFY_Brush *brush = nil;
    switch (_edit_drawMenu_brushType) {
        case TFYEditToolbarBrushTypePaint:
            brush = [TFY_PaintBrush new];
            break;
        case TFYEditToolbarBrushTypeHighlight:
            brush = [TFY_HighlightBrush new];
            break;
        case TFYEditToolbarBrushTypeChalk:
            brush = [[TFY_ChalkBrush alloc] initWithImageName:@"brush/EditImageChalkBrush@2x.png"];
            break;
        case TFYEditToolbarBrushTypeFluorescent:
            brush = [TFY_FluorescentBrush new];
            break;
        case TFYEditToolbarBrushTypeStamp:
        {
            switch (self.edit_drawMenu_stampBrushType) {
                case TFYEditToolbarStampBrushTypeAnimal:
                    brush = TFYStampBrushAnimal();
                    break;
                case TFYEditToolbarStampBrushTypeFruit:
                    brush = TFYStampBrushFruit();
                    break;
                case TFYEditToolbarStampBrushTypeHeart:
                    brush = TFYStampBrushHeart();
                    break;
            }
        }
            break;
        case TFYEditToolbarBrushTypeEraser:
            brush = [TFY_EraserBrush new];
            break;
        default:
            break;
    }
    
    if (brush == nil) {
        /** 超出定制范围，默认使用画笔 */
        self.edit_drawMenu_brushType = TFYEditToolbarBrushTypePaint;
        return;
    }
    brush.bundle = [NSBundle picker_mediaEditingBundle];
    
    [self.edit_drawMenu_brush setImage:bundleEditImageNamed(TFYEditToolbarBrushImageNormals[self.edit_drawMenu_brushType]) forState:UIControlStateNormal];
    
    // callback
    if ([self.delegate respondsToSelector:@selector(picker_editToolbar:drawBrushDidChange:)]) {
        [self.delegate picker_editToolbar:self drawBrushDidChange:brush];
    }
}

#pragma mark - TFYPickColorViewDelegate
- (void)picker_PickColorView:(TFY_PickColorView *)pickColorView didSelectColor:(UIColor *)color
{
    if ([self.delegate respondsToSelector:@selector(picker_editToolbar:drawColorDidChange:)]) {
        [self.delegate picker_editToolbar:self drawColorDidChange:color];
    }
}

#pragma mark - TFYToolCollectionViewCellDelegate
- (void)picker_edit_toolBar_buttonClick:(TFY_ToolCollectionViewCell *)cell
{
    [self edit_toolBar_buttonClick:cell.picker_button];
}

#pragma mark - TFY_EditCollectionViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self scrollViewDidEndDecelerating:scrollView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.edit_scrollMenu == (TFY_EditCollectionView *)scrollView.superview) {
        CGFloat contentOffsetX = scrollView.contentOffset.x;
        CGFloat multiple = roundf(contentOffsetX/self.edit_scrollMenu.itemSize.width);
        CGFloat newContentOffsetX = multiple*self.edit_scrollMenu.itemSize.width;
        [scrollView setContentOffset:CGPointMake(newContentOffsetX, 0) animated:YES];
    }
}

#pragma mark - public对外
- (void)selectMainMenuIndex:(NSUInteger)index
{
    __block NSInteger tag = -1;
    [self.edit_scrollMenu.dataSources.firstObject enumerateObjectsUsingBlock:^(TFY_ToolCollectionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == index) {
            tag = idx;
            *stop = YES;
        }
    }];
    if (tag == -1) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    [self.edit_scrollMenu scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    TFY_ToolCollectionViewCell *cell = (TFY_ToolCollectionViewCell *)[self.edit_scrollMenu cellForItemAtIndexPath:indexPath];
    if (cell == nil) {
        // 滚动后没有立即刷新。导致获取不到cell。手动刷新。
        [self.edit_scrollMenu layoutIfNeeded];
        cell = (TFY_ToolCollectionViewCell *)[self.edit_scrollMenu cellForItemAtIndexPath:indexPath];
    }
    if ([cell isKindOfClass:[TFY_ToolCollectionViewCell class]]) {
        [self edit_toolBar_buttonClick:cell.picker_button];
    }
}

/** 设置默认模糊类型 */
- (void)setSplashIndex:(NSUInteger)index
{
    UIView *view = [self.edit_splashMenu viewWithTag:index+1];
    if ([view isKindOfClass:[UIButton class]]) {
        [self splashMenu_buttonClick:(UIButton *)view];
    }
}

/** 设置画笔等待状态 */
- (void)setDrawBrushWait:(BOOL)isWait
{
    self.edit_drawMenu_brush.enabled = !isWait;
}

/** 设置模糊等待状态 */
- (void)setSplashWait:(BOOL)isWait index:(NSUInteger)index
{
    UIView *view = [self.edit_splashMenu viewWithTag:index+1];
    if ([view isKindOfClass:[UIButton class]]) {
        NSInteger tag = 100 + view.tag;
        if (isWait) {
            if ([view.superview viewWithTag:tag]) {
                return;
            }
            UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            aiView.frame = view.frame;
            aiView.tag = tag;
            [aiView startAnimating];
            [view.superview addSubview:aiView];
            view.hidden = YES;
        } else {
            [[view.superview viewWithTag:tag] removeFromSuperview];
            view.hidden = NO;
        }
    }
}

@end
