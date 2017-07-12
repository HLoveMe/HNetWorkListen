//
//  HGMethod.h
//  ZZH_NSProxy
//
//  Created by 朱子豪 on 2016/11/28.
//  Copyright © 2016年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
typedef void(^BeforMethod)(NSArray *pars);
typedef void(^AfterMethod)();
@interface HGMethod : NSObject
//监听的sel
@property(nonatomic,assign)SEL asel;

@property(nonatomic,assign)BeforMethod before;

@property(nonatomic,assign)AfterMethod after;

@property(nonatomic,strong)NSMutableArray *blocks;
//调用的参数
@property(nonatomic,assign)Method selfMethod;
//替换的IMP
@property(nonatomic,assign)IMP selfIMP;
//调用结果
@property(nonatomic,strong)id result;

@end
@interface HM:NSObject
@property(nonatomic,assign)BeforMethod before;
@property(nonatomic,assign)AfterMethod after;
@end
