//
//  AppDelegate.h
//  JSWeatherDesign
//
//  Created by wangtingxu on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

{
    UINavigationController *nav;

}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain)UINavigationController *nav;

@end
