//
//  WeatherViewController.m
//  JSWeatherDesign
//
//  Created by wangtingxu on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WeatherViewController.h"

@implementation WeatherViewController

@synthesize popoverCityController;
@synthesize popoverRemainCityController;
@synthesize resoure;
@synthesize scrollView;
@synthesize remainCityModel;
@synthesize baseAlert;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */
- (void) dealloc
{
    
    [resoure release];
    [popoverCityController release];
    [popoverRemainCityController release];
    [scrollView release];
    [remainCityModel release];
    [baseAlert release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //背景图片
    UIImageView *bgImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 768, 1004)];
    bgImg.tag=999;
    [bgImg setContentMode:UIViewContentModeScaleAspectFill];
    bgImg.autoresizesSubviews=YES;
    bgImg.opaque=YES;
    bgImg.clearsContextBeforeDrawing=YES;
    [bgImg setImage:[UIImage imageNamed:@"bg_wtx.jpg"]];
    [self.view addSubview:bgImg];
    [bgImg release];
    [self initalToolbar];
    //实例化 获取天气的实例类
    resoure=[[weatherResoure alloc]init];
    resoure.delegate=self;
    ScreenWidth=768;
    ScreenHeight=1024;
   [NSThread detachNewThreadSelector:@selector(backgroundloadcitynames:) toTarget:self withObject:nil];
    
}


-(void)backgroundloadcitynames:(id)sender
{ 
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    CityData *allcitys=[[CityData alloc]init];
    if ([[allcitys getcitys] count]==0) {
        CityResource *cityRecource=[[CityResource alloc]init];
        [cityRecource CityNames];
    }
    [allcitys release ];
    [pool release];
}
//初始化工具条
- (void)initalToolbar
{
    UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 110, 45)]; 
    [tools setBarStyle:UIBarStyleBlack];
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
	
	UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc]initWithTitle:@"更新" style:UITabBarSystemItemContacts target:self action:@selector(refreshCityBtnClicked:)];
	
	UIBarButtonItem *btndelete = [[UIBarButtonItem alloc]
                                  initWithTitle:@"管理" style:UITabBarSystemItemContacts target:self action:@selector(removeCityBtnClicked:)];
    [buttons addObject:btnRefresh]; 
	[btnRefresh release]; 
	[buttons addObject:btndelete]; 
	[btndelete release]; 
	[tools setItems:buttons animated:NO]; 
	[buttons release]; 
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] 
										   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCityBtnClicked:)];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:tools];
	[tools release];
}

