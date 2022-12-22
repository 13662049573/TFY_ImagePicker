//
//  TFY_StickerDisplayView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_StickerDisplayView.h"
#import "TFY_PickerCollectionViewCell.h"
#import "TFY_TitleCollectionViewCell.h"
#import "TFY_StickerContent.h"
#import "TFY_ConfigTool.h"
#import "TFY_ImageCoder.h"
#import "TFY_TitleCollectionModel.h"

NSString * const picker_local_title_key = @"picker_local_title_key";
NSString * const picker_local_content_key = @"picker_local_content_key";

#define TFYStickerDisplayView_bind_var(varType, varName, setterName) \
TFYSticker_bind_var_getter(varType, varName, [TFY_ConfigTool shareInstance]) \
TFYSticker_bind_var_setter(varType, varName, setterName, [TFY_ConfigTool shareInstance])

/** 按钮在scrollView的间距 */
CGFloat const TFY_O_margin = 15.f;

@interface TFY_StickerDisplayView ()<TFYCollectionViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (readonly , nonatomic, nonnull) NSArray <TFY_TitleCollectionModel *>*titles;

@property (readonly , nonatomic, nonnull) NSArray <NSArray <TFY_StickerContent *>*>*contents;

@property (strong, nonatomic) TFY_TitleCollectionModel *selectTitleMoel;

@property (assign, nonatomic) BOOL stopAnimation;

@property (strong, nonatomic, nullable) NSIndexPath *selectIndexPath;

@property (weak, nonatomic) UICollectionView *collectionView;

@property (weak, nonatomic) UICollectionView *titleCollectionView;

@property (weak, nonatomic) UIView *lineView;

@end

@implementation TFY_StickerDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _stopAnimation = YES;
        self.backgroundColor = [UIColor blackColor];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _customLayoutSubviews];
}

- (void)dealloc
{
    [self.titleCollectionView removeFromSuperview];
    [self.collectionView removeFromSuperview];
    self.titleCollectionView = nil;
    self.collectionView = nil;
}
    
TFYStickerDisplayView_bind_var(UIColor *, selectTitleColor, setSelectTitleColor);
TFYStickerDisplayView_bind_var(UIColor *, normalTitleColor, setNormalTitleColor);
TFYStickerDisplayView_bind_var(CGSize, itemSize, setItemSize);
TFYStickerDisplayView_bind_var(CGFloat, itemMargin, setItemMargin);
TFYStickerDisplayView_bind_var(UIImage *, normalImage, setNormalImage);
TFYStickerDisplayView_bind_var(UIImage *, failureImage, setFailureImage);

#pragma mark - @Public Methods
- (void)setTitles:(NSArray *)titles contents:(NSArray<NSArray *> *)contents
{
    NSMutableArray *titleModels = [NSMutableArray arrayWithCapacity:titles.count];
    for (NSString *string in titles) {
        TFY_TitleCollectionModel *model = [[TFY_TitleCollectionModel alloc] initWithTitle:string];
        [titleModels addObject:model];
    }
    _titles = [titleModels copy];
    _selectTitleMoel = [_titles firstObject];
    NSMutableArray *r_contents = [NSMutableArray arrayWithCapacity:contents.count];
    for (NSArray *subContents in contents) {
        NSMutableArray *s_contents = [NSMutableArray arrayWithCapacity:subContents.count];
        for (id content in subContents) {
            [s_contents addObject:[TFY_StickerContent stickerContentWithContent:content]];
        }
        [r_contents addObject:[s_contents copy]];
    }
    _contents = [r_contents copy];
    if (_titles.count) {
        [self _initSubViews];
    }
}

- (void)setCacheData:(id)cacheData
{
    if ([cacheData isKindOfClass:[NSDictionary class]]) {
        NSArray *titles = @[];
        if ([[cacheData allKeys] containsObject:picker_local_title_key]) {
            titles = [cacheData objectForKey:picker_local_title_key];
        }
        
        NSMutableArray *titleModels = [NSMutableArray arrayWithCapacity:titles.count];
        for (NSDictionary *dic in titles) {
            [titleModels addObject:[[TFY_TitleCollectionModel alloc] initWithDictionary:dic]];
        }
        _titles = [titleModels copy];
        _selectTitleMoel = [_titles firstObject];

        NSArray *contents = @[];
        if ([[cacheData allKeys] containsObject:picker_local_content_key]) {
            contents = [cacheData objectForKey:picker_local_content_key];
        }
        
        
        NSMutableArray *r_contents = [NSMutableArray arrayWithCapacity:contents.count];

        for (NSArray *subContents in contents) {
            NSMutableArray *s_contents = [NSMutableArray arrayWithCapacity:subContents.count];
            for (NSDictionary *dic in subContents) {
                [s_contents addObject:[[TFY_StickerContent alloc] initWithDictionary:dic]];
            }
            [r_contents addObject:[s_contents copy]];
        }
        
        _contents = [r_contents copy];
        if (_titles.count) {
            [self _initSubViews];
        }

    }
}

