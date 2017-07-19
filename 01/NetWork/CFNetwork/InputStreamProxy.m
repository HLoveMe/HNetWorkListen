//
//  InputStreamProxy.m
//  01
//
//  Created by 朱子豪 on 2017/7/12.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "InputStreamProxy.h"

@interface InputStreamProxy()
//流
@property(nonatomic,assign)BOOL isclose;
@end

@implementation InputStreamProxy
-(void)setStream:(id)stream{
    _stream = stream;
    _client = [[CFNetClient alloc]init];
    _client.stream=self;
}
-(BOOL)respondsToSelector:(SEL)aSelector{
    return [self.stream respondsToSelector:aSelector];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [_stream methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    //泄露
    @autoreleasepool {
        [anInvocation invokeWithTarget:_stream];
    }
    NSString *name = NSStringFromSelector(anInvocation.selector);
    if(self.isclose){
        self.client=nil;
        self.stream=nil;
    }
    if([name isEqualToString:@"close"] || [name isEqualToString:@"_unscheduleFromCFRunLoop:forMode:"]){
        self.isclose=YES;
    }
}
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len{
    NSInteger readSize = [_stream read:buffer maxLength:len];
    self.client.message.data_size += readSize;
    return readSize;
}

@end
@interface InputManager()
@property(nonatomic,strong)NSMutableArray<InputStreamProxy *> *proxys;
@end
@implementation InputManager
static id inputsingle;
+(instancetype)ShareManager{
    if(nil==inputsingle){
        inputsingle = [[InputManager alloc]init];
    }
    return inputsingle;
}
-(NSMutableArray<InputStreamProxy *> *)proxys{
    if(nil==_proxys){
        _proxys = [NSMutableArray array];
    }
    return _proxys;
}
-(InputStreamProxy *)proxy{
    __block InputStreamProxy *pr ;
    [self .proxys enumerateObjectsUsingBlock:^(InputStreamProxy * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.client == nil){
            pr = obj;
            *stop=YES;
        }
    }];
    if(nil==pr){
        pr = [[InputStreamProxy alloc]init];
        [self.proxys addObject:pr];
    }
    return pr;
}
@end

