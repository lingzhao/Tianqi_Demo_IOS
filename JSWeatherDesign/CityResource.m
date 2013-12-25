//
//  CityResource.m
//  JSWeatherDesign
//
//  Created by wtx on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CityResource.h"
#import "ASIHTTPRequest.h"
#import "TFHpple.h"
#import "sqlService.h"
@implementation CityResource

- (id)init
{
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

-(void)CityNames
{
   
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><getSupportCity xmlns=\"http://WebXml.com.cn/\"><byProvinceName>ALL</byProvinceName></getSupportCity></soap:Body></soap:Envelope>"
                             ];
    NSString * wsURL = @"http://www.webxml.com.cn/WebServices/WeatherWebService.asmx";
    NSURL *URL =[NSURL URLWithString:wsURL];
    ASIHTTPRequest * theRequest = [ASIHTTPRequest requestWithURL:URL];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    [theRequest addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [theRequest addRequestHeader:@"SOAPAction" value:@"http://WebXml.com.cn/getSupportCity"];
    
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
	NSMutableArray *Citynames=[[NSMutableArray alloc]init];
	NSString *responseString = [request responseString ]; // 对于 2 进制数据，使用： NSData *
	NSData *htmlData=[responseString dataUsingEncoding:NSUTF8StringEncoding];
	TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];		
	NSArray *elements  = [xpathParser search:@"//string"]; // get the page title
    for (int i=0; i<[elements count]; i++) {
        TFHppleElement *element = [elements objectAtIndex:i];
        NSString *Cityname = [element content];  
        NSLog(@"%@",Cityname);
        [Citynames addObject:[Cityname substringToIndex:[Cityname rangeOfString:@" ("].location]];
    }
    NSMutableArray *temparray=[[NSMutableArray alloc]init];
    for (int j=0; j<[Citynames count]; j++) {
        if ([[Citynames objectAtIndex:j]rangeOfString:@" "].length==0) {
            
            [temparray addObject:[Citynames objectAtIndex:j]];
        }
    }
    CityData *citdata=[[CityData alloc]init];
    [citdata insertArray:temparray];
    [temparray release];
    [citdata release];
	[xpathParser release];
    [Citynames release];
	
}

// 请求失败，获取 error

- ( void )requestFailed:( ASIHTTPRequest *)request

{
	
	NSError *error = [request error ];
	
	NSLog ( @"%@" ,error. userInfo );
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"后台城市数据下载失败,请检查网络" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    
} 

@end
