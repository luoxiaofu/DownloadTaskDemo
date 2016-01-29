//
//  ViewController.m
//  下载任务
//
//  Created by Macx on 16/1/4.
//  Copyright © 2016年 wl. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<
NSURLSessionDownloadDelegate
>
{
    NSURLSessionDownloadTask *downTask;
    NSData *myResumeData;
    NSURLSession *session;
    NSString *fielName;
    
}

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",NSHomeDirectory());
}


//创建下载任务
- (IBAction)downloadAction:(id)sender
{
    if (downTask)
    {
        return;
    }
    //构造需要下载的url链接
    
    NSURL *url = [NSURL URLWithString:@"http://apk500.bce.baidu-mgame.com/game/883000/883227/20160127061354_oem_5004211.apk?r=1"];
    //设置保存文件名为url的最后部分
    fielName = [url lastPathComponent];
    //设置session工作类型为默认
    NSURLSessionConfiguration *sessionCf = [NSURLSessionConfiguration defaultSessionConfiguration];
    //用sessionConfig配置session
    session = [NSURLSession sessionWithConfiguration:sessionCf delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //设置任务类型
    downTask = [session downloadTaskWithURL:url];

    //发送任务请求
    [downTask resume];
    
}



//暂停下载任务
- (IBAction)pauseAction:(UIButton *)sender
{
    if (downTask.state == NSURLSessionTaskStateRunning)
    {
        [downTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            //If resume data cannot be created, the completion handler will be called with nil resumeData
            myResumeData = resumeData;
            downTask = nil;
        }];
    }
    
}
//恢复下载任务
- (IBAction)resumeAction:(id)sender
{
    if (myResumeData)
    {
        downTask = [session downloadTaskWithResumeData:myResumeData];
        [downTask resume];
        
        myResumeData = nil;
    }
}
//把下载来的文件移动到Documents文件夹下并修改扩展名
- (void)moveFileToDocuments:(NSURL *)location
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *newPath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",fielName]];
    fielName = nil;
    NSLog(@"%@",newPath);
    
    [manager moveItemAtURL:location toURL:[NSURL fileURLWithPath:newPath] error:nil];
    
}

#pragma mark - NSURLSessionDownloadDelegate

//在下载完成后调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"%@",location);
    [self moveFileToDocuments:location];
}

//进度条相关设置
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    self.progressView.progress = progress;
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%", progress* 100];
    
}

@end
