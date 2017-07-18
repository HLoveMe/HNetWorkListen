//
//  CFNetClient.h
//  01
//
//  Created by 朱子豪 on 2017/7/13.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RRHeader.h"
@class InputStreamProxy;
@interface CFNetClient : NSObject{
@public
    CFReadStreamClientCallBack call;
    void * target;
}
@property(nonatomic,weak)RRTask *task;
@property(nonatomic,weak)RRMessage *message;
@property(nonatomic,weak)InputStreamProxy *stream;
@property(nonatomic,assign)CFOptionFlags flags;
-(CFReadStreamClientCallBack)CallBack;
@end
