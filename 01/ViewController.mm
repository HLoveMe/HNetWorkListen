//
//  ViewController.m
//  01
//
//  Created by 朱子豪 on 2017/7/3.
//  Copyright © 2017年 朱子豪. All rights reserved.
//
#import <dlfcn.h>
#import "ViewController.h"
#import "TargetProxy.h"
#import "Student.h"
#import "HGClass.h"
#import "InputStreamProxy.h"
#import "NetWorkControl.h"
#import <resolv.h>
#include <arpa/inet.h>
#import <objc/runtime.h>
@interface ViewController ()<NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate,NSURLConnectionDataDelegate>
@property(nonatomic,strong)NSMutableData *data;
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)NSURLSessionTask *task;
@property(nonatomic,strong)NSURLConnection *con;
@end
void AAA(NSException *err){

}
@implementation ViewController

-(NSMutableData *)data{
    if(nil==_data){
        _data =[NSMutableData data];
    }
    return _data;
}
NSMutableData *imageData;
void myCallBack(CFReadStreamRef stream,CFStreamEventType type,void *clientCallBackInfo) {
        
    if (type == kCFStreamEventHasBytesAvailable) {
        NSLog(@"收到数据");
        //将流中的数据存入到数组中
        UInt8 buff [1024];
        long length = CFReadStreamRead(stream, buff, 1024);
        
        
        if (!imageData) {
            imageData = [NSMutableData data];
        }
        
        [imageData appendBytes:buff length:length];
        
    }
    if (type == kCFStreamEventEndEncountered) {
        NSLog(@"完成");
        //通知imageView显示图片
        NSLog(@"%ld",[imageData length]);
        UIImage *img = [UIImage imageWithData:imageData];
        if(img){
            [(__bridge_transfer  ViewController *)clientCallBackInfo showImage:img];
        }
        NSLog(@"%ld",[imageData length]);
        
        CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        //关闭流
        CFReadStreamClose(stream);
        //将流从runloop中移除
        
    }
    if(type == kCFStreamEventNone){
        NSLog(@"没有认识事");
    }
    if(type == kCFStreamEventOpenCompleted){
        NSLog(@"流被打开");
    }
    if(type == kCFStreamEventCanAcceptBytes){
        NSLog(@"kCFStreamEventCanAcceptBytes");
    
    }
    if(type==kCFStreamEventErrorOccurred){
        NSLog(@"发生错误");
    }
}
-(void)showImage:(UIImage *)img{
    self.imgV.image = img;
}
//CF 网络请求
-(void)cfnetwork{
    
    CFStringRef url = CFSTR("https://github.com");
//    CFStringRef url = CFSTR("http://www.cnblogs.com/");
    CFURLRef myURL = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);// note: release
    CFStringRef requestMethod = CFSTR("GET");
    CFHTTPMessageRef myRequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, myURL, kCFHTTPVersion1_1);// note: release
    // 设置body
    CFReadStreamRef requestReadStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, myRequest);
    
    CFStreamClientContext clientContext = {0, (__bridge void *)self, NULL, NULL, NULL};
    
    CFOptionFlags flags = kCFStreamEventHasBytesAvailable | kCFStreamEventEndEncountered | kCFStreamEventErrorOccurred;
    
    Boolean result = CFReadStreamSetClient(requestReadStream, flags, myCallBack, &clientContext);
    if (result) {
        CFReadStreamScheduleWithRunLoop(requestReadStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        if (CFReadStreamOpen(requestReadStream)) {
            
        } else {
            CFReadStreamUnscheduleFromRunLoop(requestReadStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        }
    }
    CFRelease(myURL);
    CFRelease(myRequest);
    
}
-(void)connect{
    //NSURLConnection
    NSArray *arr =@[@"https://www.baidu.com/",@"https://www.baidu.com/",@"http://www.tuicool.com/",@"https://segmentfault.com/",@"http://iconfont.cn/"];
    
    for (int i=0; i<1; i++) {
        NSURL *url = [NSURL URLWithString:arr[i]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLConnection *connect = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        _con = connect;
        [HClassDocument scanInstanceMethod:[connect class] _super:YES];
        [HClassDocument scanProperty:[connect class] _super:YES];
        
//        _con=connect;
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//            NSLog(@"-finish-size:%lu",data.length);
//        }];
        
    }
}
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response{
    return request;
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    
}
-(void)session{
    NSArray *arr =@[@"https://github.com",@"https://www.baidu.com/",@"http://www.tuicool.com/",@"https://segmentfault.com/",@"http://iconfont.cn/"];
    //NSURLSession
    for (int i=0; i<1; i++) {
        NSURL*url=[NSURL URLWithString:arr[i]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod  = @"POST";
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//        [[session dataTaskWithRequest:request] resume];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            NSLog(@"Success");

        }];
        [task resume];
        
        
//        NSLog(@"session:%p",session);
//        NSLog(@"task:%p",task);
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NetWorkControl start];
    
    
//    [self cfnetwork];
//    [self connect];
    [self session];
}
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
}
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{

}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{

    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}



- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    completionHandler(request);
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{

}

@end
