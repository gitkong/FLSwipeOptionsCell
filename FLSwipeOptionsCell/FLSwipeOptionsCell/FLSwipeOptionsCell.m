//
//  FLSwipeOptionsCell.m
//  FLSwipeOptionsCell
//
//  Created by clarence on 16/9/6.
//  Copyright © 2016年 clarence. All rights reserved.
//

#import "FLSwipeOptionsCell.h"

@implementation FLTableViewRowAction

+ (instancetype)fl_rowActionWithStyle:(UITableViewRowActionStyle)style title:(nullable NSString *)title handler:(void (^)(FLTableViewRowAction *action, NSIndexPath *indexPath))handler{
    FLTableViewRowAction *action = [[self alloc] init];
    action.title = title;
    return action;
}

+ (instancetype)fl_deleteActionWithTitle:(nullable NSString *)title Handle:(void (^)(FLTableViewRowAction *action, NSIndexPath *indexPath))handler{
    FLTableViewRowAction *action = [[self alloc] init];
    action.title = title;
    return action;
}

@end

@interface FLSwipeOptionsCell ()<UIScrollViewDelegate>
// base scrollView
@property (nonatomic,weak)UIScrollView *scrollView;
// last scrollView
@property (nonatomic,weak)UIScrollView *lastScrollView;

// init content view on scrollView
@property (nonatomic,weak)UIView *scrollViewContentView;
// init buttons view on scrollView
@property (nonatomic,weak)UIView *scrollViewButtonsView;
@property (nonatomic,strong)NSMutableArray *buttonArrM;
@property (nonatomic,strong)NSMutableArray *buttonWidthArrM;
// action arr
@property (nonatomic,strong)NSArray *actionArr;
@end

@implementation FLSwipeOptionsCell{
    CGFloat scrollViewButtonsViewWidth;
    CGFloat scrollViewStopedOffsetX;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self prepareUI];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // init buttons View
    UIView *scrollViewButtonsView = [[UIView alloc] init];
    scrollViewButtonsView.backgroundColor = [UIColor orangeColor];
    self.scrollViewButtonsView = scrollViewButtonsView;
    [self.contentView addSubview:scrollViewButtonsView];
    
    // init scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView = scrollView;
    [self.contentView addSubview:scrollView];
    
    // init scrollView content view
    UIView *scrollViewContentView = [[UIView alloc] init];
    scrollViewContentView.backgroundColor = [UIColor redColor];
    self.scrollViewContentView = scrollViewContentView;
    [self.scrollView addSubview:scrollViewContentView];
    
    // init button on buttonsView
    if ([self.delegate respondsToSelector:@selector(fl_createRowAction:)]) {
        self.actionArr = [self.delegate fl_createRowAction:self];
    }
    else{
        
        self.actionArr = [NSArray arrayWithObject:[FLTableViewRowAction fl_deleteActionWithTitle:@"删除" Handle:nil]];
    }
    for (NSInteger index = 0; index < self.actionArr.count; index ++) {
        UIButton *button = [[UIButton alloc] init];
        [self.scrollViewButtonsView addSubview:button];
        [self.buttonArrM addObject:button];
        
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    // count button full width
//    CGFloat scrollViewButtonsViewWidth = 0.0f;
    for (FLTableViewRowAction *action in self.actionArr) {
        scrollViewButtonsViewWidth += [action.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 attributes:nil context:nil].size.width;
    }
    for (NSInteger index = 0; index < self.actionArr.count; index ++) {
        FLTableViewRowAction *action = self.actionArr[index];
        CGFloat buttonWidth = [action.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 attributes:nil context:nil].size.width;
        scrollViewButtonsViewWidth += buttonWidth;
        
        [self.buttonWidthArrM addObject:@(buttonWidth)];
        
    }
    
    for (NSInteger index = 0; index < self.buttonWidthArrM.count; index ++) {
        NSNumber *numWidth = self.buttonWidthArrM[index];
        if (index < self.buttonWidthArrM.count - 1) {
            NSNumber *nextNumWidth = self.buttonWidthArrM[index + 1];
        }
        
//        UIButton *button = self.buttonArrM[index];
//        button.frame = CGRectMake(buttonWidth, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    }
    
    self.scrollViewButtonsView.frame = CGRectMake(CGRectGetWidth(self.bounds) - scrollViewButtonsViewWidth, 0, scrollViewButtonsViewWidth, CGRectGetHeight(self.bounds));
    
    self.scrollViewContentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    // scrollView contentSize
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + scrollViewButtonsViewWidth, CGRectGetHeight(self.bounds));
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"offset.x = %.2lf",scrollView.contentOffset.x);
    if (scrollView.contentOffset.x < 0) {
        scrollView.scrollEnabled = NO;
    }
    else {
        scrollView.scrollEnabled = YES;
        if (scrollViewStopedOffsetX > scrollView.contentOffset.x) {
            [self backToZero];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // 正常速度拖动的时候，这个就会自动记录最后的x为0，防止快速拖动防止记录没有reset，然后上个方法scrollViewStopedOffsetX > scrollView.contentOffset.x一直成立，造成没办法显示按钮，此时在backToZero手动reset可解决
    scrollViewStopedOffsetX = scrollView.contentOffset.x;
}

- (void)backToZero{
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = 0.0f;
    self.scrollView.contentOffset = offset;
    // reset
    scrollViewStopedOffsetX = 0.0f;
}

#pragma mark -- Setter & Getter

- (NSMutableArray *)buttonArrM{
    if (_buttonArrM == nil) {
        _buttonArrM = [NSMutableArray array];
    }
    return _buttonArrM;
}

- (NSMutableArray *)buttonWidthArrM{
    if (_buttonWidthArrM == nil) {
        _buttonWidthArrM = [NSMutableArray array];
    }
    return _buttonWidthArrM;
}


@end
