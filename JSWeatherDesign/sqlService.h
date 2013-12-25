//
//  sqlService.h
//  Browser
//
//  Created by wtx on 12-4-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define kFilename @"Localweather.sql"
#define kCitydata @"Citydata.sql"
@class CityData;
@class ModelWeather;

@interface sqlService : NSObject
{
    sqlite3 *_database;
}
@property (nonatomic) sqlite3 *_database;
-(BOOL) CreatTable:(sqlite3 *)db;//创建数据库
-(BOOL) insertModel:(ModelWeather *)insertList;//插入数据									
-(NSMutableArray*)getweatherinfo;//获取全部数据
- (BOOL) deleteWeatherModel:(NSString *)Cityname;//删除数据
-(BOOL) updateTestList:(ModelWeather *)Updatemodel;//更新数据
@end

@interface CityData : NSObject
{
    sqlite3 *_database;
}
@property(nonatomic)sqlite3 *_database;
-(BOOL) CreatTable:(sqlite3 *)db;//创建数据库
-(BOOL) insertArray:(NSMutableArray *)insertList;//插入数据									
- (NSMutableArray*)getcitys;//获取全部数据
@end









@interface ModelWeather : NSObject
{
	NSString *_1CityName;
    NSString *_2CityCode;
    NSString *_3UpdateTime;
    NSString *_4ToTemp;
    NSString *_5ToInfo;
    NSString *_6ToWind;
    NSString *_7ToImgState;
    NSString *_8ToForcast;
    NSString *_9ToLiftIndex;
    NSString *_10SecTemp;
    NSString *_11SecInfo;
    NSString *_12SecWind;
    NSString *_13SecImgState;
    NSString *_14ThiTemp;
    NSString *_15ThiInfo;
    NSString *_16ThiWind;
    NSString *_17ThiImgState;
}
@property (nonatomic, retain)  NSString *_1CityName;
@property (nonatomic, retain)  NSString *_2CityCode;
@property (nonatomic, retain)  NSString *_3UpdateTime;
@property (nonatomic, retain)  NSString *_4ToTemp;
@property (nonatomic, retain)  NSString *_5ToInfo;
@property (nonatomic, retain)  NSString *_6ToWind;
@property (nonatomic, retain)  NSString *_7ToImgState;
@property (nonatomic, retain)  NSString *_8ToForcast;
@property (nonatomic, retain)  NSString *_9ToLiftIndex;
@property (nonatomic, retain)  NSString *_10SecTemp;
@property (nonatomic, retain)  NSString *_11SecInfo;
@property (nonatomic, retain)  NSString *_12SecWind;
@property (nonatomic, retain)  NSString *_13SecImgState;
@property (nonatomic, retain)  NSString *_14ThiTemp;
@property (nonatomic, retain)  NSString *_15ThiInfo;
@property (nonatomic, retain)  NSString *_16ThiWind;
@property (nonatomic, retain)  NSString *_17ThiImgState;


@end
