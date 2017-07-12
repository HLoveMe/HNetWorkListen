//
//  HGProperty.h
//  ZZH_NSProxy
//
//  Created by 朱子豪 on 2016/11/28.
//  Copyright © 2016年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^ChangeBlock)(id target);
@interface HGProperty : NSObject
@property(nonatomic,copy)NSString *name;
@property(nonatomic,weak)id target;
//@property(nonatomic,assign)ChangeBlock block;
@property(nonatomic,strong)NSMutableArray *blocks;

@property(nonatomic,assign)SEL asel;
@property(nonatomic,assign)SEL bsel;
@end

@interface HP : NSObject
@property(nonatomic,assign)ChangeBlock block;
@end
