//
//  NSURLSession+Aop.m
//  01
//
//  Created by 朱子豪 on 2017/7/5.
//  Copyright © 2017年 朱子豪. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "NSURLSession+Aop.h"
#import <objc/runtime.h>
#import "URLSessionDelegate.h"
#import "URLSessionProxy.h"
#import "RRHeader.h"

@implementation NSURLSession (Aop)
static id single;
+(NSURLSession *)_sharedSession{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        single = [NSURLSession _sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDelegate>)[[URLSessionProxy alloc]initWithTarget:[[URLSessionDelegate alloc]init]] delegateQueue:[NSOperationQueue mainQueue]];
    });
    return single;
}
+(NSURLSession *)_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration{
    //泄露
    //解决
    return [NSURLSession _sessionWithConfiguration:configuration delegate:(id<NSURLSessionDelegate>)[[URLSessionProxy alloc]initWithTarget:[[URLSessionDelegate alloc]init]]delegateQueue:[NSOperationQueue mainQueue]];
}
+(NSURLSession *)_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(id<NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue{
    //泄露
    //解决
    return [NSURLSession _sessionWithConfiguration:configuration delegate:(id<NSURLSessionDelegate>)[[URLSessionProxy alloc]initWithTarget:[[URLSessionDelegate alloc]initWith:delegate]] delegateQueue:queue];
//    return [NSURLSession _sessionWithConfiguration:configuration delegate:(id<NSURLSessionDelegate>)[[URLSessionProxy alloc]initWithTarget:delegate] delegateQueue:queue];
}
//data
/*
    所有session(即使是Block回调) 都是用Proxy 作为代理 进行消息转发；
 
 */
-(NSURLSessionDataTask *)_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler{
    URLSessionProxy *proxy =  self.delegate;
    
    //block 回调
    URLSessionDelegate *delegate = (URLSessionDelegate *)proxy.target;
    if([delegate isKindOfClass:[URLSessionDelegate class]]){
        delegate.block = completionHandler;
    }
    NSURLSessionDataTask *dataTask = [self _dataTaskWithRequest:request completionHandler:nil];
    
    
    //信息搜集
    RRMessage *info;
    if(iOS10){
        info = [[RRStrongMessage alloc]init];
    }else{
        info =  [[RRMessage alloc]init];
    }
    info.date = [NSDate date];
    info.absUrl = request.URL.absoluteString;
    info.type = URLSession;
    info.method = request.HTTPMethod;
    RRTask *ta = [RRTask new];
    ta.msg = info;
    ta.session = self;
    ta.task = dataTask;
    [[RRNetWorkManager shareWorkManager] addTask:ta];
    proxy.task = ta;
    
    
    return dataTask;
}


//是否可以发送Body信息
-(BOOL)_can_delegate_task_didSendBodyData{
    URLSessionProxy *proxy =  self.delegate;
    [proxy performSelector:@selector(can_delegate_task_didSendBodyData)];
    return  [self _can_delegate_task_didSendBodyData];
}

+(void)rebind{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = [self class];
        method_exchangeImplementations(class_getClassMethod(clazz, @selector(sharedSession)), class_getClassMethod(clazz, @selector(_sharedSession)));
        
        method_exchangeImplementations(class_getClassMethod(clazz, @selector(sessionWithConfiguration:)), class_getClassMethod(clazz, @selector(_sessionWithConfiguration:)));
        
        method_exchangeImplementations(class_getClassMethod(clazz, @selector(sessionWithConfiguration:delegate:delegateQueue:)), class_getClassMethod(clazz, @selector(_sessionWithConfiguration:delegate:delegateQueue:)));
    
        
        
        method_exchangeImplementations(class_getInstanceMethod(clazz, @selector(dataTaskWithRequest:completionHandler:)), class_getInstanceMethod(clazz, @selector(_dataTaskWithRequest:completionHandler:)));
        
        
        method_exchangeImplementations(class_getInstanceMethod(clazz, @selector(can_delegate_task_didSendBodyData)), class_getInstanceMethod(clazz, @selector(_can_delegate_task_didSendBodyData)));
        
    });
//#endif
}
@end
