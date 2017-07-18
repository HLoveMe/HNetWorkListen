//
//  AppDelegate.h
//  01
//
//  Created by 朱子豪 on 2017/7/3.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InputStreamProxy.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,weak)InputStreamProxy *delegate;
@end

