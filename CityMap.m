//
//  CityMap.m
//  tube
//
//  Created by Alex 1 on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CityMap.h"
#import "CatmullRomSpline.h"
#include "ini.h"
#import <CoreLocation/CoreLocation.h>

@implementation CityMap

@synthesize w;
@synthesize h;
@synthesize linesCount;
@synthesize addNodesCount;
@synthesize linesCoord;
@synthesize linesCoordForText;
@synthesize linesColors;
@synthesize stationsData;
@synthesize stationsName;
@synthesize stationsTime;
@synthesize utils;
@synthesize addNodes;
@synthesize transfersCount;
@synthesize graph;
@synthesize transfersTime;
@synthesize contentAZForTableView,contentLinesForTableView;
@synthesize gpsCoords;
@synthesize allStationsNames;
@synthesize koef;
@synthesize gpsCoordsCount;
@synthesize linesIndex;
@synthesize linesNames;

@synthesize currentLineNum;
@synthesize drawedStations;
@synthesize view;
@synthesize labelPlaced;


NSInteger const kDataShift=5;
NSInteger const kDataRowForLine=5;

-(void) initMap:(NSString*) mapName {
	[self initVars];
	[self loadMap:mapName];
	[self calcGraph];
}

-(void) initVars {
    drawedStations =  [[NSMutableDictionary alloc] init];
    kLineWidth = 9.f;
	utils = [[[Utils alloc] init] autorelease];
	linesCoord = [[NSMutableArray alloc] init];
	linesIndex = [[NSMutableDictionary alloc] init];
	linesCoordForText = [[NSMutableArray alloc] init];	
	linesColors = [[NSMutableArray alloc] init];
	stationsTime = [[NSMutableArray alloc] init];
	stationsData = [[NSMutableArray alloc] init];
	stationsName = [[NSMutableArray alloc] init];
	addNodes = [[NSMutableDictionary alloc] init];
	transfersTime = [[NSMutableDictionary alloc] init];
	contentAZForTableView = [[NSMutableDictionary alloc] init];
	linesNames = [[NSMutableArray alloc] init];
	gpsCoords = [[NSMutableDictionary alloc] init];
	graph = [[Graph graph] retain];
	allStationsNames = [[NSMutableDictionary alloc] init];
    //обе метки с названиями еще не выставлены
    labelPlaced = false;
	
	//NSMutableDictionary *coords = [[NSMutableDictionary alloc] init];
	//[coords setObject:[NSNumber numberWithDouble:] forKey:@"x"];

	koef = 2;
	/*
	Ch. De Gaulle - Etoile
	48.873917, 2.294598
	Argentine
	48.875385,  2.290049
	George V
	48.871913, 2.300477
	Franklin D. Roosevelt
	48.868949, 2.310047
	*/
	
	/*
	[gpsCoords setObject:[[[CLLocation alloc] initWithLatitude:48.873917 longitude:2.294598] autorelease] 
				  forKey:@"Ch. De Gaulle - Etoile"];

	[gpsCoords setObject:[[[CLLocation alloc] initWithLatitude:48.875385 longitude:2.290049] autorelease] 
				  forKey:@"Argentine"];

	[gpsCoords setObject:[[[CLLocation alloc] initWithLatitude:48.871913 longitude:2.300477] autorelease] 
				  forKey:@"George V"];

	[gpsCoords setObject:[[[CLLocation alloc] initWithLatitude:48.868949 longitude:2.310047] autorelease] 
				  forKey:@"Franklin D. Roosevelt"];

	*/
	
}
-(void) loadMap:(NSString *)mapName{
	INIParser* parser;
	
	parser = [[INIParser alloc] init];
	
	int err;
	
	NSString* str = [[NSBundle mainBundle] pathForResource:@"paris2" ofType:@"trp"]; 
	char cstr[512] = {0}; 
	
	[str getCString:cstr maxLength:512 encoding:NSASCIIStringEncoding]; 
	err = [parser parse:cstr];	

	linesCount = [[parser get:@"LinesCount" section:@"main"] integerValue];
	
	NSArray *size = [[parser get:@"Size" section:@"main"] componentsSeparatedByString:@","];
	w = ([[size objectAtIndex:0] integerValue]*koef);
	h = ([[size objectAtIndex:1] integerValue]*koef);

	for (int i =0 ;i<linesCount; i++) {
		NSString *sectionName = [NSString stringWithFormat:@"Line%d", i+1 ];
		NSString *lineName = [parser get:@"Name" section:sectionName];
		[linesNames addObject:lineName];
		[linesIndex setObject:[NSNumber numberWithInt:i+1	] forKey:lineName];

		NSString *colors = [parser get:@"Color" section:lineName];
		[self processLinesColors:colors];
		
		NSString *coords = [parser get:@"Coordinates" section:lineName];
		[self processLinesCoord:[coords componentsSeparatedByString:@", "]];

		NSString *coordsText = [parser get:@"Rects" section:lineName];
		[self processLinesCoordForText:[coordsText componentsSeparatedByString:@", "]];
		
		NSString *stations = [parser get:@"Stations" section:sectionName];
		[self processLinesStations:stations	:i];
		
		NSString *coordsTime = [parser get:@"Driving" section:sectionName];
		[self processLinesTime:coordsTime :i];
	}
	
/*	for (int i =0 ; i<(addNodesCount); i++) {
		[self processAddNodes:[map objectAtIndex:i+kDataShift+linesCount*kDataRowForLine]];
	}*/
	
	int counter = 0;
	INISection *section = [parser getSection:@"AdditionalNodes"];
	NSMutableDictionary *as = [section assignments];
	for (NSString* key in as) {
		NSString *value = [parser get:key section:@"AdditionalNodes"];
		[self processAddNodes:value];
		counter++;
	}
	addNodesCount = counter;

	counter = 0;
	INISection *section2 = [parser getSection:@"Transfers"];
	NSMutableDictionary *as2 = [section2 assignments];
	for (NSString* key in as2) {
		NSString *value = [parser get:key section:@"Transfers"];
		[self processTransfers:value];
		counter++;
	}
	transfersCount = counter;
	
	counter = 0;
	INISection *section3 = [parser getSection:@"gps"];
	NSMutableDictionary *as3 = [section3 assignments];
	for (NSString* key in as3) {
		NSString *value = [parser get:key section:@"gps"];
		[self processGPS :key :value];
		counter++;
	}
	gpsCoordsCount = counter;
	[parser release];
}

