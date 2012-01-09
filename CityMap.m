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
#import "ManagedObjects.h"
#import <CoreLocation/CoreLocation.h>

NSMutableArray * Split(NSString* s)
{
    NSMutableArray *res = [[[NSMutableArray alloc] init] autorelease];
    NSRange range = NSMakeRange(0, [s length]);
    while (YES) {
        NSUInteger comma = [s rangeOfString:@"," options:0 range:range].location;
        NSUInteger bracket = [s rangeOfString:@"(" options:0 range:range].location;
        if(comma == NSNotFound) {
            if(bracket != NSNotFound) range.length --;
            [res addObject:[s substringWithRange:range]];
            break;
        } else {
            if(bracket == NSNotFound || bracket > comma) {
                comma -= range.location;
                [res addObject:[s substringWithRange:NSMakeRange(range.location, comma)]];
                range.location += comma+1;
                range.length -= comma+1;
            } else {
                NSUInteger bracket2 = [s rangeOfString:@")" options:0 range:range].location;
                bracket2 -= range.location;
                [res addObject:[s substringWithRange:NSMakeRange(range.location, bracket2)]];
                range.location += bracket2+2;
                range.length -= bracket2+2;
            }
        }
    }
    return res;
}

CGFloat Sql(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p1.x-p2.x;
    CGFloat dy = p1.y-p2.y;
    return dx*dx + dy*dy;
}

@implementation Station

@synthesize relation;
@synthesize segment;
@synthesize sibling;
@synthesize pos;
@synthesize index;
@synthesize name;

-(id)initWithName:(NSString*)sname pos:(CGPoint)p index:(int)i andRect:(CGRect)r
{
    if((self = [super init])) {
        pos = p;
        index = i;
        textRect = r;
        segment = [[NSMutableArray alloc] init];
        relation = [[NSMutableArray alloc] init];
        sibling = [[NSMutableArray alloc] init];
        
        NSUInteger br = [sname rangeOfString:@"("].location;
        if(br == NSNotFound) {
            name = [sname retain];
        } else {
            name = [[sname substringToIndex:br] retain];
            for (NSString* s in [[sname substringFromIndex:br+1] componentsSeparatedByString:@","]) {
                [relation addObject:s];
            }
        }
    }
    return self;
}

-(void)dealloc
{
    [segment release];
    [relation release];
    [sibling release];
}

-(void)draw:(CGContextRef)context
{
    CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.2, 0.8);
	CGContextSetLineWidth(context, 2.5);
	CGContextStrokeEllipseInRect(context, CGRectMake(pos.x-2.75, pos.y-2.75, 5.5, 5.5));
    CGContextFillEllipseInRect(context, CGRectMake(pos.x-2.5, pos.y-2.5, 5, 5));
}

-(void) drawLines:(CGContextRef)context width:(CGFloat)lineWidth
{
    for (Segment *s in segment) {
        [s draw:context width:lineWidth];
    }
}

-(void)drawName:(CGContextRef)context
{
	UIGraphicsPushContext(context);			
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor] );
	CGContextSetTextDrawingMode (context, kCGTextFill);
	[name drawInRect:textRect  withFont: [UIFont fontWithName:@"Arial-BoldMT" size:7] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
	UIGraphicsPopContext();
}

-(void) makeSegments
{
    for (Station *st in sibling) {
        [segment addObject:[[Segment alloc] initFromStation:self toStation:st]];
    }
}

@end

@implementation TangentPoint

@synthesize base;
@synthesize backTang;
@synthesize frontTang;

-(id)initWithPoint:(CGPoint)p
{
    if((self = [super init])) {
        base = p;
    }
    return self;
}

-(void)calcTangentFrom:(CGPoint)p1 to:(CGPoint)p2
{
    CGFloat x = (1 + (Sql(base, p1) - Sql(base, p2)) / Sql(p1, p2)) / 2;
    CGPoint d = CGPointMake(p1.x + (p2.x-p1.x) * x, p1.y + (p2.y-p1.y) * x);
    
    frontTang = CGPointMake(base.x + (p2.x-d.x)/4, base.y + (p2.y-d.y)/4);
    backTang = CGPointMake(base.x + (p1.x-d.x)/4, base.y + (p1.y-d.y)/4);
}
@end

@implementation Segment

@synthesize start;
@synthesize end;

-(id)initFromStation:(Station *)from toStation:(Station *)to
{
    if((self = [super init])) {
        start = from;
        end = to;
    }
    return self;
}

-(void)dealloc
{
    [splinePoints release];
}

-(void)appendPoint:(CGPoint)p
{
    if(splinePoints == nil) splinePoints = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGPoint:p], nil];
    else [splinePoints addObject:[NSValue valueWithCGPoint:p]];
}

-(void)calcSpline
{
    [splinePoints addObject:[NSValue valueWithCGPoint:CGPointMake(end.pos.x, end.pos.y)]];
    [splinePoints insertObject:[NSValue valueWithCGPoint:CGPointMake(start.pos.x, start.pos.y)] atIndex:0];
    NSMutableArray *newSplinePoints = [[NSMutableArray alloc] init];
    for(int i=1; i<[splinePoints count]-1; i++) {
        TangentPoint *p = [[TangentPoint alloc] initWithPoint:[[splinePoints objectAtIndex:i] CGPointValue]];
        [p calcTangentFrom:[[splinePoints objectAtIndex:i-1] CGPointValue] to:[[splinePoints objectAtIndex:i+1] CGPointValue]];
        [newSplinePoints addObject:p];
    }
    [splinePoints release];
    splinePoints = newSplinePoints;
}