- (id)cacheData
{
    NSArray *cacheContents = nil;
    if (!_contents ) {
        cacheContents = @[];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:_contents.count];
        for (NSArray *subContents in _contents) {
            NSMutableArray *subArray = [NSMutableArray arrayWithCapacity:subContents.count];
            for (TFY_StickerContent *obj in subContents) {
                [subArray addObject:obj.dictionary];
            }
            [array addObject:[subArray copy]];
        }
        cacheContents = [array copy];
    }
    
    NSArray *cacheTitles = nil;
    if (!_titles) {
        cacheTitles = @[];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:_titles.count];
        for (TFY_TitleCollectionModel *model in _titles) {
            [array addObject:model.dictionary];
        }
        cacheTitles = [array copy];
    }
    return @{picker_local_title_key:cacheTitles, picker_local_content_key:cacheContents};
}

#pragma mark - @Private Methods

#pragma mark 初始化视图
- (void)_initSubViews
{
    //title View
    {
        UICollectionViewFlowLayout *tFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        tFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        tFlowLayout.minimumInteritemSpacing = TFY_O_margin;
        tFlowLayout.sectionInset = UIEdgeInsetsMake(TFY_O_margin, TFY_O_margin, TFY_O_margin, TFY_O_margin);
        
        TFY_TitleCollectionModel *model = [self.titles firstObject];
        CGFloat height = model.size.height + TFY_O_margin*2;
        UICollectionView *titleView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.frame), height) collectionViewLayout:tFlowLayout];
        titleView.showsVerticalScrollIndicator = NO;
        titleView.showsHorizontalScrollIndicator = NO;
        titleView.backgroundColor = [UIColor clearColor];
        titleView.delegate = self;
        titleView.dataSource = self;
        [self addSubview:titleView];
        self.titleCollectionView = titleView;
        
        [self.titleCollectionView registerClass:[TFY_TitleCollectionViewCell class] forCellWithReuseIdentifier:[TFY_TitleCollectionViewCell identifier]];

    }
    
    {
        UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.titleCollectionView.bounds), .3f)];
        marginView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.8f];
        [self addSubview:marginView];
        self.lineView = marginView;
    }
    
    //九宫格
    {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.pagingEnabled = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 10.0, *)) {
            collectionView.prefetchingEnabled = NO;
        }
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        [self.collectionView registerClass:[TFY_PickerCollectionViewCell class] forCellWithReuseIdentifier:[TFY_PickerCollectionViewCell identifier]];
    }

}

#pragma mark 点击切换文字
- (void)_changeTitle:(TFY_TitleCollectionModel *)model
{
    if ([self.selectTitleMoel isEqual:model]) {
        return;
    }
    self.stopAnimation = YES;
    NSUInteger oldIndex = [self.titles indexOfObject:self.selectTitleMoel];
    NSUInteger selectIndex = [self.titles indexOfObject:model];
    self.selectTitleMoel = model;
    [self.titleCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndex inSection:0], [NSIndexPath indexPathForRow:selectIndex inSection:0]]];
}

#pragma mark 切换文字动画效果
- (void)_changeTitleAnimotionProgress:(CGFloat)progress
{
    NSUInteger _selectedIndex = [self.titles indexOfObject:self.selectTitleMoel];
    //获取下一个index
    NSInteger targetIndex = progress < 0 ? _selectedIndex - 1 : _selectedIndex + 1;
    if (targetIndex < 0 || targetIndex >= [self.titles count]) return;

    //获取cell
    TFY_TitleCollectionViewCell *currentCell = (TFY_TitleCollectionViewCell *)[self.titleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    TFY_TitleCollectionViewCell *targetCell = (TFY_TitleCollectionViewCell *)[self.titleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0]];
    
    [currentCell showAnimationOfProgress:progress select:NO];
    
    [targetCell showAnimationOfProgress:progress select:YES];

}