-(NSArray*) calcPath :(NSString*) firstStation :(NSString*) secondStation :(NSInteger) firstStationLineNum :(NSInteger)secondStationLineNum {

	
	NSString *name1 = [firstStation stringByAppendingString:[NSString stringWithFormat:@"|%d", firstStationLineNum]];
	NSString *name2 = [secondStation stringByAppendingString:[NSString stringWithFormat:@"|%d", secondStationLineNum]];
	DLog(@" %@ %@ ",name1,name2);
	
	NSArray *pp = [graph shortestPath:[GraphNode nodeWithValue:name1] to:[GraphNode nodeWithValue:name2]];
	 
	return pp;
}
-(void) processGPS: (NSString*) station :(NSString*) lineCoord {
	
	NSArray *elements = [lineCoord componentsSeparatedByString:@","];
	
	CLLocation *et = [[[CLLocation alloc] initWithLatitude:[[elements objectAtIndex:0] floatValue] 
												 longitude:[[elements objectAtIndex:1] floatValue]
															] autorelease];
	
	[gpsCoords setObject:et forKey:station];
}
-(void) processTransfers:(NSString*)transferInfo{
	
	NSArray *elements = [transferInfo componentsSeparatedByString:@","];
	NSMutableDictionary *transferData = [[NSMutableDictionary alloc] init];

	NSString *lineStation1 = [[linesIndex objectForKey:[elements objectAtIndex:0]] stringValue];
	NSString *lineStation2 = [[linesIndex objectForKey:[elements objectAtIndex:2]] stringValue];
	
	[transferData setObject:lineStation1 forKey:@"lineStation1"];
	[transferData setObject:[elements objectAtIndex:1] forKey:@"stationName1"];
	[transferData setObject:lineStation2 forKey:@"lineStation2"];
	[transferData setObject:[elements objectAtIndex:3] forKey:@"stationName2"];
	[transferData setObject:[elements objectAtIndex:4] forKey:@"transferTime"];	
	
	NSMutableArray *transferTimeTemp ;
	transferTimeTemp = [transfersTime objectForKey:[elements objectAtIndex:1]];
	if (transferTimeTemp==nil)
	{
		transferTimeTemp = [[NSMutableArray alloc] init];
	}

	[transferTimeTemp addObject:transferData];
	///[transferTimeTemp setObject:transferData forKey:[NSString stringWithFormat:@"%@%@%@%@" , [elements objectAtIndex:0], [elements objectAtIndex:1], [elements objectAtIndex:2],[elements objectAtIndex:3] ]];

	[transfersTime setObject:transferTimeTemp forKey:[elements objectAtIndex:1]];
}


