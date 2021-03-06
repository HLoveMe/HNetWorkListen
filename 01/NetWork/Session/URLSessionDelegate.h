//
//  URLSessionDelegate.h
//  01
//
//  Created by 朱子豪 on 2017/7/5.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLSessionDelegate : NSObject<NSURLSessionDataDelegate>
@property(nonatomic,copy)void(^block)(NSData *,NSURLResponse*,NSError *);
-(instancetype)initWith:(id)origin;
@end
