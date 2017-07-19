//
//  CFNetClient.m
//  01
//
//  Created by 朱子豪 on 2017/7/13.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "CFNetClient.h"

@interface CFNetClient()
@end
@implementation CFNetClient
static bool  EventContain(CFStreamEventType type , CFStreamEventType events){
    int _events = events;
    for (int i = 4; _events>=0; i--) {
        int res = pow(2, i);
        if(_events>=res && type==res){
            return YES;
        }
        _events=_events-res;
        if(_events==type){
            return YES;
        }
    }
    return NO;
}
static void MCFReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo){
    CFNetClient *client = (__bridge CFNetClient *)(clientCallBackInfo);
    
   if (type == kCFStreamEventHasBytesAvailable) {
        //收到数据
        if(client.message.receive_data_first == 0 ){
            client.message.receive_data_first = CFAbsoluteTimeGetCurrent()-client.message.start;
        }
       client.message.receive_data_end=CFAbsoluteTimeGetCurrent()-client.message.start;
       client.message.receive_data_count+=1;
    }else if (type == kCFStreamEventEndEncountered) {
        //完成
        client.message.finish = CFAbsoluteTimeGetCurrent()-client.message.start;
        client.message.success=YES;
        client.message.start=0;
        
        [[RRNetWorkManager shareWorkManager] hasFinish:client.task];
    }else if(type == kCFStreamEventNone){
        
    }else if(type == kCFStreamEventOpenCompleted){
        
        CFHTTPMessageRef message = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPFinalRequest);
        
        CFURLRef url = CFHTTPMessageCopyRequestURL(message);
        CFStringRef method = CFHTTPMessageCopyRequestMethod(message);
        
        RRMessage *info = [[RRMessage alloc]init];
        info.date = [[NSDate date] timeIntervalSince1970];
        info.absUrl = [(__bridge NSURL *)(url) absoluteString];
        info.type = CFNetWork;
        info.method = (__bridge NSString *)(method);
        RRTask *ta = [RRTask new];
        ta.msg = info;
        [[RRNetWorkManager shareWorkManager] addTask:ta];
        client.message = info;
        client.task = ta;
        
        info.start = CFAbsoluteTimeGetCurrent();
        
    }else if(type == kCFStreamEventCanAcceptBytes){
        
        
    }else if(type==kCFStreamEventErrorOccurred){
        //失败
        client.message.finish=CFAbsoluteTimeGetCurrent()-client.message.start;
        client.message.success=NO;
        client.message.start=0;
        [[RRNetWorkManager shareWorkManager] hasFinish:client.task];
    }
    //消息转发
    if(EventContain(type,client.flags)){
        /**
         kCFStreamEventOpenCompleted = 1,
         kCFStreamEventHasBytesAvailable = 2,
         kCFStreamEventCanAcceptBytes = 4,
         kCFStreamEventErrorOccurred = 8,
         kCFStreamEventEndEncountered = 16
         
         
         */
        (client->call)((__bridge CFReadStreamRef)(client.stream),type,client->target);
    }
    
}

-(CFReadStreamClientCallBack)CallBack{
    return MCFReadStreamClientCallBack;
}

@end
