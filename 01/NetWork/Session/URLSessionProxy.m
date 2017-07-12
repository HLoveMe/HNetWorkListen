//
//  URLSessionProxy.m
//  01
//
//  Created by 朱子豪 on 2017/7/5.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "URLSessionProxy.h"
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
    if(!self.info){return;}
    if([name isEqualToString:@"resume"]){
//        NSLog(@"session start %f",CFAbsoluteTimeGetCurrent());
        self.info.start = CFAbsoluteTimeGetCurrent();
    }else if([name isEqualToString:@"URLSession:didReceiveChallenge:completionHandler:"]){
//        NSLog(@"session SSL %f",CFAbsoluteTimeGetCurrent());
        self.info.is_ssl=YES;
        self.info.SSL = CFAbsoluteTimeGetCurrent()-self.info.start;
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
        if (self.info.receive_data==0) {
            self.info.receive_data = CFAbsoluteTimeGetCurrent()-self.info.start;
        }
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
        } @catch (NSException *exception) {
            
        }
        self.info.finish = CFAbsoluteTimeGetCurrent()-self.info.start;
        self.info.start=0;
        NSLog(@"%@",self.info);
        [[RRNetWorkManager shareWorkManager] hasFinish:self.task];
        
    }
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
                        @"create",
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
                  ];
    });
    return [invocations containsObject:NSStringFromSelector(aSel)];
}
@end
