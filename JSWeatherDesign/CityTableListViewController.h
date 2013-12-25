//
//  CityTableListViewController.h
//  WeatherInfo
//
//  Created by Wu Jing on 11-5-12.
//  Copyright 2011 cfmetinfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
@protocol CityTableListViewDelegate
- (void)citySelected:(NSString *)cityName;
@end

@interface CityTableListViewController : UITableViewController {
	id<CityTableListViewDelegate> _delegate;
    UISearchBar *searchBar;
	UISearchDisplayController *searchDC;
    NSMutableArray *remainCity;
    NSMutableArray *cityNames;
	NSMutableArray *allCitys;
    NSArray *FilterArray;
    NSMutableDictionary *fileArray;
}
@property (retain) UISearchBar *searchBar;
@property (retain) UISearchDisplayController *searchDC;
@property (nonatomic,assign) id<CityTableListViewDelegate> _delegate;
@property (nonatomic,retain) NSMutableArray *remainCity;
@property (nonatomic,retain) NSMutableArray *cityNames;
@property (nonatomic,retain) NSMutableArray *allCitys;
@property (retain) NSMutableDictionary *fileArray;
@property (retain)NSArray *FilterArray;

@end