-(void)draw:(CGContextRef)context width:(CGFloat)lineWidth
{
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, lineWidth);
	CGContextMoveToPoint(context, start.pos.x, start.pos.y);
    if(splinePoints) {
        [self draw:context fromPoint:CGPointMake(start.pos.x, start.pos.y) toTangentPoint:[splinePoints objectAtIndex:0]];
        for(int i=0; i<[splinePoints count]-1; i++) {
            [self draw:context fromTangentPoint:[splinePoints objectAtIndex:i] toTangentPoint:[splinePoints objectAtIndex:i+1]];
        }
        [self draw:context fromTangentPoint:[splinePoints lastObject] toPoint:CGPointMake(end.pos.x, end.pos.y)];
    } else {
        CGContextAddLineToPoint(context, end.pos.x, end.pos.y);
    }
	CGContextStrokePath(context);    
}

-(void)draw:(CGContextRef)context fromPoint:(CGPoint)p toTangentPoint:(TangentPoint*)tp
{
    CGContextMoveToPoint(context, tp.base.x, tp.base.y);
    CGContextAddQuadCurveToPoint(context, tp.backTang.x, tp.backTang.y, p.x, p.y);
    CGContextStrokePath(context);
}

-(void)draw:(CGContextRef)context fromTangentPoint:(TangentPoint*)tp toPoint:(CGPoint)p
{
    CGContextMoveToPoint(context, tp.base.x, tp.base.y);
    CGContextAddQuadCurveToPoint(context, tp.frontTang.x, tp.frontTang.y, p.x, p.y);
    CGContextStrokePath(context);
}

-(void)draw:(CGContextRef)context fromTangentPoint:(TangentPoint*)tp1 toTangentPoint:(TangentPoint*)tp2
{
    CGContextMoveToPoint(context, tp1.base.x, tp1.base.y);
    CGContextAddCurveToPoint(context, tp1.frontTang.x, tp1.frontTang.y, tp2.backTang.x, tp2.backTang.y, tp2.base.x, tp2.base.y);
    CGContextStrokePath(context);
}

@end

@implementation Line

@synthesize color  = _color;
@synthesize name;

-(id)initWithName:(NSString*)n stations:(NSString *)station driving:(NSString *)driving coordinates:(NSString *)coordinates rects:(NSString *)rects
{
    if((self = [super init])) {
        name = [n retain];
        stations = [[NSMutableArray alloc] init];
        NSArray *sts = Split(station);
        NSArray *drs = Split(driving);
        NSArray *crds = [coordinates componentsSeparatedByString:@", "];
        NSArray *rcts = [rects componentsSeparatedByString:@", "];
        int count = MIN( MIN([sts count], [crds count]), [rcts count]);
        for(int i=0; i<count; i++) {
            NSArray *coord_x_y = [[crds objectAtIndex:i] componentsSeparatedByString:@","];
            int x = [[coord_x_y objectAtIndex:0] intValue];
            int y = [[coord_x_y objectAtIndex:1] intValue];
            NSArray *coord_text = [[rcts objectAtIndex:i] componentsSeparatedByString:@","];
            int tx = [[coord_text objectAtIndex:0] intValue];
            int ty = [[coord_text objectAtIndex:1] intValue];
            int tw = [[coord_text objectAtIndex:2] intValue];
            int th = [[coord_text objectAtIndex:3] intValue];
            
            Station *st = [[Station alloc] initWithName:[sts objectAtIndex:i] pos:CGPointMake(x, y) index:i andRect:CGRectMake(tx, ty, tw, th)];
            if(![st.relation count] && [stations count]) {
                // создаём простые связи
                [[[stations lastObject] sibling] addObject:st];
            }
            [stations addObject:st];
        }
        // создаём отложенные связи
        for (Station *st in stations) {
            for(NSString *rel in st.relation) {
                for(Station *st2 in stations) {
                    if([st2.name isEqualToString:rel]) {
                        [st.sibling addObject:st2];
                        break;
                    }
                }
            }
            [st.relation removeAllObjects];
        }
        for(Station *st in stations) {
            [st makeSegments];
        }
    }
    return self;
}

-(void)dealloc
{
    [stations release];
}

-(void)draw:(CGContextRef)context width:(CGFloat)lineWidth
{
	CGContextSetStrokeColorWithColor(context, [_color CGColor]);
    CGContextSetFillColorWithColor(context, [_color CGColor]);
    for (Station *s in stations) {
        [s drawLines:context width:lineWidth];
    }
    for (Station *s in stations) {
        [s draw:context];
    }
}

-(void)drawNames:(CGContextRef)context
{
    for (Station *s in stations) {
        [s drawName:context];
    }
}

