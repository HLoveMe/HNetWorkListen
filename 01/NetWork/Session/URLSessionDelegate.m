//
//  URLSessionDelegate.m
//  01
//
//  Created by 朱子豪 on 2017/7/5.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "URLSessionDelegate.h"
@interface URLSessionDelegate()
@property(nonatomic,strong)NSMutableData *data;
@property(nonatomic,weak)NSURLResponse *resopnse;
@property(nonatomic,weak)id origin;
@end
@implementation URLSessionDelegate
-(instancetype)initWith:(id)origin{
    if(self = [super init]){
        _origin=origin;
    }
    return self;
}
-(NSMutableData *)data{
    if(nil==_data){
        _data = [NSMutableData data];
    }
    return _data;
}
//NSURLSessionDelegate  三个
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDelegate>)self.origin URLSession:session didBecomeInvalidWithError:error];
    }
}
//SSL
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDelegate>)self.origin URLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
        return;
    }
    
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDelegate>)self.origin URLSessionDidFinishEventsForBackgroundURLSession:session];
        return;
    }
}
//NSURLSessionTaskDelegate   6
//重定向
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDataDelegate>)self.origin URLSession:session task:task willPerformHTTPRedirection:response newRequest:request completionHandler:completionHandler];
        return;
    }
    
    completionHandler(request);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionTaskDelegate>)self.origin URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
        return;
    }
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * _Nullable bodyStream))completionHandler{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionTaskDelegate>)self.origin URLSession:session task:task needNewBodyStream:completionHandler];
        return;
    }
    NSAssert(NO, @"这里没实现");
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionTaskDelegate>)self.origin URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
        return;
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDataDelegate>)self.origin URLSession:session task:task didCompleteWithError:error];
        return;
    }
    
    if(self.block){
        self.block(self.data,self.resopnse,error);
        [session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            if(dataTasks.count==0 && uploadTasks.count==0&&downloadTasks.count==0){
                [session invalidateAndCancel];
            }
        }];
        self.data=nil;
        self.resopnse=nil;
    }
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDataDelegate>)self.origin URLSession:session task:task didFinishCollectingMetrics:metrics];
        return;
    }
}
//NSURLSessionDataDelegate  5
//收到回复
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDataDelegate>)self.origin URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
        return;
    }
    self.resopnse = response;
    completionHandler(NSURLSessionResponseAllow);
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDataDelegate>)self.origin URLSession:session dataTask:dataTask didReceiveData:data];
        return;
    }
    [self.data appendData:data];
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDataDelegate>)self.origin URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask];
    }
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDataDelegate>)self.origin URLSession:session dataTask:dataTask didBecomeStreamTask:streamTask];
    }
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler{
    if(self.origin && [self.origin respondsToSelector:_cmd]){
        [(id<NSURLSessionDataDelegate>)self.origin URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
        return;
    }
    completionHandler(proposedResponse);
}
@end
