//
//  RRTask.h
//  01
//
//  Created by 朱子豪 on 2017/7/10.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RRMessage ;
@interface RRTask : NSObject
//session
@property(nonatomic,weak)NSURLSession  *session;
@property(nonatomic,weak)NSURLSessionTask  *task;

//connect
@property(nonatomic,weak)NSURLConnection  *connect;

@property(nonatomic,weak)NSThread  *thread;
@property(nonatomic,strong)RRMessage *msg;
@end
