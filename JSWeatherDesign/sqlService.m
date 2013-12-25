//
//  sqlService.m
//  Browser
//
//  Created by wtx on 12-4-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "sqlService.h"

@implementation sqlService

@synthesize _database;

- (id)init
{
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

//获取document目录并返回数据库目录
- (NSString *)dataFilePath{
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@",documentsDirectory);
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
	
}

//创建，打开数据库
- (BOOL)openDB {
	
	//获取数据库路径
	NSString *path = [self dataFilePath];
	//文件管理器
	NSFileManager *fileManager = [NSFileManager defaultManager];
	//判断数据库是否存在
	BOOL find = [fileManager fileExistsAtPath:path];
	
	//如果数据库存在，则用sqlite3_open直接打开（不要担心，如果数据库不存在sqlite3_open会自动创建）
	if (find) {
		
		NSLog(@"Database file have already existed.");
		
		//打开数据库，这里的[path UTF8String]是将NSString转换为C字符串，因为SQLite3是采用可移植的C(而不是
		//Objective-C)编写的，它不知道什么是NSString.
		if(sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
			
			//如果打开数据库失败则关闭数据库
			sqlite3_close(self._database);
			NSLog(@"Error: open database file.");
			return NO;
		}
		
		//创建一个新表
		[self CreatTable:self._database];
		
		return YES;
	}
	//如果发现数据库不存在则利用sqlite3_open创建数据库（上面已经提到过），与上面相同，路径要转换为C字符串
	if(sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
		
		//创建一个新表
		[self CreatTable:self._database];
		return YES;
    } else {
		//如果创建并打开数据库失败则关闭数据库
		sqlite3_close(self._database);
		NSLog(@"Error: open database file.");
		return NO;
    }
	return NO;
}
//创建表
- (BOOL) CreatTable:(sqlite3*)db {
	
	//这句是大家熟悉的SQL语句
//	char *sql = "create table if not exists weatherTable(ID INTEGER PRIMARY KEY AUTOINCREMENT,testValue text)";
	char *sql = "create table if not exists weatherTable(ID INTEGER PRIMARY KEY AUTOINCREMENT,_1CityName text, _2CityCode text, _3UpdateTime text, _4ToTemp text, _5ToInfo text, _6ToWind text, _7ToImgState text, _8ToForcast text,_9ToLifeIndex text, _10SecTemp text, _11SecInfo text, _12SecWind text, _13SecImgState text, _14ThiTemp text, _15ThiInfo text, _16ThiWind text, _17ThiImgState text)";
	sqlite3_stmt *statement;
	//sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
	NSInteger sqlReturn = sqlite3_prepare_v2(_database, sql, -1, &statement, nil);
	//第一个参数跟前面一样，是个sqlite3 * 类型变量，
	//第二个参数是一个 sql 语句。
	//第三个参数我写的是-1，这个参数含义是前面 sql 语句的长度。如果小于0，sqlite会自动计算它的长度（把sql语句当成以\0结尾的字符串）。
	//第四个参数是sqlite3_stmt 的指针的指针。解析以后的sql语句就放在这个结构里。
	//第五个参数我也不知道是干什么的。为nil就可以了。
	//如果这个函数执行成功（返回值是 SQLITE_OK 且 statement 不为NULL ），那么下面就可以开始插入二进制数据。
	
	
	//如果SQL语句解析出错的话程序返回
	if(sqlReturn != SQLITE_OK) {
		NSLog(@"Error: failed to prepare statement:create test table");
		return NO;
	}
	
	//执行SQL语句
	int success = sqlite3_step(statement);
	//释放sqlite3_stmt 
	sqlite3_finalize(statement);
	
	//执行SQL语句失败
	if ( success != SQLITE_DONE) {
		NSLog(@"Error: failed to dehydrate:create table test");
		return NO;
	}
	NSLog(@"Create table 'weatherTable' successed.");
	return YES;
}

//插入数据
-(BOOL) insertModel:(ModelWeather *)insertList {
    
    NSMutableArray *tempdata=[[NSMutableArray alloc]init];
	tempdata=[self getweatherinfo];
    NSMutableArray *hisvalue=[[NSMutableArray alloc]init ];
    for (int i=0; i<[tempdata count]; i++) {
        [hisvalue addObject:((ModelWeather *)[tempdata objectAtIndex:i])._1CityName];
        NSLog(@"%@",[hisvalue objectAtIndex:i]);
        NSLog(@"%@",((ModelWeather *)[tempdata objectAtIndex:i])._2CityCode);
    }
    [tempdata release];
    //如果本地有,则不插入新的数据
    if (![hisvalue containsObject:insertList._1CityName]) {
	//先判断数据库是否打开
	if ([self openDB]) {
		
		sqlite3_stmt *statement;
		
		//这个 sql 语句特别之处在于 values 里面有个? 号。在sqlite3_prepare函数里，?号表示一个未定的值，它的值等下才插入。
		static char *sql = "INSERT INTO weatherTable( _1CityName,_2CityCode,_3UpdateTime,_4ToTemp,_5ToInfo,_6ToWind,_7ToImgState,_8ToForcast,_9ToLifeIndex,_10SecTemp,_11SecInfo,_12SecWind,_13SecImgState,_14ThiTemp,_15ThiInfo,_16ThiWind,_17ThiImgState) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		
		int success2 = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
		if (success2 != SQLITE_OK) {
			NSLog(@"Error: failed to insert:weatherTable");
			sqlite3_close(_database);
			return NO;
		}
		
		//这里的数字1，2，3代表第几个问号，这里将两个值绑定到两个绑定变量
		
		sqlite3_bind_text(statement, 1, [insertList._1CityName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [insertList._2CityCode UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [insertList._3UpdateTime UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [insertList._4ToTemp UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [insertList._5ToInfo UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [insertList._6ToWind UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 7, [insertList._7ToImgState UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 8, [insertList._8ToForcast UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 9, [insertList._9ToLiftIndex UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 10, [insertList._10SecTemp UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 11, [insertList._11SecInfo UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 12, [insertList._12SecWind UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 13, [insertList._13SecImgState UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 14, [insertList._14ThiTemp UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 15, [insertList._15ThiInfo UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 16, [insertList._16ThiWind UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 17, [insertList._17ThiImgState UTF8String], -1, SQLITE_TRANSIENT);
        
		//执行插入语句
		success2 = sqlite3_step(statement);
		//释放statement
		sqlite3_finalize(statement);
		
		//如果插入失败
		if (success2 == SQLITE_ERROR) {
			NSLog(@"Error: failed to insert into the database with message.");
			//关闭数据库
			sqlite3_close(_database);
			return NO;
		}
		//关闭数据库
		sqlite3_close(_database);
		return YES;
	}
    }
    
    [hisvalue release];
	return NO;
    
    
}


//获取数据
- (NSMutableArray*)getweatherinfo{
	
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:1000];
	//判断数据库是否打开
	if ([self openDB]) {
		
		sqlite3_stmt *statement = nil;
		//sql语句
		char *sql = "SELECT * FROM weatherTable";
		
		if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
			NSLog(@"Error: failed to prepare statement with message:get testValue.");
			return NO;
		}
		else {
			//查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
			while (sqlite3_step(statement) == SQLITE_ROW) {
				ModelWeather* sqlList = [[ModelWeather alloc] init] ;
				sqlList._1CityName = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
                sqlList._2CityCode = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
                sqlList._3UpdateTime = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
                sqlList._4ToTemp = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
                sqlList._5ToInfo = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
                sqlList._6ToWind = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 6)];
                sqlList._7ToImgState = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 7)];
                sqlList._8ToForcast = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 8)];
                sqlList._9ToLiftIndex = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 9)];
                sqlList._10SecTemp = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 10)];
                sqlList._11SecInfo = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 11)];
                sqlList._12SecWind = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 12)];
                sqlList._13SecImgState = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 13)];
                sqlList._14ThiTemp = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 14)];
                sqlList._15ThiInfo = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 15)];
                sqlList._16ThiWind = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 16)];
                sqlList._17ThiImgState = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 17)];
                [array addObject:sqlList];
				[sqlList release];
			}
		}
		sqlite3_finalize(statement);
		sqlite3_close(_database);
	}
	
	return [array retain];
}

