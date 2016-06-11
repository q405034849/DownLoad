//
//  CZBook.m
//  多任务下载
//
//  Created by 张玺科 on 16/6/10.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import "CZBook.h"

@implementation CZBook
- (void)setValue:(id)value forKey:(NSString *)key{};

- (NSString *)description{
    return [NSString stringWithFormat:@"name:%@,path:%@,size:%zd",_name,_path,_size];
}
@end
