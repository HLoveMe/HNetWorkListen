//
//  TargetProxy.h
//  01
//
//  Created by 朱子豪 on 2017/7/4.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TargetProxy : NSProxy
-(id)initWithTarget:(id)target;
@end
