//
//  URLSessionProxy.h
//  01
//
//  Created by 朱子豪 on 2017/7/5.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"
@interface URLSessionProxy : NSProxy
//@property(nonatomic,weak)RRMessage *info;
@property(nonatomic,weak)RRTask *task;
@property(nonatomic,strong,readonly)id target;
-(id)initWithTarget:(id)target;
@end
