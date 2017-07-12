//
//  NSObject+Proxy.m
//  ZZH_NSProxy
//
//  Created by 朱子豪 on 2016/11/28.
//  Copyright © 2016年 Space. All rights reserved.
//

#import "NSObject+Proxy.h"
#import "HGProperty.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

/**
 1:如何实现方法监听

 缺点: 对需要监听的方法 参数必须为对象（int BOOL 不被容许）
 
 2:实现属性监听
 对需要监听属性的set方法掉包 监听
 
 缺点:对类目里面的计算属性 无法监听
 */


#define HMETHOD(count) METHOD##count

@implementation NSObject (Proxy)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)set_pro:(id)value{
    [self set_pro:value];
    NSString *name = [self propertyNameScanFromSetterSelector:_cmd];
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGProperty *proper = dic[name];
    if(proper.blocks.count>=1){
        for(HP *hp in proper.blocks){
            hp.block(self);
        }
    }else{
        if([proper.target respondsToSelector:@selector(changeTarget:)]){
            [proper.target performSelector:@selector(changeTarget:) withObject:self];
        }
    }
}
-(void)set_proN:(double)value{
    [self set_proN:value];
    NSString *name = [self propertyNameScanFromSetterSelector:_cmd];
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGProperty *proper = dic[name];
    if(proper.blocks.count>=1){
        for(HP *hp in proper.blocks){
            hp.block(self);
        }
    }else{
        if([proper.target respondsToSelector:@selector(changeTarget:)]){
            [proper.target performSelector:@selector(changeTarget:) withObject:self];
        }
    }
    
}
#pragma clang diagnostic pop

-(void)startPropertyListen:(id)target proName:(NSString *)name{
    //    HGProxy *proxy = [[HGProxy alloc]init:self listener:target proName:name];
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    if(!dic){
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self,"HG_Proxy", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    HGProperty *proper = dic[name];
    if(!proper){
        proper = [[HGProperty alloc]init];
        dic[name]= proper;
        
        proper.name = name;
        proper.target = target;
        
        objc_property_t pro = class_getProperty(self.class, [name cStringUsingEncoding:4]);
        
        NSString *atr = [[NSString alloc]initWithUTF8String:property_getAttributes(pro)];
        NSString *proOne = [[atr componentsSeparatedByString:@","] firstObject];
        
        NSString *selStr=[[NSString alloc]initWithFormat:@"set%@:",[name capitalizedString]];
        SEL change;
        if([proOne containsString:@"@"]){
            change = @selector(set_pro:);
        }else{
            change = @selector(set_proN:);
        }
        SEL asel = NSSelectorFromString(selStr);
        method_exchangeImplementations(class_getInstanceMethod(self.class, asel),class_getInstanceMethod(self.class,change));
        proper.asel=asel;
        proper.bsel = change;
    }
    
    
}


-(void)startPropertyListenProName:(NSString *)name withChange:(ChangeBlock) block{
    [self startPropertyListen:nil proName:name];
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGProperty *proper = dic[name];
    HP *hp=[HP new];
    hp.block=block;
    [proper.blocks addObject:hp];
}
-(void)endPropertyListen:(NSString *)name{
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGProperty *proper = dic[name];
    method_exchangeImplementations(class_getInstanceMethod(self.class, proper.asel),class_getInstanceMethod(self.class,proper.bsel));
}


-(void)startMethodListen:(SEL)sel befor:(BeforMethod)befor after:(AfterMethod)after{
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    if(!dic){
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self,"HG_Proxy", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    Method one = class_getInstanceMethod(self.class, sel);
    NSString *methStr = NSStringFromSelector(sel);
    NSArray *arr = [methStr componentsSeparatedByString:@":"];
    
    IMP aimp = [NSObject getIMPWithIndex:(int)arr.count-1];
    
    IMP source = method_setImplementation(one,aimp);
    HGMethod *method = dic[NSStringFromSelector(sel)];
    
    if(!method){
        method = [[HGMethod alloc]init];
        method.selfMethod = one;
        method.selfIMP = source;
        method.asel = sel;
        dic[NSStringFromSelector(sel)]=method;
    }
    
    HM *hm = [[HM alloc]init];
    hm.before=befor;
    hm.after=after;
    [method.blocks addObject:hm];
    
}
-(void)endMethodListen:(SEL)sel{
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    NSString *key = NSStringFromSelector(sel);
    HGMethod *method = dic[key];
    method_setImplementation(method.selfMethod, method.selfIMP);
    [dic removeObjectForKey:key];
    
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (NSString *)propertyNameScanFromSetterSelector:(SEL)selector
{
    NSString *selectorName = NSStringFromSelector(selector);
    NSUInteger parameterCount = [[selectorName componentsSeparatedByString:@":"] count] - 1;
    if ([selectorName hasPrefix:@"set"] && parameterCount == 1) {
        NSUInteger firstColonLocation = [selectorName rangeOfString:@":"].location;
        return [selectorName substringWithRange:NSMakeRange(3, firstColonLocation - 3)].lowercaseString;
    }
    return nil;
}

id METHOD(id self,SEL _cmd){
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGMethod *method = dic[NSStringFromSelector(_cmd)];
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.before){
                value.before(@[]);
            }
        }
    }
    id (*me)(id, SEL)  =((id (*)(id, SEL))method.selfIMP);
    id res;
    @try {
        res = me(self,_cmd);
    } @catch (NSException *exception) {
        
    }
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.after){
                value.after();
            }
        }
    }
    return res;
}