-(void) processAddNodes:(NSString*)addNodeInfo{
	
	NSArray *elements = [addNodeInfo componentsSeparatedByString:@", "];

	
	NSMutableArray *splinePoints = [[NSMutableArray alloc] init];
	for (int i=1; i<([elements count]-1); i++) {
		[splinePoints addObject:[elements objectAtIndex:i]];
	}
	//expected 3+ elements
	//separate line sations info
	NSArray *stations = [[elements objectAtIndex:0] componentsSeparatedByString:@","];
	
	//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

	NSString *lineName = [stations objectAtIndex:0];
	NSNumber *num = [linesIndex objectForKey:lineName];
	
	[addNodes setObject:splinePoints forKey:[NSString stringWithFormat:@"%d,%@,%@" , [num intValue] , [stations objectAtIndex:1], [stations objectAtIndex:2]]];
	
	//[dict setObject:splinePoints forKey:[[[stations objectAtIndex:1] stringByAppendingString:@","] stringByAppendingString:[stations objectAtIndex:2]]];
//	[addNodes setObject:splinePoints forKey:[[[stations objectAtIndex:1] stringByAppendingString:@","] stringByAppendingString:[stations objectAtIndex:2]]];
	
}
-(void) processLinesTime:(NSString*) lineTime :(NSUInteger) line{

//	NSMutableDictionary *lineTimes = [[NSMutableDictionary alloc] init];
	NSMutableArray *lineStationsTime = [[NSMutableArray alloc] init];
	
	//NSUInteger location=0;
	NSUInteger location2=0;
	Boolean endline=false;
	
	NSString *new_s = nil;
	
	NSString *remained_stationTime = lineTime;
	
	int i = 0;
	while ([remained_stationTime length] != 0) {
		if ([remained_stationTime rangeOfString:@","].location!=NSNotFound)
			location2 = [remained_stationTime rangeOfString:@","].location;
		else
		{
			endline = true;
			location2 = [remained_stationTime length];	
		}
		new_s = [remained_stationTime substringToIndex:location2];
		
		if ([new_s rangeOfString:@"("].location==NSNotFound)
		{
			
			NSString *newstring = [remained_stationTime substringToIndex:location2];
			[lineStationsTime addObject:newstring];
			
			i++;
			if (!endline)
				remained_stationTime = [remained_stationTime substringFromIndex:location2+1];			
			else
				remained_stationTime = [remained_stationTime substringFromIndex:location2];							
			continue;
		}
		else
		{
			
			
			if ([new_s rangeOfString:@")"].location==NSNotFound)
			{
				location2 = [remained_stationTime rangeOfString:@")"].location+1;
				
			}
			NSString *newstring = [remained_stationTime substringToIndex:location2]; // +1 
			
			NSUInteger location3 = [newstring rangeOfString:@"("].location;
			NSString *stationTime = [newstring substringToIndex:location3];
			
			NSString *stringForSub = [newstring substringWithRange:NSMakeRange(location3+1, [newstring length]-2-(location3))];
			
			
			// для случвкы с (,station_name)
			NSArray *stationsTime_list;
			if ([stringForSub rangeOfString:@","].location==0)
				stationsTime_list = [[stringForSub substringFromIndex:1] componentsSeparatedByString:@","];
			else {
			stationsTime_list = [stringForSub componentsSeparatedByString:@","];			
			}

			NSMutableArray *list = [[NSMutableArray alloc] init];
			
			for (int i = 0; i<[stationsTime_list count]; i++) {
				[list addObject:[stationsTime_list objectAtIndex:i]];
			}
			
			NSString *currentStationName = [[stationsName objectAtIndex:line] objectAtIndex:i];
			
			NSMutableDictionary *stationDataDict = [[stationsData objectAtIndex:line] objectForKey:currentStationName];
			[stationDataDict setObject:list forKey:@"linked_time"];
			
			NSMutableDictionary *newDict = [stationsData objectAtIndex:line];
			[newDict setObject:stationDataDict forKey:currentStationName];
			
			[stationsData replaceObjectAtIndex:line withObject:newDict];
			
			//[lineTimes setObject:dict forKey:stationTime];
			[lineStationsTime addObject:stationTime];
			i++;
			if(!endline)
				remained_stationTime = [remained_stationTime substringFromIndex:location2+1]; // +2			
			else
				remained_stationTime = [remained_stationTime substringFromIndex:location2];							
		}
	}
//	[stationsData addObject:lineTimes];
	[stationsTime addObject:lineStationsTime];
	
}
-(void) sortSectionDataForTable {
	// Sort each section array
    for (NSString *key in [contentAZForTableView allKeys])
    {
	   //[[contentAZForTableView objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    }
}

-(void) prepareStationForTable:(NSString*) stationName :(NSInteger)line{
	//add for line
	
	
	//add for A..Z
	NSString *c = [stationName substringToIndex:1];

	if ([contentAZForTableView objectForKey:c]!=nil)
	{
		[[contentAZForTableView objectForKey:c] addObject:stationName];
	}
	else {
		[contentAZForTableView setObject:[[NSMutableArray alloc] init] forKey:c];
		[[contentAZForTableView objectForKey:c] addObject:stationName];		
	}
	
}

-(void) processLinesStations:(NSString*) stations :(NSUInteger) line{

	NSMutableDictionary *lineStations = [[NSMutableDictionary alloc] init];
	NSMutableArray *lineStationsName = [[NSMutableArray alloc] init];
	
	//NSUInteger location=0;
	NSUInteger location2=0;
	Boolean endline=false;
	
	NSString *new_s = nil;

	NSString *remained_station = stations;

	int i = 0;
	while ([remained_station length] != 0) {
		if ([remained_station rangeOfString:@","].location!=NSNotFound)
			location2 = [remained_station rangeOfString:@","].location;
		else
		{
			endline = true;
			location2 = [remained_station length];	
		}
		new_s = [remained_station substringToIndex:location2];

		if ([new_s rangeOfString:@"("].location==NSNotFound)
		{
			NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

			NSString *newstring = [remained_station substringToIndex:location2];
			[dict setObject:newstring forKey:newstring];
			[dict setObject:[[linesCoord objectAtIndex:line] objectAtIndex:i] forKey:@"coord"];
			[dict setObject:[[linesCoordForText objectAtIndex:line] objectAtIndex:i] forKey:@"text_coord"];			
			[lineStations setObject:dict forKey:newstring];
			[lineStationsName addObject:newstring];
			[allStationsNames setObject:[NSNumber numberWithInt:line] forKey:newstring];
			
			i++;
			if (!endline)
			remained_station = [remained_station substringFromIndex:location2+1];			
			else
			remained_station = [remained_station substringFromIndex:location2];							
			continue;
		}
		else
		{
			
			
			if ([new_s rangeOfString:@")"].location==NSNotFound)
			{
				location2 = [remained_station rangeOfString:@")"].location+1;

			}
			NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
			NSString *newstring = [remained_station substringToIndex:location2]; // +1 

			NSUInteger location3 = [newstring rangeOfString:@"("].location;
			NSString *stationname = [newstring substringToIndex:location3];
			
			NSString *stringForSub = [newstring substringWithRange:NSMakeRange(location3+1, [newstring length]-2-(location3))];
			

			// для случая с (,station_name)
			Boolean reverse_linked=false;

			NSArray *stations_list;
			if ([stringForSub rangeOfString:@","].location==0){
				reverse_linked=true;
				stations_list = [[stringForSub substringFromIndex:1] componentsSeparatedByString:@","];
			}
			else {
				stations_list = [stringForSub componentsSeparatedByString:@","];			
			}

			
			NSMutableArray *list = [[NSMutableArray alloc] init];
			
			for (int i = 0; i<[stations_list count]; i++) {
				[list addObject:[stations_list objectAtIndex:i]];
			}
			
			[dict setObject:stationname forKey:stationname];
			
			[dict setObject:list forKey:@"linked"];
			if (reverse_linked)
			{
				[dict setObject:[NSNumber numberWithInt:1] forKey:@"reverse"];				
			}
			[dict setObject:[[linesCoord objectAtIndex:line] objectAtIndex:i] forKey:@"coord"];
			[dict setObject:[[linesCoordForText objectAtIndex:line] objectAtIndex:i] forKey:@"text_coord"];

			[lineStations setObject:dict forKey:stationname];
			[lineStationsName addObject:stationname];
			[allStationsNames setObject:[NSNumber numberWithInt:line] forKey:stationname];			
			
			i++;
			if(!endline)
			remained_station = [remained_station substringFromIndex:location2+1]; // +2			
			else
			remained_station = [remained_station substringFromIndex:location2];							
		}
	}
	[stationsData addObject:lineStations];
	[stationsName addObject:lineStationsName];
}


- (UIColor *) colorForHex:(NSString *)hexColor {
	hexColor = [[hexColor stringByTrimmingCharactersInSet:
				 [NSCharacterSet whitespaceAndNewlineCharacterSet]
				 ] uppercaseString];  
	
    // String should be 6 or 7 characters if it includes '#'  
    if ([hexColor length] < 6) 
		return [UIColor blackColor];  
	
    // strip # if it appears  
    if ([hexColor hasPrefix:@"#"]) 
		hexColor = [hexColor substringFromIndex:1];  
	
    // if the value isn't 6 characters at this point return 
    // the color black	
    if ([hexColor length] != 6) 
		return [UIColor blackColor];  
	
    // Separate into r, g, b substrings  
    NSRange range;  
    range.location = 0;  
    range.length = 2; 
	
    NSString *rString = [hexColor substringWithRange:range];  
	
    range.location = 2;  
    NSString *gString = [hexColor substringWithRange:range];  
	
    range.location = 4;  
    NSString *bString = [hexColor substringWithRange:range];  
	
    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  
	
    return [UIColor colorWithRed:((float) r / 255.0f)  
                           green:((float) g / 255.0f)  
                            blue:((float) b / 255.0f)  
                           alpha:1.0f];  
	
}

-(void) processLinesColors:(NSString*) colors {
	
	
	UIColor *hh = [self colorForHex:colors];
	
	const CGFloat *components = CGColorGetComponents(hh.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
	
	NSMutableArray *lineColors = [[NSMutableArray alloc] init];
	
	[lineColors  addObject:[NSNumber numberWithFloat:r]];
	[lineColors  addObject:[NSNumber numberWithFloat:g]];
	[lineColors  addObject:[NSNumber numberWithFloat:b]];
	
	[linesColors addObject:lineColors];

}
-(void) processLinesCoord:(NSArray*) coord{
	NSMutableArray *lineCoord = [[NSMutableArray alloc] init];
	for (int j = 0 ; j < coord.count; j++) {
		NSArray *coord_x_y = [[coord objectAtIndex:j] componentsSeparatedByString:@","];
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		
		NSString *xxs = [coord_x_y objectAtIndex:0];
		NSString *yys = [coord_x_y objectAtIndex:1];
		
		
		NSNumber *x = [NSNumber numberWithFloat:([xxs intValue]*koef)];
		NSNumber *y = [NSNumber numberWithFloat:([yys intValue]*koef)];
		[dict setValue:x forKey:@"x"];
		[dict setValue:y forKey:@"y"];			
		[lineCoord addObject:dict];
	}
	[linesCoord addObject:lineCoord];
}

-(void) processLinesCoordForText:(NSArray*) coord{
	NSMutableArray *lineCoordForText = [[NSMutableArray alloc] init];
	for (int j = 0 ; j < coord.count; j++) {
		NSArray *coord_x_y = [[coord objectAtIndex:j] componentsSeparatedByString:@","];
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		
		NSString *xxs = [coord_x_y objectAtIndex:0];
		NSString *yys = [coord_x_y objectAtIndex:1];
		NSString *wws = [coord_x_y objectAtIndex:2];
		NSString *hhs = [coord_x_y objectAtIndex:3];
		
		NSNumber *x = [NSNumber numberWithFloat:([xxs intValue]*koef)];
		NSNumber *y = [NSNumber numberWithFloat:([yys intValue]*koef)];
		NSNumber *ww = [NSNumber numberWithFloat:([wws intValue]*koef)];
		NSNumber *hh = [NSNumber numberWithFloat:([hhs intValue]*koef)];

		[dict setValue:x forKey:@"x"];
		[dict setValue:y forKey:@"y"];
		[dict setValue:ww forKey:@"w"];
		[dict setValue:hh forKey:@"h"];
		
		[lineCoordForText addObject:dict];
	}
	[linesCoordForText addObject:lineCoordForText];
}


-(void) calcGraph {
	
	//for each line
	for (int i=0; i< linesCount; i++) {
		NSDictionary *lineStations = [stationsData objectAtIndex:i];
		NSArray *lineStationNames = [NSArray arrayWithArray:[stationsName objectAtIndex:i]];
		NSArray *lineStationsTime = [stationsTime objectAtIndex:i];
		//if (i==0)
		[self calcOneLineGraph:lineStations :lineStationNames :lineStationsTime :i];
	}
	[self processTransfersForGraph];
}

-(void) processTransfersForGraph{
	for(id key in transfersTime) {
		NSArray *transfers = [transfersTime objectForKey:key];
			for (int i=0; i<[transfers count]; i++) {
				NSDictionary *transferDict = [transfers objectAtIndex:i];
				
				NSString *station1 = [NSString stringWithFormat:@"%@|%@", 
									  [transferDict objectForKey:@"stationName1"],
									  [transferDict objectForKey:@"lineStation1"]];
				
				NSString *station2 = [NSString stringWithFormat:@"%@|%@", 
									  [transferDict objectForKey:@"stationName2"],
									  [transferDict objectForKey:@"lineStation2"]];
				
				[graph addEdgeFromNode:[GraphNode nodeWithValue:station1] 
				 				toNode:[GraphNode nodeWithValue:station2]				 
							withWeight:[[transferDict objectForKey:@"transferTime"] floatValue]];
				
				[graph addEdgeFromNode:[GraphNode nodeWithValue:station2] 
				 				toNode:[GraphNode nodeWithValue:station1]				 
							withWeight:[[transferDict objectForKey:@"transferTime"] floatValue]];
				
			}
	}	
}
-(void) calcOneLineGraph: (NSDictionary*)lineStationsData :(NSArray*) lineStationsName :(NSArray*) lineStationsTime :(NSInteger)lineNum { 
	
	//	NSArray *keyArray =  [lineStations allKeys];
	int keys_count = [lineStationsName count];
	NSArray *prev_linkedStations = nil;
	
	for (int j =0 ; j < keys_count-1; j++) {
		
		//NSDictionary *next_stationDict = [[NSDictionary alloc] init];
		NSString *nextStationName;
		//NSString *nextStationsTime;
		
		//
		NSString *stationName = [lineStationsName objectAtIndex:j];
		NSDictionary *stationDict = [lineStationsData objectForKey:stationName];
		NSArray *linkedStations = [stationDict objectForKey:@"linked"];
		NSArray *linkedStationsTime = [stationDict objectForKey:@"linked_time"];
		NSString *stationTime = [lineStationsTime objectAtIndex:j];
		stationName = [NSString stringWithFormat:@"%@|%d",[lineStationsName objectAtIndex:j],lineNum+1];
		NSString *prev_stationTime;
		//NSDictionary *coords = [stationDict objectForKey:@"coord"];
		//NSDictionary *text_coords = [stationDict objectForKey:@"text_coord"];
		
		if (linkedStations==nil)
		{
			if ((j+1)!=keys_count)
			{
				//обычная станция

				nextStationName = [NSString stringWithFormat:@"%@|%d",[lineStationsName objectAtIndex:j+1],lineNum+1] ;

				//next_stationDict = [lineStationsData objectForKey:[lineStationsName objectAtIndex:j+1]];	
				//nextStationsTime = [lineStationsTime objectAtIndex:j+1];
				
				[graph addEdgeFromNode:[GraphNode nodeWithValue:stationName] toNode:[GraphNode nodeWithValue:nextStationName] withWeight:[stationTime floatValue]];
				[graph addEdgeFromNode:[GraphNode nodeWithValue:nextStationName] toNode:[GraphNode nodeWithValue:stationName] withWeight:[stationTime floatValue]];

				//next_coords = [next_stationDict objectForKey:@"coord"];
				//next_text_coords = [stationDict objectForKey:@"text_coord"];
				
				//NSArray *splineCoords = [map.addNodes objectForKey: [[stationName stringByAppendingString:@","] stringByAppendingString:nextStationName]];
				//[self draw2Station:context :lineColor :coords :next_coords :splineCoords];
				
				//[self drawStationPoint: context coord:coords lineColor: lineColor];
				//[self drawStationName:context :text_coords :coords :stationName];
			}
			else {
				//последняя станция в ветке
				//[self drawStationPoint: context coord:coords lineColor: lineColor];
				//[self drawStationName:context :text_coords :coords :stationName];
			}
			//если пред станция имела линкованные , а  теперь идет обычная, рисуем линк. Возможно косталь.
			if (prev_linkedStations!=nil)
			{
				//[self draw2Station:context :lineColor :coords :prev_coords :nil];
			}
		}
		else {
			
			//[self drawStationPoint: context coord:coords lineColor: lineColor];
			//[self drawStationName:context :text_coords :coords :stationName];
			
			//линкованные
			for (int ii = 0 ; ii<[linkedStations count];ii++)
			{
				nextStationName = [NSString stringWithFormat:@"%@|%d",[linkedStations objectAtIndex:ii],lineNum+1];
				//next_stationDict = [lineStationsData objectForKey:[linkedStations objectAtIndex:ii]];
				NSString *next_stationsTime = [linkedStationsTime objectAtIndex:ii];
				[graph addEdgeFromNode:[GraphNode nodeWithValue:stationName] toNode:[GraphNode nodeWithValue:nextStationName] withWeight:[next_stationsTime floatValue]];
				[graph addEdgeFromNode:[GraphNode nodeWithValue:nextStationName] toNode:[GraphNode nodeWithValue:stationName] withWeight:[stationTime floatValue]];

				//next_text_coords = [next_stationDict objectForKey:@"coord"];
				//NSArray *splineCoords = [map.addNodes objectForKey: [[stationName stringByAppendingString:@","] stringByAppendingString:nextStationName]];
				//[self draw2Station:context :lineColor :coords :next_coords :splineCoords];				
				//[self drawStationPoint: context coord:next_coords lineColor: lineColor];
				//[self drawStationName:context :next_text_coords :next_coords :stationName];
			}
		}
		prev_stationTime = stationTime;
		prev_linkedStations = linkedStations;
		//		DLog(@" %f %f ",x,y);
	}
}


- (void)dealloc {
    [super dealloc];
    [drawedStations dealloc];

	[linesNames dealloc];
	[linesIndex dealloc];
	[contentAZForTableView dealloc];
	[linesCoord dealloc];
	[linesCoordForText dealloc];
	[linesColors dealloc];
	[stationsData dealloc];
	[stationsTime dealloc];
	[addNodes dealloc];
	[transfersTime dealloc];
	[gpsCoords dealloc];

	[graph dealloc];
}

// drawing

-(void) drawMap:(CGContextRef) context {
    
    [drawedStations removeAllObjects];
	//for each line
	for (int i=0; i< linesCount; i++) {
		NSArray *lineCoord = [NSArray arrayWithArray:[linesCoord objectAtIndex:i]];
		NSArray *lineColor = [NSArray arrayWithArray:[linesColors objectAtIndex:i]];
		NSDictionary *lineStations = [stationsData objectAtIndex:i];
		NSArray *lineStationNames = [NSArray arrayWithArray:[stationsName objectAtIndex:i]];
        //		if (i==9)
		[self drawMetroLine:context :lineCoord :lineColor :lineStations :lineStationNames :i];
	}
	currentLineNum = 0;
	for (int i=0; i< linesCount; i++) {
		currentLineNum = i+1;
        
		NSArray *lineColor = [NSArray arrayWithArray:[linesColors objectAtIndex:i]];
		NSDictionary *lineStations = [stationsData objectAtIndex:i];
		NSArray *lineStationNames = [NSArray arrayWithArray:[stationsName objectAtIndex:i]];
        //		if (i==9)
		[self drawMetroLineStationName:context :lineColor :lineStations :lineStationNames :i];
	}
    labelPlaced=true;
}

-(void) drawMetroLine:(CGContextRef) context :(NSArray*)lineCoords :(NSArray*)lineColor 
					 :(NSDictionary*)lineStationsData :(NSArray*) lineStationsName :(NSInteger)line{ 
	
    //	NSArray *keyArray =  [lineStations allKeys];
	int keys_count = [lineStationsName count];
	NSDictionary *prev_coords = nil;
	NSArray *prev_linkedStations = nil;
	
	for (int j =0 ; j < keys_count; j++) {
        
		NSDictionary *next_coords = [[NSDictionary alloc] init];
		NSDictionary *next_text_coords = [[NSDictionary alloc] init];	
		NSDictionary *next_stationDict = [[NSDictionary alloc] init];
		NSString *nextStationName ;
		NSNumber *reverse_linked_prev;
		
		//
		NSString *stationName = [lineStationsName objectAtIndex:j];
		NSDictionary *stationDict = [lineStationsData objectForKey:[lineStationsName objectAtIndex:j]];
		NSArray *linkedStations = [stationDict objectForKey:@"linked"];
		NSNumber *reverse_linked = [stationDict objectForKey:@"reverse"];
		NSDictionary *coords = [stationDict objectForKey:@"coord"];
		//NSDictionary *text_coords = [stationDict objectForKey:@"text_coord"];
		
		if (linkedStations==nil)
		{
			if ((j+1)!=keys_count)
                //if (1==1)
			{
				//обычная станция
				nextStationName = [lineStationsName objectAtIndex:j+1];
				next_stationDict = [lineStationsData objectForKey:[lineStationsName objectAtIndex:j+1]];	
				next_coords = [next_stationDict objectForKey:@"coord"];
				next_text_coords = [stationDict objectForKey:@"text_coord"];
				
				
				Boolean reverse=false;
				NSArray *splineCoords;
				splineCoords = [addNodes objectForKey: 
								[NSString stringWithFormat:@"%d,%@,%@" , (line+1),stationName,nextStationName]];
			 	if (splineCoords == nil)
				{
					reverse=true;	
					splineCoords = [addNodes objectForKey: 
									[NSString stringWithFormat:@"%d,%@,%@" , (line+1),nextStationName,stationName]];
				}
				[self draw2Station:context :lineColor :coords :next_coords :splineCoords :reverse];
			}
			
			//если пред станция имела линкованные(только с признаком reversed), а  теперь идет обычная, рисуем линк. Возможно косталь.
            
			if((prev_linkedStations!=nil) && ([reverse_linked_prev intValue]==1))
			{
				Boolean reverse=false;
				NSArray *splineCoords;
				splineCoords = [addNodes objectForKey: 
								[NSString stringWithFormat:@"%d,%@,%@" , (line+1),stationName,nextStationName]];
                //[[stationName stringByAppendingString:@","] stringByAppendingString:nextStationName]];
			 	if (splineCoords == nil)
				{
					reverse=true;	
					splineCoords = [addNodes objectForKey: 
									[NSString stringWithFormat:@"%d,%@,%@" , (line+1),nextStationName,stationName]];
                    //[[nextStationName stringByAppendingString:@","] stringByAppendingString:stationName]];
				}
				
				[self draw2Station:context :lineColor :coords :prev_coords :splineCoords :reverse];
			}
			
		}
		else {
			
			//линкованные
			for (int ii = 0 ; ii<[linkedStations count];ii++)
			{
				nextStationName = [linkedStations objectAtIndex:ii];
				next_stationDict = [lineStationsData objectForKey:[linkedStations objectAtIndex:ii]];
				next_coords = [next_stationDict objectForKey:@"coord"];
				next_text_coords = [next_stationDict objectForKey:@"coord"];
                
				Boolean reverse=false;
				NSArray *splineCoords;
				splineCoords = [addNodes objectForKey: 
								[NSString stringWithFormat:@"%d,%@,%@" , (line+1),stationName,nextStationName]];
			 	if (splineCoords == nil)
				{
					reverse=true;	
					splineCoords = [addNodes objectForKey: 
									[NSString stringWithFormat:@"%d,%@,%@" , (line+1),nextStationName,stationName]];
				}
				[self draw2Station:context :lineColor :coords :next_coords :splineCoords :reverse];				
			}
			
		}
		prev_coords = coords;
		prev_linkedStations = linkedStations;
		reverse_linked_prev = reverse_linked;
		
	}
}

-(void) drawMetroLineStationName:(CGContextRef) context :(NSArray*)lineColor 
								:(NSDictionary*)lineStationsData :(NSArray*) lineStationsName :(NSInteger) line { 
	
	//	NSArray *keyArray =  [lineStations allKeys];
	int keys_count = [lineStationsName count];
	NSDictionary *prev_coords = nil;
	NSArray *prev_linkedStations = nil;
	
	for (int j =0 ; j < keys_count; j++) {
		
		NSDictionary *next_coords = [[NSDictionary alloc] init];
		NSDictionary *next_text_coords = [[NSDictionary alloc] init];	
		NSDictionary *next_stationDict = [[NSDictionary alloc] init];
		NSString *nextStationName ;
		
		//
		NSString *stationName = [lineStationsName objectAtIndex:j];
		NSDictionary *stationDict = [lineStationsData objectForKey:[lineStationsName objectAtIndex:j]];
		NSArray *linkedStations = [stationDict objectForKey:@"linked"];
		NSDictionary *coords = [stationDict objectForKey:@"coord"];
		NSDictionary *text_coords = [stationDict objectForKey:@"text_coord"];
		
		if (linkedStations==nil)
		{
			if ((j+1)!=keys_count)
			{
				//обычная станция
				nextStationName = [lineStationsName objectAtIndex:j+1];
				next_stationDict = [lineStationsData objectForKey:[lineStationsName objectAtIndex:j+1]];	
				next_coords = [next_stationDict objectForKey:@"coord"];
				next_text_coords = [stationDict objectForKey:@"text_coord"];
				
				[self drawStationPoint: context coord:coords lineColor: lineColor];
				[self drawStationName:context :text_coords :coords :stationName :line+1];
			}
			else {
				//последняя станция в ветке
				[self drawStationPoint: context coord:coords lineColor: lineColor];
				[self drawStationName:context :text_coords :coords :stationName :line+1];
			}
			
			//если пред станция имела линкованные , а  теперь идет обычная, рисуем линк. Возможно косталь.
			if (prev_linkedStations!=nil)
			{
				//[self draw2Station:context :lineColor :coords :prev_coords :nil];
			}
		}
		else {
			
			[self drawStationPoint: context coord:coords lineColor: lineColor];
			[self drawStationName:context :text_coords :coords :stationName :line];
			
			//линкованные
			for (int ii = 0 ; ii<[linkedStations count];ii++)
			{
				nextStationName = [linkedStations objectAtIndex:ii];
				next_stationDict = [lineStationsData objectForKey:[linkedStations objectAtIndex:ii]];
				next_coords = [next_stationDict objectForKey:@"coord"];
				next_text_coords = [next_stationDict objectForKey:@"coord"];
				
				//[self draw2Station:context :lineColor :coords :next_coords :splineCoords];				
				[self drawStationPoint: context coord:next_coords lineColor: lineColor];
				[self drawStationName:context :next_text_coords :next_coords :stationName :line+1];
			}
			
		}
		prev_coords = coords;
		prev_linkedStations = linkedStations;
		
		
		//		DLog(@" %f %f ",x,y);
	}
}

-(void) draw2Station:(CGContextRef)context :(NSArray*)lineColor :(NSDictionary*) coord1 :(NSDictionary*)coord2 :(NSArray*) splineCoords :(Boolean) reverse{ 
	float x = [[coord1 objectForKey:@"x"] floatValue];
	float y = [[coord1 objectForKey:@"y"] floatValue];
	
	float x2 = [[coord2 objectForKey:@"x"] floatValue];
	float y2 = [[coord2 objectForKey:@"y"] floatValue];
	
    
	if (x==421)
	{
		DLog(@"bingo");
	}
	CGContextSetRGBStrokeColor(context, [[lineColor objectAtIndex:0] floatValue], [[lineColor objectAtIndex:1] floatValue], [[lineColor objectAtIndex:2] floatValue], 1);				
	if (splineCoords!=nil)
	{
		[self drawSpline:context :x :y :x2 :y2 :splineCoords :reverse];
	}
	else
		[self drawLine:context :x :y :x2 :y2 :kLineWidth];
}

- (void) drawStationPoint: (CGContextRef) context y: (float) y x: (float) x lineColor: (NSArray *) lineColor  {
	
	
	CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.2, 0.8);
	[self drawCircle:context :x	:y :5.5];
	CGContextSetRGBFillColor(context, [[lineColor objectAtIndex:0] floatValue], [[lineColor objectAtIndex:1] floatValue], [[lineColor objectAtIndex:2] floatValue], 1);		
	[self drawFilledCircle:context :x :y :5.0];
	
}

-(void) drawStationName:(CGContextRef) context :(float) x :(float) y  :(float) ww :(float)hh :(NSString*) stationName 
					   :(UITextAlignment) mode :(NSInteger) line{
	
	//draw filled rect
	CGRect textRect = CGRectMake(x, y, ww, hh);
	CGContextSetRGBFillColor (context, 1, 1, 1, 0.3); // 6	
	CGContextFillRect(context, textRect);
	
	if (!labelPlaced)
	{
		UILabel *l = [[UILabel alloc] initWithFrame:textRect];
		[l setText:stationName];
		l.tag = currentLineNum;
		l.textColor = [UIColor clearColor];
		l.userInteractionEnabled = YES;
		l.backgroundColor = [UIColor clearColor];
		[view addSubview:l];
	}
	
	
	//draw text
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	//	CGContextSetCharacterSpacing (context, 2); 
	CGContextSelectFont(context, "Helvetica", 9.0, kCGEncodingMacRoman);
	
	
	CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor] );
	CGContextSetTextDrawingMode (context, kCGTextFill); 
	
	//CGContextShowTextAtPoint(context, x, y, 
	//					 [stationName cStringUsingEncoding:NSUTF8StringEncoding], [stationName length]); 
	
	UIGraphicsPushContext(context);			
	[stationName drawInRect:textRect  withFont: [UIFont fontWithName:@"Arial-BoldMT" size:14] 
			  lineBreakMode: UILineBreakModeWordWrap alignment: mode];
	UIGraphicsPopContext();			
	
	
} 