-(void)loading{
	baseAlert = [[[UIAlertView alloc] initWithTitle:@"正在获取天气数据，请稍候！" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    [baseAlert show];
	
	// Create and add the activity indicator
	UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	aiv.center = CGPointMake(baseAlert.bounds.size.width / 2.0f, baseAlert.bounds.size.height - 40.0f);
	[aiv startAnimating];
	[baseAlert addSubview:aiv];
	[aiv release];	
}

//隐藏加载动画窗口
- (void) loadingDismiss
{
	[baseAlert dismissWithClickedButtonIndex:0 animated:NO];
}


//添加城市
- (void)addCityBtnClicked:(id)sender
{
    CityTableListViewController *cityTable =[[CityTableListViewController alloc] init];
    cityTable.contentSizeForViewInPopover=CGSizeMake(300, 400);
    cityTable._delegate=self;
    popoverCityController=[[UIPopoverController alloc] initWithContentViewController:cityTable];
    [cityTable release];
    if (popoverRemainCityController.popoverVisible==YES) {
		[popoverRemainCityController dismissPopoverAnimated:YES];
	}
	[popoverCityController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

//删除关注城市
- (void)removeCityBtnClicked:(id)sender
{
    // Create the segmented control. Choose one of the three styles
	RemainCityTableViewController *remainCityTable =[[RemainCityTableViewController alloc] init];
    remainCityTable.contentSizeForViewInPopover=CGSizeMake(300, 450);
    remainCityTable.remainCityDelegate=self;
    //[remainCityTable enterEditMode];
    popoverRemainCityController=[[UIPopoverController alloc] initWithContentViewController:remainCityTable];
	[remainCityTable release];
	if (popoverCityController.popoverVisible==YES) {
		[popoverCityController dismissPopoverAnimated:YES];
	}	
	[popoverRemainCityController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


//刷新数据
- (void)refreshCityBtnClicked :(id)sender
{
    [self loading];
    int location=((int)scrollView.contentOffset.x)/((int)ScreenWidth);
    sqlService *sqlservice=[[sqlService alloc]init];
    remainCityModel=[sqlservice getweatherinfo];
    NSString *currentCity=((ModelWeather *)[remainCityModel objectAtIndex:location])._1CityName;
    [sqlservice release];
    [NSThread detachNewThreadSelector:@selector(startUPTheBackgroudJob:) toTarget:self withObject:currentCity];
}


//选中 所要添加的城市 scorllerview 重绘
- (void)citySelected:(NSString *)cityName;
{
    sqlService *sqlservice=[[sqlService alloc]init];
    NSMutableArray *remainList=[[NSMutableArray alloc]init];
    remainList=[sqlservice getweatherinfo];
    BOOL ISCitySaved=NO;
    for (int i=0; i<[remainList count]; i++) {
        if ([((ModelWeather *)[remainList objectAtIndex:i])._1CityName isEqualToString:cityName]) {
            ISCitySaved=YES;
            [scrollView setContentOffset:CGPointMake(ScreenWidth*i, 0) animated:YES];
            break;
        }
    }
    [sqlservice release];
    //获取天气源
    //如果没有保存本城市的天气信息,则下载数据
    if (!ISCitySaved) {
        [self loading];
        [NSThread detachNewThreadSelector:@selector(startTheBackgroundJob:) toTarget:self withObject:cityName];
    }
    [popoverCityController dismissPopoverAnimated:YES];
    
}
//后台下载城市天气
- (void)startTheBackgroundJob:(NSString *)CityName
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    [resoure GetWeatherByCityName:CityName update:NO];
    [pool release];
}
//后台更新城市天气
-(void)startUPTheBackgroudJob:(NSString *)cityname
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    [resoure GetWeatherByCityName:cityname update:YES];
    [pool release];
}

//删除 选中的城市  scrollerview重绘
- (void)cityDeleted:(NSString *)cityName
{
    sqlService *sqlservice=[[sqlService alloc]init];
    remainCityModel=[sqlservice getweatherinfo];
    
    for (int i=0; i<[remainCityModel count]+1; i++) {
        [(UIView *)[scrollView viewWithTag:1000+i] removeFromSuperview];
    }
    scrollView.contentSize=CGSizeMake(ScreenWidth*[remainCityModel count],ScreenHeight);
    for (int j=0; j<[remainCityModel count]; j++) {
        UIView *uv=[self DrawScrollerViews:ScreenWidth WithLength:ScreenHeight WithPosition:j];
        [scrollView addSubview:uv];
        [uv release];
    }
    [scrollView setContentOffset:CGPointMake(0, 0)];
    [sqlservice release];
    
    
}
//增加一个城市的天气模型
- (void)addWeatherResoure:(ModelWeather *)model
{
    sqlService *sqlservice=[[sqlService alloc]init];
    [sqlservice insertModel:model];
    
    remainCityModel=[sqlservice getweatherinfo];
    for (int i=0; i<[remainCityModel count]-1; i++) {
        [(UIView *)[scrollView viewWithTag:1000+i] removeFromSuperview];
    }
    
    //remainCityModel=[sqlservice getweatherinfo];
    scrollView.contentSize=CGSizeMake(ScreenWidth*[remainCityModel count],ScreenHeight);
    for (int j=0; j<[remainCityModel count]; j++) {
        UIView *uv=[self DrawScrollerViews:ScreenWidth WithLength:ScreenHeight WithPosition:j];
        [scrollView addSubview:uv];
        [uv release];
    }
    [scrollView setContentOffset:CGPointMake(ScreenWidth*([remainCityModel count]-1), 0)];
    [sqlservice release];
    [self loadingDismiss];
    
}

//更新一个城市的天气
- (void)upWeatherResource:(ModelWeather *)model
{
    sqlService *sql=[[sqlService alloc]init];
    [sql updateTestList:model];
    remainCityModel=[sql getweatherinfo];
    for (int i=0; i<[remainCityModel count]; i++) {
        [(UIView *)[scrollView viewWithTag:1000+i] removeFromSuperview];
    }
    scrollView.contentSize=CGSizeMake(ScreenWidth*[remainCityModel count],ScreenHeight);
    for (int j=0; j<[remainCityModel count]; j++) {
        UIView *uv=[self DrawScrollerViews:ScreenWidth WithLength:ScreenHeight WithPosition:j];
        [scrollView addSubview:uv];
        [uv release];
    }
    //[scrollView setContentOffset:CGPointMake(ScreenWidth*([remainCityModel count]-1), 0)];
    [sql release];
    [self loadingDismiss];
}


-(void)getweatherfaild
{
    [self loadingDismiss];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络连接失败,请检查网络" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

//初始化ScrollerView
-(void)initScrollerView
{
    sqlService *sql=[[sqlService alloc]init];
    remainCityModel = [[NSMutableArray alloc]init];
    remainCityModel=[sql getweatherinfo];
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
	scrollView.pagingEnabled = YES;
	scrollView.delegate =self;
    scrollView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:scrollView];
    scrollView.contentSize=CGSizeMake(ScreenWidth*[remainCityModel count],ScreenHeight);
    for (int i=0; i<[remainCityModel count]; i++) {
        UIView *uv=[self DrawScrollerViews:ScreenWidth WithLength:ScreenHeight WithPosition:i];
        [scrollView addSubview:uv];
        [uv release];
    }
    [scrollView setContentOffset:CGPointMake(0, 0)];
}

-(UIView *)DrawScrollerViews:(float)width WithLength :(float)height WithPosition :(NSInteger)position
{
    /*
     数据处理过程
     */
    //天气模型
    ModelWeather *model=[[ModelWeather alloc]init];
    model=[remainCityModel objectAtIndex:position];
    //截取相应数据 实况数据
    //    NSLog(@"%@",model._8ToForcast);
    NSArray *forcastweather=[model._8ToForcast componentsSeparatedByString:@"；"];
    //现在温度
    NSString *NowTemp=[[forcastweather objectAtIndex:0]substringFromIndex:[[forcastweather  objectAtIndex:0] rangeOfString:@"气温：" ].location+3];
    //现在风向风力
    NSString *NowWind=[[forcastweather objectAtIndex:1]substringFromIndex:[[forcastweather  objectAtIndex:1] rangeOfString:@"风向/风力：" ].location+6];
    //现在湿度
    NSString *NowHumidity=[[forcastweather objectAtIndex:2]substringFromIndex:[[forcastweather  objectAtIndex:2] rangeOfString:@"湿度：" ].location+3];
    
    //空气质量
    NSString *NowAirQuality=[[forcastweather objectAtIndex:3]substringFromIndex:[[forcastweather  objectAtIndex:3] rangeOfString:@"空气质量：" ].location+5];
    //紫外线强度
    NSString *UV=[[forcastweather objectAtIndex:4]substringFromIndex:[[forcastweather  objectAtIndex:4] rangeOfString:@"紫外线强度：" ].location+6];
    //今日总体风向风速
    NSRange rangewind24=[model._6ToWind rangeOfString:@"转"];
    int length24=rangewind24.length;
    if (length24==0) length24=0;
    else length24=rangewind24.location+1;
    NSString *toWind24=[model._6ToWind substringFromIndex:length24];
    //第二天风向风速
    NSRange rangewind48=[model._12SecWind rangeOfString:@"转"];
    int length48=rangewind48.length;
    if (length48==0) length48=0;
    else length48=rangewind48.location+1;
    NSString *toWind48=[model._12SecWind substringFromIndex:length48];
    //第三天风向风速
    NSRange rangewind72=[model._16ThiWind rangeOfString:@"转"];
    int length72=rangewind72.length;
    if (length72==0) length72=0;
    else length72=rangewind72.location+1;
    NSString *toWind72=[model._16ThiWind substringFromIndex:length72];
    
    //今天的天气状况
    NSString *ToWeatherState24;
    NSRange rangestate24=[model._5ToInfo rangeOfString:@"转"];
    int lengthstate24=rangestate24.length;
    if (lengthstate24==0) 
        ToWeatherState24=[model._5ToInfo substringFromIndex:[model._5ToInfo rangeOfString:@"日" ].location+1];
    else
        ToWeatherState24=[model._5ToInfo substringFromIndex:[model._5ToInfo rangeOfString:@"转" ].location+1];
    ToWeatherState24=[ToWeatherState24 stringByReplacingOccurrencesOfString:@" " withString:@""];
    //第二天的天气状态
    NSString *ToWeatherState48;
    NSRange rangestate48=[model._11SecInfo rangeOfString:@"转"];
    int lengthstate48=rangestate48.length;
    if (lengthstate48==0) 
        ToWeatherState48=[model._11SecInfo substringFromIndex:[model._11SecInfo rangeOfString:@"日" ].location+1];
    else
        ToWeatherState48=[model._11SecInfo substringFromIndex:[model._11SecInfo rangeOfString:@"转" ].location+1];
    ToWeatherState48=[ToWeatherState48 stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //第三天天气状态
    NSString *ToWeatherState72;
    NSRange rangestate72=[model._15ThiInfo rangeOfString:@"转"];
    int lengthstate72=rangestate72.length;
    if (lengthstate72==0) 
        ToWeatherState72=[model._15ThiInfo substringFromIndex:[model._15ThiInfo rangeOfString:@"日" ].location+1];
    else
        ToWeatherState72=[model._15ThiInfo substringFromIndex:[model._15ThiInfo rangeOfString:@"转" ].location+1];
    ToWeatherState72=[ToWeatherState72 stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    //处理星期信息
    //第一天
    NSString * date10=[model._5ToInfo substringToIndex:[model._5ToInfo rangeOfString:@"日"].location];
    NSString *date11=[date10 stringByReplacingOccurrencesOfString:@"月" withString:@"-"] ;
    NSString *firstweek=[self getWeek:[NSString stringWithFormat:@"%@-%@",[model._3UpdateTime substringToIndex:4],date11]];
    //第二天
    NSString * date20=[model._11SecInfo substringToIndex:[model._11SecInfo rangeOfString:@"日"].location];
    NSString *date21=[date20 stringByReplacingOccurrencesOfString:@"月" withString:@"-"] ;
    NSString *secondweek=[self getWeek:[NSString stringWithFormat:@"%@-%@",[model._3UpdateTime substringToIndex:4],date21]];
    
    //第三天
    NSString * date30=[model._15ThiInfo substringToIndex:[model._15ThiInfo rangeOfString:@"日"].location];
    NSString *date31=[date30 stringByReplacingOccurrencesOfString:@"月" withString:@"-"] ;
    NSString *Thirdweek=[self getWeek:[NSString stringWithFormat:@"%@-%@",[model._3UpdateTime substringToIndex:4],date31]];
    /*
     数据可视化过程
     */
    UIView *uv=[[UIView alloc]initWithFrame:CGRectMake(width*position, 0, width, height)];
    uv.tag=1000+position;
    //竖屏
    if (ScreenWidth==768) {
        //城市名字
        UILabel *cityLabel =[[UILabel alloc] initWithFrame:CGRectMake(20, 51, 128, 79)];
        cityLabel.font=[UIFont fontWithName:@"Helvetica" size:50];
        cityLabel.text=[NSString stringWithFormat:@"%@市",model._1CityName];
        cityLabel.backgroundColor=[UIColor clearColor];
        cityLabel.textColor=[UIColor whiteColor];
        [cityLabel setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:cityLabel];
        [cityLabel release];
        //天气更新时间
        UILabel *updateTime=[[UILabel alloc] initWithFrame:CGRectMake(216, 72, 250, 28)];
        updateTime.font=[UIFont fontWithName:@"Helvetica" size:17];
        updateTime.text=[NSString stringWithFormat:@"更新时间：%@",model._3UpdateTime];
        updateTime.backgroundColor=[UIColor clearColor];
        updateTime.textColor=[UIColor whiteColor];
        [updateTime setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:updateTime];
        [updateTime release];
        
        //今天温度
        UILabel *ToTemp=[[UILabel alloc] initWithFrame:CGRectMake(20, 145, 139, 21)];
        ToTemp.font=[UIFont fontWithName:@"Helvetica" size:25];
        ToTemp.text=[NSString stringWithFormat:@"温度: %@",model._4ToTemp];
        ToTemp.backgroundColor=[UIColor clearColor];
        ToTemp.textColor=[UIColor whiteColor];
        [ToTemp setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToTemp];
        [ToTemp release];
        
        //今天实况风向风速
        UILabel *ToWind=[[UILabel alloc] initWithFrame:CGRectMake(20, 170, 175, 30)];
        ToWind.font=[UIFont fontWithName:@"Helvetica" size:25];
        ToWind.text=[NSString stringWithFormat:@"风向/风力:%@",NowWind];
        ToWind.backgroundColor=[UIColor clearColor];
        ToWind.textColor=[UIColor whiteColor];
        [ToWind setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToWind];
        [ToWind release];
        
        //今天湿度
        UILabel *ToHumidity=[[UILabel alloc] initWithFrame:CGRectMake( 20, 208, 139, 21)];
        ToHumidity.font=[UIFont fontWithName:@"Helvetica" size:18];
        ToHumidity.text=[NSString stringWithFormat:@"湿度:%@",NowHumidity];
        ToHumidity.backgroundColor=[UIColor clearColor];
        ToHumidity.textColor=[UIColor whiteColor];
        [ToHumidity setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToHumidity];
        [ToHumidity release];
        //今天的天气状况
        UILabel *ToweatherState=[[UILabel alloc] initWithFrame:CGRectMake( 350, 118, 128, 97)];
        ToweatherState.font=[UIFont fontWithName:@"Helvetica" size:45];
        ToweatherState.text=ToWeatherState24;
        ToweatherState.backgroundColor=[UIColor clearColor];
        ToweatherState.textColor=[UIColor whiteColor];
        [ToweatherState setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToweatherState];
        [ToweatherState  release];
        //目前的温度实况
        UILabel *Temp=[[UILabel alloc] initWithFrame:CGRectMake( 510, 360, 92, 43)];
        Temp.font=[UIFont fontWithName:@"Helvetica" size:40];
        Temp.text=[NSString stringWithFormat:@"%@",NowTemp];
        Temp.backgroundColor=[UIColor clearColor];
        Temp.textColor=[UIColor colorWithRed:246.0f/255.0f green:131.0f/255.0f blue:22.0f/255.0f alpha:1.0f];
        [Temp setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:Temp];
        [Temp release];
        
        //空气质量
        UILabel *ToAirQuality=[[UILabel alloc] initWithFrame:CGRectMake(510, 450, 150, 30)];
        ToAirQuality.font=[UIFont fontWithName:@"Helvetica" size:20];
        ToAirQuality.text=[NSString stringWithFormat:@"空气质量: %@",NowAirQuality];
        ToAirQuality.backgroundColor=[UIColor clearColor];
        ToAirQuality.textColor=[UIColor whiteColor];
        [ToAirQuality setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToAirQuality];
        [ToAirQuality release];
        
        //紫外线强度
        UILabel *ToUV=[[UILabel alloc] initWithFrame:CGRectMake(510, 490, 150, 30)];
        ToUV.font=[UIFont fontWithName:@"Helvetica" size:20];
        ToUV.text=[NSString stringWithFormat:@"紫外线强度: %@",UV];
        ToUV.backgroundColor=[UIColor clearColor];
        ToUV.textColor=[UIColor whiteColor];
        [ToUV setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToUV];
        [ToUV release];
        //今天天气的图片资源
        UIImageView *ToimgView=[[UIImageView alloc] initWithFrame:CGRectMake( 480, 60, 250, 250)];
        ToimgView.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[model._7ToImgState substringToIndex:[model._7ToImgState rangeOfString:@"." ].location]]];
        //第一天数据背景图
        [uv addSubview:ToimgView];
        [ToimgView release];
        UIImageView *firstBg=[[UIImageView alloc] initWithFrame:CGRectMake(20, 280, 425, 196)];
        firstBg.image=[UIImage imageNamed:@"mianban.png"];
        [uv addSubview:firstBg];
        [firstBg release];
        //第一天的星期
        UILabel *lblfirstWeek=[[UILabel alloc] initWithFrame:CGRectMake( 29, 288, 139, 25)];
        lblfirstWeek.font=[UIFont fontWithName:@"Helvetica" size:17];
        lblfirstWeek.text=[NSString stringWithFormat:@"%@",firstweek];
        lblfirstWeek.backgroundColor=[UIColor clearColor];
        lblfirstWeek.textColor=[UIColor whiteColor];
        [lblfirstWeek setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:lblfirstWeek];
        [lblfirstWeek release];
        //第一天的天气状态
        UILabel *weatherState24=[[UILabel alloc] initWithFrame:CGRectMake( 169, 424, 80, 40)];
        weatherState24.font=[UIFont fontWithName:@"Helvetica" size:20];
        weatherState24.text=ToWeatherState24;
        weatherState24.backgroundColor=[UIColor clearColor];
        weatherState24.textColor=[UIColor whiteColor];
        [weatherState24 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:weatherState24];
        [weatherState24 release];
        //第一天的风向风力
        UILabel *wind24=[[UILabel alloc] initWithFrame:CGRectMake( 246, 384, 149, 36)];
        wind24.font=[UIFont fontWithName:@"Helvetica" size:20];
        wind24.text=[NSString stringWithFormat:@"%@",toWind24];
        wind24.backgroundColor=[UIColor clearColor];
        wind24.textColor=[UIColor whiteColor];
        [wind24 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:wind24];
        [wind24 release];
        //第一天温度
        UILabel *temp24=[[UILabel alloc] initWithFrame:CGRectMake( 246, 345, 149, 36)];
        temp24.font=[UIFont fontWithName:@"Helvetica" size:20];
        temp24.text=model._4ToTemp;
        temp24.backgroundColor=[UIColor clearColor];
        temp24.textColor=[UIColor whiteColor];
        [temp24 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:temp24];
        [temp24 release];
        //第一天天气图片
        UIImageView * ImgState24=[[UIImageView alloc] initWithFrame:CGRectMake( 39, 332, 118, 113)];
        ImgState24.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[model._7ToImgState substringToIndex:[model._7ToImgState rangeOfString:@"." ].location]]];
        [uv addSubview:ImgState24];
        [ImgState24 release];
        //第二天数据背景图
        UIImageView *secondBg=[[UIImageView alloc] initWithFrame:CGRectMake(20, 486, 425, 196)];
        secondBg.image=[UIImage imageNamed:@"mianban.png"];
        [uv addSubview:secondBg];
        [secondBg release];
        //第二天的星期
        UILabel *lblfsecondWeek=[[UILabel alloc] initWithFrame:CGRectMake( 29, 495, 139, 25)];
        lblfsecondWeek.font=[UIFont fontWithName:@"Helvetica" size:17];
        lblfsecondWeek.text=[NSString stringWithFormat:@"%@",secondweek];
        lblfsecondWeek.backgroundColor=[UIColor clearColor];
        lblfsecondWeek.textColor=[UIColor whiteColor];
        [lblfsecondWeek setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:lblfsecondWeek];
        [lblfsecondWeek release];
        //第二天的天气状态
        UILabel *weatherState48=[[UILabel alloc] initWithFrame:CGRectMake( 169, 630, 80, 40)];
        weatherState48.font=[UIFont fontWithName:@"Helvetica" size:20];
        weatherState48.text=ToWeatherState48;
        weatherState48.backgroundColor=[UIColor clearColor];
        weatherState48.textColor=[UIColor whiteColor];
        [weatherState48 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:weatherState48];
        [weatherState48 release];
        //第二天的风向风力
        UILabel *wind48=[[UILabel alloc] initWithFrame:CGRectMake( 246, 590, 149, 36)];
        wind48.font=[UIFont fontWithName:@"Helvetica" size:20];
        wind48.text=[NSString stringWithFormat:@"%@",toWind48];
        wind48.backgroundColor=[UIColor clearColor];
        wind48.textColor=[UIColor whiteColor];
        [wind48 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:wind48];
        [wind48 release];
        //第二天温度
        UILabel *temp48=[[UILabel alloc] initWithFrame:CGRectMake( 246, 551, 149, 36)];
        temp48.font=[UIFont fontWithName:@"Helvetica" size:20];
        temp48.text=model._10SecTemp;
        temp48.backgroundColor=[UIColor clearColor];
        temp48.textColor=[UIColor whiteColor];
        [temp48 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:temp48];
        [temp48 release];
        //第二天天气图片
        UIImageView * ImgState48=[[UIImageView alloc] initWithFrame:CGRectMake( 39, 544, 118, 113)];
        ImgState48.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[model._13SecImgState substringToIndex:[model._13SecImgState rangeOfString:@"." ].location]]];
        [uv addSubview:ImgState48];
        [ImgState48 release];
        
        //第三天数据背景图
        UIImageView *thirdBg=[[UIImageView alloc] initWithFrame:CGRectMake(20, 692, 425, 196)];
        thirdBg.image=[UIImage imageNamed:@"mianban.png"];
        [uv addSubview:thirdBg];
        [thirdBg release];
        //第三天的星期
        UILabel *lblthirdWeek=[[UILabel alloc] initWithFrame:CGRectMake( 29, 701, 139, 25)];
        lblthirdWeek.font=[UIFont fontWithName:@"Helvetica" size:17];
        lblthirdWeek.text=[NSString stringWithFormat:@"%@",Thirdweek];
        lblthirdWeek.backgroundColor=[UIColor clearColor];
        lblthirdWeek.textColor=[UIColor whiteColor];
        [lblthirdWeek setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:lblthirdWeek];
        [lblthirdWeek release];
        //第三天的天气状态
        UILabel *weatherState72=[[UILabel alloc] initWithFrame:CGRectMake( 169, 836, 80, 40)];
        weatherState72.font=[UIFont fontWithName:@"Helvetica" size:20];
        weatherState72.text=ToWeatherState72;
        weatherState72.backgroundColor=[UIColor clearColor];
        weatherState72.textColor=[UIColor whiteColor];
        [weatherState72 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:weatherState72];
        [weatherState72 release];
        //第三天的风向风力
        UILabel *wind72=[[UILabel alloc] initWithFrame:CGRectMake( 246, 796, 149, 36)];
        wind72.font=[UIFont fontWithName:@"Helvetica" size:20];
        wind72.text=[NSString stringWithFormat:@"%@",toWind72];
        wind72.backgroundColor=[UIColor clearColor];
        wind72.textColor=[UIColor whiteColor];
        [wind72 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:wind72];
        [wind72 release];
        //第三天温度
        UILabel *temp72=[[UILabel alloc] initWithFrame:CGRectMake( 246, 757, 149, 36)];
        temp72.font=[UIFont fontWithName:@"Helvetica" size:20];
        temp72.text=model._14ThiTemp;
        temp72.backgroundColor=[UIColor clearColor];
        temp72.textColor=[UIColor whiteColor];
        [temp72 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:temp72];
        [temp72 release];
        //第三天天气图片
        UIImageView * ImgState72=[[UIImageView alloc] initWithFrame:CGRectMake( 39, 750, 118, 113)];
        ImgState72.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[model._17ThiImgState substringToIndex:[model._17ThiImgState rangeOfString:@"." ].location]]];
        [uv addSubview:ImgState72];
        [ImgState72 release];
    }
    else
    {
        //城市名字
        UILabel *cityLabel =[[UILabel alloc] initWithFrame:CGRectMake(105, 105, 143, 48)];
        cityLabel.font=[UIFont fontWithName:@"Helvetica" size:50];
        cityLabel.text=[NSString stringWithFormat:@"%@市",model._1CityName];
        cityLabel.backgroundColor=[UIColor clearColor];
        cityLabel.textColor=[UIColor whiteColor];
        [cityLabel setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:cityLabel];
        [cityLabel release];
        //第一天实况背景
        UIImageView *todaybg=[[UIImageView alloc] initWithFrame:CGRectMake( 130, 240, 709, 60)];
        todaybg.image=[UIImage imageNamed:@"tm-01.png"];
        [uv addSubview:todaybg];
        [todaybg release];
        
        //天气更新时间
        UILabel *updateTime=[[UILabel alloc] initWithFrame:CGRectMake(650, 650, 250, 28)];
        updateTime.font=[UIFont fontWithName:@"Helvetica" size:17];
        updateTime.text=[NSString stringWithFormat:@"更新时间：%@",model._3UpdateTime];
        updateTime.backgroundColor=[UIColor clearColor];
        updateTime.textColor=[UIColor whiteColor];
        [updateTime setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:updateTime];
        [updateTime release];
        
        //今天温度
        UILabel *ToTemp=[[UILabel alloc] initWithFrame:CGRectMake(320, 260, 139, 21)];
        ToTemp.font=[UIFont fontWithName:@"Helvetica" size:25];
        ToTemp.text=[NSString stringWithFormat:@"温度: %@",model._4ToTemp];
        ToTemp.backgroundColor=[UIColor clearColor];
        ToTemp.textColor=[UIColor whiteColor];
        [ToTemp setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToTemp];
        [ToTemp release];
        
        //今天实况风向风速
        UILabel *ToWind=[[UILabel alloc] initWithFrame:CGRectMake(490, 260, 160, 21)];
        ToWind.font=[UIFont fontWithName:@"Helvetica" size:25];
        ToWind.text=[NSString stringWithFormat:@"风向/风力:%@",NowWind];
        ToWind.backgroundColor=[UIColor clearColor];
        ToWind.textColor=[UIColor whiteColor];
        [ToWind setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToWind];
        [ToWind release];
        
        //今天湿度
        UILabel *ToHumidity=[[UILabel alloc] initWithFrame:CGRectMake( 682, 260, 70, 21)];
        ToHumidity.font=[UIFont fontWithName:@"Helvetica" size:21];
        ToHumidity.text=[NSString stringWithFormat:@"湿度:%@",NowHumidity];
        ToHumidity.backgroundColor=[UIColor clearColor];
        ToHumidity.textColor=[UIColor whiteColor];
        [ToHumidity setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToHumidity];
        [ToHumidity release];
        //今天的天气状况
        UILabel *ToweatherState=[[UILabel alloc] initWithFrame:CGRectMake( 210, 235, 50, 50)];
        ToweatherState.font=[UIFont fontWithName:@"Helvetica" size:45];
        ToweatherState.text=ToWeatherState24;
        ToweatherState.backgroundColor=[UIColor clearColor];
        ToweatherState.textColor=[UIColor whiteColor];
        [ToweatherState setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToweatherState];
        [ToweatherState  release];
        //目前的温度实况
        UILabel *Temp=[[UILabel alloc] initWithFrame:CGRectMake( 510, 170, 92, 43)];
        Temp.font=[UIFont fontWithName:@"Helvetica" size:40];
        Temp.text=[NSString stringWithFormat:@"%@",NowTemp];
        Temp.backgroundColor=[UIColor clearColor];
        Temp.textColor=[UIColor colorWithRed:246.0f/255.0f green:131.0f/255.0f blue:22.0f/255.0f alpha:1.0f];
        [Temp setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:Temp];
        [Temp release];
        
        //空气质量
        UILabel *ToAirQuality=[[UILabel alloc] initWithFrame:CGRectMake(525, 305, 88, 23)];
        ToAirQuality.font=[UIFont fontWithName:@"Helvetica" size:20];
        ToAirQuality.text=[NSString stringWithFormat:@"空气质量: %@",NowAirQuality];
        ToAirQuality.backgroundColor=[UIColor clearColor];
        ToAirQuality.textColor=[UIColor whiteColor];
        [ToAirQuality setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToAirQuality];
        [ToAirQuality release];
        
        //紫外线强度
        UILabel *ToUV=[[UILabel alloc] initWithFrame:CGRectMake(650, 305, 120, 23)];
        ToUV.font=[UIFont fontWithName:@"Helvetica" size:20];
        ToUV.text=[NSString stringWithFormat:@"紫外线强度: %@",UV];
        ToUV.backgroundColor=[UIColor clearColor];
        ToUV.textColor=[UIColor whiteColor];
        [ToUV setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:ToUV];
        [ToUV release];
        //今天天气的图片资源
        UIImageView *ToimgView=[[UIImageView alloc] initWithFrame:CGRectMake( 650, 50, 200, 200)];
        ToimgView.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[model._7ToImgState substringToIndex:[model._7ToImgState rangeOfString:@"." ].location]]];
        [uv addSubview:ToimgView];
        [ToimgView release];
        //三天总体背景
        UIImageView *ThreeDaybg=[[UIImageView alloc] initWithFrame:CGRectMake(130, 356, 709, 261)];
        ThreeDaybg.image=[UIImage imageNamed:@"tm-011-01.png"];
        [uv addSubview:ThreeDaybg];
        [ThreeDaybg release];
        //第一天数据背景图
        UIImageView *firstbg=[[UIImageView alloc] initWithFrame:CGRectMake( 144, 405, 215, 202)];
        firstbg.image=[UIImage imageNamed:@"ybk-01.png"];
        [uv addSubview:firstbg];
        [firstbg release];
        
        //第一天的星期
        UILabel *lblfirstWeek=[[UILabel alloc] initWithFrame:CGRectMake( 225, 408, 139, 25)];
        lblfirstWeek.font=[UIFont fontWithName:@"Helvetica" size:17];
        lblfirstWeek.text=[NSString stringWithFormat:@"%@",firstweek];
        lblfirstWeek.backgroundColor=[UIColor clearColor];
        lblfirstWeek.textColor=[UIColor whiteColor];
        [lblfirstWeek setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:lblfirstWeek];
        [lblfirstWeek release];
        //第一天的天气状态
        UILabel *weatherState24=[[UILabel alloc] initWithFrame:CGRectMake( 160, 490, 70, 30)];
        weatherState24.font=[UIFont fontWithName:@"Helvetica" size:20];
        weatherState24.text=ToWeatherState24;
        weatherState24.backgroundColor=[UIColor clearColor];
        weatherState24.textColor=[UIColor whiteColor];
        [weatherState24 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:weatherState24];
        [weatherState24 release];
        //第一天的风向风力
        UILabel *wind24=[[UILabel alloc] initWithFrame:CGRectMake( 160, 580, 90, 21)];
        wind24.font=[UIFont fontWithName:@"Helvetica" size:20];
        wind24.text=[NSString stringWithFormat:@"%@",toWind24];
        wind24.backgroundColor=[UIColor clearColor];
        wind24.textColor=[UIColor whiteColor];
        [wind24 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:wind24];
        [wind24 release];
        //第一天温度
        UILabel *temp24=[[UILabel alloc] initWithFrame:CGRectMake( 160, 557, 80, 21)];
        temp24.font=[UIFont fontWithName:@"Helvetica" size:20];
        temp24.text=model._4ToTemp;
        temp24.backgroundColor=[UIColor clearColor];
        temp24.textColor=[UIColor whiteColor];
        [temp24 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:temp24];
        [temp24 release];
        //第一天天气图片
        UIImageView * ImgState24=[[UIImageView alloc] initWithFrame:CGRectMake( 230, 450, 100, 100)];
        ImgState24.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[model._7ToImgState substringToIndex:[model._7ToImgState rangeOfString:@"." ].location]]];
        [uv addSubview:ImgState24];
        [ImgState24 release];
        //第二天背景图片
        UIImageView *secondbg=[[UIImageView alloc] initWithFrame:CGRectMake( 374, 405, 215, 202)];
        secondbg.image=[UIImage imageNamed:@"ybk-01.png"];
        [uv addSubview:secondbg];
        [secondbg release];
        
        //第二天的星期
        UILabel *lblfsecondWeek=[[UILabel alloc] initWithFrame:CGRectMake(455, 408, 139, 25)];
        lblfsecondWeek.font=[UIFont fontWithName:@"Helvetica" size:17];
        lblfsecondWeek.text=[NSString stringWithFormat:@"%@",secondweek];
        lblfsecondWeek.backgroundColor=[UIColor clearColor];
        lblfsecondWeek.textColor=[UIColor whiteColor];
        [lblfsecondWeek setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:lblfsecondWeek];
        [lblfsecondWeek release];
        //第二天的天气状态
        UILabel *weatherState48=[[UILabel alloc] initWithFrame:CGRectMake( 390, 490, 70, 30)];
        weatherState48.font=[UIFont fontWithName:@"Helvetica" size:20];
        weatherState48.text=ToWeatherState48;
        weatherState48.backgroundColor=[UIColor clearColor];
        weatherState48.textColor=[UIColor whiteColor];
        [weatherState48 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:weatherState48];
        [weatherState48 release];
        //第二天的风向风力
        UILabel *wind48=[[UILabel alloc] initWithFrame:CGRectMake( 390, 580, 90, 21)];
        wind48.font=[UIFont fontWithName:@"Helvetica" size:20];
        wind48.text=[NSString stringWithFormat:@"%@",toWind48];
        wind48.backgroundColor=[UIColor clearColor];
        wind48.textColor=[UIColor whiteColor];
        [wind48 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:wind48];
        [wind48 release];
        //第二天温度
        UILabel *temp48=[[UILabel alloc] initWithFrame:CGRectMake( 390, 557, 80, 21)];
        temp48.font=[UIFont fontWithName:@"Helvetica" size:20];
        temp48.text=model._10SecTemp;
        temp48.backgroundColor=[UIColor clearColor];
        temp48.textColor=[UIColor whiteColor];
        [temp48 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:temp48];
        [temp48 release];
        //第二天天气图片
        UIImageView * ImgState48=[[UIImageView alloc] initWithFrame:CGRectMake( 460, 450, 100, 100)];
        ImgState48.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[model._13SecImgState substringToIndex:[model._13SecImgState rangeOfString:@"." ].location]]];
        [uv addSubview:ImgState48];
        [ImgState48 release];
        
        //第三天数据背景图片
        
        UIImageView *thirdbg=[[UIImageView alloc] initWithFrame:CGRectMake( 604, 405, 215, 202)];
        thirdbg.image=[UIImage imageNamed:@"ybk-01.png"];
        [uv addSubview:thirdbg];
        [thirdbg release];
        
        //第三天的星期
        UILabel *lblthirdWeek=[[UILabel alloc] initWithFrame:CGRectMake( 685,408, 139, 25)];
        lblthirdWeek.font=[UIFont fontWithName:@"Helvetica" size:17];
        lblthirdWeek.text=[NSString stringWithFormat:@"%@",Thirdweek];
        lblthirdWeek.backgroundColor=[UIColor clearColor];
        lblthirdWeek.textColor=[UIColor whiteColor];
        [lblthirdWeek setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:lblthirdWeek];
        [lblthirdWeek release];
        //第三天的天气状态
        UILabel *weatherState72=[[UILabel alloc] initWithFrame:CGRectMake( 620, 490, 70, 30)];
        weatherState72.font=[UIFont fontWithName:@"Helvetica" size:20];
        weatherState72.text=ToWeatherState72;
        weatherState72.backgroundColor=[UIColor clearColor];
        weatherState72.textColor=[UIColor whiteColor];
        [weatherState72 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:weatherState72];
        [weatherState72 release];
        //第三天的风向风力
        UILabel *wind72=[[UILabel alloc] initWithFrame:CGRectMake( 620, 580, 90, 21)];
        wind72.font=[UIFont fontWithName:@"Helvetica" size:20];
        wind72.text=[NSString stringWithFormat:@"%@",toWind72];
        wind72.backgroundColor=[UIColor clearColor];
        wind72.textColor=[UIColor whiteColor];
        [wind72 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:wind72];
        [wind72 release];
        //第三天温度
        UILabel *temp72=[[UILabel alloc] initWithFrame:CGRectMake( 620, 557, 80, 21)];
        temp72.font=[UIFont fontWithName:@"Helvetica" size:20];
        temp72.text=model._14ThiTemp;
        temp72.backgroundColor=[UIColor clearColor];
        temp72.textColor=[UIColor whiteColor];
        [temp72 setAdjustsFontSizeToFitWidth:YES];
        [uv addSubview:temp72];
        [temp72 release];
        //第三天天气图片
        UIImageView * ImgState72=[[UIImageView alloc] initWithFrame:CGRectMake( 690, 450, 100, 100)];
        ImgState72.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[model._17ThiImgState substringToIndex:[model._17ThiImgState rangeOfString:@"." ].location]]];
        [uv addSubview:ImgState72];
        [ImgState72 release];
    }
    
    
    [model release];
    
    
    return uv;
    
    
}