#pragma mark 适配横竖屏
- (void)_customLayoutSubviews
{
    self.stopAnimation = YES;
    
    NSInteger currentIndex = [self.titles indexOfObject:self.selectTitleMoel];

    CGRect topViewR = self.titleCollectionView.frame;

    topViewR.size.width = CGRectGetWidth(self.frame);
    self.titleCollectionView.frame = topViewR;
    [self.titleCollectionView.collectionViewLayout invalidateLayout];
    
    CGRect lineViewF = self.lineView.frame;
    lineViewF.origin.y = CGRectGetMaxY(self.titleCollectionView.frame);
    lineViewF.size.width = CGRectGetWidth(self.titleCollectionView.frame);
    self.lineView.frame = lineViewF;
    
    CGRect collectionViewR = self.collectionView.frame;
    if (CGRectEqualToRect(collectionViewR, CGRectZero)) {
        collectionViewR = CGRectMake(0.f, CGRectGetMaxY(lineViewF), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(lineViewF));
    }
    
    collectionViewR.size = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(lineViewF));
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = collectionViewR.size;
    self.collectionView.frame = collectionViewR;
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.contentSize = CGSizeMake(self.titles.count * (self.collectionView.frame.size.width), 0.f);
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    if (self.titles.count) {
        [self.collectionView setContentOffset:CGPointMake((self.collectionView.frame.size.width) * currentIndex, 0) animated:NO];
    }
}


#pragma mark - TFYCollectionViewDelegate
- (void)picker_didSelectData:(nullable NSData *)data thumbnailImage:(nullable UIImage *)thumbnailImage index:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[self.titles indexOfObject:self.selectTitleMoel]];
    _selectIndexPath = indexPath;
    if (self.didSelectBlock) {
        self.didSelectBlock(data, thumbnailImage);
    }
    _selectIndexPath = nil;
}

#pragma mark - @UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.collectionView]) {
        if (self.stopAnimation) {
            return;
        }
        NSInteger currentIndex = [self.titles indexOfObject:self.selectTitleMoel];
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
        CGFloat value = scrollView.contentOffset.x/scrollView.bounds.size.width - [self.titles indexOfObject:self.selectTitleMoel];
        [self _changeTitleAnimotionProgress:value];
        CGFloat index = scrollView.contentOffset.x/scrollView.bounds.size.width;
        if (isnan(index)) {
            index = 0.f;
        }
        self.selectTitleMoel = [self.titles objectAtIndex:index];
        UICollectionViewCell *cell = [self.titleCollectionView cellForItemAtIndexPath:currentIndexPath];
        CGRect convertF = [self.titleCollectionView convertRect:cell.frame toView:self];
        if (!CGRectContainsRect(convertF, self.titleCollectionView.frame)) {
            [self.titleCollectionView scrollToItemAtIndexPath:currentIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
}

//更新执行动画状态
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}

////更新执行动画状态
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}

//更新执行动画状态
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}

//更新执行动画状态
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([scrollView isEqual:self.collectionView]) {
        self.stopAnimation = false;
    }
}


#pragma mark - @UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *resultCell = nil;
    NSString *identifier = nil;
    if (self.collectionView == collectionView) {
        identifier = [TFY_PickerCollectionViewCell identifier];
        TFY_PickerCollectionViewCell *imageCell = (TFY_PickerCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        imageCell.delegate = self;
        imageCell.backgroundColor = [UIColor clearColor];
        if (self.contents.count > indexPath.row) {
            [imageCell setCellData:[self.contents objectAtIndex:indexPath.row]];
        } else {
            [imageCell setCellData:nil];
        }
        resultCell = imageCell;
    } else if (self.titleCollectionView == collectionView) {
        
        TFY_TitleCollectionModel *item = [self.titles objectAtIndex:indexPath.row];
        identifier = [TFY_TitleCollectionViewCell identifier];
        
        TFY_TitleCollectionViewCell *cell = (TFY_TitleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        [cell setCellData:item];
        cell.backgroundColor =  [UIColor clearColor];
        [cell showAnimationOfProgress:1.f select:NO];
        if ([self.selectTitleMoel isEqual:item]) {
            [cell showAnimationOfProgress:1.f select:YES];
        }
        
        resultCell = cell;
    }
    
    return resultCell;
}

#pragma mark - @UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.titleCollectionView) {
        TFY_TitleCollectionModel *item = [self.titles objectAtIndex:indexPath.row];
        [self _changeTitle:item];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout itemSize];
    if (collectionView == self.titleCollectionView) {
        TFY_TitleCollectionModel *item = [self.titles objectAtIndex:indexPath.row];
        size = item.size;
        size.width += 20.f;
        return size;
    }
    return size;
}

@end
