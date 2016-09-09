/*
 * author 孔凡列
 *
 * gitHub https://github.com/gitkong
 * cocoaChina http://code.cocoachina.com/user/
 * 简书 http://www.jianshu.com/users/fe5700cfb223/latest_articles
 * QQ 279761135
 * 喜欢就给个like 和 star 喔~
 */

#import <UIKit/UIKit.h>

// 事件处理
@interface FLTableViewRowAction : NSObject

@property (nonatomic,copy)NSString *title;

+ (instancetype)fl_rowActionWithStyle:(UITableViewRowActionStyle)style title:(nullable NSString *)title handler:(void (^)(FLTableViewRowAction *action, NSIndexPath *indexPath))handler;

+ (instancetype)fl_deleteActionWithTitle:(nullable NSString *)title Handle:(void (^)(FLTableViewRowAction *action, NSIndexPath *indexPath))handler;


@end

@class FLSwipeOptionsCell,FLTableViewRowAction;
@protocol FLSwipeOptionsCellDelegate <NSObject>

- (NSArray <FLTableViewRowAction *> *)fl_createRowAction:(FLSwipeOptionsCell *)swipeOptionsCell;

@end

@interface FLSwipeOptionsCell : UITableViewCell

@property (nonatomic,weak)id <FLSwipeOptionsCellDelegate> delegate;

@end
