//
//  NetWorkManager.m
//  01
//
//  Created by 朱子豪 on 2017/7/10.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "RRDNS.h"
#include <dlfcn.h>
#import <objc/runtime.h>
#import "RRHeader.h"
#import <UIKit/UIKit.h>

//ios9.3 以前
static int  (* origin_getaddrinfo)(const char * __restrict, const char * __restrict,const struct addrinfo * __restrict,
                              struct addrinfo ** __restrict);
int my_getaddrinfo(const char *  a, const char * b,
                       const struct addrinfo * c,
                   struct addrinfo ** d){
    //DNS解析开始
    int result = origin_getaddrinfo(a,b,c,d);
    //DNS解析结束
    return result;
}



//ios9.3 以后
static DNSServiceErrorType(*orig_DNSServiceGetAddrInfo)(DNSServiceRef *,DNSServiceFlags,uint32_t,DNSServiceProtocol,const char *,DNSServiceGetAddrInfoReply,void *);

static void ABCDE(DNSServiceRef sdRef,
           DNSServiceFlags flags,
           uint32_t interfaceIndex,
           DNSServiceErrorType errorCode,
           const char                       *hostname,
           const struct sockaddr            *address,
           uint32_t ttl,
           void *context){
    if(context){
        id con = (__bridge id)(context);
        AddrInfoReply  *reply = objc_getAssociatedObject(con, "AddrInfoReply");
        if(reply->info){
            ((DNSServiceGetAddrInfoReply)(reply->info))(sdRef,flags,interfaceIndex,errorCode,hostname,address,ttl,context);
        }
    }
    //DNS 解析结束
}
DNSServiceErrorType my_DNSServiceGetAddrInfo(DNSServiceRef *sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceProtocol protocol, const char *hostname, DNSServiceGetAddrInfoReply callBack, void *context){
//    RRTask *task = [[RRNetWorkManager shareWorkManager] currentTask];
    //还在想办法解决   RRTask 和  该 DNS 的对应关系
    
    //DNS 解析开始
    if(context){
        id con = (__bridge id)(context);
        AddrInfoReply  *reply = [[AddrInfoReply alloc]init];
        reply->info =  callBack;
        objc_setAssociatedObject(con, "AddrInfoReply", reply, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return orig_DNSServiceGetAddrInfo(sdRef,flags,interfaceIndex,protocol,hostname,ABCDE,context);;
    }
    return orig_DNSServiceGetAddrInfo(sdRef,flags,interfaceIndex,protocol,hostname,callBack,context);;
    
}


@implementation RRDNS

+(void)rebind{
    if(iOS9_3){
        static dispatch_once_t rebind;
        dispatch_once(&rebind, ^{
            void *lib = dlopen("/usr/lib/system/libsystem_dnssd.dylib", RTLD_NOW);
            orig_DNSServiceGetAddrInfo = dlsym(lib, "DNSServiceGetAddrInfo");
            rebind_symbols((struct rebinding[1]){
                {"DNSServiceGetAddrInfo",my_DNSServiceGetAddrInfo},
                
            }, 1);
            dlclose(lib);
        });
    }else{
//        void *lib = dlopen("/usr/lib/system/libsystem_sim_info.dylib", RTLD_NOW);
        origin_getaddrinfo = dlsym(RTLD_DEFAULT, "getaddrinfo");
        rebind_symbols((struct rebinding[1]){
            {"getaddrinfo",my_getaddrinfo}
        }, 1);
//        dlclose(lib);
    }
}
@end

@implementation AddrInfoReply


@end
//void ABsCDE(DNSServiceRef sdRef,
//           DNSServiceFlags flags,
//           uint32_t interfaceIndex,
//           DNSServiceErrorType errorCode,
//           const char                       *hostname,
//           const struct sockaddr            *address,
//           uint32_t ttl,
//           void *context){
//    
//    char host[1024];
//    char serv[20];
//    getnameinfo(address, sizeof(address), host, sizeof(host), serv, sizeof(serv), NI_NUMERICHOST| NI_NUMERICSERV);
//    
//    NSString *ip = [NSString stringWithUTF8String:host];
//    int B =[[NSString stringWithUTF8String:serv] intValue];
//    NSLog(@"-%@-%d",ip,B);
//    //    (2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)
//        NSError *error;
//        NSRegularExpression *ex =  [NSRegularExpression regularExpressionWithPattern:@"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)" options:NSRegularExpressionCaseInsensitive error:&error];
//        if(error==nil){
//            NSRange range = [ex rangeOfFirstMatchInString:ip options:NSMatchingReportProgress range:NSMakeRange(0, ip.length)];
//            if(range.location != NSNotFound){
//                    NSLog(@"DNS end %f",CFAbsoluteTimeGetCurrent());
//            }
//    
//    
//    
//        }
//}