-(void)additionalPointsBetween:(NSString *)station1 and:(NSString *)station2 points:(NSArray *)points
{
    for (Station *s in stations) {
        BOOL search = NO;
        BOOL rev = NO;
        if([s.name isEqualToString:station1]) search = YES;
        else if([s.name isEqualToString:station2]) search = rev = YES;
        if(search) {
            for (Segment *seg in s.segment) {
                if(([seg.end.name isEqualToString:station1] && rev)
                   || ([seg.end.name isEqualToString:station2] && !rev)) {
                    NSEnumerator *enumer;
                    if(rev) enumer = [points reverseObjectEnumerator];
                    else enumer = [points objectEnumerator];
                    for (NSString *p in enumer) {
                        NSArray *coord = [p componentsSeparatedByString:@","];
                        [seg appendPoint:CGPointMake([[coord objectAtIndex:0] intValue], [[coord objectAtIndex:1] intValue])];
                    }
                    [seg calcSpline];
                }
            }
        }
    }
}

@end

@implementation CityMap

@synthesize linesCount;
@synthesize addNodesCount;
@synthesize linesCoord;
@synthesize linesCoordForText;
@synthesize stationsData;
@synthesize utils;
@synthesize addNodes;
@synthesize graph;
@synthesize gpsCoords;
@synthesize allStationsNames;
@synthesize koef;
@synthesize gpsCoordsCount;

@synthesize currentLineNum;
@synthesize drawedStations;
@synthesize view;
@synthesize FontSize = kFontSize;
@synthesize LineWidth = kLineWidth;

NSInteger const kDataShift=5;
NSInteger const kDataRowForLine=5;

-(id) init {
    [super init];
	[self initVars];
    return self;
}

-(void) initVars {
    drawedStations =  [[NSMutableDictionary alloc] init];
    kLineWidth = 4.5f;
    kFontSize = 7.0f;
	utils = [[[Utils alloc] init] autorelease];
	linesCoord = [[NSMutableArray alloc] init];
	linesCoordForText = [[NSMutableArray alloc] init];	
	stationsData = [[NSMutableArray alloc] init];
	addNodes = [[NSMutableDictionary alloc] init];
	gpsCoords = [[NSMutableDictionary alloc] init];
	graph = [[Graph graph] retain];
	allStationsNames = [[NSMutableDictionary alloc] init];
    mapLines = [[NSMutableArray alloc] init];
	
	//NSMutableDictionary *coords = [[NSMutableDictionary alloc] init];
	//[coords setObject:[NSNumber numberWithDouble:] forKey:@"x"];

	koef = 1;
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

-(CGSize) size { return CGSizeMake(maxX-minX, maxY-minY); }
-(NSInteger) w { return (maxX - minX) * koef; }
-(NSInteger) h { return (maxY - minY) * koef; }

-(void) loadMap:(NSString *)mapName {
	INIParser* parser;
	
	parser = [[INIParser alloc] init];
	
	int err;

	NSString* str = [[NSBundle mainBundle] pathForResource:@"paris2" ofType:@"trp"]; 
	char cstr[512] = {0}; 
	
	[str getCString:cstr maxLength:512 encoding:NSASCIIStringEncoding]; 
	err = [parser parse:cstr];	

	linesCount = [[parser get:@"LinesCount" section:@"main"] integerValue];
	
	NSArray *size = [[parser get:@"Size" section:@"main"] componentsSeparatedByString:@","];
	_w = ([[size objectAtIndex:0] integerValue]);
	_h = ([[size objectAtIndex:1] integerValue]);

    minX = MAXFLOAT;
    maxX = 0.f;
    minY = MAXFLOAT;
    maxY = 0.f;
	for (int i =0 ;i<linesCount; i++) {
		NSString *sectionName = [NSString stringWithFormat:@"Line%d", i+1 ];
		NSString *lineName = [parser get:@"Name" section:sectionName];

        MLine *newLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
        newLine.name=lineName;
        newLine.index = [[NSNumber alloc] initWithInt:i+1];
 
		NSString *colors = [parser get:@"Color" section:lineName];
        newLine.color = [self colorForHex:colors];
		
		NSString *coords = [parser get:@"Coordinates" section:lineName];
		[self processLinesCoord:[coords componentsSeparatedByString:@", "]];

		NSString *coordsText = [parser get:@"Rects" section:lineName];
		[self processLinesCoordForText:[coordsText componentsSeparatedByString:@", "]];
		
		NSString *stations = [parser get:@"Stations" section:sectionName];
		[self processLinesStations:stations	:i];
		
		NSString *coordsTime = [parser get:@"Driving" section:sectionName];
		[self processLinesTime:coordsTime :i];
        
        Line *l = [[Line alloc] initWithName:lineName stations:stations driving:coordsTime coordinates:coords rects:coordsText];
        l.color = newLine.color;
        [mapLines addObject:l];
	}
    [[MHelper sharedHelper] saveContext];
    minX -= 40;
    maxX += 40;
    minY -= 40;
    maxY += 40;
		
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
    
    [self calcGraph];
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

    NSString *lineStation1 = [elements objectAtIndex:0];
    NSString *station1 = [elements objectAtIndex:1];
    NSString *lineStation2 = [elements objectAtIndex:2];
    NSString *station2 = [elements objectAtIndex:3];

    MStation *st1 = [[MHelper sharedHelper] getStationWithName:station1 forLine:lineStation1];
    MStation *st2 = [[MHelper sharedHelper] getStationWithName:station2 forLine:lineStation2];

    if(st1.transfer != nil && st2.transfer != nil) {
        // nothing to do
        // both stations already in transfers
        // i hope transfers are the same
    } else if(st1.transfer != nil) {
        st2.transfer = st1.transfer;
    } else if(st2.transfer != nil) {
        st1.transfer = st2.transfer;
    } else {
        MTransfer *newTransfer = [NSEntityDescription insertNewObjectForEntityForName:@"Transfer" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
        newTransfer.time = [NSNumber numberWithFloat:[[elements objectAtIndex:4] floatValue]];
        st1.transfer = newTransfer;
        st2.transfer = newTransfer;
    }
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
	
	NSString *lineName = [stations objectAtIndex:0];
    int num = [[[MHelper sharedHelper] lineByName:lineName].index intValue];
	
	[addNodes setObject:splinePoints forKey:[NSString stringWithFormat:@"%d,%@,%@" , num , [stations objectAtIndex:1], [stations objectAtIndex:2]]];
    
    for (Line* l in mapLines) {
        if([l.name isEqualToString:lineName]) {
            [l additionalPointsBetween:[stations objectAtIndex:1] and:[stations objectAtIndex:2] points:[elements objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [elements count]-2)]]];
            break;
        }
    }
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
		
		if ([new_s rangeOfString:@"("].location==NSNotFound) {
			
			NSString *newstring = [remained_stationTime substringToIndex:location2];
			[lineStationsTime addObject:newstring];
			[[MHelper sharedHelper] getStationWithIndex:i andLineIndex:line+1].driving = [NSNumber numberWithFloat:[newstring floatValue]];
			i++;
			if (!endline)
				remained_stationTime = [remained_stationTime substringFromIndex:location2+1];			
			else
				remained_stationTime = [remained_stationTime substringFromIndex:location2];							
			continue;

		} else {
				
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
			
			NSString *currentStationName = [[MHelper sharedHelper] getStationWithIndex:i andLineIndex:line+1].name; 
			
			NSMutableDictionary *stationDataDict = [[stationsData objectAtIndex:line] objectForKey:currentStationName];
			[stationDataDict setObject:list forKey:@"linked_time"];
			
			NSMutableDictionary *newDict = [stationsData objectAtIndex:line];
			[newDict setObject:stationDataDict forKey:currentStationName];
			
			[stationsData replaceObjectAtIndex:line withObject:newDict];
			
			[lineStationsTime addObject:stationTime];
			i++;
			if(!endline)
				remained_stationTime = [remained_stationTime substringFromIndex:location2+1]; // +2			
			else
				remained_stationTime = [remained_stationTime substringFromIndex:location2];							
		}
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
			
            MStation *station = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
            station.name=newstring;
            station.isFavorite=[NSNumber numberWithInt:0];
            station.lines=[[MHelper sharedHelper] lineByIndex:line+1 ];
            station.index = [NSNumber numberWithInt:i];
            station.transfer = nil;

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
			
            MStation *station = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
                        station.name=stationname;
            station.isFavorite=[NSNumber numberWithInt:0];
            station.lines=[[MHelper sharedHelper] lineByIndex:line+1 ];
            station.index = [NSNumber numberWithInt:i];
            station.transfer = nil;
            
			i++;
			if(!endline)
			remained_station = [remained_station substringFromIndex:location2+1]; // +2			
			else
			remained_station = [remained_station substringFromIndex:location2];							
		}
	}
	[stationsData addObject:lineStations];
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

