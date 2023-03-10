//
//  TFY_EditCollectionView.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_EditCollectionView.h"

// get方法
#define pickerEditCollection_bind_var_getter(varType, varName, target) \
- (varType)varName \
{ \
    return target.varName; \
}

// set方法
#define pickerEditCollection_bind_var_setter(varType, varName, setterName, target) \
- (void)setterName:(varType)varName \
{ \
    [target setterName:varName]; \
}

#define pickerEditCollection_bind_var(varType, varName, setterName) \
pickerEditCollection_bind_var_getter(varType, varName, self.collectionView) \
pickerEditCollection_bind_var_setter(varType, varName, setterName, self.collectionView)

#define pickerEditCollectionFlowLayout_bind_var(varType, varName, setterName) \
pickerEditCollection_bind_var_getter(varType, varName, ((UICollectionViewFlowLayout *)self.collectionViewLayout)) \
pickerEditCollection_bind_var_setter(varType, varName, setterName, ((UICollectionViewFlowLayout *)self.collectionViewLayout))

@interface TFY_EditCollectionView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, copy) TFYEditCollectionViewDequeueReusableCellBlock dequeueReusableCellBlock;
@property (nonatomic, copy) TFYEditCollectionViewCellConfigureBlock cellConfigureBlock;
@property (nonatomic, copy) TFYEditCollectionViewDidSelectItemAtIndexPathBlock didSelectItemAtIndexPathBlock;

@end

@implementation TFY_EditCollectionView

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


- (void)customInit
{
    [self UI_init];
    
}

- (void)UI_init
{
    /* UI */
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.collectionViewLayout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    if (@available(iOS 11.0, *)){
        [collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}

- (void)callbackCellIdentifier:(TFYEditCollectionViewDequeueReusableCellBlock)aCellIdentifier
                 configureCell:(TFYEditCollectionViewCellConfigureBlock)aConfigureCell
      didSelectItemAtIndexPath:(TFYEditCollectionViewDidSelectItemAtIndexPathBlock)aDidSelectItemAtIndexPath
{
    self.dequeueReusableCellBlock = aCellIdentifier;
    self.cellConfigureBlock = aConfigureCell;
    self.didSelectItemAtIndexPathBlock = aDidSelectItemAtIndexPath;
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

#pragma mark - UICollectionViewDataSource
- (__kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSArray *subDataSources = self.dataSources[indexPath.section];
    id model = subDataSources[indexPath.row];
    
    NSString *TFYEditCollectionViewCellIdentifier = @"TFY_EditCollectionViewCell";
    if (self.dequeueReusableCellBlock) {
        TFYEditCollectionViewCellIdentifier = self.dequeueReusableCellBlock(indexPath);
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TFYEditCollectionViewCellIdentifier forIndexPath:indexPath];
    
    if (self.cellConfigureBlock) {
        self.cellConfigureBlock(indexPath, model, cell);
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *subDataSources = self.dataSources[section];
    return subDataSources.count;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSources.count;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *subDataSources = self.dataSources[indexPath.section];
    id model = subDataSources[indexPath.row];
    if (self.didSelectItemAtIndexPathBlock) {
        self.didSelectItemAtIndexPathBlock(indexPath, model);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging: withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging: willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [self.delegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        return [(id <TFYEditCollectionViewDelegateFlowLayout>)self.delegate collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    return [(UICollectionViewFlowLayout *)self.collectionViewLayout itemSize];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        return [(id <TFYEditCollectionViewDelegateFlowLayout>)self.delegate collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:section];
    }
    return [(UICollectionViewFlowLayout *)self.collectionViewLayout sectionInset];
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        return [(id <TFYEditCollectionViewDelegateFlowLayout>)self.delegate collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
    }
    return [(UICollectionViewFlowLayout *)self.collectionViewLayout minimumLineSpacing];
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        return [(id <TFYEditCollectionViewDelegateFlowLayout>)self.delegate collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:section];
    }
    return [(UICollectionViewFlowLayout *)self.collectionViewLayout minimumInteritemSpacing];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        return [(id <TFYEditCollectionViewDelegateFlowLayout>)self.delegate collectionView:collectionView layout:collectionViewLayout referenceSizeForHeaderInSection:section];
    }
    return [(UICollectionViewFlowLayout *)self.collectionViewLayout headerReferenceSize];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        return [(id <TFYEditCollectionViewDelegateFlowLayout>)self.delegate collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];
    }
    return [(UICollectionViewFlowLayout *)self.collectionViewLayout footerReferenceSize];
}

#pragma mark - UIScrollView setter/getter

pickerEditCollection_bind_var(BOOL, bounces, setBounces);
pickerEditCollection_bind_var(CGPoint, contentOffset, setContentOffset);
pickerEditCollection_bind_var(CGSize, contentSize, setContentSize);
pickerEditCollection_bind_var(UIEdgeInsets, contentInset, setContentInset);

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [self.collectionView setContentOffset:contentOffset animated:animated];
}
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    [self.collectionView scrollRectToVisible:rect animated:animated];
}

#pragma mark - UICollectionView setter/getter
pickerEditCollection_bind_var(BOOL, isPagingEnabled, setPagingEnabled);
pickerEditCollection_bind_var(BOOL, showsVerticalScrollIndicator, setShowsVerticalScrollIndicator);
pickerEditCollection_bind_var(BOOL, showsHorizontalScrollIndicator, setShowsHorizontalScrollIndicator);
pickerEditCollection_bind_var(BOOL, isPrefetchingEnabled, setPrefetchingEnabled);

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (nullable UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)performBatchUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^ _Nullable)(BOOL finished))completion
{
    [self.collectionView performBatchUpdates:updates completion:completion];
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (NSArray <UICollectionViewCell *>*)visibleCells
{
    return [self.collectionView visibleCells];
}

- (NSArray <NSIndexPath *>*)indexPathsForVisibleItems
{
    return [self.collectionView indexPathsForVisibleItems];
}

- (void)invalidateLayout
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (nullable NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point
{
    return [self.collectionView indexPathForItemAtPoint:point];
}

#pragma mark - UICollectionViewFlowLayout setter/getter
- (void)setCollectionViewLayout:(UICollectionViewLayout *)collectionViewLayout
{
    self.collectionView.collectionViewLayout = collectionViewLayout;
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        _collectionViewLayout = collectionViewLayout;
    } else {
        _collectionViewLayout = nil;
    }
}

pickerEditCollectionFlowLayout_bind_var(CGFloat, minimumLineSpacing, setMinimumLineSpacing)
pickerEditCollectionFlowLayout_bind_var(CGFloat, minimumInteritemSpacing, setMinimumInteritemSpacing)
pickerEditCollectionFlowLayout_bind_var(CGSize, itemSize, setItemSize)
pickerEditCollectionFlowLayout_bind_var(CGSize, estimatedItemSize, setEstimatedItemSize)
pickerEditCollectionFlowLayout_bind_var(UICollectionViewScrollDirection, scrollDirection, setScrollDirection)
pickerEditCollectionFlowLayout_bind_var(CGSize, headerReferenceSize, setHeaderReferenceSize)
pickerEditCollectionFlowLayout_bind_var(CGSize, footerReferenceSize, setFooterReferenceSize)
pickerEditCollectionFlowLayout_bind_var(UIEdgeInsets, sectionInset, setSectionInset)

@end
