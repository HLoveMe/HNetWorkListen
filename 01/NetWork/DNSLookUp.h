//
//  NetWorkManager.h
//  01
//
//  Created by 朱子豪 on 2017/7/10.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fishhook.h"
#include <sys/socket.h>
#include <netdb.h>
#include <dns_sd.h>
@interface DNSLookUp : NSObject
+(void)rebind;
@end

@interface AddrInfoReply : NSObject{
@public
    DNSServiceGetAddrInfoReply info;
}
@property(nonatomic,strong)id context;
@end
