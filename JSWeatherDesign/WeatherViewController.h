//
//  WeatherViewController.h
//  JSWeatherDesign
//
//  Created by wangtingxu on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CityTableListViewController.h"
#import "RemainCityTableViewController.h"
#import "weatherResoure.h"
#import "sqlService.h"
#import "CityResource.h"
@interface WeatherViewController : UIViewController<CityTableListViewDelegate,RemainCityTableViewDelegate,WeatherResoureDelegate,UIScrollViewDelegate>
{
   	
    UIPopoverController *popoverCityController;
	UIPopoverController *popoverRemainCityController;
    weatherResoure *resoure;
    UIScrollView *scrollView;
    NSMutableArray *remainCityModel;
    float ScreenWidth;
    float ScreenHeight;
    UIAlertView *baseAlert;
}

@property (nonatomic,retain) UIPopoverController *popoverCityController;
@property (nonatomic,retain) UIPopoverController *popoverRemainCityController;
@property (nonatomic,retain) weatherResoure *resoure;
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) NSMutableArray *remainCityModel;
@property (nonatomic,retain) UIAlertView *baseAlert;
- (void)initalToolbar;
- (void)addCityBtnClicked:(id)sender;
- (void)removeCityBtnClicked:(id)sender;
- (void) initScrollerView;
-(UIView *)DrawScrollerViews:(float)width WithLength :(float)height WithPosition :(NSInteger)position;
-(NSString *)getWeek:(NSString *)date;
-(void)loading;
- (void) loadingDismiss;
-(void)startUPTheBackgroudJob:(NSString *)cityname;
- (void)startTheBackgroundJob:(NSString *)CityName;
-(void)animation;
@end
