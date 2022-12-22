//
//  TFY_PickerPreviewBar.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PickerPreviewBar.h"
#import "TFY_PreviewBarCell.h"
#import "TFYCategory.h"
#import "TFY_PickerAsset.h"

@interface TFY_PickerPreviewBar ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray <TFY_PickerAsset *>*myDataSource;
/**最初选中cell的NSIndexPath*/
@property (nonatomic, strong) NSIndexPath *sourceIndexPath;
/**之前选中cell的NSIndexPath*/
@property (nonatomic, strong) NSIndexPath *destinationIndexPath;
/**单元格的截图*/
@property (nonatomic, weak) UIView *snapshotView;
@end

@implementation TFY_PickerPreviewBar

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
    _selectedDataSource = [NSMutableArray array];
    _borderWidth = 2.f;
    _borderColor = [UIColor blackColor];
    
    CGFloat margin = 15.f;
    CGFloat itemH = CGRectGetHeight(self.bounds) - margin * 2;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(itemH, itemH);
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = 0;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[TFY_PreviewBarCell class] forCellWithReuseIdentifier:[TFY_PreviewBarCell identifier]];
    
    // 添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
    [collectionView addGestureRecognizer:longPress];
}

#pragma mark - 长按手势
- (void)handlelongGesture:(UILongPressGestureRecognizer *)longPress
{
    [self action:longPress];
}

- (void)setDataSource:(NSArray<TFY_PickerAsset *> *)dataSource
{
    if (dataSource) {
        self.myDataSource = [NSMutableArray arrayWithArray:dataSource];
    } else {
        self.myDataSource = [NSMutableArray arrayWithCapacity:0];
    }
}

- (NSArray<TFY_PickerAsset *> *)dataSource{
    return [self.myDataSource copy];
}

/** 添加数据源 */
- (void)addAssetInDataSource:(TFY_PickerAsset *)asset
{
    if (asset) {
        __weak typeof(self) weakSelf = self;
        [self.collectionView performBatchUpdates:^{
            [weakSelf.myDataSource addObject:asset];
            [weakSelf.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.myDataSource.count-1 inSection:0]]];
            
        } completion:nil];
    }
}
/** 删除数据源 */
- (void)removeAssetInDataSource:(TFY_PickerAsset *)asset
{
    if (asset) {
        __weak typeof(self) weakSelf = self;
        [self.collectionView performBatchUpdates:^{
            NSInteger index = [weakSelf.myDataSource indexOfObject:asset];
            [weakSelf.myDataSource removeObject:asset];
            if (index != NSNotFound) {
                [weakSelf.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            }
            
        } completion:nil];
    }
}

- (void)setSelectAsset:(TFY_PickerAsset *)selectAsset
{
    if (_selectAsset != selectAsset) {
        TFY_PickerAsset *oldAsset = _selectAsset;
        /** 刷新+滚动 */
        _selectAsset = selectAsset;
        if (oldAsset) {
            NSInteger index = [self.myDataSource indexOfObject:oldAsset];
            if (index != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
        
        if (selectAsset) {
            NSInteger index = [self.myDataSource indexOfObject:selectAsset];
            if (index != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
        }
    } else {
        if (selectAsset) {
            NSInteger index = [self.myDataSource indexOfObject:selectAsset];
            if (index != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
        }
    }
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.myDataSource.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [TFY_PreviewBarCell identifier];
    TFY_PreviewBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    TFY_PickerAsset *asset = self.myDataSource[indexPath.row];
    
    cell.asset = asset;
    cell.isSelectedAsset = [self.selectedDataSource containsObject:asset];
    
    [self selectCell:cell asset:asset];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 返回YES允许row移动
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //取出移动row数据
    TFY_PickerAsset *asset = self.myDataSource[sourceIndexPath.row];
    //从数据源中移除该数据
    [self.myDataSource removeObject:asset];
    //将数据插入到数据源中的目标位置
    [self.myDataSource insertObject:asset atIndex:destinationIndexPath.row];
    if (self.didMoveItem) {
        self.didMoveItem(asset, sourceIndexPath.row, destinationIndexPath.row);
    }
}

#pragma mark -  UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    TFY_PickerAsset *asset = self.myDataSource[indexPath.row];
    if (self.didSelectItem) {
        self.didSelectItem(asset);
    }
    self.selectAsset = asset;
}

#pragma mark - iOS9 之后的方法
- (void)iOS9_Action:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        { //手势开始
            //判断手势落点位置是否在row上
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
            if (indexPath == nil) {
                break;
            }
            
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            [self bringSubviewToFront:cell];
            //iOS9方法 移动cell
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            [self starShake:self.snapshotView = cell];
        }
            break;
        case UIGestureRecognizerStateChanged:
        { // 手势改变
            // iOS9方法 移动过程中随时更新cell位置
            [self.collectionView updateInteractiveMovementTargetPosition:[longPress locationInView:self.collectionView]];
        }
            break;
        case UIGestureRecognizerStateEnded:
        { // 手势结束
            // iOS9方法 移动结束后关闭cell移动
            [self stopShake:self.snapshotView];
            self.snapshotView = nil;
            [self.collectionView endInteractiveMovement];
        }
            break;
        default: //手势其他状态
        {
            [self stopShake:self.snapshotView];
            self.snapshotView = nil;
            [self.collectionView cancelInteractiveMovement];
        }
            break;
    }
}

#pragma mark - iOS9 之前的方法
- (void)action:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        { // 手势开始
            //判断手势落点位置是否在row上
            CGPoint collectionPoint = [longPress locationInView:self.collectionView];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:collectionPoint];
            self.sourceIndexPath = indexPath;
            self.destinationIndexPath = indexPath;
            if (indexPath == nil) {
                break;
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            // 使用系统的截图功能,得到cell的截图视图
            UIView *snapshotView = [cell snapshotViewAfterScreenUpdates:NO];
            snapshotView.frame = [self.collectionView convertRect:cell.frame toView:self];
            [self addSubview:snapshotView];
            self.snapshotView = snapshotView;
            // 截图后隐藏当前cell
            cell.hidden = YES;
            [self starShake:snapshotView];
            __weak typeof(self) weakSelf = self;
            [self.collectionView setAutoScrollChanged:^(CGPoint position) {
                [weakSelf updateCellMovementTargetPosition:position];
            }];
            
            CGPoint currentPoint = [longPress locationInView:self];
            [UIView animateWithDuration:0.25 animations:^{
                snapshotView.transform = CGAffineTransformMakeScale(1.05, 1.05);
                snapshotView.center = currentPoint;
            } completion:^(BOOL finished) {
                [self.collectionView autoScrollForView:snapshotView];
            }];
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        { // 手势改变
            //当前手指位置 截图视图位置随着手指移动而移动
            CGPoint currentPoint = [longPress locationInView:self];
            self.snapshotView.center = currentPoint;
            [self.collectionView autoScrollForView:self.snapshotView];
            // 计算截图视图和哪个cell相交
            CGPoint collectionPoint = [longPress locationInView:self.collectionView];
            [self updateCellMovementTargetPosition:collectionPoint];
        }
            break;
        default:
        { // 手势结束和其他状态
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.destinationIndexPath];
            CGRect cellRect = [self.collectionView convertRect:cell.frame toView:self];
            // 结束动画过程中停止交互,防止出问题
            self.collectionView.userInteractionEnabled = NO;
            [self stopShake:self.snapshotView];
            [self.collectionView autoScrollForView:nil];
            // 给截图视图一个动画移动到隐藏cell的新位置
            [UIView animateWithDuration:0.25 animations:^{
                self.snapshotView.center = CGPointMake(CGRectGetMidX(cellRect), CGRectGetMidY(cellRect));
                self.snapshotView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                // 移除截图视图,显示隐藏的cell并开始交互
                [self.snapshotView removeFromSuperview];
                cell.hidden = NO;
                self.collectionView.userInteractionEnabled = YES;
                if (self.sourceIndexPath != self.destinationIndexPath) {
                    if (self.didMoveItem) {
                        // 已经在changed时改变了数据源，取destinationIndexPath的对象
                        self.didMoveItem(self.myDataSource[self.destinationIndexPath.row], self.sourceIndexPath.row, self.destinationIndexPath.row);
                    }
                }
                self.sourceIndexPath = nil;
                self.destinationIndexPath = nil;
            }];
        }
            break;
    }
}

