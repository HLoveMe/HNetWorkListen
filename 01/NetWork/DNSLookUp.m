//
//  NetWorkManager.m
//  01
//
//  Created by 朱子豪 on 2017/7/10.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "DNSLookUp.h"
#include <dlfcn.h>
#import "RRHeader.h"

static int (*orig_gethostbyname)(const char *);

int my_gethostbyname(const char *a){
    
    
    return orig_gethostbyname(a);
}

void ABCDE(DNSServiceRef sdRef,
           DNSServiceFlags flags,
           uint32_t interfaceIndex,
           DNSServiceErrorType errorCode,
           const char                       *hostname,
           const struct sockaddr            *address,
           uint32_t ttl,
           void *context){
    
    char host[1024];
    char serv[20];
    getnameinfo(address, sizeof(address), host, sizeof(host), serv, sizeof(serv), NI_NUMERICHOST| NI_NUMERICSERV);
    
        NSString *ip = [NSString stringWithUTF8String:host];
        int B =[[NSString stringWithUTF8String:serv] intValue];
        NSLog(@"-%@-%d",ip,B);
////    (2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)
//    NSError *error;
//    NSRegularExpression *ex =  [NSRegularExpression regularExpressionWithPattern:@"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)" options:NSRegularExpressionCaseInsensitive error:&error];
//    if(error==nil){
//        NSRange range = [ex rangeOfFirstMatchInString:ip options:NSMatchingReportProgress range:NSMakeRange(0, ip.length)];
//        if(range.location != NSNotFound){
//                NSLog(@"DNS end %f",CFAbsoluteTimeGetCurrent());
//        }
//
//        
//        
//    }
    
}
Boolean (*orig_CFHostStartInfoResolution)(CFHostRef theHost, CFHostInfoType info, CFStreamError * __nullable error);
Boolean my_CFHostStartInfoResolution(CFHostRef theHost, CFHostInfoType info, CFStreamError * __nullable error){

    return orig_CFHostStartInfoResolution(theHost,info,error);
}

static DNSServiceErrorType(*orig_DNSServiceGetAddrInfo)(DNSServiceRef *,DNSServiceFlags,uint32_t,DNSServiceProtocol,const char *,DNSServiceGetAddrInfoReply,void *);

DNSServiceErrorType my_DNSServiceGetAddrInfo(DNSServiceRef *sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceProtocol protocol, const char *hostname, DNSServiceGetAddrInfoReply callBack, void *context){
//    NSLog(@"DNS start %f",CFAbsoluteTimeGetCurrent());
    NSThread *thread = [NSThread currentThread];
    NSLog(@"%@-%@",[NSString stringWithUTF8String:hostname],thread);
   //为什么是同一线程
    
    /**
        1: 想法为使用ABCDE 替换该出callBack 作为解析ip地址后的回调
        2: 但是callBack 必须在合适的时机回调 来保证请求的正常进行
        3: 暂时还没有 办法得到DNS 解析结束时间
     */

    return orig_DNSServiceGetAddrInfo(sdRef,flags,interfaceIndex,protocol,hostname,callBack,context);
}


@implementation DNSLookUp

+(void)rebind{
#ifdef __IPHONE_9_3
    static dispatch_once_t rebind;
    dispatch_once(&rebind, ^{
        void *lib = dlopen("/usr/lib/system/libsystem_dnssd.dylib", RTLD_NOW);
        orig_DNSServiceGetAddrInfo = dlsym(lib, "DNSServiceGetAddrInfo");
        rebind_symbols((struct rebinding[1]){{"DNSServiceGetAddrInfo",my_DNSServiceGetAddrInfo}}, 1);
        dlclose(lib);
    });
#else
    rebind_symbols((struct rebinding[1]){{"gethostbyname",my_gethostbyname,(void *)&orig_gethostbyname}}, 1);
    
#endif
}
@end

@implementation AddrInfoReply
@end
