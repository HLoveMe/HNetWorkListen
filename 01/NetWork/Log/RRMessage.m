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
    if ([super init]) {
        self.status = [[RRNetWorkManager shareWorkManager] currentNetworkStatu];
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
    unsigned int count ;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i=0; i<count; i++) {
        NSString *name = [[NSString alloc]initWithUTF8String:ivar_getName(ivars[i])];
        id  value = [self valueForKey:name];
        if (value) {
            dic[name]=value;
        }
    }
    NSLog(@"%@",dic);
    return @"";
}
@end

#ifdef __IPHONE_10_0
@implementation RRStrongMessage
-(NSString *)description{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [HClassDocument scanProperty:[self class] _super:YES option:^(NSDictionary *dictionary) {
        for(NSString *key in dictionary){
            NSArray<NSArray *> *one =dictionary[key];
            for (int i=0; i<one.count; i++) {
                NSString * aa = one[i].firstObject;
                id value = [self valueForKey:aa];
                dic[aa]=value;
            }
        }
    }];
    NSLog(@"%@",dic);
    return @"";
}
@end
#else
#endif