- (void) drawStationPoint: (CGContextRef) context coord: (NSDictionary*) coord lineColor: (NSArray *) lineColor  {
	float x = [[coord objectForKey:@"x"] floatValue];
	float y = [[coord objectForKey:@"y"] floatValue];
	[self drawStationPoint: context y: y x: x lineColor: lineColor];
}

-(void) drawStationName:(CGContextRef) context  :(NSDictionary*) text_coord  :(NSDictionary*) point_coord :(NSString*) stationName :(NSInteger) line {
	
	if ([drawedStations objectForKey:stationName]!=nil)
		return;
	
	[drawedStations setObject:@"yes" forKey:stationName];
	
	float x = [[text_coord objectForKey:@"x"] floatValue];
	float y = [[text_coord objectForKey:@"y"] floatValue];
	float ww = [[text_coord objectForKey:@"w"] floatValue];
	float hh = [[text_coord objectForKey:@"h"] floatValue];
	
	float point_x = [[point_coord objectForKey:@"x"] floatValue];
    
	UITextAlignment mode;
	if (x<point_x)
		mode = UITextAlignmentRight;
	else mode = UITextAlignmentLeft;
	[self drawStationName:context :x :y :ww :hh :stationName :mode :line];
} 

-(void) drawSpline :(CGContextRef)context :(CGFloat)x1 :(CGFloat)y1 :(CGFloat)x2 :(CGFloat)y2 :(NSArray*) coordSpline :(Boolean) reverse {
	
	//CGContextSetRGBStrokeColor(context, 0.1, 0.3, 1.0, 1);				
    
	
	CatmullRomSpline *ctSpline = [CatmullRomSpline catmullRomSplineAtPoint:CGPointMake(x1,y1)];
    
	NSEnumerator *enumerator;
	
	if (!reverse)
		enumerator = [coordSpline objectEnumerator];
	else
		enumerator = [coordSpline reverseObjectEnumerator];
    
	///for (int i=0; i<[coordSpline count]; i++) {
	for (id element in enumerator) {
		NSArray *coords = [element componentsSeparatedByString:@","];
		[ctSpline addPoint:CGPointMake(([[coords objectAtIndex:0] floatValue]*koef), 
									   ([[coords objectAtIndex:1] floatValue]*koef))];
		//DLog(@" ");
	}
	//}
	
	[ctSpline addPoint:CGPointMake(x2,y2)];
    
    
    
	NSArray *splineArray = [ctSpline asPointArray];
	CGContextBeginPath(context);
	CGPoint begin = [[splineArray objectAtIndex:0] CGPointValue];
	CGContextMoveToPoint(context,begin.x,begin.y);
	for (int i=1; i<[splineArray count]-1; i++) {
		//DLog(" 1 %@ ",[splineArray objectAtIndex:i]);
		//DLog(" 2 %@ ",[splineArray objectAtIndex:i+1]);		
		CGPoint p = [[splineArray objectAtIndex:i] CGPointValue];
		CGPoint p2 = [[splineArray objectAtIndex:i+1] CGPointValue];		
		CGContextAddQuadCurveToPoint(context,p.x ,p.y, p2.x ,p2.y);
	}
	CGContextMoveToPoint(context,x2,y2);
	//CGContextAddQuadCurveToPoint(context, 10 , 10, 300 ,300);	
    //	CGContextSetLineWidth(context, 4.5);
	CGContextSetLineWidth(context, kLineWidth);
	CGContextDrawPath(context, kCGPathStroke);
	//DLog(@" ");
}

