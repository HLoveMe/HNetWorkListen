//
//  RRTask.m
//  01
//
//  Created by 朱子豪 on 2017/7/10.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "RRTask.h"
#import "RRMessage.h"
@implementation RRTask
-(BOOL)isEqual:(id)object{
    if([object isKindOfClass:[NSURLSessionTask class]]){
        return [self.task isEqual:object];
    }
    return NO;
}
@end
