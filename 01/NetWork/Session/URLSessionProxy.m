//
//  URLSessionProxy.m
//  01
//
//  Created by 朱子豪 on 2017/7/5.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "URLSessionProxy.h"
#import "HClassDocument.h"
@interface URLSessionProxy()

@end
@implementation URLSessionProxy
-(RRMessage *)info{
    return self.task.msg;
}
-(id)initWithTarget:(id)target{
    _target=target;
    return self;
}
-(void)message:(NSInvocation *)invocation{
    NSString *name = NSStringFromSelector(invocation.selector);
#ifdef __IPHONE_10_0
    if([name isEqualToString:@"resume"]){
        self.info.start = CFAbsoluteTimeGetCurrent();
    }else if([name isEqualToString:@"URLSession:task:didFinishCollectingMetrics:"]){
        typeof(NSClassFromString(@"__NSCFURLSessionTaskMetrics")) metrices;
        [invocation getArgument:&metrices atIndex:4];
        NSURLSessionTaskMetrics *origin = (NSURLSessionTaskMetrics *)metrices;
        //重定向次数
        self.info.redirect_count = (int)origin.redirectCount;
        NSURLSessionTaskTransactionMetrics *transaction = origin.transactionMetrics.lastObject;
        double start = [transaction.fetchStartDate timeIntervalSince1970];
        double dnsStart = [transaction.domainLookupStartDate timeIntervalSince1970]-start;
        double dnsend = [transaction.domainLookupEndDate timeIntervalSince1970]-start;
        
        double sslstart = [transaction.secureConnectionStartDate timeIntervalSince1970]-start;
        
        
#ifdef __IPHONE_10_0
        //发送请求头
        double requestStartDate = [transaction.requestStartDate timeIntervalSince1970]-start;
        //发送请求头结束
        double requestend = [transaction.requestEndDate timeIntervalSince1970]-start;
        RRStrongMessage *message = (RRStrongMessage *)self.info;
        if(transaction.secureConnectionStartDate){
            message.ssl_end = [transaction.secureConnectionEndDate timeIntervalSince1970]-start;;
        }
        
        
        message.request_head_start = requestStartDate;
        message.request_head_end = requestend;
#else
#endif
        
        //开始响应
        double responsestart = [transaction.responseStartDate timeIntervalSince1970]-start;
        //结束data
        double responseDataend= [transaction.responseEndDate timeIntervalSince1970]-start;
        
        self.info.dns_start=dnsStart;
        self.info.dns_end = dnsend;
        if(transaction.secureConnectionStartDate){
            self.info.is_ssl=YES;
            self.info.ssl_start= sslstart;
        }
        self.info.receive_response = responsestart;
        
        self.info.finish = responseDataend;

    }else if([name isEqualToString:@"URLSession:task:didCompleteWithError:"]){
        //        NSLog(@"session end  %f",CFAbsoluteTimeGetCurrent());
        @try {
            NSError *err;
            [invocation getArgument:&err atIndex:4];
            self.info.success = err ? NO : YES;
            self.info.errorReason = [err description];
        } @catch (NSException *exception) {
            
        }
        self.info.finish = CFAbsoluteTimeGetCurrent()-self.info.start;
        self.info.start=0;
        NSLog(@"%@",self.info);
        [[RRNetWorkManager shareWorkManager] hasFinish:self.task];
        
    }else if([name isEqualToString:@"URLSession:dataTask:didReceiveData:"]){
        if (self.info.receive_data_first==0) {
            self.info.receive_data_first = CFAbsoluteTimeGetCurrent()-self.info.start;
        }
        self.info.receive_data_end = CFAbsoluteTimeGetCurrent()-self.info.start;
        @try {
            typeof(NSClassFromString(@"OS_dispatch_data")) data;
            [invocation getArgument:&data atIndex:4];
            if(data){
                self.info.data_size += (unsigned long)[(NSData *)data length];
            }
        } @catch (NSException *exception) {
            
        }
        self.info.receive_data_count +=1;
    }
#else
    
    if(!self.info){return;}
    if([name isEqualToString:@"resume"]){
        //        NSLog(@"session start %f",CFAbsoluteTimeGetCurrent());
        self.info.start = CFAbsoluteTimeGetCurrent();
    }else if([name isEqualToString:@"URLSession:didReceiveChallenge:completionHandler:"]){
        //        NSLog(@"session SSL %f",CFAbsoluteTimeGetCurrent());
        self.info.is_ssl=YES;
        self.info.ssl_start = CFAbsoluteTimeGetCurrent()-self.info.start;
    }else if([name isEqualToString:@"URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:"]){
        self.info.redirect_count +=1;
    }else if ([name isEqualToString:@"can_delegate_task_didSendBodyData"]){
        //        NSLog(@"session post Boby %f",CFAbsoluteTimeGetCurrent());
        self.info.boby_send = CFAbsoluteTimeGetCurrent()-self.info.start;
    }else if([name isEqualToString:@"URLSession:dataTask:didReceiveResponse:completionHandler:"]){
        //        NSLog(@"session reposnst %f",CFAbsoluteTimeGetCurrent());
        self.info.receive_response = CFAbsoluteTimeGetCurrent()-self.info.start;
    }else if([name isEqualToString:@"URLSession:dataTask:didReceiveData:"]){
        //        NSLog(@"session data  %f",CFAbsoluteTimeGetCurrent());
        if (self.info.receive_data_first==0) {
            self.info.receive_data_first = CFAbsoluteTimeGetCurrent()-self.info.start;
        }
        self.info.receive_data_end = CFAbsoluteTimeGetCurrent()-self.info.start;
        @try {
            typeof(NSClassFromString(@"OS_dispatch_data")) data;
            [invocation getArgument:&data atIndex:4];
            if(data){
                self.info.data_size += (unsigned long)[(NSData *)data length];
            }
        } @catch (NSException *exception) {
            
        }
        self.info.receive_data_count +=1;
    }else if([name isEqualToString:@"URLSession:task:didCompleteWithError:"]){
        //        NSLog(@"session end  %f",CFAbsoluteTimeGetCurrent());
        @try {
            NSError *err;
            [invocation getArgument:&err atIndex:4];
            self.info.success = err ? NO : YES;
            self.info.errorReason = [err description];
        } @catch (NSException *exception) {
            
        }
        self.info.finish = CFAbsoluteTimeGetCurrent()-self.info.start;
        self.info.start=0;
        NSLog(@"%@",self.info);
        [[RRNetWorkManager shareWorkManager] hasFinish:self.task];
        
    }
#endif
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    
    [self message:invocation];
    if([self.target respondsToSelector:invocation.selector]){
        [invocation invokeWithTarget:self.target];
    }
}
-(BOOL)respondsToSelector:(SEL)aSelector{
    return [URLSessionProxy is_delegate_selector:aSelector];
}

- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    NSMethodSignature *sing = [self.target methodSignatureForSelector:sel];
    if(sing){
        return sing;
    }
    return  [NSData instanceMethodSignatureForSelector:@selector(base64EncodedDataWithOptions:)];
}
static NSArray *invocations;
//代理需要执行的方法
+(BOOL)is_delegate_selector:(SEL)aSel{
    static dispatch_once_t invocation;
    dispatch_once(&invocation, ^{
        invocations = @[
                        @"resume",
                  //重定向
                  @"URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:",
                  //收到SSL
                  @"URLSession:didReceiveChallenge:completionHandler:",
                  //收到回应
                  @"URLSession:dataTask:didReceiveResponse:completionHandler:",
                  //收到数据
                  @"URLSession:dataTask:didReceiveData:",
                  //完成
                  @"URLSession:task:didCompleteWithError:",
                  @"URLSession:task:didFinishCollectingMetrics:"
                  ];
    });
    return [invocations containsObject:NSStringFromSelector(aSel)];
}
@end
