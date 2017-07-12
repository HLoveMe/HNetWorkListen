//
//  Student.m
//  01
//
//  Created by 朱子豪 on 2017/7/5.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "Student.h"
@interface Student()
@property(nonatomic,strong)NSString *AAA;
@end
@implementation Student
-(instancetype)init{
    if(self = [super init]){
        self.AAA=@"zm";
    }
    return self;
}
-(NSString *)dothing:(NSString *)con{
    return [NSString stringWithFormat:@"%@-%@",con,@"呵呵"];
}
@end
