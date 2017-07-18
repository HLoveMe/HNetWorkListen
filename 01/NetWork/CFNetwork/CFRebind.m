//
//  CFRebind.m
//  01
//
//  Created by 朱子豪 on 2017/7/13.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "CFRebind.h"
#include <dlfcn.h>
#include "fishhook.h"
#import "InputStreamProxy.h"
#import <objc/runtime.h>
#import "RRHeader.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@implementation CFRebind
//创建连接
static CFReadStreamRef (*original_CFReadStreamCreateForHTTPRequest)(CFAllocatorRef __nullable alloc,
                                                                    CFHTTPMessageRef request);
CFReadStreamRef my_CFReadStreamCreateForHTTPRequest(CFAllocatorRef __nullable alloc, CFHTTPMessageRef request){
    CFReadStreamRef originalCFStream = original_CFReadStreamCreateForHTTPRequest(alloc, request);
    NSInputStream *stream = (__bridge NSInputStream *)originalCFStream;
    InputStreamProxy *prostream = [[InputManager ShareManager] proxy];
    prostream.stream = stream;
    CFRelease(originalCFStream);
    CFReadStreamRef result = (__bridge_retained CFReadStreamRef)prostream;
    return result;
}
Boolean (* origin_CFReadStreamSetClient)(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext);
Boolean my_CFReadStreamSetClient(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext){
    id _stream = (__bridge id)(stream);
    NSString *classname = [NSString stringWithFormat:@"%@",_stream];
    if([classname containsString:@"InputStreamProxy"]){
        InputStreamProxy *proxy = (InputStreamProxy *)_stream;
        CFNetClient *client = proxy.client;
        client.flags = streamEvents;
        client->target = (*clientContext).info;
        client->call = clientCB;
        //掉包
        CFStreamClientContext _tempContext = {(*clientContext).version,(__bridge void  *)(client),(*clientContext).retain,(*clientContext).release,(*clientContext).copyDescription};
        CFStreamClientContext *tempContext = &_tempContext;
        return origin_CFReadStreamSetClient(stream,31,[client CallBack],tempContext);
        
    }else{
        return origin_CFReadStreamSetClient(stream,streamEvents,clientCB,clientContext);
    }
    
}

+(void)load{;
    static dispatch_once_t cf;
    dispatch_once(&cf, ^{
        
        original_CFReadStreamCreateForHTTPRequest = dlsym(RTLD_DEFAULT, "CFReadStreamCreateForHTTPRequest");
        origin_CFReadStreamSetClient = dlsym(RTLD_DEFAULT, "CFReadStreamSetClient");
        rebind_symbols((struct rebinding[2]){
            {
                "CFReadStreamCreateForHTTPRequest", my_CFReadStreamCreateForHTTPRequest
            },{
                "CFReadStreamSetClient",
                my_CFReadStreamSetClient
            }
        },2);
    });
}
@end
