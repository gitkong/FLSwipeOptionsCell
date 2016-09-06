//
//  FLSwipeOptionsCell.h
//  FLSwipeOptionsCell
//
//  Created by clarence on 16/9/6.
//  Copyright © 2016年 clarence. All rights reserved.
//

#import <UIKit/UIKit.h>

// 事件处理
@interface FLTableViewRowAction : NSObject

@property (nonatomic,copy)NSString *title;

+ (instancetype)fl_rowActionWithStyle:(UITableViewRowActionStyle)style title:(nullable NSString *)title handler:(void (^)(FLTableViewRowAction *action, NSIndexPath *indexPath))handler;

@end

@class FLSwipeOptionsCell,FLTableViewRowAction;
@protocol FLSwipeOptionsCellDelegate <NSObject>

- (NSArray <FLTableViewRowAction *> *)fl_createRowAction:(FLSwipeOptionsCell *)swipeOptionsCell;

@end

@interface FLSwipeOptionsCell : UITableViewCell

@property (nonatomic,weak)id <FLSwipeOptionsCellDelegate> delegate;

@end