-(void) processLinesCoord:(NSArray*) coord{
	NSMutableArray *lineCoord = [[NSMutableArray alloc] init];
	for (int j = 0 ; j < coord.count; j++) {
		NSArray *coord_x_y = [[coord objectAtIndex:j] componentsSeparatedByString:@","];
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		
		NSString *xxs = [coord_x_y objectAtIndex:0];
		NSString *yys = [coord_x_y objectAtIndex:1];
		
		NSNumber *x = [NSNumber numberWithFloat:[xxs intValue]];
		NSNumber *y = [NSNumber numberWithFloat:[yys intValue]];
        minX = MIN(minX, [x floatValue]);
        maxX = MAX(maxX, [x floatValue]);
        minY = MIN(minY, [y floatValue]);
        maxY = MAX(maxY, [y floatValue]);
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
		
		NSNumber *x = [NSNumber numberWithFloat:[xxs intValue]];
		NSNumber *y = [NSNumber numberWithFloat:[yys intValue]];
		NSNumber *ww = [NSNumber numberWithFloat:[wws intValue]];
		NSNumber *hh = [NSNumber numberWithFloat:[hhs intValue]];

		[dict setValue:x forKey:@"x"];
		[dict setValue:y forKey:@"y"];
		[dict setValue:ww forKey:@"w"];
		[dict setValue:hh forKey:@"h"];
		
		[lineCoordForText addObject:dict];

        minX = MIN(minX, [x floatValue]);
        maxX = MAX(maxX, [x floatValue] + [ww floatValue]);
        minY = MIN(minY, [y floatValue]);
        maxY = MAX(maxY, [y floatValue] + [hh floatValue]);
	}
	[linesCoordForText addObject:lineCoordForText];
}


-(void) calcGraph {
	//for each line
	for (int i=0; i< linesCount; i++) {
		NSDictionary *lineStations = [stationsData objectAtIndex:i];
		[self calcOneLineGraph:lineStations :i];
	}
	[self processTransfersForGraph];
}

