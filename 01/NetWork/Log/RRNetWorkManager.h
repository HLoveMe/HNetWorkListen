//
//  RRNetWorkManager.h
//  01
//
//  Created by 朱子豪 on 2017/7/10.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NetworkStatesNone,// 0
    NetworkStates2G, //1
    NetworkStates3G, // 2
    NetworkStates4G, // 3
    NetworkStatesWIFI  // 4
}NetWorkStatues;


@class RRTask,RRMessage;
@interface RRNetWorkManager : NSObject
+(instancetype)shareWorkManager;
-(void)addTask:(RRTask *)task;
-(void)hasFinish:(RRTask *)task;

-(RRMessage *)currentTask;
@end

@interface RRNetWorkManager (netWork)
-(NetWorkStatues)currentNetworkStatu;
@end
