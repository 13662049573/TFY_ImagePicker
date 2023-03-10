//
//  TFY_FilterBar.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_FilterBar.h"
#import "TFY_FilterBarCell.h"

CGFloat const TFY_FilterBar_MAX_WIDTH = 100.f;

@interface TFY_FilterBar ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (assign, nonatomic) CGSize cellSize;
@property (nonatomic, strong) NSMutableArray <TFY_FilterModel *>*list;
@property (nonatomic, strong) TFY_FilterModel *selectModel;

@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) dispatch_queue_t serialQueue;

@end

@implementation TFY_FilterBar

- (instancetype)initWithFrame:(CGRect)frame defalutEffectType:(NSInteger)defalutEffectType dataSource:(NSArray<NSNumber *> *)dataSource
{
    self = [super initWithFrame:frame];
    if (self) {
        _serialQueue = dispatch_queue_create("com.TFY_FilterBar.SerialQueue", DISPATCH_QUEUE_SERIAL);
        _list = @[].mutableCopy;
        _defaultColor = [UIColor grayColor];
        _selectColor = [UIColor blueColor];
        _defalutEffectType = defalutEffectType;
        [self _createDataSource:dataSource];
        [self _createCustomView_picker];
    } return self;
}

#pragma mark - System Methods
- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11, *)) {
        CGRect rect = self.bounds;
        rect.size.height -= self.safeAreaInsets.bottom;
        _backgroundView.frame = rect;
    }
    _collectionView.frame = _backgroundView.bounds;
    _cellSize = CGSizeMake(TFY_FilterBar_MAX_WIDTH, CGRectGetHeight(_backgroundView.frame));
    [_collectionView.collectionViewLayout invalidateLayout];
    
    [self _scrollView_jrAnimated:NO];
}

#pragma mark - Private Methods

#pragma mark 创建collectionView
- (void)_createCustomView_picker {
    UIView *aView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:aView];
    _backgroundView = aView;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:_backgroundView.bounds collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = YES;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    if (@available(iOS 11.0, *)){
        [collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    [_backgroundView addSubview:collectionView];
    [collectionView registerClass:[TFY_FilterBarCell class] forCellWithReuseIdentifier: [TFY_FilterBarCell identifier]];
    _collectionView = collectionView;
}

#pragma mark 创建数据源
- (void)_createDataSource:(NSArray <NSNumber *>*)typeCollects {
    for (NSNumber *number in typeCollects) {
        TFY_FilterModel *obj = [TFY_FilterModel new];
        obj.effectType = [number integerValue];
        [self.list addObject:obj];
        if (_defalutEffectType == obj.effectType) {
            self.selectModel = obj;
        }
    }
    if (self.selectModel == nil) {
        self.selectModel = self.list.firstObject;
    }
}

#pragma mark 滚动
- (void)_scrollView_jrAnimated:(BOOL)animated {
    if (self.selectModel) {
        NSInteger index = [self.list indexOfObject:self.selectModel];
        NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView scrollToItemAtIndexPath:selectIndexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:animated];
    }
}

#pragma mark - UICollectionViewDataSource
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TFY_FilterModel *item = [_list objectAtIndex:indexPath.row];
    if (item == _selectModel) {
        return;
    }
    if (_selectModel) {
        NSInteger index = [_list indexOfObject:_selectModel];
        _selectModel = nil;
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView reloadItemsAtIndexPaths:@[oldIndexPath]];
    }
    _selectModel = item;
    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [self _scrollView_jrAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(picker_filterBar:didSelectImage:effectType:)]) {
        [self.delegate picker_filterBar:self didSelectImage:item.image effectType:item.effectType];
    }

}
#pragma mark - UICollectionViewDelegate
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TFY_FilterBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[TFY_FilterBarCell identifier] forIndexPath:indexPath];
    TFY_FilterModel *item = [_list objectAtIndex:indexPath.row];
    cell.defaultColor = self.defaultColor;
    cell.selectColor = self.selectColor;
    if (!item.image) {
        if ([self.dataSource respondsToSelector:@selector(picker_async_filterBarImageForEffectType:)]) {
            __weak typeof(self) weakSelf = self;
            __weak typeof(cell) weakCell = cell;
            __weak typeof(item) weakitem = item;
            dispatch_async(self.serialQueue, ^{
                UIImage *image = [weakSelf.dataSource picker_async_filterBarImageForEffectType:weakitem.effectType];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf) {
                        weakitem.image = image;
                        [weakCell setCellData:weakitem];
                    }
                });
            });
        }
    }
    if (!item.name) {
        if ([self.dataSource respondsToSelector:@selector(picker_filterBarNameForEffectType:)]) {
            item.name = [self.dataSource picker_filterBarNameForEffectType:item.effectType];
        }
    }
    cell.isSelectedModel = [item isEqual:_selectModel];
    [cell setCellData:item];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _list.count;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.f, 5.f, 0.f, 5.f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

@end
