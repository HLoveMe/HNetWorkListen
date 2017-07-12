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
#import "NetWork/DNSLookUp.h"
@interface ViewController ()<NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
@property(nonatomic,strong)NSMutableData *data;
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)NSURLSessionTask *task;
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
- (void)viewDidLoad {
    [super viewDidLoad];
    [DNSLookUp rebind];
    NSSetUncaughtExceptionHandler(AAA);
    NSArray *arr =@[@"https://github.com",@"https://www.baidu.com/",@"http://www.tuicool.com/",@"https://segmentfault.com/",@"http://iconfont.cn/"];

    for (int i=0; i<5; i++) {
        NSURL *url = [NSURL URLWithString:arr[i]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            NSLog(@"-finish-size:%lu",data.length);
        }];
    
    }
    
    return;
    for (int i=0; i<5; i++) {
        NSURL*url=[NSURL URLWithString:arr[i]];
        //    NSURL*url=[NSURL URLWithString:@"https://github.com/"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod  = @"POST";
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
  
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request] ;
        _task=task;
        [task resume];
    }
    
    
}
//task
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

     NSURL* url=[NSURL URLWithString:@"https://www.baidu.com"];
    NSMutableURLRequest *requesta = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requesta] ;
    _task=task;
    [task resume];}
//重定向
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    completionHandler(request);
}
//SSL
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}
//收到回复
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    completionHandler(NSURLSessionResponseAllow);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
//    NSLog(@"size:%lu",self.data.length);
//    NSLog(@"%@",[[NSString alloc]initWithData:self.data encoding:4]);
}
//data
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
//    54627   54619
    [self.data appendData:data];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics{

}
@end
