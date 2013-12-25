//
//  weatherResoure.h
//  JSWeatherDesign
//
//  Created by wangtingxu on 12-4-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlService.h"
@protocol WeatherResoureDelegate
- (void)addWeatherResoure:(ModelWeather *)model;
- (void)upWeatherResource:(ModelWeather *)model;
-(void)getweatherfaild;
@end

@interface weatherResoure : NSObject
{
    id<WeatherResoureDelegate> delegate;
    BOOL ISupdate;
}
@property(nonatomic,assign) id<WeatherResoureDelegate> delegate;
-(void)GetWeatherByCityName:(NSString *)cityname update:(BOOL)isupdate;
-(ModelWeather *)getModel:(NSMutableArray *)array;
@end
