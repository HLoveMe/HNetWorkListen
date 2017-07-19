//
//  URLConnectProxy.m
//  01
//
//  Created by 朱子豪 on 2017/7/3.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "URLConnectProxy.h"
#import "RRHeader.h"
@interface URLConnectProxy()
@property(nonatomic,strong)id _delegate;
@end
@implementation URLConnectProxy
-(instancetype)initOrigin:(id)delegate{
    self._delegate = delegate;
    return self;
}
-(RRMessage *)info{
    return self.task.msg;
}
-(void)message:(NSInvocation *)invocation{
    NSString *name = NSStringFromSelector(invocation.selector);
    if([name isEqualToString:@"start"]){
        self.info.start = CFAbsoluteTimeGetCurrent();
    }else if([name isEqualToString:@"connection:willSendRequestForAuthenticationChallenge:"]){
        self.info.is_ssl=YES;
        self.info.ssl_start = CFAbsoluteTimeGetCurrent()-self.info.start;
    }else if([name isEqualToString:@"send_body_data"]){
        //POST 发送body 时间
    }else if ([name isEqualToString:@"connection:didReceiveResponse:"]){
        self.info.receive_response = CFAbsoluteTimeGetCurrent()-self.info.start;
    }else if ([name isEqualToString:@"connection:didReceiveData:"]){
        if (self.info.receive_data_first==0) {
            self.info.receive_data_first = CFAbsoluteTimeGetCurrent()-self.info.start;
        }
        self.info.receive_data_end = CFAbsoluteTimeGetCurrent()-self.info.start;
        
        @try {
            //54627
            typeof(NSClassFromString(@"OS_dispatch_data")) data;
            [invocation getArgument:&data atIndex:3];
            if(data){
                self.info.data_size += (unsigned long)[(NSData *)data length];
            }
        } @catch (NSException *exception) {
            
        }
        self.info.receive_data_count +=1;
    }else if([name isEqualToString:@"connection:didFailWithError:"]){
        self.info.finish = CFAbsoluteTimeGetCurrent()-self.info.start;
        self.info.start=0;
        self.info.success = NO;
        typeof(NSClassFromString(@"NSURLError")) err;
        [invocation getArgument:&err atIndex:3];
        self.info.errorReason= [(NSError *)err description];
        [[RRNetWorkManager shareWorkManager] hasFinish:self.task];
    }else if([name isEqualToString:@"connectionDidFinishLoading:"]){
        self.info.finish = CFAbsoluteTimeGetCurrent()-self.info.start;
        self.info.start=0;
        self.info.success = YES;
        [[RRNetWorkManager shareWorkManager] hasFinish:self.task];
    }else if([name isEqualToString:@"connection:willSendRequest:redirectResponse:"]){
        self.info.redirect_count +=1;
    }
    //信息收集
    //    start   请求开始
    //    connection:willSendRequestForAuthenticationChallenge:   SSL 证书认证
    //    connection:didReceiveResponse: 收到回复
    //    connection:didReceiveData:  多次回调   第一次收到数据
    //    connectionDidFinishLoading:   请求完毕
    //    connection:didFailWithError:   数据请求错误
    //    @selector(connection:willSendRequest:redirectResponse:)  被重定向
}
- (void)forwardInvocation:(NSInvocation *)invocation{
    //    所有实现的回调将会在这里进行消息转发
    [self message:invocation];
    
    if([self._delegate respondsToSelector:invocation.selector]){
        [invocation invokeWithTarget:self._delegate];
    }
}
-(BOOL)respondsToSelector:(SEL)aSelector{
    BOOL flag = [URLConnectProxy is_delegate_selector:aSelector];
    if(flag){
        return YES;
    }
    return [self._delegate respondsToSelector:aSelector];
//    //    为了防止没实现协议
}
- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    NSMethodSignature *signa = [self._delegate methodSignatureForSelector:sel];
    if(signa){return signa;}
    return  [NSData instanceMethodSignatureForSelector:@selector(base64EncodedDataWithOptions:)];
    
}
static NSArray *names;
+(BOOL)is_delegate_selector:(SEL)aSel{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @[
                  @"connection:willSendRequestForAuthenticationChallenge:",
                  @"connection:didReceiveResponse:",
                  @"connection:didReceiveData:",
                  @"connectionDidFinishLoading:",
                  @"connection:didFailWithError:",
                  @"connection:willSendRequest:redirectResponse:"
                  ];
    });
    return [names containsObject:NSStringFromSelector(aSel)];
}
@end
