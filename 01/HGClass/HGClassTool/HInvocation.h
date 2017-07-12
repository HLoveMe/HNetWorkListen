//
//  HInvocation.h
//  runtime2
//
//  Created by 朱子豪 on 16/4/5.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface HInvocation : NSObject
@property(nonatomic,strong)NSInvocation *invocation;
@property (readonly, retain) NSMethodSignature *methodSignature;
@property (readonly) BOOL argumentsRetained;
@property (nullable, assign) id target;
@property SEL selector;
+(instancetype)invocation:(NSInvocation *)invocation;

- (void)getReturnValue:(void *)retLoc;
- (void)setReturnValue:(void *)retLoc;
- (void)getArgument:(void *)argumentLocation atIndex:(NSInteger)idx;
- (void)setArgument:(void *)argumentLocation atIndex:(NSInteger)idx;

-(void)invokeWithTarget:(id)targer  Object:(id)obj;
- (void)invokeWithTarget:(id)target;
@end
