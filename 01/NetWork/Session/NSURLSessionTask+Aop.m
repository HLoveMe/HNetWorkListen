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
//#import "RRDNS.h"

@implementation NSURLSessionTask (Aop)

-(void)_resume{
    NSURLSession *session = [self valueForKey:@"session"];
    URLSessionProxy *proxy = session.delegate;
    [proxy performSelector:@selector(resume)];
    [self _resume];
}

- (id)onqueue_strippedMutableRequest{
    //关系
    return [self onqueue_strippedMutableRequest];
}
+(void)rebind{
    
    static dispatch_once_t task;
    dispatch_once(&task, ^{
        Class clazz = NSClassFromString(@"__NSCFLocalDataTask");
        method_exchangeImplementations(class_getInstanceMethod(clazz, @selector(resume)), class_getInstanceMethod([self class], @selector(_resume)));

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

