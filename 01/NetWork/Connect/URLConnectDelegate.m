//
//  URLConnectDelegate.m
//  01
//
//  Created by 朱子豪 on 2017/7/3.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "URLConnectDelegate.h"
@interface URLConnectDelegate()
@property(nonatomic,copy)void(^Block)(id ,id ,id);
@property(nonatomic,strong)NSMutableData *data;
@property(nonatomic,weak)NSURLResponse *response;
@property(nonatomic,weak)id origin;
@end
@implementation URLConnectDelegate
-(instancetype)initWith:(id)target{
    if(self = [super init]){
        self.origin = target;
    }
    return self;
}
-(instancetype)initOriginWith:(void (^)(NSURLResponse *, NSData *, NSError *))block{
    if(self = [super init]){
        self.Block = block;
    }
    return self;
}
-(NSMutableData *)data{
    if(nil==_data){
        _data = [NSMutableData data];
    }
    return _data;
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLConnectionDelegate>)self.origin connection:connection didFailWithError:error];
        return;
    }
    self.Block(nil,nil,error);
}
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        return [(id<NSURLConnectionDelegate>)self.origin connectionShouldUseCredentialStorage:connection];
    }
    return [connection.currentRequest.URL.scheme.lowercaseString containsString:@"https"];
}
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLConnectionDelegate>)self.origin connection:connection willSendRequestForAuthenticationChallenge:challenge];
        return;
    }
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    SecTrustResultType result;
    OSStatus status = SecTrustEvaluate(trust, &result);
    if (status == errSecSuccess &&
        (result == kSecTrustResultProceed ||
         result == kSecTrustResultUnspecified)) {
            NSURLCredential *cred = [NSURLCredential credentialForTrust:trust];
            [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
            
        } else {
            [challenge.sender cancelAuthenticationChallenge:challenge];
        }
}

/**
 - (void)connectionDidFinishLoading:(NSURLConnection *)connection;
 
 */
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        return [(id<NSURLConnectionDataDelegate>)self.origin connection:connection willSendRequest:request redirectResponse:response];
    }
    return request;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLConnectionDataDelegate>)self.origin connection:connection didReceiveResponse:response];
        return;
    }
    self.response=response;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLConnectionDataDelegate>)self.origin connection:connection didReceiveData:data];
        return;
    }
    [self.data appendData:data];
}
- (nullable NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        return [(id<NSURLConnectionDataDelegate>)self.origin connection:connection needNewBodyStream:request];
    }
    NSAssert(NO, @"没有实现");
    return nil;
}
- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLConnectionDataDelegate>)self.origin connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}
- (nullable NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{

    if(self.origin && [self.origin respondsToSelector:_cmd]){
        return [(id<NSURLConnectionDataDelegate>)self.origin connection:connection willCacheResponse:cachedResponse];
    }
    return cachedResponse;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLConnectionDataDelegate>)self.origin connectionDidFinishLoading:connection];
        return;
    }
    self.Block(self.response,self.data,nil);
    self.data=nil;
    self.response=nil;
}
@end
