//
//  NSURLSessionTask+Aop.m
//  01
//
//  Created by 朱子豪 on 2017/7/6.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "NSURLSessionTask+Aop.h"
#import <objc/runtime.h>
#import "URLSessionProxy.h"
#import "DNSLookUp.h"

@implementation NSURLSessionTask (Aop)

-(void)_resume{
    NSURLSession *session = [self valueForKey:@"session"];
    URLSessionProxy *proxy = session.delegate;
    [proxy performSelector:@selector(resume)];
    [self _resume];
}
//- (id)onqueue_suspend{
//    //开启的请求任务  会调用该方法  仅仅调用一次
//    //  可以区别 任务和其所在线程
//    //  在DNS 解析之后 所以这里没有用
////    NSLog(@"%p-%@",self,[NSThread currentThread]);
//    return [self onqueue_suspend];
//}
static int indexA=100;
- (id)onqueue_strippedMutableRequest{
    NSThread *thread = [NSThread currentThread];
    
    [thread setName:[NSString stringWithFormat:@"name-%d",indexA]];
    indexA+=1;
    NSLog(@"%@-%@",self.currentRequest.URL.absoluteString,[NSThread currentThread]);
    return [self onqueue_strippedMutableRequest];
}
+(void)load{
    static dispatch_once_t task;
    dispatch_once(&task, ^{
        Class clazz = NSClassFromString(@"__NSCFLocalDataTask");
        method_exchangeImplementations(class_getInstanceMethod(clazz, @selector(resume)), class_getInstanceMethod([self class], @selector(_resume)));
        
        
//        method_exchangeImplementations(class_getInstanceMethod(clazz, @selector(_onqueue_suspend)), class_getInstanceMethod([self class], @selector(onqueue_suspend)));
        
        
        method_exchangeImplementations(class_getInstanceMethod(clazz, @selector(_onqueue_strippedMutableRequest)), class_getInstanceMethod([self class], @selector(onqueue_strippedMutableRequest)));
        /**
         NSURLSessionTask
         __NSCFURLSessionTask
         __NSCFLocalSessionTask
         __NSCFLocalDataTask<-
         
         
         NSURLSessionTask
         __NSCFURLSessionTask
         __NSCFLocalSessionTask
         __NSCFLocalDataTask<-
         __NSCFLocalUploadTask
         */
    });
}
@end

