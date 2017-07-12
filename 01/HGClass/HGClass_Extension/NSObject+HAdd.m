//
//  NSObject+HAdd.m
//  HClass(OC)
//
//  Created by 朱子豪 on 16/7/23.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "NSObject+HAdd.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
@implementation NSObject (HAdd)

-(id)performSelectorWithPars:(SEL)aSelector,...{
    NSMethodSignature *signa = [self methodSignatureForSelector:aSelector];
    if (!signa) {return nil;}
    NSInvocation *invocation =[NSInvocation invocationWithMethodSignature:signa];
    NSUInteger count = signa.numberOfArguments;
    va_list args;
    va_start(args, aSelector);
    BOOL unsupportedType=NO;
    for (int i=2; i<count; i++) {
        const char *type = [signa getArgumentTypeAtIndex:i];
        switch (*type) {
            case 'c':{
                char *value = va_arg( args, char);
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case 'C':{
                unsigned char *value = va_arg(args, unsigned char);
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case 's':{
                short value =va_arg(args, short);
                [invocation setArgument:&value atIndex:i];

                break;
            }
            case 'S':{
                unsigned short value =va_arg(args,unsigned short);
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case 'i':{
                int value = va_arg( args, int);
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case 'I':{
                unsigned int value =va_arg(args,unsigned int);
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case 'q':{
                long long value =va_arg(args,long long );
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case 'Q':{
                unsigned long long value =va_arg(args,unsigned long long );
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case 'f':{
                float value = va_arg( args, float);
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case 'd':{
                double value = va_arg( args, double);
                [invocation setArgument:&value atIndex:i];
                break;
            }
                
            case 'D':{
                long double value =va_arg(args,long double );
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case ':':{
                 SEL value =va_arg(args,SEL );
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case '@':{
                id value =va_arg(args,id );
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case '#':{
                Class value =va_arg(args,Class);
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case '{':{
                if (strcmp(type, @encode(CGPoint)) == 0) {
                    CGPoint arg = va_arg(args, CGPoint);
                    [invocation setArgument:&arg atIndex:i];
                } else if (strcmp(type, @encode(CGSize)) == 0) {
                    CGSize arg = va_arg(args, CGSize);
                    [invocation setArgument:&arg atIndex:i];
                } else if (strcmp(type, @encode(CGRect)) == 0) {
                    CGRect arg = va_arg(args, CGRect);
                    [invocation setArgument:&arg atIndex:i];
                } else if (strcmp(type, @encode(CGVector)) == 0) {
                    CGVector arg = va_arg(args, CGVector);
                    [invocation setArgument:&arg atIndex:i];
                } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                    CGAffineTransform arg = va_arg(args, CGAffineTransform);
                    [invocation setArgument:&arg atIndex:i];
                } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                    CATransform3D arg = va_arg(args, CATransform3D);
                    [invocation setArgument:&arg atIndex:i];
                } else if (strcmp(type, @encode(NSRange)) == 0) {
                    NSRange arg = va_arg(args, NSRange);
                    [invocation setArgument:&arg atIndex:i];
                } else if (strcmp(type, @encode(UIOffset)) == 0) {
                    UIOffset arg = va_arg(args, UIOffset);
                    [invocation setArgument:&arg atIndex:i];
                } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                    UIEdgeInsets arg = va_arg(args, UIEdgeInsets);
                    [invocation setArgument:&arg atIndex:i];
                } else {
                    unsupportedType = YES;
                }
                break;
            }
            default:{
                if (unsupportedType){
                    NSLog(@"not support");
                }
            }
        }
        
    }
    va_end(args);
    invocation.selector =aSelector;
    [invocation invokeWithTarget:self];
    NSString *ctype = [[NSString alloc]initWithUTF8String:[signa methodReturnType]];
    if([ctype hasPrefix:@"v"])return nil;
    id res;
    [invocation getReturnValue:&res];
    return res;
}
@end
