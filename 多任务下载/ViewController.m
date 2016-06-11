//
//  ViewController.m
//  多任务下载
//
//  Created by 张玺科 on 16/6/10.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import "ViewController.h"
#import "CZBook.h"
#import "CZBookCell.h"
#import "CZDownloadManager.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,CZBookCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tabelView;

@property (nonatomic,strong)NSArray <CZBook *> *bookList;
@end

@implementation ViewController{
    AVPlayer *_player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadData];
}

- (void)loadData{
    
    NSURL *url = [NSURL URLWithString:@"http://42.62.15.100/yyting/snsresource/getAblumnAudios.action?ablumnId=2719&imei=RkVGNzBFMkYtNjc2QS00NkQwLUEwOTYtNUU5Q0QyOUVGMzdE&nwt=1&q=50506&sc=1438f6d61a2907bfa8b3ea0973474ac1&sortType=1&token=j5xm1WPkdnI-uxtFXlv6CsWiNfwjfQYPQb63ToXOFc8%2A"];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"发送请求失败");
            return;
        }
        
        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
//        NSLog(@"%@",result);
        NSArray *list = result[@"list"];
        
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *dict in list) {
            CZBook *model = [CZBook new];
            
            [model setValuesForKeysWithDictionary:dict];
            
            [arrayM addObject:model];
        }
        self.bookList = arrayM.copy;
        NSLog(@"%@", self.bookList);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tabelView reloadData];
        });
        
    }]resume];
}

#pragma mark - CZBookCellDelegate
- (void)bookCellDidClickActionButton:(CZBookCell *)cell {
    // NSLog(@"%s", __FUNCTION__);
    
    // 开始下载 - 一般开发网络工具通常使用单例，由一个单例统一调度所有的网络任务！
    // 1. 根据 cell 获取到对应的 indexPath
    NSIndexPath *indexPath = [self.tabelView indexPathForCell:cell];
    
    // 2. 根据 indexPath 获取模型
    CZBook *model = _bookList[indexPath.row];
    
    // 3. 根据模型中的 path 建立 url 准备下载
    NSURL *url = [NSURL URLWithString:model.path];
    
    NSLog(@"%zd %@", indexPath.row, url);
    
    // 4. 判断是否正在下载
    if (![[CZDownloadManager sharedManager] isDownloadingWithURL:url]) {
        // 5. 下载
        [[CZDownloadManager sharedManager] downloadWithURL:url progress:^(float p) {
            NSLog(@"%f", p);
            
            // 1> 更新 model 的值
            model.progress = p;
            
            // 2> 让 cell 更新进度
            // 注意：随着表格的滚动 cell 会被复用
            // cell.model = model;
            // *** 根据 indexPath 获取表格对应的 cell
            CZBookCell *bookCell = [self.tabelView cellForRowAtIndexPath:indexPath];
            
            // 更新 bookCell 的模型
            bookCell.model = model;
            
        } completion:^(BOOL isSuccess) {
            NSLog(@"下载完成 %d", isSuccess);
        }];
    } else {
        // 暂停 url 对应的操作
        [[CZDownloadManager sharedManager] pauseWithURL:url completion:^{
            NSLog(@"===>暂停完成");
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _bookList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CZBookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    
    cell.model = _bookList[indexPath.row];
    
    // 自定义 cell 推荐使用设置代理，而不要设置 block，否则每个 cell 都需要设置一段 block!
    cell.delegate = self;
    
    // 如果用 block
    //    cell.block = ^ {
    //
    //    };
    
    return cell;
}

@end
