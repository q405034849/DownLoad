//
//  CZBookCell.h
//  多任务下载
//
//  Created by 张玺科 on 16/6/10.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CZBook,CZBookCell;

@protocol CZBookCellDelegate <NSObject>

/**
 * cell 点击操作按钮
 */
- (void)bookCellDidClickActionButton:(CZBookCell *)cell;

@end

@interface CZBookCell : UITableViewCell

@property (nonatomic, weak) id <CZBookCellDelegate> delegate;
@property (nonatomic, strong) CZBook *model;

@end
