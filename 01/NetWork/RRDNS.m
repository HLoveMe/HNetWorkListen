//
//  NetWorkManager.m
//  01
//
//  Created by 朱子豪 on 2017/7/10.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "RRDNS.h"
#include <dlfcn.h>
#include <netdb.h>
#import "RRHeader.h"
#import <UIKit/UIKit.h>
static int  (* origin_getaddrinfo)(const char * __restrict, const char * __restrict,const struct addrinfo * __restrict,
                              struct addrinfo ** __restrict);
int my_getaddrinfo(const char *  a, const char * b,
                       const struct addrinfo * c,
                   struct addrinfo ** d){
    NSLog(@"----%@-----%@",[NSString stringWithCString:a encoding:4],[NSThread currentThread]);
    int result = origin_getaddrinfo(a,b,c,d);
    return result;
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


@implementation RRDNS

+(void)rebind{
    if(iOS9_3){
        static dispatch_once_t rebind;
        dispatch_once(&rebind, ^{
            void *lib = dlopen("/usr/lib/system/libsystem_dnssd.dylib", RTLD_NOW);
            orig_DNSServiceGetAddrInfo = dlsym(lib, "DNSServiceGetAddrInfo");
            rebind_symbols((struct rebinding[1]){{"DNSServiceGetAddrInfo",my_DNSServiceGetAddrInfo}}, 1);
            dlclose(lib);
        });
    }else{
//        getaddrinfo
//        void *lib = dlopen("/usr/lib/system/libsystem_sim_info.dylib", RTLD_NOW);
        origin_getaddrinfo = dlsym(RTLD_DEFAULT, "getaddrinfo");
        rebind_symbols((struct rebinding[1]){
            {"getaddrinfo",my_getaddrinfo}
        }, 1);
//        dlclose(lib);
    }
}
@end

//@implementation AddrInfoReply
//@end
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
