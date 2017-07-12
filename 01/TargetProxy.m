//
//  TargetProxy.m
//  01
//
//  Created by 朱子豪 on 2017/7/4.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "TargetProxy.h"
@interface TargetProxy()
@property(nonatomic,strong)id target;
@end
static Class targetClass;
@implementation TargetProxy
-(id)initWithTarget:(id)target{
    self.target = target;
    targetClass = [target class];
//    NSLog(@"%p",self);
    return self;
}
-(BOOL)respondsToSelector:(SEL)aSelector{
    return [self.target respondsToSelector:aSelector];
}
+ (BOOL)respondsToSelector:(SEL)aSelector{
    return NO;
}
- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    NSLog(@"-:%@",NSStringFromSelector(sel));
    if([self.target respondsToSelector:sel]){
        return [self.target methodSignatureForSelector:sel];
    }
    
    return nil;
}
- (void)forwardInvocation:(NSInvocation *)invocation{
    NSLog(@"=:%@",NSStringFromSelector(invocation.selector));
    [invocation invokeWithTarget:self.target];
    
    
    NSLog(@"------");
}
@end