-(void) processTransfersForGraph{
    NSArray *stations = [[MHelper sharedHelper] getStationList];
    for (MStation* st in stations) {
        if(st.transfer) {
            NSString *station1 = [NSString stringWithFormat:@"%@|%@", st.name, st.lines.index];
            for (MStation *lst in st.transfer.stations) {
                if(lst != st) {
                    NSString *station2 = [NSString stringWithFormat:@"%@|%@", lst.name, lst.lines.index];
                    [graph addEdgeFromNode:[GraphNode nodeWithValue:station1] 
                                    toNode:[GraphNode nodeWithValue:station2]				 
                                withWeight:[st.transfer.time floatValue]];
                }
            }
        }
    }
}

-(void) calcOneLineGraph: (NSDictionary*)lineStationsData :(NSInteger)lineNum { 
	
	NSArray *stations = [[MHelper sharedHelper] getStationsForLineIndex:lineNum+1];
    NSString *prevStationName = nil;
    for (MStation *st in stations) {
		
		NSString *nextStationName;

		NSDictionary *stationDict = [lineStationsData objectForKey:st.name];
		NSArray *linkedStations = [stationDict objectForKey:@"linked"];
		NSArray *linkedStationsTime = [stationDict objectForKey:@"linked_time"];
		float stationTime;
		NSString *stationName = [NSString stringWithFormat:@"%@|%d",st.name,lineNum+1];
		
		if (linkedStations==nil) {
            if(prevStationName != nil) {
				[graph addEdgeFromNode:[GraphNode nodeWithValue:stationName] toNode:[GraphNode nodeWithValue:prevStationName] withWeight:stationTime];
				[graph addEdgeFromNode:[GraphNode nodeWithValue:prevStationName] toNode:[GraphNode nodeWithValue:stationName] withWeight:stationTime];
            }
		} else {
            stationTime = [st.driving floatValue];
			//линкованные
			for (int ii = 0 ; ii<[linkedStations count];ii++) {
				nextStationName = [NSString stringWithFormat:@"%@|%d",[linkedStations objectAtIndex:ii],lineNum+1];
				NSString *next_stationsTime = [linkedStationsTime objectAtIndex:ii];
				[graph addEdgeFromNode:[GraphNode nodeWithValue:stationName] toNode:[GraphNode nodeWithValue:nextStationName] withWeight:[next_stationsTime floatValue]];
				[graph addEdgeFromNode:[GraphNode nodeWithValue:nextStationName] toNode:[GraphNode nodeWithValue:stationName] withWeight:stationTime];
			}
		}
        prevStationName = stationName;
        stationTime = [st.driving floatValue];
	}
}


- (void)dealloc {
    [super dealloc];
    [drawedStations dealloc];

	[linesCoord dealloc];
	[linesCoordForText dealloc];
	[stationsData dealloc];
	[addNodes dealloc];
	[gpsCoords dealloc];
    [mapLines dealloc];
	[graph dealloc];
}

// drawing

-(void) drawMap:(CGContextRef) context 
{
    CGContextSaveGState(context);
    CGContextScaleCTM(context, koef, koef);
    CGContextTranslateCTM(context, -minX, -minY);
	//for each line
	/*for (int i=0; i< linesCount; i++) {
		NSArray *lineCoord = [NSArray arrayWithArray:[linesCoord objectAtIndex:i]];
        UIColor *lineColor = [[MHelper sharedHelper] lineByIndex:i+1].color;
		NSDictionary *lineStations = [stationsData objectAtIndex:i];
		[self drawMetroLine:context :lineCoord :lineColor :lineStations :i];
	}*/
    for (Line* l in mapLines) {
        [l draw:context width:kLineWidth];
    }
    CGContextRestoreGState(context);
}

-(void) drawStations:(CGContextRef) context
{
    CGContextSaveGState(context);
    CGContextScaleCTM(context, koef, koef);
    CGContextTranslateCTM(context, -minX, -minY);
    [drawedStations removeAllObjects];

    for (Line* l in mapLines) {
        [l drawNames:context];
    }
	/*currentLineNum = 0;
	for (int i=0; i< linesCount; i++) {
		currentLineNum = i+1;
        
        UIColor *lineColor = [[MHelper sharedHelper] lineByIndex:currentLineNum].color;
		NSDictionary *lineStations = [stationsData objectAtIndex:i];
		[self drawMetroLineStationName:context :lineColor :lineStations :i];
	}*/
    CGContextRestoreGState(context);
}

