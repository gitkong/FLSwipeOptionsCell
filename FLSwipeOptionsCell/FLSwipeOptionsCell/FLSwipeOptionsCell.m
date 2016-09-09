/*
 * author 孔凡列
 *
 * gitHub https://github.com/gitkong
 * cocoaChina http://code.cocoachina.com/user/
 * 简书 http://www.jianshu.com/users/fe5700cfb223/latest_articles
 * QQ 279761135
 * 喜欢就给个like 和 star 喔~
 */

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
        button.backgroundColor = [UIColor blackColor];
        FLTableViewRowAction *action = self.actionArr[index];
        [button setTitle:action.title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.scrollViewButtonsView addSubview:button];
        [self.scrollViewButtonsView bringSubviewToFront:button];
        [self.buttonArrM addObject:button];
        
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    // count button full width
    for (FLTableViewRowAction *action in self.actionArr) {
        scrollViewButtonsViewWidth += [action.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 attributes:nil context:nil].size.width;
    }
    for (NSInteger index = 0; index < self.actionArr.count; index ++) {
        FLTableViewRowAction *action = self.actionArr[index];
        CGFloat buttonWidth = [action.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 attributes:nil context:nil].size.width;
        scrollViewButtonsViewWidth += buttonWidth;
        
        [self.buttonWidthArrM addObject:@(buttonWidth)];
        
    }
    
    
    self.scrollViewButtonsView.frame = CGRectMake(CGRectGetWidth(self.bounds) - scrollViewButtonsViewWidth, 0, scrollViewButtonsViewWidth, CGRectGetHeight(self.bounds));
    
    self.scrollViewContentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    // scrollView contentSize
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + scrollViewButtonsViewWidth, CGRectGetHeight(self.bounds));
    
    // 从右开始
    for (NSInteger index = 0; index < self.buttonWidthArrM.count; index ++) {
        NSNumber *numWidth = self.buttonWidthArrM[index];
        CGFloat btnWidth = [numWidth floatValue];
        // 拿一个宽度移除一个
        [self.buttonWidthArrM removeObjectAtIndex:index];
        // 算出其余的宽度总和
        CGFloat widthSum = [[self.buttonWidthArrM valueForKeyPath:@"@sum.floatValue"] floatValue];
        UIButton *button = self.buttonArrM[index];
        button.frame = CGRectMake(CGRectGetWidth(self.bounds) - scrollViewButtonsViewWidth + widthSum, 0, btnWidth, CGRectGetHeight(self.bounds));
        NSLog(@"self.width = %.2lf",CGRectGetWidth(self.bounds));
        NSLog(@"btn.frame = %@",NSStringFromCGRect(button.frame));
    }
    
    
    
}

//开始拖拽视图

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // 重置contentOffsetX
    contentOffsetX = scrollView.contentOffset.x;
    // 此时如果显示全部按钮的话，那么一拖拽就回到原点
    if (isFullButtonsShowing) {
        NSLog(@"offsetX = %.2lf",scrollView.contentOffset.x);
        [self backToZero:scrollView];
    }
    
}



// 滚动时调用此方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    newContentOffsetX = scrollView.contentOffset.x;
    // 偏移量大于0才能滚动
    if (scrollView.contentOffset.x < 0) {
        scrollView.scrollEnabled = NO;
        newContentOffsetX = 0.0f;
    }
    else {
        scrollView.scrollEnabled = YES;
    }
    // 向左滚动（手放开了）
    if (newContentOffsetX > oldContentOffsetX && oldContentOffsetX > contentOffsetX) {
        NSLog(@"left");
    }
    // 向右滚动(手放开了)
    else if (newContentOffsetX < oldContentOffsetX && oldContentOffsetX < contentOffsetX) {
        NSLog(@"right%zd",isFullButtonsShowing);
        // 此时如果是不显示全部按钮，那么就肯定调用了backToZero 方法，因为只有在这个方法内部设置isFullButtonsShowing 为 NO，此时设置scrollView 不能滚动，避免拖拽时候影响scrollView自动滚回起点，注意一定要在backToZero方法最后设置scrollView可滚动，相当于reset一下
        if (!isFullButtonsShowing) {
            scrollView.scrollEnabled = NO;
            return;
        }
        
    } else {// 拖拽方向判断，是按刚开始的方向来判断的，一开始往左拖，此时一直不松手往右拖，方向还是左边的
        // 向左拖拽
        if ((scrollView.contentOffset.x - contentOffsetX) > 0.0f) {
            NSLog(@"left-------");
            // 如果此时偏移量大于等于总按钮的宽度，那么肯定是全部显示出来了，设置isFullButtonsShowing 为 YES
            if (scrollView.contentOffset.x >= scrollViewButtonsViewWidth) {
                isFullButtonsShowing = YES;
                return;
            }
        }
        // 向右拖拽
        else if ((contentOffsetX - scrollView.contentOffset.x) > 0.0f) {
            NSLog(@"right-------");
            // 只要是往右拖拽都回到原点
            [self backToZero:scrollView];
        }
    }
}


// 完成拖拽(滚动停止时调用此方法，手指离开屏幕)

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    oldContentOffsetX = scrollView.contentOffset.x;
    if (scrollView.contentOffset.x <= 0) {
        oldContentOffsetX = 0.0f;
    }
    // 手指离开后也需要判断,防止快速拖动过去，超过了按钮部分的就不作处理，不然会卡卡的
    if (scrollView.contentOffset.x >= scrollViewButtonsViewWidth / 2 && scrollView.contentOffset.x < scrollViewButtonsViewWidth) {
        [self showFullButtons];
    }
    // 如果此时偏移量还没到总按钮宽度的一半，那么就回到原点
    else if (scrollView.contentOffset.x < scrollViewButtonsViewWidth / 2){
        [self backToZero:scrollView];
    }
    
    self.lastScrollView = scrollView;
}


- (void)showFullButtons{
    
    [self animationLeftScrollTo:scrollViewButtonsViewWidth];
    // 标记是否正在显示
    isFullButtonsShowing = YES;
}
/**
 *  @author 孔凡列, 16-09-10 06:09:12
 *
 *  向左动画偏移到指定的x值
 *
 *  @param end x偏移量
 */
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
/**
 *  @author 孔凡列, 16-09-10 06:09:45
 *
 *  回到原点
 *
 *  @param scrollView scrollView description
 */
- (void)backToZero:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    offset.x = 0.0f;
    scrollView.contentOffset = offset;
    // 标记是否显示
    isFullButtonsShowing = NO;
    scrollView.scrollEnabled = YES;
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
