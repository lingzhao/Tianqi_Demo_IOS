//
//  RemainCityTableViewController.h
//  WeatherInfo
//
//  Created by Wu Jing on 11-5-17.
//  Copyright 2011 cfmetinfo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RemainCityTableViewDelegate
- (void)cityDeleted:(NSString *)cityName;
@end

@interface RemainCityTableViewController : UITableViewController {
	id<RemainCityTableViewDelegate> remainCityDelegate;
    NSMutableArray *cityArray;
}

@property (nonatomic,assign) id<RemainCityTableViewDelegate> remainCityDelegate;
@property (nonatomic,retain)NSMutableArray *cityArray;
-(void)saveCities:(NSMutableArray *) array;
-(void)enterEditMode;

@end