/*
-(void) drawMetroLine:(CGContextRef) context :(NSArray*)lineCoords :(UIColor*)lineColor 
					 :(NSDictionary*)lineStationsData :(NSInteger)line{ 
	
	NSDictionary *prev_coords = nil;
	NSArray *prev_linkedStations = nil;
	NSArray *stations = [[MHelper sharedHelper] getStationsForLineIndex:line+1];
    NSString *prevStationName = nil;
    for (MStation *st in stations) {
        
		NSString *nextStationName ;
		NSNumber *reverse_linked_prev;
		
		NSDictionary *stationDict = [lineStationsData objectForKey:st.name];
		NSArray *linkedStations = [stationDict objectForKey:@"linked"];
		NSNumber *reverse_linked = [stationDict objectForKey:@"reverse"];
		NSDictionary *coords = [stationDict objectForKey:@"coord"];
		
		if (linkedStations==nil)
		{
            if(prevStationName != nil) {
				//обычная станция
				NSDictionary * prevStationDict = [lineStationsData objectForKey:prevStationName];	
				NSDictionary * prevCoords = [prevStationDict objectForKey:@"coord"];
                
				Boolean reverse=false;
				NSArray *splineCoords;
				splineCoords = [addNodes objectForKey: [NSString stringWithFormat:@"%d,%@,%@" , (line+1),prevStationName,st.name]];
			 	if (splineCoords == nil) {
					reverse=true;	
					splineCoords = [addNodes objectForKey: [NSString stringWithFormat:@"%d,%@,%@" , (line+1),st.name,prevStationName]];
				}
				[self draw2Station:context :lineColor :prevCoords :coords :splineCoords :reverse];
                
            }
			
			//если пред станция имела линкованные(только с признаком reversed), а  теперь идет обычная, рисуем линк. Возможно косталь.
            
			if((prev_linkedStations!=nil) && ([reverse_linked_prev intValue]==1))
			{
				Boolean reverse=false;
				NSArray *splineCoords;
				splineCoords = [addNodes objectForKey: 
								[NSString stringWithFormat:@"%d,%@,%@" , (line+1),st.name,nextStationName]];
			 	if (splineCoords == nil)
				{
					reverse=true;	
					splineCoords = [addNodes objectForKey: 
									[NSString stringWithFormat:@"%d,%@,%@" , (line+1),nextStationName,st.name]];
				}
				
				[self draw2Station:context :lineColor :coords :prev_coords :splineCoords :reverse];
			}
			
		} else {
			
			//линкованные
			for (int ii = 0 ; ii<[linkedStations count];ii++)
			{
				nextStationName = [linkedStations objectAtIndex:ii];
				NSDictionary * next_stationDict = [lineStationsData objectForKey:[linkedStations objectAtIndex:ii]];
				NSDictionary * next_coords = [next_stationDict objectForKey:@"coord"];
                
				Boolean reverse=false;
				NSArray *splineCoords;
				splineCoords = [addNodes objectForKey: 
								[NSString stringWithFormat:@"%d,%@,%@" , (line+1),st.name,nextStationName]];
			 	if (splineCoords == nil)
				{
					reverse=true;	
					splineCoords = [addNodes objectForKey: 
									[NSString stringWithFormat:@"%d,%@,%@" , (line+1),nextStationName,st.name]];
				}
				[self draw2Station:context :lineColor :coords :next_coords :splineCoords :reverse];				
			}
			
		}
		prev_coords = coords;
		prev_linkedStations = linkedStations;
		reverse_linked_prev = reverse_linked;
		prevStationName = st.name;
	}
}*/
/*
-(void) drawMetroLineStationName:(CGContextRef) context :(UIColor*)lineColor 
								:(NSDictionary*)lineStationsData :(NSInteger) line { 
	
	NSDictionary *prev_coords = nil;
	NSArray *prev_linkedStations = nil;
	
    NSArray * stations = [[MHelper sharedHelper] getStationsForLineIndex:line + 1];
    for (MStation *st in stations) {
		
		NSDictionary *next_coords = nil;
		NSDictionary *next_text_coords = nil;
		NSDictionary *next_stationDict = nil;
		
		NSDictionary *stationDict = [lineStationsData objectForKey:st.name];
		NSArray *linkedStations = [stationDict objectForKey:@"linked"];
		NSDictionary *coords = [stationDict objectForKey:@"coord"];
		NSDictionary *text_coords = [stationDict objectForKey:@"text_coord"];
		
		if (linkedStations==nil) {
			//[self drawStationPoint: context coord:coords lineColor: lineColor];
			[self drawStationName:context :text_coords :coords :st.name :line+1];
			
		} else {
			
			[self drawStationPoint: context coord:coords lineColor: lineColor];
			[self drawStationName:context :text_coords :coords :st.name :line];
			
			//линкованные
			for (int ii = 0 ; ii<[linkedStations count];ii++)
			{
				next_stationDict = [lineStationsData objectForKey:[linkedStations objectAtIndex:ii]];
				next_coords = [next_stationDict objectForKey:@"coord"];
				next_text_coords = [next_stationDict objectForKey:@"coord"];
				
				//[self drawStationPoint: context coord:next_coords lineColor: lineColor];
				[self drawStationName:context :next_text_coords :next_coords :st.name :line+1];
			}
			
		}
		prev_coords = coords;
		prev_linkedStations = linkedStations;
	}
}
*/
-(void) draw2Station:(CGContextRef)context :(UIColor*)lineColor :(NSDictionary*) coord1 :(NSDictionary*)coord2 :(NSArray*) splineCoords :(Boolean) reverse{ 
	float x = [[coord1 objectForKey:@"x"] floatValue];
	float y = [[coord1 objectForKey:@"y"] floatValue];
	
	float x2 = [[coord2 objectForKey:@"x"] floatValue];
	float y2 = [[coord2 objectForKey:@"y"] floatValue];
	
	CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
	if (splineCoords!=nil)
	{
		[self drawSpline:context :x :y :x2 :y2 :splineCoords :reverse];
	}
	else
		[self drawLine:context :x :y :x2 :y2 :kLineWidth];
}