// рисует часть карты
-(void) drawPathMap:(CGContextRef) context :(NSArray*) pathMap {
	
	[drawedStations removeAllObjects];
    
	//for each line
	int count_ = [pathMap count];
	for (int i=0; i< count_; i++) {
		
		NSString *rawSrting1 = (NSString*)[[pathMap objectAtIndex:i] value];
		NSArray *el1  = [rawSrting1 componentsSeparatedByString:@"|"];
		NSString *stationName1 = [el1 objectAtIndex:0];
		NSInteger lineNum1 = [[el1 objectAtIndex:1] intValue]; 
        
		if ((i+1)!=count_)
		{
			NSString *rawSrting2 = (NSString*)[[pathMap objectAtIndex:i+1] value];
			NSArray *el2  = [rawSrting2 componentsSeparatedByString:@"|"];
			NSString *stationName2 = [el2 objectAtIndex:0];
			NSInteger lineNum2 = [[el2 objectAtIndex:1] intValue]; 
			
			//NSArray *lineCoord = [NSArray arrayWithArray:[cityMap.linesCoord objectAtIndex:lineNum-1]];
			NSArray *lineColor = [NSArray arrayWithArray:[linesColors objectAtIndex:lineNum1-1]];
			
			if (lineNum1==lineNum2)
			{
				NSDictionary *lineStations = [stationsData objectAtIndex:lineNum1-1];
				//			NSArray *lineStationNames = [[NSArray alloc] initWithObjects:stationName1,nil];			
				
				NSDictionary* stationDict1 = [lineStations objectForKey:stationName1];
				NSDictionary* stationDict2 = [lineStations objectForKey:stationName2];				
                
				NSDictionary* coords = [stationDict1 objectForKey:@"coord"];
				NSDictionary* next_coords = [stationDict2 objectForKey:@"coord"];
				
				NSDictionary *text_coords = [stationDict1 objectForKey:@"text_coord"];
				NSDictionary *next_text_coords = [stationDict2 objectForKey:@"text_coord"];
                
				Boolean reverse=false;
				NSArray *splineCoords;
				splineCoords = [addNodes objectForKey: 
								[NSString stringWithFormat:@"%d,%@,%@" , (lineNum1),stationName1,stationName2]];
                //[[stationName1 stringByAppendingString:@","] stringByAppendingString:stationName2]];
			 	if (splineCoords == nil)
				{
					reverse=true;	
					splineCoords = [addNodes objectForKey: 
									[NSString stringWithFormat:@"%d,%@,%@" , (lineNum1),stationName2,stationName1]];
                    //[[stationName2 stringByAppendingString:@","] stringByAppendingString:stationName1]];
				}
				
				//NSArray *splineCoords = [cityMap.addNodes objectForKey: [[stationName1 stringByAppendingString:@","] stringByAppendingString:stationName2]];
                
				[self draw2Station:context :lineColor :coords :next_coords :splineCoords :reverse];
				
				[self drawStationPoint: context coord:coords lineColor: lineColor];
				[self drawStationName:context :text_coords :coords :stationName1 :lineNum1-1];
                
				[self drawStationPoint: context coord:next_coords lineColor: lineColor];
				[self drawStationName:context :next_text_coords :next_coords :stationName2 :lineNum1-1];
                
			}
		}
		//[self drawMetroLine:context :lineCoord :lineColor :lineStations :lineStationNames :cityMap];
	}
	
	/*for (int i=0; i< count_; i++) {
     NSString *rawSrting1 = (NSString*)[[pathMap objectAtIndex:i] value];
     NSArray *el1  = [rawSrting1 componentsSeparatedByString:@"|"];
     NSString *stationName1 = [el1 objectAtIndex:0];
     NSInteger lineNum1 = [[el1 objectAtIndex:1] intValue]; 
     
     NSArray *lineColor = [NSArray arrayWithArray:[cityMap.linesColors objectAtIndex:lineNum1-1]];
     NSDictionary *lineStations = [cityMap.stationsData objectAtIndex:lineNum1-1];
     //NSArray *lineStationNames = [NSArray arrayWithArray:[cityMap.stationsName objectAtIndex:lineNum1-1]];
     NSArray *lineStationNames = [NSArray arrayWithObjects:stationName1,nil];
     [self drawMetroLineStationName:context :lineColor :lineStations :lineStationNames :cityMap :lineNum1-1];
     
     }
	 */
    
    labelPlaced=true;
}

