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

@end

@interface FLSwipeOptionsCell ()
@property (nonatomic,weak)UIScrollView *scrollView;

// init content view on scrollView
@property (nonatomic,weak)UIView *scrollViewContentView;
// init buttons view on scrollView
@property (nonatomic,weak)UIView *scrollViewButtonsView;
@property (nonatomic,strong)NSMutableArray *buttonArrM;
@property (nonatomic,strong)NSMutableArray *buttonWidthArrM;
// action arr
@property (nonatomic,strong)NSArray *actionArr;
@end

@implementation FLSwipeOptionsCell

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
    // init scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    self.scrollView = scrollView;
    [self.contentView addSubview:scrollView];
    
    // init buttons View
    UIView *scrollViewButtonsView = [[UIView alloc] init];
    self.scrollViewButtonsView = scrollViewButtonsView;
    [self.contentView addSubview:scrollViewButtonsView];
    
    // init scrollView content view
    UIView *scrollViewContentView = [[UIView alloc] init];
    self.scrollViewContentView = scrollViewContentView;
    [self.contentView addSubview:scrollViewContentView];
    
    // init button on buttonsView
    self.actionArr = [self.delegate fl_createRowAction:self];
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
    CGFloat scrollViewButtonsViewWidth = 0.0f;
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
        NSNumber *nextNumWidth = self.buttonWidthArrM[index + 1];
        UIButton *button = self.buttonArrM[index];
//        button.frame = CGRectMake(buttonWidth, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    }
    
    self.scrollViewButtonsView.frame = CGRectMake(CGRectGetWidth(self.bounds) - scrollViewButtonsViewWidth, 0, scrollViewButtonsViewWidth, CGRectGetHeight(self.bounds));
    
    self.scrollViewContentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
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
