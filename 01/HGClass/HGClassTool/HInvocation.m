//
//  HInvocation.m
//  runtime2
//
//  Created by 朱子豪 on 16/4/5.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "HInvocation.h"

@implementation HInvocation
-(NSMethodSignature *)methodSignature{
    return self.invocation.methodSignature;
}
-(BOOL)argumentsRetained{
    return self.invocation.argumentsRetained;
}
-(void)setTarget:(id)target{
    self.invocation.target = target;
}
-(id)target{
    return self.invocation.target;
}
-(void)setSelector:(SEL)selector{
    self.invocation.selector = selector;
}
-(SEL)selector{
    return self.invocation.selector;
}
- (void)getReturnValue:(void *)retLoc{
    if (self.methodSignature.methodReturnLength)
        [self.invocation getReturnValue:retLoc];
}
- (void)setReturnValue:(void *)retLoc{
    [self.invocation setReturnValue:retLoc];
}
- (void)getArgument:(void *)argumentLocation atIndex:(NSInteger)idx{
    [self.invocation getArgument:argumentLocation atIndex:idx];
}
- (void)setArgument:(void *)argumentLocation atIndex:(NSInteger)idx{
    [self.invocation setArgument:argumentLocation atIndex:idx];
}
-(void)invokeWithTarget:(id)target  Object:(id)obj{
    [self.invocation setArgument:&obj atIndex:2];
    [self invokeWithTarget:target];
}
- (void)invokeWithTarget:(id)target{
    [self.invocation invokeWithTarget:target];
}
+(instancetype)invocation:(NSInvocation *)invocation{
    HInvocation *invo = [[HInvocation alloc]init];
    invo.invocation = invocation;
    return invo;
}
@end