//对星期进行数据解析翻译
-(NSString *)getWeek:(NSString *)date
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd" ];
    NSDate *formatterDate = [inputFormatter dateFromString:date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"EEEE"];
    NSString *newDateString = [outputFormatter stringFromDate:formatterDate];
    [inputFormatter release];
    [outputFormatter release];
    //    NSLog(@"%@",newDateString);
    if ([newDateString isEqualToString:@"Monday"]) return @"星期一";
    else if([newDateString isEqualToString:@"Tuesday"])return @"星期二";
    else if([newDateString isEqualToString:@"Wednesday"])return @"星期三";
    else if([newDateString isEqualToString:@"Thursday"])return @"星期四";
    else if([newDateString isEqualToString:@"Friday"])return @"星期五";
    else if([newDateString isEqualToString:@"Saturday"])return @"星期六";
    else if([newDateString isEqualToString:@"Sunday"])return @"星期日";
    else return newDateString;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    int location=((int)scrollView.contentOffset.x)/((int)ScreenWidth);
    [self animation];
    UIInterfaceOrientation destOrientation=self.interfaceOrientation;
	if(destOrientation==UIInterfaceOrientationPortrait ||
	   destOrientation==UIInterfaceOrientationPortraitUpsideDown)
	{
        ScreenWidth=768;
        ScreenHeight=1024;
    }
    else
    {
        ScreenWidth=1024;
        ScreenHeight=768;
    }
    ((UIImageView *)[self.view viewWithTag:999]).frame=CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    if (ScreenWidth==768) 
        ((UIImageView *)[self.view viewWithTag:999]).image=[UIImage imageNamed:@"bg_wtx.jpg"];
    else 
    {
        ((UIImageView *)[self.view viewWithTag:999]).image=[UIImage imageNamed:@"bj-01.jpg"];
        ((UIImageView *)[self.view viewWithTag:999]).frame=CGRectMake(0, 0, ScreenWidth, ScreenWidth);
    }
    
    scrollView.frame=CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    sqlService *sql=[[sqlService alloc]init];
    remainCityModel=[sql getweatherinfo];
    for (int i=0; i<[remainCityModel count]; i++) {
        [(UIView *)[scrollView viewWithTag:1000+i] removeFromSuperview];
    }
    scrollView.contentSize=CGSizeMake(ScreenWidth*[remainCityModel count],ScreenHeight);
    for (int j=0; j<[remainCityModel count]; j++) {
        UIView *uv=[self DrawScrollerViews:ScreenWidth WithLength:ScreenHeight WithPosition:j];
        [scrollView addSubview:uv];
        [uv release];
    }
    scrollView.contentOffset=CGPointMake(ScreenWidth*location, 0);
    [sql release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initScrollerView];
    UIInterfaceOrientation destOrientation=self.interfaceOrientation;
	if(destOrientation==UIInterfaceOrientationPortrait ||
	   destOrientation==UIInterfaceOrientationPortraitUpsideDown)
	{
        ScreenWidth=768;
        ScreenHeight=1024;
    }
    else
    {
        ScreenWidth=1024;
        ScreenHeight=768;
    }
}


