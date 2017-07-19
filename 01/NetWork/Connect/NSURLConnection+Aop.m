//
//  NSURLConnection+Aop.m
//  01
//
//  Created by 朱子豪 on 2017/7/3.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "NSURLConnection+Aop.h"
#import <objc/runtime.h>
#import "URLConnectProxy.h"
#import "URLConnectDelegate.h"
#import "RRHeader.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
@implementation NSURLConnection (Aop)
-(instancetype)_initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately{
    URLConnectProxy *proxy = [[URLConnectProxy alloc]initOrigin:[[URLConnectDelegate alloc]initWith:delegate]];
    objc_setAssociatedObject(self, "_proxy_", proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self _initWithRequest:request delegate:proxy startImmediately:startImmediately];
}
-(instancetype)_initWithRequest:(NSURLRequest *)request delegate:(id)delegate{
    URLConnectProxy *proxy = [[URLConnectProxy alloc]initOrigin:[[URLConnectDelegate alloc]initWith:delegate]];
    objc_setAssociatedObject(self, "_proxy_", proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//
    //信息搜集
    RRMessage *info =  [[RRMessage alloc]init];
    info.date = [[NSDate date] timeIntervalSince1970];
    info.absUrl = request.URL.absoluteString;
    info.type = URLConnection;
    info.method = request.HTTPMethod;
    RRTask *ta = [RRTask new];
    ta.msg = info;
    ta.connect = self;
    [[RRNetWorkManager shareWorkManager] addTask:ta];
    proxy.task = ta;
    
    return [self _initWithRequest:request delegate:proxy];
}
+(NSURLConnection *)_connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate{
    return [[NSURLConnection alloc]initWithRequest:request delegate:delegate];
}

+(void)_sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse * _Nullable, NSData * _Nullable, NSError * _Nullable))handler{
    [[NSURLConnection alloc] initWithRequest:request delegate: [[URLConnectDelegate alloc] initOriginWith:^(NSURLResponse *res, NSData *data, NSError *err) {
        [queue addOperation:[NSBlockOperation blockOperationWithBlock:^{
            handler(res,data,err);
        }]];
    }]];
}
+(NSData*)_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error{
    __block NSData *_data;
    [[NSURLConnection alloc] initWithRequest:request delegate: [[URLConnectDelegate alloc] initOriginWith:^(NSURLResponse *res, NSData *data, NSError *err) {
        _data = data;
        if(response){
            *response = res;
        }
        if(error){
            *error = err;
        }
        CFRunLoopStop(CFRunLoopGetCurrent());
    }]];
    CFRunLoopRun();
    return _data;
}
-(void)startNetwork{
    URLConnectProxy *proxy = objc_getAssociatedObject(self, "_proxy_");
    if(proxy){[proxy performSelector:@selector(start)];}
    [self startNetwork];
}

+(void)rebind{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = [NSURLConnection class];
        //    initWithRequestdelegate
        Method method1 = class_getInstanceMethod(clazz, @selector(initWithRequest:delegate:));
        method_exchangeImplementations(method1, class_getInstanceMethod(clazz, @selector(_initWithRequest:delegate:)));
        
        
        Method method2 = class_getInstanceMethod(clazz, @selector(initWithRequest:delegate:startImmediately:));
        
        method_exchangeImplementations(method2, class_getInstanceMethod(clazz, @selector(_initWithRequest:delegate:startImmediately:)));
        
        
        
        method_exchangeImplementations(class_getClassMethod(clazz, @selector(connectionWithRequest:delegate:)), class_getClassMethod(clazz, @selector(_connectionWithRequest:delegate:)));
        
        method_setImplementation(class_getClassMethod(clazz, @selector(sendAsynchronousRequest:queue:completionHandler:)),method_getImplementation(class_getClassMethod(clazz, @selector(_sendAsynchronousRequest:queue:completionHandler:))));
        
        
        method_setImplementation(class_getClassMethod(clazz, @selector(sendSynchronousRequest:returningResponse:error:)),method_getImplementation(class_getClassMethod(clazz, @selector(_sendSynchronousRequest:returningResponse:error:))));
        
        method_exchangeImplementations(class_getInstanceMethod(clazz, @selector(start)), class_getInstanceMethod(clazz, @selector(startNetwork)));
       
    });
}

@end

#pragma clang diagnostic pop