// CG Helpres
-(void) drawLine :(CGContextRef) context :(CGFloat)x1 :(CGFloat)y1 :(CGFloat)x2 :(CGFloat)y2 :(int)lineWidth{
    
	CGContextTranslateCTM(context, 0, 0);
    
    //	CGContextSetLineWidth(context, 4.5);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, lineWidth);
	CGContextMoveToPoint(context, x1, y1);
	CGContextAddLineToPoint(context, x2, y2);
	CGContextStrokePath(context);
}

-(void) drawCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r{
	CGContextTranslateCTM(context, 0, 0);
	
	CGContextSetLineWidth(context, 2.5);
	// Draw a circle (border only)
	//	CGContextMoveToPoint(context, x, y);
	CGContextStrokeEllipseInRect(context, CGRectMake(x-r, y-r, 2*r, 2*r));
}

-(void) drawFilledCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r{
	
    
	CGContextTranslateCTM(context, 0, 0);
	// Draw a circle (filled)
	//	CGContextMoveToPoint(context, x, y);
	CGContextFillEllipseInRect(context, CGRectMake(x-r, y-r, 2*r, 2*r));
}

-(void) drawTransfers:(CGContextRef) context {
    
	for(id key in transfersTime) {
		NSArray *transfers = [transfersTime objectForKey:key];
		for (int i=0; i<[transfers count]; i++) {
			NSDictionary *transferDict = [transfers objectAtIndex:i];
            
            
			NSString *station1 = [transferDict objectForKey:@"stationName1"];
			int line1 = [[transferDict objectForKey:@"lineStation1"] intValue];
            
			NSString *station2 = [transferDict objectForKey:@"stationName2"];
			int line2 = [[transferDict objectForKey:@"lineStation2"] intValue];
			
			NSDictionary *lineStations1 = [stationsData objectAtIndex:line1-1];
			NSDictionary *lineStations2 = [stationsData objectAtIndex:line2-1];			
            
			NSDictionary *stationDict1 = [lineStations1 objectForKey:station1];
			NSDictionary *stationDict2 = [lineStations2 objectForKey:station2];
			
			NSDictionary *coords1 = [stationDict1 objectForKey:@"coord"];
			NSDictionary *coords2 = [stationDict2 objectForKey:@"coord"];	
            
			float x1 = [[coords1 objectForKey:@"x"] floatValue];
			float y1 = [[coords1 objectForKey:@"y"] floatValue];
			float x2 = [[coords2 objectForKey:@"x"] floatValue];
			float y2 = [[coords2 objectForKey:@"y"] floatValue];
            
			CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
			
			[self drawFilledCircle:context :x1 :y1 :7.0];
			[self drawFilledCircle:context :x2 :y2 :7.0];
            
			[self drawLine:context :x1 :y1 :x2 :y2 :5];
		}
	}	
    
	for(id key in transfersTime) {
		NSArray *transfers = [transfersTime objectForKey:key];
		for (int i=0; i<[transfers count]; i++) {
			NSDictionary *transferDict = [transfers objectAtIndex:i];
			
			
			NSString *station1 = [transferDict objectForKey:@"stationName1"];
			int line1 = [[transferDict objectForKey:@"lineStation1"] intValue];
 			NSString *station2 = [transferDict objectForKey:@"stationName2"];
			int line2 = [[transferDict objectForKey:@"lineStation2"] intValue];
			
			NSDictionary *lineStations1 = [stationsData objectAtIndex:line1-1];
			NSDictionary *lineStations2 = [stationsData objectAtIndex:line2-1];			
			
			NSDictionary *stationDict1 = [lineStations1 objectForKey:station1];
			NSDictionary *stationDict2 = [lineStations2 objectForKey:station2];
			
			NSDictionary *coords1 = [stationDict1 objectForKey:@"coord"];
			NSDictionary *coords2 = [stationDict2 objectForKey:@"coord"];	
			
			float x1 = [[coords1 objectForKey:@"x"] floatValue];
			float y1 = [[coords1 objectForKey:@"y"] floatValue];
			float x2 = [[coords2 objectForKey:@"x"] floatValue];
			float y2 = [[coords2 objectForKey:@"y"] floatValue];
			
            
			CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
			CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);				
			[self drawFilledCircle:context :x1 :y1 :5.0];
			[self drawFilledCircle:context :x2 :y2 :5.0];
            
			[self drawLine:context :x1 :y1 :x2 :y2 :3];
		}
	}	
	
}
-(void) drawTransfers2:(CGContextRef) context {
	
	for(id key in transfersTime) {
		NSArray *transfers = [transfersTime objectForKey:key];
		for (int i=0; i<[transfers count]; i++) {
			NSDictionary *transferDict = [transfers objectAtIndex:i];
			
			
			NSString *station1 = [transferDict objectForKey:@"stationName1"];
			int line1 = [[transferDict objectForKey:@"lineStation1"] intValue];
			
			NSString *station2 = [transferDict objectForKey:@"stationName2"];
			int line2 = [[transferDict objectForKey:@"lineStation2"] intValue];
			
			NSDictionary *lineStations1 = [stationsData objectAtIndex:line1-1];
			NSDictionary *lineStations2 = [stationsData objectAtIndex:line2-1];			
			
			NSDictionary *stationDict1 = [lineStations1 objectForKey:station1];
			NSDictionary *stationDict2 = [lineStations2 objectForKey:station2];
			
			NSDictionary *coords1 = [stationDict1 objectForKey:@"coord"];
			NSDictionary *coords2 = [stationDict2 objectForKey:@"coord"];	
			
			float x1 = [[coords1 objectForKey:@"x"] floatValue];
			float y1 = [[coords1 objectForKey:@"y"] floatValue];
			float x2 = [[coords2 objectForKey:@"x"] floatValue];
			float y2 = [[coords2 objectForKey:@"y"] floatValue];
			
			CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
			
			[self drawFilledCircle:context :x1 :y1 :7.0];
			[self drawFilledCircle:context :x2 :y2 :7.0];
			
			[self drawLine:context :x1 :y1 :x2 :y2 :5];
			
            
			CGMutablePathRef path = CGPathCreateMutable();
            //			CGContextSetLineWidth(context, 40);
			CGPathAddArc(path, NULL, 100, 100, 45, 0*3.142/180, 270*3.142/180, 0);
			CGContextAddPath(context, path);
			CGContextStrokePath(context);
			CGPathRelease(path);
        }
	}	
	
	for(id key in transfersTime) {
		NSArray *transfers = [transfersTime objectForKey:key];
		for (int i=0; i<[transfers count]; i++) {
			NSDictionary *transferDict = [transfers objectAtIndex:i];
			
			
			NSString *station1 = [transferDict objectForKey:@"stationName1"];
			int line1 = [[transferDict objectForKey:@"lineStation1"] intValue];
 			NSString *station2 = [transferDict objectForKey:@"stationName2"];
			int line2 = [[transferDict objectForKey:@"lineStation2"] intValue];
			
			NSDictionary *lineStations1 = [stationsData objectAtIndex:line1-1];
			NSDictionary *lineStations2 = [stationsData objectAtIndex:line2-1];			
			
			NSDictionary *stationDict1 = [lineStations1 objectForKey:station1];
			NSDictionary *stationDict2 = [lineStations2 objectForKey:station2];
			
			NSDictionary *coords1 = [stationDict1 objectForKey:@"coord"];
			NSDictionary *coords2 = [stationDict2 objectForKey:@"coord"];	
			
			float x1 = [[coords1 objectForKey:@"x"] floatValue];
			float y1 = [[coords1 objectForKey:@"y"] floatValue];
			float x2 = [[coords2 objectForKey:@"x"] floatValue];
			float y2 = [[coords2 objectForKey:@"y"] floatValue];
			
			
			CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
			CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);				
			[self drawFilledCircle:context :x1 :y1 :5.0];
			[self drawFilledCircle:context :x2 :y2 :5.0];
			
			[self drawLine:context :x1 :y1 :x2 :y2 :3];
		}
	}	
	
}


@end
