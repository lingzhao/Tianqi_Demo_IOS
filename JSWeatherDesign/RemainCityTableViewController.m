    //
//  RemainCityTableViewController.m
//  WeatherInfo
//
//  Created by Wu Jing on 11-5-17.
//  Copyright 2011 cfmetinfo. All rights reserved.
//

#import "RemainCityTableViewController.h"
#import "sqlService.h"

@implementation RemainCityTableViewController
@synthesize remainCityDelegate;
@synthesize cityArray;

-(void)enterEditMode
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	[self.tableView setEditing:YES animated:YES];
}

//-(void)leaveEditMode
//{
//	[self.tableView setEditing:YES animated:YES];
//}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
	return @"删除";
}


- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// No deletions actually take place and no fonts are harmed
    NSString *cityName=[cityArray objectAtIndex:indexPath.row];
    sqlService *sqlservice=[[sqlService alloc]init];
    [sqlservice deleteWeatherModel:cityName];
    [sqlservice release];
     //删除后scorllerview重绘
    [remainCityDelegate cityDeleted:cityName];
    [cityArray removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	
	return 1; 
}



- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	return cityArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] autorelease];
	cell.textLabel.text = [cityArray objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSLog(@"%@",[cityArray objectAtIndex:indexPath.row]);
	
}


-(void)viewDidLoad
{
    cityArray =[[NSMutableArray alloc]init];
    sqlService *sqlservice=[[sqlService alloc]init];
    ModelWeather *weatherModle=[[ModelWeather alloc]init];
    NSMutableArray *Modellist=[[NSMutableArray alloc]init];
    Modellist=[sqlservice getweatherinfo];
    for (int i=0; i<[Modellist count]; i++) {
        [cityArray addObject:((ModelWeather *)[Modellist objectAtIndex:i])._1CityName];
        NSLog(@"remaincity%@",[cityArray objectAtIndex:i]);
    }
    [Modellist release];
    [weatherModle release];
    [sqlservice release];
    [self enterEditMode];
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.



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
	[cityArray release];
	remainCityDelegate=nil;
    [super dealloc];
}


@end
