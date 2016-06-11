//
//  CZBookCell.m
//  多任务下载
//
//  Created by 张玺科 on 16/6/10.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import "CZBookCell.h"
#import "CZBook.h"

@interface CZBookCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@end

@implementation CZBookCell

- (void)setModel:(CZBook *)model {
    _model = model;
    
    _nameLabel.text = model.name;
    
    _progressView.progress = model.progress;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIButton *btn = [[UIButton alloc] init];
    
    [btn setTitle:@"Start" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    
    [btn sizeToFit];
    
    self.accessoryView = btn;
    
    [btn addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickButton {
    // NSLog(@"%s", __FUNCTION__);
    
    /**
     * 通知代理执行协议方法
     */
    [_delegate bookCellDidClickActionButton:self];
}

@end
