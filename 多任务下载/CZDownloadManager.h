//
//  CZDownloadManager.h
//  多任务下载
//
//  Created by 张玺科 on 16/6/10.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZDownloadManager : NSObject

+ (instancetype)sharedManager;

- (void)downloadWithURL:(NSURL *)url progress:(void (^)(float p))progress completion:(void (^)(BOOL isSuccess))completion;

- (void)pauseWithURL:(NSURL *)url completion:(void (^)())completion;

- (BOOL)isDownloadingWithURL:(NSURL *)url;

@end