//删除数据
- (BOOL) deleteWeatherModel:(NSString *)Cityname{
	if ([self openDB]) {
		
		sqlite3_stmt *statement;
		//组织SQL语句
		static char *sql = "delete from weatherTable where _1CityName=? ";
		//将SQL语句放入sqlite3_stmt中
		int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
		if (success != SQLITE_OK) {
			NSLog(@"Error: failed to delete:weatherTable");
			sqlite3_close(_database);
			return NO;
		}
		
		//这里的数字1，2，3代表第几个问号。这里只有1个问号，这是一个相对比较简单的数据库操作，真正的项目中会远远比这个复杂
		//当掌握了原理后就不害怕复杂了
		
		sqlite3_bind_text(statement, 1, [Cityname UTF8String], -1, SQLITE_TRANSIENT);
		
		//执行SQL语句。这里是更新数据库
		success = sqlite3_step(statement);
		//释放statement
		sqlite3_finalize(statement);
		
		//如果执行失败
		if (success == SQLITE_ERROR) {
			NSLog(@"Error: failed to delete the database with message.");
			//关闭数据库
			sqlite3_close(_database);
			return NO;
		}
		//执行成功后依然要关闭数据库
		sqlite3_close(_database);
		return YES;
	}
	return NO;
	
}

//更新数据
-(BOOL) updateTestList:(ModelWeather *)Updatemodel{
	
	if ([self openDB]) {
		
		//我想下面几行已经不需要我讲解了，嘎嘎 
		sqlite3_stmt *statement;
		//组织SQL语句
		char *sql = "update weatherTable set _2CityCode=?,_3UpdateTime=?,_4ToTemp=?,_5ToInfo=?,_6ToWind=?,_7ToImgState=?,_8ToForcast=?,_9ToLifeIndex=?,_10SecTemp=?,_11SecInfo=?,_12SecWind=?,_13SecImgState=?,_14ThiTemp=?,_15ThiInfo=?,_16ThiWind=?,_17ThiImgState=? where _1CityName=? ";
		
		//将SQL语句放入sqlite3_stmt中
		int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
		if (success != SQLITE_OK) {
			NSLog(@"Error: failed to update:testTable");
			sqlite3_close(_database);
			return NO;
		}
		
		//这里的数字1，2，3代表第几个问号。这里只有1个问号，这是一个相对比较简单的数据库操作，真正的项目中会远远比这个复杂
		//当掌握了原理后就不害怕复杂了
		sqlite3_bind_text(statement, 1, [Updatemodel._2CityCode UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 2, [Updatemodel._3UpdateTime UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [Updatemodel._4ToTemp UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [Updatemodel._5ToInfo UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [Updatemodel._6ToWind UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [Updatemodel._7ToImgState UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 7, [Updatemodel._8ToForcast UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 8, [Updatemodel._9ToLiftIndex UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 9, [Updatemodel._10SecTemp UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 10, [Updatemodel._11SecInfo UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 11, [Updatemodel._12SecWind UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 12, [Updatemodel._13SecImgState UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 13, [Updatemodel._14ThiTemp UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 14, [Updatemodel._15ThiInfo UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 15, [Updatemodel._16ThiWind UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 16, [Updatemodel._17ThiImgState UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 17, [Updatemodel._1CityName UTF8String], -1, SQLITE_TRANSIENT);
		
		//执行SQL语句。这里是更新数据库
		success = sqlite3_step(statement);
		//释放statement
		sqlite3_finalize(statement);
		
		//如果执行失败
		if (success == SQLITE_ERROR) {
			NSLog(@"Error: failed to update the database with message.");
			//关闭数据库
			sqlite3_close(_database);
			return NO;
		}
		//执行成功后依然要关闭数据库
		sqlite3_close(_database);
		return YES;
	}
	return NO;
}



@end
@implementation CityData
@synthesize _database;

- (id)init
{
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

//获取document目录并返回数据库目录
- (NSString *)dataFilePath{
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@",documentsDirectory);
	return [documentsDirectory stringByAppendingPathComponent:kCitydata];
	
}

//创建，打开数据库
- (BOOL)openDB {
	
	//获取数据库路径
	NSString *path = [self dataFilePath];
	//文件管理器
	NSFileManager *fileManager = [NSFileManager defaultManager];
	//判断数据库是否存在
	BOOL find = [fileManager fileExistsAtPath:path];
	
	//如果数据库存在，则用sqlite3_open直接打开（不要担心，如果数据库不存在sqlite3_open会自动创建）
	if (find) {
		
		NSLog(@"Database file have already existed.");
		
		//打开数据库，这里的[path UTF8String]是将NSString转换为C字符串，因为SQLite3是采用可移植的C(而不是
		//Objective-C)编写的，它不知道什么是NSString.
		if(sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
			
			//如果打开数据库失败则关闭数据库
			sqlite3_close(self._database);
			NSLog(@"Error: open database file.");
			return NO;
		}
		
		//创建一个新表
		[self CreatTable:self._database];
		
		return YES;
	}
	//如果发现数据库不存在则利用sqlite3_open创建数据库（上面已经提到过），与上面相同，路径要转换为C字符串
	if(sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
		
		//创建一个新表
		[self CreatTable:self._database];
		return YES;
    } else {
		//如果创建并打开数据库失败则关闭数据库
		sqlite3_close(self._database);
		NSLog(@"Error: open database file.");
		return NO;
    }
	return NO;
}
//创建表
- (BOOL) CreatTable:(sqlite3*)db {
	
	//这句是大家熟悉的SQL语句
    //	char *sql = "create table if not exists weatherTable(ID INTEGER PRIMARY KEY AUTOINCREMENT,testValue text)";
	char *sql = "create table if not exists Citydata(ID INTEGER PRIMARY KEY AUTOINCREMENT,CityName text)";
	sqlite3_stmt *statement;
	//sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
	NSInteger sqlReturn = sqlite3_prepare_v2(_database, sql, -1, &statement, nil);
	//第一个参数跟前面一样，是个sqlite3 * 类型变量，
	//第二个参数是一个 sql 语句。
	//第三个参数我写的是-1，这个参数含义是前面 sql 语句的长度。如果小于0，sqlite会自动计算它的长度（把sql语句当成以\0结尾的字符串）。
	//第四个参数是sqlite3_stmt 的指针的指针。解析以后的sql语句就放在这个结构里。
	//第五个参数我也不知道是干什么的。为nil就可以了。
	//如果这个函数执行成功（返回值是 SQLITE_OK 且 statement 不为NULL ），那么下面就可以开始插入二进制数据。
	
	
	//如果SQL语句解析出错的话程序返回
	if(sqlReturn != SQLITE_OK) {
		NSLog(@"Error: failed to prepare statement:create test table");
		return NO;
	}
	
	//执行SQL语句
	int success = sqlite3_step(statement);
	//释放sqlite3_stmt 
	sqlite3_finalize(statement);
	
	//执行SQL语句失败
	if ( success != SQLITE_DONE) {
		NSLog(@"Error: failed to dehydrate:create table citydata");
		return NO;
	}
	NSLog(@"Create table 'citydata' successed.");
	return YES;
}

//插入数据
-(BOOL) insertArray:(NSMutableArray *)insertList {
        //先判断数据库是否打开
        if ([self openDB]) {
            for (int i=0; i<[insertList count]; i++) {
                if ([self openDB]) {
                sqlite3_stmt *statement;
                //这个 sql 语句特别之处在于 values 里面有个? 号。在sqlite3_prepare函数里，?号表示一个未定的值，它的值等下才插入。
                static char *sql = "INSERT INTO Citydata(CityName) VALUES(?)";
                int success2 = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
                if (success2 != SQLITE_OK) {
                    NSLog(@"Error: failed to insert:Citydata");
                    sqlite3_close(_database);
                    return NO;
                }
                //这里的数字1，2，3代表第几个问号，这里将两个值绑定到两个绑定变量
                sqlite3_bind_text(statement, 1, [[insertList objectAtIndex:i] UTF8String], -1, SQLITE_TRANSIENT);
                //执行插入语句
                success2 = sqlite3_step(statement);
                //释放statement
                sqlite3_finalize(statement);
                
                //如果插入失败
                if (success2 == SQLITE_ERROR) {
                    NSLog(@"Error: failed to insert into the database with message.");
                    //关闭数据库
                    sqlite3_close(_database);
                    return NO;
                }
                //关闭数据库
                sqlite3_close(_database);
            }
            }
            return YES;
        }
	return NO;
}

//获取数据
- (NSMutableArray*)getcitys{
	
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:10000];
	//判断数据库是否打开
	if ([self openDB]) {
		
		sqlite3_stmt *statement = nil;
		//sql语句
		char *sql = "SELECT * FROM Citydata";
		
		if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
			NSLog(@"Error: failed to prepare statement with message:get testValue.");
			return NO;
		}
		else {
			//查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
			while (sqlite3_step(statement) == SQLITE_ROW) {
                [array addObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)]];
			}
		}
		sqlite3_finalize(statement);
		sqlite3_close(_database);
	}
	
	return [array retain];
}
@end




@implementation ModelWeather


@synthesize _1CityName;
@synthesize _2CityCode;
@synthesize _3UpdateTime;
@synthesize _4ToTemp;
@synthesize _5ToInfo;
@synthesize _6ToWind;
@synthesize _7ToImgState;
@synthesize _8ToForcast;
@synthesize _9ToLiftIndex;
@synthesize _10SecTemp;
@synthesize _11SecInfo;
@synthesize _12SecWind;
@synthesize _13SecImgState;
@synthesize _14ThiTemp;
@synthesize _15ThiInfo;
@synthesize _16ThiWind;
@synthesize _17ThiImgState;
-(id) init
{
	_1CityName = @"";
    _2CityCode=@"";
    _3UpdateTime=@"";
    _4ToTemp=@"";
    _5ToInfo=@"";
    _6ToWind=@"";
    _7ToImgState=@"";
    _8ToForcast=@"";
    _9ToLiftIndex=@"";
    _10SecTemp=@"";
    _11SecInfo=@"";
    _12SecWind=@"";
    _13SecImgState=@"";
    _14ThiTemp=@"";
    _15ThiInfo=@"";
    _16ThiWind=@"";
    _17ThiImgState=@"";
	return self;
};
-(void) dealloc
{
	if (_1CityName != nil) {
		[_1CityName release];
	}
    if (_2CityCode != nil) {
		[_2CityCode release];
	}
    if (_3UpdateTime!=nil) {
        [_3UpdateTime release];
    }
    if (_4ToTemp != nil) {
		[_4ToTemp release];
	}
    if (_5ToInfo != nil) {
		[_5ToInfo release];
	}
    if (_6ToWind != nil) {
		[_6ToWind release];
	}
    if (_7ToImgState != nil) {
		[_7ToImgState release];
	}
    if (_8ToForcast != nil) {
		[_8ToForcast release];
	}
    if (_9ToLiftIndex != nil) {
		[_9ToLiftIndex release];
	}
    if (_10SecTemp != nil) {
		[_10SecTemp release];
	}
    if (_11SecInfo != nil) {
		[_11SecInfo release];
	}
    if (_12SecWind != nil) {
		[_12SecWind release];
	}
    if (_13SecImgState != nil) {
		[_13SecImgState release];
	}
    if (_14ThiTemp != nil) {
		[_14ThiTemp release];
	}
    if (_15ThiInfo != nil) {
		[_15ThiInfo release];
	}
    if (_16ThiWind != nil) {
		[_16ThiWind release];
	}
    if (_17ThiImgState != nil) {
		[_17ThiImgState release];
	}
 
	[super dealloc];
}

@end

