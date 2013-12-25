    //
//  CityTableListViewController.m
//  WeatherInfo
//
//  Created by Wu Jing on 11-5-12.
//  Copyright 2011 cfmetinfo. All rights reserved.
//

#import "CityTableListViewController.h"
#import "RemainCityTableViewController.h"
#import "WeatherViewController.h"
#import "sqlService.h"
#import "ChineseToPinyin.h"
@implementation CityTableListViewController
@synthesize searchBar;
@synthesize searchDC;
@synthesize _delegate;
@synthesize remainCity;
@synthesize cityNames;
@synthesize allCitys;
@synthesize FilterArray;
@synthesize fileArray;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	if(aTableView==self.tableView)
	return cityNames.count;
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", self.searchBar.text];
        self.FilterArray=[self.fileArray.allKeys filteredArrayUsingPredicate:predicate];
        return [self.FilterArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] autorelease];
    if (tView==self.tableView) {
        cell.textLabel.text = [cityNames objectAtIndex:indexPath.row];
        return cell;
    }
	else
    {
       
        NSString *cellvalue=[self.FilterArray objectAtIndex:indexPath.row];
        cell.textLabel.text=cellvalue;
       
        return  cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    if (tableView==self.tableView) {
        NSString *cityName = [cityNames objectAtIndex:indexPath.row];
            [_delegate citySelected:cityName];
        
    }
    else
    {
        NSString *cityName = [self.FilterArray objectAtIndex:indexPath.row];
            [_delegate citySelected:[cityName substringToIndex:[cityName rangeOfString:@" "].location]];
        
    }
    
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
	cityNames= [[NSMutableArray alloc] init];
	[cityNames addObject:@"南京"];
	[cityNames addObject:@"无锡"];
	[cityNames addObject:@"徐州"];
	[cityNames addObject:@"常州"];
	[cityNames addObject:@"苏州"];
	[cityNames addObject:@"南通"];
	[cityNames addObject:@"连云港"];
	[cityNames addObject:@"淮安"];
	[cityNames addObject:@"盐城"];
	[cityNames addObject:@"扬州"];
	[cityNames addObject:@"镇江"];
	[cityNames addObject:@"泰州"];
	[cityNames addObject:@"宿迁"];
    //[cityNames addObject:@"上海"];
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] autorelease];
	self.searchBar.tintColor = [UIColor blackColor];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeAlphabet;
	self.tableView.tableHeaderView = self.searchBar;
	
	// Create the search display controller
	self.searchDC = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;
	
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewDidLoad
{
    [super viewDidLoad];
    remainCity =[[NSMutableArray alloc]init];
    allCitys=[[NSMutableArray alloc]init];
    fileArray=[[NSMutableDictionary alloc] init];
    CityData *allcitys=[[CityData alloc]init];
    
    allCitys=[allcitys getcitys];
    NSLog(@"总共提供城市个数%d",[allCitys count]);
    for (int i=0; i<[allCitys count]; i++) {
        NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
        //NSLog(@"%@",[allCitys objectAtIndex:i]);
        ChineseToPinyin *Addpinpin=[[ChineseToPinyin alloc]init];
        //NSLog(@"%@",[Addpinpin pinyinFromChiniseString:[allCitys objectAtIndex:i]]);
        NSString *city=[NSString stringWithFormat:@"%@ %@",[allCitys objectAtIndex:i],[Addpinpin pinyinFromChiniseString:[allCitys objectAtIndex:i]]];
       // NSLog(@"city %@",city);
        [fileArray setObject:city forKey:city];
        [Addpinpin release];
        [pool release];
    }
    [allcitys release];
    [self.tableView reloadData];
}





/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self._delegate=nil;
    [remainCity release];
    [cityNames release];
    [allCitys release];
    [FilterArray release];
    [fileArray release];
    [super dealloc];
}


@end
