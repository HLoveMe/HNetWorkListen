
//
//  RRNetWorkManager.m
//  01
//
//  Created by 朱子豪 on 2017/7/10.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "RRNetWorkManager.h"
#import <UIKit/UIKit.h>
#import "RRHeader.h"
@interface RRNetWorkManager()
@property(nonatomic,strong)NSMutableArray *tasks;
@property(nonatomic,strong)UIView *stausV;
@property(nonatomic,copy)RRMBlock block;
@end
static id single;
@implementation RRNetWorkManager
-(NSMutableArray *)tasks{
    if (nil==_tasks) {
        _tasks = [NSMutableArray array];
    }
    return _tasks;
}
+(instancetype)shareWorkManager{
    if(single == nil){
        single = [[RRNetWorkManager alloc]init];
    }
    return single;
}

-(void)addTask:(RRTask *)msg{
    [self.tasks addObject:msg];
}

-(void)hasFinish:(RRTask *)task{
    //main
    [self.tasks removeObject:task];
    if(self.block){
        self.block(task.msg);
    }
   
}
-(RRTask *)currentTask{
    NSMutableArray *tas = [NSMutableArray array];
//    @synchronized (self) {
//        double current =  CFAbsoluteTimeGetCurrent();
//        [self.tasks enumerateObjectsUsingBlock:^(RRTask *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if(obj.msg.start!=0 && current>obj.msg.start && obj.msg.ssl_start == 0){
//                [tas addObject:obj];
//            }
//        }];
//    }
//    if(tas.count>1){
//    
//    }
    return tas.lastObject;
}

@end


@implementation RRNetWorkManager (netWork)

-(NetWorkStatues)currentNetworkStatu{
    static dispatch_once_t network;
    dispatch_once(&network, ^{
        NSArray *subviews = [[[[UIApplication sharedApplication] valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        for (id child in subviews) {
            //判断是否为状态栏网络图标
            if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                self.stausV = child;
                break;
            }
        }
    });
    //获取到状态栏码
    NetWorkStatues states=0;
    int networkType = [[self.stausV valueForKeyPath:@"dataNetworkType"] intValue];
    switch (networkType) {
        case 0:
            states = NetworkStatesNone;
            //无网模式
            break;
        case 1:
            states = NetworkStates2G;
            break;
        case 2:
            states = NetworkStates3G;
            break;
        case 3:
            states = NetworkStates4G;
            break;
        case 5:
        {
            states = NetworkStatesWIFI;
            break;
        }
        default:break;
    }
    
    return states;
}

@end

@implementation RRNetWorkManager (log)
//该框架不做任何数据记录
-(void)LogHandleBlock:(RRMBlock)block{
    self.block = block;
}
@end
