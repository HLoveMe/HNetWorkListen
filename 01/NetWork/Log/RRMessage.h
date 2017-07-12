//
//  RRMessage.h
//  01
//
//  Created by 朱子豪 on 2017/7/10.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    URLConnection = 0, // 使用NSURLConnect
    URLSession,   //NSURLSession
    CFNetWork    // CFNetWork
}NetWorkType;
#import "RRNetWorkManager.h"
@interface RRMessage : NSObject
/**
    > 属性start 就是开启时间  始终为 0
    > 所有 表示的时间的属性 都是相对于任务开始的时间
    > 除了start 其他都都不可能为0  除非没有得到该值 / 或者没有该属性值
 
 
 */

/**
    当前网络状态
 */
@property(nonatomic,assign)NetWorkStatues status;
/**
    请求创建的 时间
 */
@property(nonatomic,strong)NSDate *date;

/**
 请求的网址
 */
@property(nonatomic,copy)NSString *absUrl;

/**
    网络连接方式
 */
@property(nonatomic,assign)NetWorkType type;

/**
    请求方式 GET、POST、。。。
 */
@property(nonatomic,copy)NSString *method;
/**
    是否成功
 */
@property(nonatomic,assign)BOOL success;

/**
    是否为安全连接
 */
@property(nonatomic,assign)BOOL is_ssl;

/**
    开始时间  在统计接受后会至 0
 */
@property(nonatomic,assign)double start;


/**
 重定向次数
 */
@property(nonatomic,assign)int redirect_count;

/**
 DNS 开始解析 时间
 */
@property(nonatomic,assign)double dns_start;


/**
 DNS 解析完成 时间
 */
@property(nonatomic,assign)double dns_end;


/**
    开始SSL 验证 时间  https
 */
@property(nonatomic,assign)double SSL;

/**
    开始发送请求体数据 时间
    POST
 */
@property(nonatomic,assign)double boby_send;

/**
    收到服务器响应 时间
 */
@property(nonatomic,assign)double receive_response;



/**
    第一次收到数据包 时间
 */
@property(nonatomic,assign)double receive_data;
/**
    收到数据包次数
 */
@property(nonatomic,assign)double receive_data_count;


/**
    数据包大小
 */
@property(nonatomic,assign)long data_size;


/**
    请求结束 时间
 */
@property(nonatomic,assign)double finish;

@end
