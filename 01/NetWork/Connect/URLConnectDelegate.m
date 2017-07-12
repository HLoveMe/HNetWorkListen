//
//  URLConnectDelegate.m
//  01
//
//  Created by 朱子豪 on 2017/7/3.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "URLConnectDelegate.h"
@interface URLConnectDelegate()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property(nonatomic,copy)void(^Block)(id ,id ,id);
@property(nonatomic,strong)NSMutableData *data;
@property(nonatomic,strong)NSURLResponse *response;
@end
@implementation URLConnectDelegate
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
    self.Block(nil,nil,error);
}
//data
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.response=response;
}
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response{
    //重定向
    return request;
}
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
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


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.data appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.Block(self.response,self.data,nil);
    self.data=nil;
    self.response=nil;
}
@end
