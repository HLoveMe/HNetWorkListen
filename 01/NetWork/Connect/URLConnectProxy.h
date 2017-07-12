//
//  URLConnectProxy.h
//  01
//
//  Created by 朱子豪 on 2017/7/3.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RRTask;
@interface URLConnectProxy : NSProxy
@property(nonatomic,weak)RRTask *task;
-(instancetype)initOrigin:(id)delegate;
@end
