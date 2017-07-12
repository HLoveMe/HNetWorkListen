//
//  HClassExtension.h
//
//  Created by 朱子豪 on 16/4/5.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HInvocation.h"
typedef NS_ENUM(NSInteger,PropertyType){
    //S---&
    TYPE_N,   //(nonatomic,assign)
    TYPE_NR,  //(nonatomic,assign,readonly)
    TYPE_NC,  //(nonatomic,copy)
    TYPE_NCR, //(nonatomic,copy,readonly)
    TYPE_NS,  //(nonatomic,strong)
    TYPE_NSR, //(nonatomic,strong,readonly)
    TYPE_NW   //(nonatomic,weak)
};
@interface HMessage: NSObject
@end
/**
 *  用于动态创建方法 属性 交换方法实现等等
 *  创建的方法有两种调用方式 （1:执行方法选择器  2:执行HInvocation）
 *
 *#pragma clang diagnostic push
 *#pragma clang diagnostic ignored "-Wundeclared-selector"
 *     去除方法选择器警告
 *#pragma clang diagnostic pop
 */
@interface HClassExtension : NSObject
/**
 *  runtime增加实例方法 无附加参数
 *
 *  @param target    target
 *  @param aSel      SEL
 *  @param implement IMP(c语言函数名(最少有两个参数))
    void xxx(id  a, SEL b,  id dic){
        NSLog(@"%@",dic);
    }
 */
+(HInvocation *)classAddInstanceMethod:(Class)targetClazz  sel:(SEL)aSel imp:(IMP)implement;
/**
 *   runtime增加实例方法 无附加参数 *
 *  @param target target
 *  @param aSel   aSel
 *  @param block  IMP
 */

+(HInvocation *)classAddInstanceMethod:(Class)targetClazz  sel:(SEL)aSel blockImp:(void(^)(id _self,SEL __cmd))block;
/**
 *  runtime增加实例方法 无附加参数  有返回值
 *  getReturnValue 得到返回值 or performSelector 得到返回值
 *  @param targetClazz
 *  @param aSel
 *  @param block
 *  @return
 */
+(HInvocation *)classAddInstanceMethod:(Class)targetClazz  sel:(SEL)aSel impWithReturnResult:(id(^)(id _self,SEL __cmd))block;
/**
 *  runtime增加新的方法   一个参数
 *
 *  @param target
 *  @param aSel
 *  @param implement
 *  @param info  传递给方法的参数
 *
 *  @return
 */
+(HInvocation *)classAddInstanceMethod:(Class)target  sel:(SEL)aSel impWithObject:(IMP)implement;
/**
 *  runtime增加新的方法   一个参数
 *
 *  @param target
 *  @param aSel
 *  @param block
 *
 *  @return
 */
+(HInvocation *)classAddInstanceMethod:(Class)targetClazz  sel:(SEL)aSel blockImpWithObject:(void(^)(id _self,id info))block;
/**
 *  runtime增加新的方法   一个参数 一个返回值
 *
 *  @param targetClazz
 *  @param aSel
 *  @param block
 *
 *  @return
 */
+(HInvocation *)classAddInstanceMethod:(Class)targetClazz  sel:(SEL)aSel blockImpWithResult:(id(^)(id _self,id info))block;
/**
 *  交换方法的实现(内部保证交换一次) 子类和父类的交换 以便在默认实现之下
    方便外部调用原有方法(增加自己的逻辑)
 
    对某个类的两个方法IMP进行交换
 
 *  @param clazz
 *  @param one
 *  @param other
 HTableView:UITableView{
    +(void)load{
        //保证只交换一次
        [[HClassExtension classExchangeInstanceMethodIMP:UITableView.class  oneMethod:@selector(reloadData) otherClazz:HTableView.class otherMethod:@selector(_reloadData)];
    }
    -(void)_reloadData{
        //增加自己的逻辑
        [self _reloadData];
    }
 }
 */
+(void)classExchangeInstanceMethodIMP:(Class)oneClazz oneMethod:(SEL)one  otherMethod:(SEL)other;
/**
 *  往目标中增加属性  默认增加设置器方法 （setProperty: and property）
 *
 *  @param target   目标
 *  @param property 属性类型   “UIView” "UItableViewDelegate"
 *  @param type
 *  @param name  属性名
 *  @return
 */
+(BOOL)classAddProperty:(Class)target proType:(NSString *)property type:(PropertyType)type propertyName:(NSString *)name;

@end




