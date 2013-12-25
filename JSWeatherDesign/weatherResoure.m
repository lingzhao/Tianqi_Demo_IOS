//
//  weatherResoure.m
//  JSWeatherDesign
//
//  Created by wangtingxu on 12-4-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "weatherResoure.h"
#import "ASIHTTPRequest.h"
#import "TFHpple.h"

@implementation weatherResoure
@synthesize delegate;

- (id)init
{
    ISupdate=NO;
	return self;
}

- (void)dealloc
{
	[super dealloc];
    delegate=nil;
}


-(void)GetWeatherByCityName:(NSString *)cityname update:(BOOL)isupdate
{
    ISupdate=isupdate;
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><getWeatherbyCityName xmlns=\"http://WebXml.com.cn/\"><theCityName>%@</theCityName></getWeatherbyCityName></soap:Body></soap:Envelope>"
                             ,cityname];
    NSString * wsURL = @"http://www.webxml.com.cn/WebServices/WeatherWebService.asmx";
    NSURL *URL =[NSURL URLWithString:wsURL];
    ASIHTTPRequest * theRequest = [ASIHTTPRequest requestWithURL:URL];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    [theRequest addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [theRequest addRequestHeader:@"SOAPAction" value:@"http://WebXml.com.cn/getWeatherbyCityName"];
    
    [theRequest addRequestHeader:@"Content-Length" value:msgLength];
    [theRequest setRequestMethod:@"POST"];
    [theRequest appendPostData:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    [theRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
    //显示网络请求信息在status bar上
    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
    [theRequest setDelegate:self];
    //同步调用
    [theRequest startSynchronous];

}

- ( void )requestFinished:( ASIHTTPRequest *)request

{
	NSMutableArray *weather=[[NSMutableArray alloc]init];
	NSString *responseString = [request responseString ]; // 对于 2 进制数据，使用： NSData *
	NSData *htmlData=[responseString dataUsingEncoding:NSUTF8StringEncoding];
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];		
	NSArray *elements  = [xpathParser search:@"//string"]; // get the page title
    for (int i=0; i<[elements count]; i++) {
        TFHppleElement *element = [elements objectAtIndex:i];
        NSString *weatherInfo = [element content];  
        [weather addObject:weatherInfo];
    }
	[xpathParser release];
    if (!ISupdate) [delegate addWeatherResoure:[self getModel:weather]];
    else [delegate upWeatherResource:[self getModel:weather]];
    
    [weather release];
	
}

-(ModelWeather *)getModel:(NSMutableArray *)array
{
    ModelWeather *model=[[[ModelWeather alloc]init] autorelease];
    model._1CityName=[array objectAtIndex:1];
    model._2CityCode=[array objectAtIndex:2];
    model._3UpdateTime=[array objectAtIndex:4];
    model._4ToTemp=[array objectAtIndex:5];
    model._5ToInfo=[array objectAtIndex:6];
    model._6ToWind=[array objectAtIndex:7];
    model._7ToImgState=[array objectAtIndex:9];
    model._8ToForcast=[array objectAtIndex:10];
    model._9ToLiftIndex=[array objectAtIndex:11];
    model._10SecTemp=[array objectAtIndex:12];
    model._11SecInfo=[array objectAtIndex:13];
    model._12SecWind=[array objectAtIndex:14];
    model._13SecImgState=[array objectAtIndex:16];
    model._14ThiTemp=[array objectAtIndex:17];
    model._15ThiInfo=[array objectAtIndex:18];
    model._16ThiWind=[array objectAtIndex:19];
    model._17ThiImgState=[array objectAtIndex:21];
    return  [model retain];
}



// 请求失败，获取 error

- ( void )requestFailed:( ASIHTTPRequest *)request

{
	
	NSError *error = [request error ];
	
	NSLog ( @"%@" ,error. userInfo );
	NSLog(@"链接网络失败");
    [delegate getweatherfaild];
    
} 

@end
