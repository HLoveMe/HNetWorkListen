//
//  HClassExtension.m
//  Created by 朱子豪 on 16/4/5.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "HClassExtension.h"
#import  <objc/runtime.h>
#import "HInvocation.h"

@implementation HClassExtension



+(HInvocation *)classAddInstanceMethod:(Class)target  sel:(SEL)aSel imp:(IMP)implement{
    const char *type = "v@:";
    class_addMethod([target class], aSel, implement, type);
    NSMethodSignature *method = [NSMethodSignature signatureWithObjCTypes:type];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method];
    invocation.selector = aSel;
    return [HInvocation invocation:invocation];
}
+(HInvocation *)classAddInstanceMethod:(Class)target  sel:(SEL)aSel blockImp:(void(^)(id _self,SEL __cmd))block{
    if (block==nil) {return nil;}
    IMP imp = imp_implementationWithBlock(block);
    const char *type = "v@:";
    class_addMethod(target, aSel, imp, type);
    NSMethodSignature *method = [NSMethodSignature signatureWithObjCTypes:type];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method];
    invocation.selector = aSel;
    return [HInvocation invocation:invocation];
}
+(HInvocation *)classAddInstanceMethod:(Class)targetClazz  sel:(SEL)aSel impWithReturnResult:(id(^)(id _self,SEL __cmd))block{
    if (block==nil) {return nil;}
    IMP imp = imp_implementationWithBlock(block);
    const char *type = "@@:";
    class_addMethod(targetClazz, aSel, imp, type);
    NSMethodSignature *method = [NSMethodSignature signatureWithObjCTypes:type];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method];
    invocation.selector = aSel;
    return [HInvocation invocation:invocation];
}

+(HInvocation *)classAddInstanceMethod:(Class)target  sel:(SEL)aSel impWithObject:(IMP)implement{
    const char *type = "v@:@";
    class_addMethod(target, aSel, implement, type);
    NSMethodSignature *method = [NSMethodSignature signatureWithObjCTypes:type];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method];
    invocation.selector = aSel;
    HInvocation *hInvocation=[HInvocation invocation:invocation];
    return hInvocation;
}
+(HInvocation *)classAddInstanceMethod:(Class)target  sel:(SEL)aSel blockImpWithObject:(void(^)(id _self,id info))block{
    if (block==nil) {return nil;}
    IMP imp = imp_implementationWithBlock(block);
    const char *type = "@@:@";
    class_addMethod(target, aSel, imp, type);
    NSMethodSignature *method = [NSMethodSignature signatureWithObjCTypes:type];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method];
    invocation.selector = aSel;
    HInvocation *hInvocation = [HInvocation invocation:invocation];
    return hInvocation;
}
+(HInvocation *)classAddInstanceMethod:(Class)targetClazz  sel:(SEL)aSel blockImpWithResult:(id(^)(id _self,id info))block{
    if (block==nil) {return nil;}
    IMP imp = imp_implementationWithBlock(block);
    const char *type = "@@:@";
    class_addMethod(targetClazz, aSel, imp, type);
    NSMethodSignature *method = [NSMethodSignature signatureWithObjCTypes:type];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method];
    invocation.selector = aSel;
    HInvocation *hInvocation = [HInvocation invocation:invocation];
    return hInvocation;
}
+(void)classExchangeInstanceMethodIMP:(Class)oneClazz oneMethod:(SEL)one  otherMethod:(SEL)other{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oneMethod = class_getInstanceMethod(oneClazz, one);
        Method otherMethod = class_getInstanceMethod(oneClazz, other);
        method_exchangeImplementations(oneMethod, otherMethod);
    });
}
+(BOOL)classAddProperty:(Class)target proType:(NSString *)property type:(PropertyType)type propertyName:(NSString *)name{
    objc_property_t *pros = class_copyPropertyList([HMessage class], nil);
    objc_property_t pro  = pros[type];
    unsigned int  count;
    objc_property_attribute_t *atts = property_copyAttributeList(pro, &count);
    
    NSString *oneChar = [name substringToIndex:1];
    NSString *lastChar  = [name substringFromIndex:1];
    NSString *propertyName = [@"_" stringByAppendingFormat:@"%@%@",oneChar.uppercaseString,lastChar];
    atts[count-1].value = [propertyName cStringUsingEncoding:4];
    NSString *str;
    if (NSClassFromString(property)) {
        str = [NSString stringWithFormat:@"@\"%@\"",property];
    }else{
       str = [NSString stringWithFormat:@"@\"<%@>\"",property];
    }
    atts[0].value = [str cStringUsingEncoding:4];
    
    BOOL flag=class_addProperty(target, [name cStringUsingEncoding:4], atts, count);
    
    if (flag) {
        NSString *set = [@"set" stringByAppendingFormat:@"%@%@:",oneChar.uppercaseString,lastChar];
        [HClassExtension classAddInstanceMethod:target sel:NSSelectorFromString(set) blockImpWithObject:^(id _self, id info) {
            objc_setAssociatedObject(_self, (__bridge const void *)(name), info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];
        [HClassExtension classAddInstanceMethod:target sel:NSSelectorFromString(name) impWithReturnResult:^id(id _self, SEL __cmd) {
            return objc_getAssociatedObject(_self, (__bridge const void *)(name));
        }];
    }
    return flag;
}

@end

@interface HMessage()
@property(nonatomic,assign)int A;
@property(nonatomic,assign,readonly)int AA;
@property(nonatomic,copy)NSString *B;
@property(nonatomic,copy,readonly)NSString *BB;
@property(nonatomic,strong)NSArray *C;
@property(nonatomic,strong,readonly)NSArray *CC;
@property(nonatomic,weak)id<NSObject> D;
@end
@implementation HMessage
@end