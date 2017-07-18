//
//  NetWorkControl.m
//  01
//
//  Created by space on 2017/7/17.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "NetWorkControl.h"
#import "RRDNS.h"
#import "NSURLSession+Aop.h"
#import "NSURLConnection+Aop.h"
#import "NSURLSessionTask+Aop.h"
@implementation NetWorkControl
+(void)start{
    [RRDNS rebind];
    [NSURLSession rebind];
    [NSURLSessionTask rebind];
    [NSURLConnection rebind];
}
@end