- (void) drawStationPoint: (CGContextRef) context y: (float) y x: (float) x lineColor: (UIColor *) lineColor  {
	
	
	CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.2, 0.8);
	[self drawCircle:context :x	:y :2.75];
	CGContextSetFillColorWithColor(context, [lineColor CGColor]);
	[self drawFilledCircle:context :x :y :2.5];
	
}

-(void) drawStationName:(CGContextRef) context :(float) x :(float) y  :(float) ww :(float)hh :(NSString*) stationName 
					   :(UITextAlignment) mode :(NSInteger) line{
	
	//draw filled rect
	CGRect textRect = CGRectMake(x, y, ww, hh);
	//CGContextSetRGBFillColor (context, 1, 1, 1, 0.3); // 6	
	//CGContextFillRect(context, textRect);
	

	//draw text
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	//	CGContextSetCharacterSpacing (context, 2); 
	CGContextSelectFont(context, "Helvetica", 9.0, kCGEncodingMacRoman);
	
	CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor] );
	CGContextSetTextDrawingMode (context, kCGTextFill); 
	
	
	UIGraphicsPushContext(context);			
	[stationName drawInRect:textRect  withFont: [UIFont fontWithName:@"Arial-BoldMT" size:7] 
			  lineBreakMode: UILineBreakModeWordWrap alignment: mode];
	UIGraphicsPopContext();
} 

- (void) drawStationPoint: (CGContextRef) context coord: (NSDictionary*) coord lineColor: (UIColor *) lineColor  {
	float x = [[coord objectForKey:@"x"] floatValue];
	float y = [[coord objectForKey:@"y"] floatValue];
	[self drawStationPoint: context y: y x: x lineColor: lineColor];
}

-(void) drawStationName:(CGContextRef) context  :(NSDictionary*) text_coord  :(NSDictionary*) point_coord :(NSString*) stationName :(NSInteger) line {
	
	if ([drawedStations objectForKey:stationName]!=nil)
		return;
	
	//[drawedStations setObject:@"yes" forKey:stationName];
	
	float x = [[text_coord objectForKey:@"x"] floatValue];
	float y = [[text_coord objectForKey:@"y"] floatValue];
	float ww = [[text_coord objectForKey:@"w"] floatValue];
	float hh = [[text_coord objectForKey:@"h"] floatValue];
	
	float point_x = [[point_coord objectForKey:@"x"] floatValue];
    
	UITextAlignment mode;
	if (x<point_x)
		mode = UITextAlignmentRight;
	else mode = UITextAlignmentLeft;

	[drawedStations setObject:@"yes" forKey:stationName];
    [self drawStationName:context :x :y :ww :hh :stationName :mode :line];
} 

-(void) drawSpline :(CGContextRef)context :(CGFloat)x1 :(CGFloat)y1 :(CGFloat)x2 :(CGFloat)y2 :(NSArray*) coordSpline :(Boolean) reverse {
	
	CatmullRomSpline *ctSpline = [CatmullRomSpline catmullRomSplineAtPoint:CGPointMake(x1,y1)];
    
    /*if([coordSpline count] == 1) {
        CGContextBeginPath(context);
        CGPoint begin = CGPointMake(x1, y1);//[[splineArray objectAtIndex:0] CGPointValue];
        CGContextMoveToPoint(context,begin.x,begin.y);
        NSArray *coords = [[coordSpline objectAtIndex:0] componentsSeparatedByString:@","];
        CGContextAddQuadCurveToPoint(context, [[coords objectAtIndex:0] floatValue], [[coords objectAtIndex:1] floatValue], x2, y2);
       	CGContextSetLineWidth(context, kLineWidth);
        CGContextDrawPath(context, kCGPathStroke);
        return;
    }*/
    
	NSEnumerator *enumerator;
	
	if (!reverse)
		enumerator = [coordSpline objectEnumerator];
	else
		enumerator = [coordSpline reverseObjectEnumerator];
    
    int pc = 1;
	for (id element in enumerator) {
		NSArray *coords = [element componentsSeparatedByString:@","];
		[ctSpline addPoint:CGPointMake([[coords objectAtIndex:0] floatValue], 
									   [[coords objectAtIndex:1] floatValue])];
        pc++;
	}
	//}
	
	[ctSpline addPoint:CGPointMake(x2,y2)];
    
    
	NSArray *splineArray = [ctSpline asPointArray];
	CGContextBeginPath(context);
	CGPoint begin = [[splineArray objectAtIndex:0] CGPointValue];
	CGContextMoveToPoint(context,begin.x,begin.y);

	for (int i=1; i<[splineArray count]-1; i++) {
		CGPoint p = [[splineArray objectAtIndex:i] CGPointValue];
		CGPoint p2 = [[splineArray objectAtIndex:i+1] CGPointValue];		
		CGContextAddQuadCurveToPoint(context, p.x, p.y, p2.x ,p2.y);
        CGContextAddLineToPoint(context, p.x, p.y);
	}
	CGContextAddLineToPoint(context,x2,y2);
	CGContextSetLineWidth(context, kLineWidth);
	CGContextDrawPath(context, kCGPathStroke);
}

