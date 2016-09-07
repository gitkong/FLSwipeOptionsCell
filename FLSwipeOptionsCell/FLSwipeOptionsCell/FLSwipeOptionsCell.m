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
    
    CGFloat contentOffsetX;
    
    CGFloat oldContentOffsetX;
    
    CGFloat newContentOffsetX;
    
    BOOL isFullButtonsShowing;
    
    
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
    scrollViewContentView.backgroundColor = [UIColor lightGrayColor];
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

//开始拖拽视图

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    [self backToZero:self.lastScrollView];
    contentOffsetX = scrollView.contentOffset.x;
    
    if (isFullButtonsShowing) {
        [self backToZero:scrollView];
    }
    
}



// 滚动时调用此方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    newContentOffsetX = scrollView.contentOffset.x;
    NSLog(@"offsetX = %.2lf",scrollView.contentOffset.x);
    if (scrollView.contentOffset.x < 0) {
        scrollView.scrollEnabled = NO;
        newContentOffsetX = 0.0f;
    }
    else {
        scrollView.scrollEnabled = YES;
    }
    
    if (newContentOffsetX > oldContentOffsetX && oldContentOffsetX > contentOffsetX) {  // 向左滚动
        
        NSLog(@"left");
        
    } else if (newContentOffsetX < oldContentOffsetX && oldContentOffsetX < contentOffsetX) { // 向右滚动
        NSLog(@"right");
        
    } else {
        
        if ((scrollView.contentOffset.x - contentOffsetX) > 0.0f) {  // 向左拖拽
            
            NSLog(@"left-------");
            if (scrollView.contentOffset.x >= scrollViewButtonsViewWidth / 2) {
//                [self showFullButtons];
            }
        } else if ((contentOffsetX - scrollView.contentOffset.x) > 0.0f) {   // 向右拖拽
            
            NSLog(@"right-------");
            if (scrollView.contentOffset.x <= scrollViewButtonsViewWidth / 2) {
                [self backToZero:scrollView];
            }
        }
        
    }
    
    
}


// 完成拖拽(滚动停止时调用此方法，手指离开屏幕)

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // NSLog(@"scrollViewDidEndDragging");
    
    oldContentOffsetX = scrollView.contentOffset.x;
    if (scrollView.contentOffset.x <= 0) {
        oldContentOffsetX = 0.0f;
    }
    // 手指离开后也需要判断,防止快速拖动过去，超过了按钮部分的就不作处理，不然会卡卡的
    if (scrollView.contentOffset.x >= scrollViewButtonsViewWidth / 2 && scrollView.contentOffset.x < scrollViewButtonsViewWidth) {
        [self showFullButtons];
    }
    else if ((contentOffsetX - scrollView.contentOffset.x) > 0.0f){
//        [self backToZero:scrollView];
    }
    
    self.lastScrollView = scrollView;
}

- (void)showFullButtons{
//    CGPoint offset = self.scrollView.contentOffset;
//    
//    offset.x = scrollViewButtonsViewWidth;
//    self.scrollView.contentOffset = offset;
    [self animationLeftScrollTo:scrollViewButtonsViewWidth];
    // 标记是否正在显示
    isFullButtonsShowing = YES;
}

- (void)animationLeftScrollTo:(CGFloat)end{
    // 进来先判断是否回到起点，如果是，不执行下面的，因为下面的会设置偏移，因而造成无限循环（0 和 1）
    if (self.scrollView.contentOffset.x <= 0 || self.scrollView.contentOffset.x == end) {
        return;
    }
    [UIView animateWithDuration:0.001 / end animations:^{
        
        CGPoint offset = self.scrollView.contentOffset;
        
        offset.x += 1;
        
        
        if (self.scrollView.contentOffset.x >= end) {
            offset.x = end;
            self.scrollView.contentOffset = offset;
            return ;
        }
        
        self.scrollView.contentOffset = offset;
    } completion:^(BOOL finished) {
        [self animationLeftScrollTo:end];
    }];
}

- (void)backToZero:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    offset.x = 0.0f;
    scrollView.contentOffset = offset;
    // 标记是否显示
    isFullButtonsShowing = NO;
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
