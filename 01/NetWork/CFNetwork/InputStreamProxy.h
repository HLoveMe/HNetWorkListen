//
//  InputStreamProxy.h
//  01
//
//  Created by 朱子豪 on 2017/7/12.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFNetClient.h"
@interface InputStreamProxy : NSObject
@property(nonatomic,strong)id stream;
@property(nonatomic,strong)CFNetClient *client;
@end


@interface InputManager : NSObject
+(instancetype)ShareManager;
-(InputStreamProxy *)proxy;
@end
