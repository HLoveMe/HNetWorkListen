//
//  HClassDocument.h
//
//  Created by 朱子豪 on 16/3/24.
//  Copyright © 2016年 Space. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
@interface HClassDocument : NSObject
/**
 *  打印属性
 *
 *  @param clazz
 *  @param hasSuper  是否包含父类
 */
+(void)scanProperty:(Class)clazz _super:(BOOL)hasSuper;
/**
 *  打印实例方法 参数  只能得到  id Clazz SEL int double long float BOOL 这几个类型
 *
 *  @param clazz
 *  @param hasSuper 是否包含子类
 */
+(void)scanInstanceMethod:(Class)clazz _super:(BOOL)hasSuper;
/**
 *  打印层级关系图
 *
 *  @param _superView
 *  @param frame      是否打印 Frame值
 */
+(NSString *)scanSubView:(UIView *)_superView frame:(BOOL)frame;







/**
 *  得到所有属性
 *
 *  @param clazz
 *  @param hasSuper
 *  @param option   回调
 */
+(void)scanProperty:(Class)clazz _super:(BOOL)hasSuper option:(void(^)(NSDictionary<NSString *,NSArray<NSString *>*>*dictionary))option;
/**
 *  得到实例方法
 *
 *  @param clazz
 *  @param hasSuper
 *  @param option
 */
+(void)scanInstanceMethod:(Class)clazz _super:(BOOL)hasSuper option:(void(^)(NSDictionary<NSString *,NSArray<NSString/**SEL*/ *>*>*dictionary))option;
@end
