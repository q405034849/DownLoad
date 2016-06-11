//
//  CZDownloadManager.m
//  多任务下载
//
//  Created by 张玺科 on 16/6/10.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import "CZDownloadManager.h"
#import "CZAdditions.h"

@interface CZDownloadManager() <NSURLSessionDownloadDelegate>

@end

@implementation CZDownloadManager {
    /**
     * 后台会话
     */
    NSURLSession *_backgroundSession;
    /**
     * 任务的缓存记录
     */
    NSMutableDictionary *_tasks;
    /**
     * 进度的回调记录
     */
    NSMutableDictionary *_progressBlocks;
    /**
     * 完成的回调记录
     */
    NSMutableDictionary *_completionBlocks;
}

+ (instancetype)sharedManager {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // 1. 实例化 session
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"cn.itcast.backgroundSession"];
        
        _backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        
        // 2. 实例化缓存字典
        _tasks = [NSMutableDictionary dictionary];
        _progressBlocks = [NSMutableDictionary dictionary];
        _completionBlocks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)downloadWithURL:(NSURL *)url progress:(void (^)(float))progress completion:(void (^)(BOOL))completion {
    // 1. 使用 URL 新建下载任务
//    NSURLSessionDownloadTask *task = [_backgroundSession downloadTaskWithURL:url];
    // 0. 判断是否有续传数据，如果有续传数据，接着下载
    NSData *data = [NSData dataWithContentsOfFile:[self resumePathWithURL:url]];
    
    NSURLSessionDownloadTask *task;
    if (data != nil) {
        // 使用续传数据，新建下载任务
        task = [_backgroundSession downloadTaskWithResumeData:data];
    } else {
        // 使用 URL 新建下载任务
        task = [_backgroundSession downloadTaskWithURL:url];
    }
    
    // 2. 将下载任务添加到缓冲池
    _tasks[url] = task;
    
    _progressBlocks[task] = progress;
    
    _completionBlocks[task] = completion;
    
    NSLog(@"====> %@", task);
    
    // 3. 启动任务
    [task resume];
}

- (void)pauseWithURL:(NSURL *)url completion:(void (^)())completion {
    // 1. 根据 url 获取下载任务
    NSURLSessionDownloadTask *task = _tasks[url];
    
    // 2. 如果 task 不存在
    if (task == nil) {
        NSLog(@"任务不存在");
        return;
    }
    
    // 3. 暂停任务
    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        // 1> 将 resumeData 写入沙盒
        [resumeData writeToFile:[self resumePathWithURL:url] atomically:YES];
        
        // 2> 清理缓存
        [_tasks removeObjectForKey:url];
        [_progressBlocks removeObjectForKey:task];
        [_completionBlocks removeObjectForKey:task];
        
        // 3> 主线程执行回调
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

- (BOOL)isDownloadingWithURL:(NSURL *)url {
    
    // 直接判断 任务缓冲池是否有 url 对应的 task
    return _tasks[url] != nil;
}

- (NSString *)resumePathWithURL:(NSURL *)url {
    return url.absoluteString.cz_md5String.cz_appendTempDir;
}

- (NSString *)finalPathWithURL:(NSURL *)url {
    return url.absoluteString.cz_md5String.cz_appendCacheDir;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSLog(@"下载完成 %@", location);
    
    // 1. 将文件复制到 cache 目录
    // 1> 取下载的 url
    NSURL *url = downloadTask.currentRequest.URL;
    // 2> 复制文件
    [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:[self finalPathWithURL:url] error:NULL];
    
    // 2. 执行完成回调
    // 1> 取完成回调
    void (^block)(BOOL) = _completionBlocks[downloadTask];
    
    // 2> 判断 block
    if (block != nil) {
        // 主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            block(YES);
        });
    }
    
    // 3. 清理工作，删除缓存[任务／进度／完成]
    NSLog(@"清理前 %@ %@ %@", _tasks, _progressBlocks, _completionBlocks);
    
    [_tasks removeObjectForKey:url];
    [_progressBlocks removeObjectForKey:downloadTask];
    [_completionBlocks removeObjectForKey:downloadTask];
    
    NSLog(@"清理后 %@ %@ %@", _tasks, _progressBlocks, _completionBlocks);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    
//    NSLog(@"%f", progress);
    void (^block)(float) = _progressBlocks[downloadTask];
    
    if (block != nil) {
        // 主线程执行 block
        dispatch_async(dispatch_get_main_queue(), ^{
            block(progress);
        });
    }

}

@end