id METHOD1(id self,SEL _cmd,id par){
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGMethod *method = dic[NSStringFromSelector(_cmd)];
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.before){
                value.before(@[par]);
            }
        }
    }
    id (*me)(id, SEL,id)  =((id (*)(id, SEL,id))method.selfIMP);
    id res;
    @try {
        res = me(self,_cmd,par);
    } @catch (NSException *exception) {
        
    }
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.after){
                value.after();
            }
        }
    }
    return res;
}
id METHOD2(id self,SEL _cmd,id par1,id par2){
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGMethod *method = dic[NSStringFromSelector(_cmd)];
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.before){
                value.before(@[par1,par2]);
            }
        }
    }
    id (*me)(id, SEL,id,id)  =((id (*)(id, SEL,id,id))method.selfIMP);
    id res;
    @try {
        res = me(self,_cmd,par1,par2);
    } @catch (NSException *exception) {
        
    }
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.after){
                value.after();
            }
        }
    }
    return res;
}
id METHOD3(id self,SEL _cmd,id par1,id par2,id par3){
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGMethod *method = dic[NSStringFromSelector(_cmd)];
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.before){
                value.before(@[par1,par2,par3]);
            }
        }
    }
    id (*me)(id, SEL,id,id,id)  =((id (*)(id, SEL,id,id,id))method.selfIMP);
    id res;
    @try {
        res = me(self,_cmd,par1,par2,par3);
    } @catch (NSException *exception) {
        
    }
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.after){
                value.after();
            }
        }
    }
    return res;
}
id METHOD4(id self,SEL _cmd,id par1,id par2,id par3,id par4){
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGMethod *method = dic[NSStringFromSelector(_cmd)];
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.before){
                value.before(@[par1,par2,par3,par4]);
            }
        }
    }
    id (*me)(id, SEL,id,id,id,id)  =((id (*)(id, SEL,id,id,id,id))method.selfIMP);
    id res;
    @try {
        res = me(self,_cmd,par1,par2,par3,par4);
    } @catch (NSException *exception) {
        
    }
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.after){
                value.after();
            }
        }
    }
    return res;
}
id METHOD5(id self,SEL _cmd,id par1,id par2,id par3,id par4,id par5){
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGMethod *method = dic[NSStringFromSelector(_cmd)];
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.before){
                value.before(@[par1,par2,par3,par4,par5]);
            }
        }
    }
    id (*me)(id, SEL,id,id,id,id,id)  =((id (*)(id, SEL,id,id,id,id,id))method.selfIMP);
    id res;
    @try {
        res = me(self,_cmd,par1,par2,par3,par4,par5);
    } @catch (NSException *exception) {
        
    }
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.after){
                value.after();
            }
        }
    }
    return res;
}
id METHOD6(id self,SEL _cmd,id par1,id par2,id par3,id par4,id par5,id par6){
    NSMutableDictionary *dic = objc_getAssociatedObject(self,"HG_Proxy");
    HGMethod *method = dic[NSStringFromSelector(_cmd)];
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.before){
                value.before(@[par1,par2,par3,par4,par5,par6]);
            }
        }
    }
    id (*me)(id, SEL,id,id,id,id,id,id)  =((id (*)(id, SEL,id,id,id,id,id,id))method.selfIMP);
    id res;
    @try {
        res = me(self,_cmd,par1,par2,par3,par4,par5,par6);
    } @catch (NSException *exception) {
        
    }
    if(method.blocks.count>=1){
        for( HM *value in method.blocks){
            if(value.after){
                value.after();
            }
        }
    }
    return res;
}

+(IMP)getIMPWithIndex:(int)count{
    switch (count) {
        case 0:
            return (IMP)METHOD;
        case 1:
            return (IMP)HMETHOD(1);
        case 2:
            return (IMP)HMETHOD(2);
        case 3:
            return (IMP)HMETHOD(3);
        case 4:
            return (IMP)HMETHOD(4);
        case 5:
            return (IMP)HMETHOD(5);
        case 6:
            return (IMP)HMETHOD(6);
        default:
            return  (IMP)METHOD;
    }
    return (IMP)METHOD;
}

@end