-(void)animation
{
    CATransition *animation = [CATransition animation];	
	animation.duration = 0.5f;	
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
    int value = (arc4random() % 12) + 1;
    switch (value) {
        case 1:
            animation.type = kCATransitionFade;
            break;
        case 2:
            animation.type = kCATransitionPush;
            break;
        case 3:
            animation.type = kCATransitionReveal;
            break;
        case 4:
            animation.type = kCATransitionMoveIn;
            break;
        case 5:
            animation.type = @"cube";
            break;
        case 6:
            animation.type = @"suckEffect";
            break;
        case 7:
            animation.type = @"oglFlip";
            break;
        case 8:
            animation.type = @"rippleEffect";
            break;
        case 9:
            animation.type = @"pageCurl";
            break;
        case 10:
            animation.type = @"pageUnCurl";
            break;
        case 11:
            animation.type = @"cameraIrisHollowOpen";
            break;
        case 12:
            animation.type = @"cameraIrisHollowClose";
            
            break;
            
        default:
            break;
    }
	int subtype=(arc4random()%4)+1;
	switch (subtype) {
        case 1:
            animation.subtype = kCATransitionFromLeft;
            break;
        case 2:
            animation.subtype = kCATransitionFromBottom;
            break;
        case 3:
            animation.subtype = kCATransitionFromRight;
            break;
        case 4:
            animation.subtype = kCATransitionFromTop;
            break;
            
        default:
            break;
    }	
	[self.view.layer addAnimation:animation forKey:@"animationID"];
}

@end
