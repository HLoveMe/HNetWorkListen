//
//  RRMessage.m
//  01
//
//  Created by 朱子豪 on 2017/7/10.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "RRMessage.h"
#import <objc/runtime.h>
#import "HClassDocument.h"
@implementation RRMessage
-(instancetype)init{
    if (self=[super init]) {
        self.status = [[RRNetWorkManager shareWorkManager] currentNetworkStatu];
        self.boby_send=0;
        self.data_size=0;
        self.dns_start=0;
        self.dns_end=0;
        self.finish = 0;
        self.receive_data_end=0;
        self.receive_data_first=0;
        self.receive_response=0;
        self.ssl_start=0;
    }
    return self;
}
-(BOOL)isEqual:(id)object{
    if([object isKindOfClass:[self class]]){
        return  [[(RRMessage *)object absUrl] isEqual:self.absUrl];
    }
    return NO;
}
-(NSString *)description{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    @autoreleasepool {
        unsigned int count ;
        Ivar *ivars = class_copyIvarList([self class], &count);
        for (int i=0; i<count; i++) {
            NSString *name = [[NSString alloc]initWithUTF8String:ivar_getName(ivars[i])];
            @try {
                id  value = [self valueForKey:name];
                if (value) {
                    dic[name]=value;
                }
            } @catch (NSException *exception) {
                
            }
        }
    }
    return dic;
}
@end

#ifdef __IPHONE_10_0
@implementation RRStrongMessage

-(instancetype)init{
    if(self = [super init]){
        self.request_head_end=0;
        self.request_head_start=0;
        self.ssl_end=0;
    }
    return self;
}
-(NSString *)description{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    @autoreleasepool {
        unsigned int count ;
        Ivar *ivars = class_copyIvarList([self class], &count);
        for (int i=0; i<count; i++) {
            NSString *name = [[NSString alloc]initWithUTF8String:ivar_getName(ivars[i])];
            @try {
                id  value = [self valueForKey:name];
                if (value) {
                    dic[name]=value;
                }
            } @catch (NSException *exception) {
                
            }
        }
    }
    return dic;
}
@end
#else
#endif