- (void)updateCellMovementTargetPosition:(CGPoint)collectionPoint
{
    // 计算截图视图和哪个cell相交
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:collectionPoint];
    if (indexPath && indexPath != self.destinationIndexPath) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        CGRect cellRect = [self.collectionView convertRect:cell.frame toView:self];
        // 计算中心距
        CGFloat space = sqrtf(pow(self.snapshotView.center.x - CGRectGetMidX(cellRect), 2) + powf(self.snapshotView.center.y - CGRectGetMidY(cellRect), 2));
        // 如果相交一半就移动
        if (space <= self.snapshotView.bounds.size.width / 2) {
            NSIndexPath *oldIndexPath = self.destinationIndexPath;
            //更新数据源
            [self.myDataSource exchangeObjectAtIndex:oldIndexPath.row withObjectAtIndex:indexPath.row];
            //移动
            [self.collectionView moveItemAtIndexPath:oldIndexPath toIndexPath:indexPath];
            //设置移动后的起始indexPath
            self.destinationIndexPath = indexPath;
        }
    }
}



#pragma mark - private
- (void)selectCell:(UICollectionViewCell *)cell asset:(TFY_PickerAsset *)asset
{
    if (asset == self.selectAsset) {
        cell.layer.borderColor = self.borderColor.CGColor;
        cell.layer.borderWidth = self.borderWidth;
    } else {
        cell.layer.borderWidth = 0.f;
    }
}

- (void)starShake:(UIView *)view{
    
    CAKeyframeAnimation * keyAnimaion = [CAKeyframeAnimation animation];
    keyAnimaion.keyPath = @"transform.rotation";
    keyAnimaion.values = @[@(-3 / 180.0 * M_PI),@(3 /180.0 * M_PI),@(-3/ 180.0 * M_PI)];//度数转弧度
    keyAnimaion.removedOnCompletion = NO;
    keyAnimaion.fillMode = kCAFillModeForwards;
    keyAnimaion.duration = 0.25;
    keyAnimaion.repeatCount = MAXFLOAT;
    [view.layer addAnimation:keyAnimaion forKey:@"cellShake"];
}
- (void)stopShake:(UIView *)view{
    [view.layer removeAnimationForKey:@"cellShake"];
}


@end
