//
//  TFY_TitleCollectionViewCell.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_TitleCollectionViewCell.h"
#import "TFY_ConfigTool.h"
#import "UIColor+picker.h"
#import "TFY_TitleCollectionModel.h"


@interface TFY_TitleCollectionViewCell ()
@property (weak, nonatomic) UILabel *label;
@end

@implementation TFY_TitleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self _createCustomView];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.label.text = nil;
}


- (void)setCellData:(id)data
{
    [super setCellData:data];
    if ([data isKindOfClass:[TFY_TitleCollectionModel class]]) {
        TFY_TitleCollectionModel *model = (TFY_TitleCollectionModel *)data;
        self.label.text = model.title;
        self.label.font = model.font;
    }
}

- (void)showAnimationOfProgress:(CGFloat)progress select:(BOOL)select
{
    if (select) {
        self.label.textColor = [UIColor picker_colorTransformFrom:[TFY_ConfigTool shareInstance].normalTitleColor to:[TFY_ConfigTool shareInstance].selectTitleColor progress:progress];
    } else {
        self.label.textColor = [UIColor picker_colorTransformFrom:[TFY_ConfigTool shareInstance].selectTitleColor to:[TFY_ConfigTool shareInstance].normalTitleColor progress:progress];
    }
}

#pragma mark - Private Methods
- (void)_createCustomView
{
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:lable];
    self.label = lable;
    self.label.numberOfLines = 1.f;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];
}


@end