// рисует часть карты
-(void) drawPathMap:(CGContextRef) context :(NSArray*) pathMap {
	
    CGContextSaveGState(context);
    CGContextScaleCTM(context, koef, koef);
    CGContextTranslateCTM(context, -minX, -minY);
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
			
            UIColor *lineColor = [[MHelper sharedHelper] lineByIndex:lineNum1].color;
			
			if (lineNum1==lineNum2)
			{
				NSDictionary *lineStations = [stationsData objectAtIndex:lineNum1-1];
				
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
			 	if (splineCoords == nil)
				{
					reverse=true;	
					splineCoords = [addNodes objectForKey: 
									[NSString stringWithFormat:@"%d,%@,%@" , (lineNum1),stationName2,stationName1]];
				}
				
				[self draw2Station:context :lineColor :coords :next_coords :splineCoords :reverse];
				
				[self drawStationPoint: context coord:coords lineColor: lineColor];
				[self drawStationName:context :text_coords :coords :stationName1 :lineNum1-1];
                
				[self drawStationPoint: context coord:next_coords lineColor: lineColor];
				[self drawStationName:context :next_text_coords :next_coords :stationName2 :lineNum1-1];
                
			}
		}
	}
    
    CGContextRestoreGState(context);
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

-(void) drawTransfers:(CGContextRef) context 
{
    CGContextSaveGState(context);
    CGContextScaleCTM(context, koef, koef);
    CGContextTranslateCTM(context, -minX, -minY);

    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
    
    NSArray *transfers = [[MHelper sharedHelper] getTransferList];
    for (MTransfer *tr in transfers) {
        NSArray *stations = [tr.stations allObjects];
        for(int i = 0; i<[stations count]; i++) {
            MStation *st = [stations objectAtIndex:i];
			NSDictionary *lineStations1 = [stationsData objectAtIndex:[st.lines.index intValue]-1];
			NSDictionary *stationDict1 = [lineStations1 objectForKey:st.name];
			NSDictionary *coords1 = [stationDict1 objectForKey:@"coord"];
			float x1 = [[coords1 objectForKey:@"x"] floatValue];
			float y1 = [[coords1 objectForKey:@"y"] floatValue];
            [self drawFilledCircle:context :x1 :y1 :3.5];
            for(int j = i+1; j<[stations count]; j++) {
                MStation *st2 = [stations objectAtIndex:j];
                NSDictionary *lineStations2 = [stationsData objectAtIndex:[st2.lines.index intValue]-1];
                NSDictionary *stationDict2 = [lineStations2 objectForKey:st2.name];
                NSDictionary *coords2 = [stationDict2 objectForKey:@"coord"];
                float x2 = [[coords2 objectForKey:@"x"] floatValue];
                float y2 = [[coords2 objectForKey:@"y"] floatValue];
                [self drawLine:context :x1 :y1 :x2 :y2 :2.5];
            }
        }
    }
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);				

    for (MTransfer *tr in transfers) {
        NSArray *stations = [tr.stations allObjects];
        for(int i = 0; i<[stations count]; i++) {
            MStation *st = [stations objectAtIndex:i];
			NSDictionary *lineStations1 = [stationsData objectAtIndex:[st.lines.index intValue]-1];
			NSDictionary *stationDict1 = [lineStations1 objectForKey:st.name];
			NSDictionary *coords1 = [stationDict1 objectForKey:@"coord"];
			float x1 = [[coords1 objectForKey:@"x"] floatValue];
			float y1 = [[coords1 objectForKey:@"y"] floatValue];
            [self drawFilledCircle:context :x1 :y1 :2.5];
            for(int j = i+1; j<[stations count]; j++) {
                MStation *st2 = [stations objectAtIndex:j];
                NSDictionary *lineStations2 = [stationsData objectAtIndex:[st2.lines.index intValue]-1];
                NSDictionary *stationDict2 = [lineStations2 objectForKey:st2.name];
                NSDictionary *coords2 = [stationDict2 objectForKey:@"coord"];
                float x2 = [[coords2 objectForKey:@"x"] floatValue];
                float y2 = [[coords2 objectForKey:@"y"] floatValue];
                [self drawLine:context :x1 :y1 :x2 :y2 :1.5];
            }
        }
    }
	CGContextRestoreGState(context);
}

-(NSInteger) checkPoint:(CGPoint)point Station:(NSMutableString *)stationName
{
    point.x /= koef;
    point.y /= koef;
    point.x += minX;
    point.y += minY;
    NSArray *stations = [[MHelper sharedHelper] getStationList];
    for (MStation* st in stations) {
        NSDictionary *lineStations = [stationsData objectAtIndex:[st.lines.index intValue]-1];
        NSDictionary *stationDict = [lineStations objectForKey:st.name];
        NSDictionary *text_coords = [stationDict objectForKey:@"text_coord"];
        float x1 = [[text_coords objectForKey:@"x"] floatValue];
        float y1 = [[text_coords objectForKey:@"y"] floatValue];
        float x2 = [[text_coords objectForKey:@"w"] floatValue] + x1;
        float y2 = [[text_coords objectForKey:@"h"] floatValue] + y1;
        
        if(point.x >= x1 && point.y >= y1 && point.x <= x2 && point.y <= y2) {
            [stationName setString:st.name];
            return [st.lines.index intValue];
        }
    }
    
    return -1;
}

@end
