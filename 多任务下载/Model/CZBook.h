//
//  CZBook.h
//  多任务下载
//
//  Created by 张玺科 on 16/6/10.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZBook : NSObject
/**
 *  章节名称
 */
@property (nonatomic,copy)NSString *name;
/**
 *  音频路径
 */
@property (nonatomic,copy)NSString *path;
/**
 *  音频文件在网络服务器的尺寸
 */
@property (nonatomic,assign)NSInteger size;
/**
 * 下载进度
 */
@property (nonatomic, assign) float progress;
@end
