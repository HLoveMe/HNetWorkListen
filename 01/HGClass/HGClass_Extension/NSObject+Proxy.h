//
//  NSObject+Proxy.h
//  ZZH_NSProxy
//
//  Created by 朱子豪 on 2016/11/28.
//  Copyright © 2016年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGMethod.h"
#import "HGProperty.h"
/**
 1:如何实现方法监听

 缺点: 对需要监听的方法 参数必须为对象（int BOOL 不被容许）
 
 2:实现属性监听
 对需要监听属性的set方法掉包 监听
 
 缺点:对类目里面的计算属性 无法监听
 */
@interface NSObject (Proxy)
//监听方法调用
//所有参数都必须是对象
-(void)startMethodListen:(SEL)sel befor:(BeforMethod)befor after:(AfterMethod)after;
//结束方法监听
-(void)endMethodListen:(SEL)sel;

//调用者 需要监听者   target 谁监听该属性   属性名
// model:{name:,age:}
//  [model startPropertyListen:self proName:@"age"];
//调用 -(void)changeTarget:(id)listen;
//-(void)startPropertyListen:(id)target proName:(NSString *)name;
-(void)startPropertyListenProName:(NSString *)name withChange:(ChangeBlock) block;

-(void)endPropertyListen:(NSString *)name;
@end

