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

@implementation Transfer

@synthesize stations;
@synthesize time;
@synthesize draw;

-(id)init
{
    if((self = [super init])) {
        stations = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [stations release];
}

@end

@implementation Station

@synthesize relation;
@synthesize relationDriving;
@synthesize segment;
@synthesize sibling;
@synthesize pos;
@synthesize textRect;
@synthesize index;
@synthesize name;
@synthesize driving;
@synthesize transfer;

-(id)initWithName:(NSString*)sname pos:(CGPoint)p index:(int)i rect:(CGRect)r andDriving:(NSString*)dr
{
    if((self = [super init])) {
        pos = p;
        index = i;
        textRect = r;
        segment = [[NSMutableArray alloc] init];
        relation = [[NSMutableArray alloc] init];
        relationDriving = [[NSMutableArray alloc] init];
        sibling = [[NSMutableArray alloc] init];
        
        NSUInteger br = [sname rangeOfString:@"("].location;
        if(br == NSNotFound) {
            name = [sname retain];
        } else {
            name = [[sname substringToIndex:br] retain];
            for (NSString* s in [[sname substringFromIndex:br+1] componentsSeparatedByString:@","]) {
                if([sname length] == 0) continue;
                [relation addObject:s];
            }
        }
        if(dr == nil) driving = 0;
        else {
            br = [dr rangeOfString:@"("].location;
            if(br == NSNotFound) {
                driving = [dr intValue];
            } else {
                driving = [[dr substringToIndex:br] intValue];
                for (NSString *s in [[dr substringFromIndex:br+1] componentsSeparatedByString:@","]) {
                    if([s length] == 0) continue;
                    int drv = [s intValue];
                    NSAssert(drv > 0, @"zero driving!");
                    [relationDriving addObject:[NSNumber numberWithInt:drv]];
                }
            }
        }
    }
    return self;
}

-(void)dealloc
{
    [segment release];
    [relation release];
    [relationDriving release];
    [sibling release];
}

-(void)addSibling:(Station *)st
{
    for (Station *s in sibling) {
        if(s == st) return;
    }
    [sibling addObject:st];
}

-(void)draw:(CGContextRef)context
{
    CGContextSetRGBStrokeColor(context, 0.9, 0.9, 0.1, 0.8);
	CGContextSetLineWidth(context, 1.5);
	CGContextStrokeEllipseInRect(context, CGRectMake(pos.x-2.75, pos.y-2.75, 5.5, 5.5));
    //CGContextFillEllipseInRect(context, CGRectMake(pos.x-2.5, pos.y-2.5, 5, 5));
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
    int alignment = UITextAlignmentCenter;
    if(pos.x < textRect.origin.x) alignment = UITextAlignmentLeft;
    else if(pos.x > textRect.origin.x + textRect.size.width) alignment = UITextAlignmentRight;
	[name drawInRect:textRect  withFont: [UIFont fontWithName:@"Arial-BoldMT" size:7] lineBreakMode: UILineBreakModeWordWrap alignment: alignment];
	UIGraphicsPopContext();
}

-(void) makeSegments
{
    int drv = [relationDriving count] - [sibling count];
    for(int i=0; i<[sibling count]; i++) {
        Station *st = [sibling objectAtIndex:i];
        int curDrv = driving;
        if(drv >= 0) curDrv = [[relationDriving objectAtIndex:drv] intValue];
        [segment addObject:[[Segment alloc] initFromStation:self toStation:st withDriving:curDrv]];
        drv ++;
    }
    if(!driving && [relationDriving count]) driving = [[relationDriving objectAtIndex:0] intValue];
    [relationDriving release];
    [relation release];
    relationDriving = nil;
    relation = nil;
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
    
    frontTang = CGPointMake(base.x + (p2.x-d.x)/3, base.y + (p2.y-d.y)/3);
    backTang = CGPointMake(base.x + (p1.x-d.x)/3, base.y + (p1.y-d.y)/3);
}
@end

@implementation Segment

@synthesize start;
@synthesize end;
@synthesize driving;

-(id)initFromStation:(Station *)from toStation:(Station *)to withDriving:(int)dr
{
    if((self = [super init])) {
        start = from;
        end = to;
        driving = dr;
        NSAssert(driving > 0, @"illegal driving");
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

@end

@implementation Line

@synthesize color  = _color;
@synthesize name;
@synthesize stations;

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
            
            NSString* drv = nil;
            if(i < [drs count]) drv = [drs objectAtIndex:i];
            Station *st = [[Station alloc] initWithName:[sts objectAtIndex:i] pos:CGPointMake(x, y) index:i rect:CGRectMake(tx, ty, tw, th) andDriving:drv];
            Station *last = [stations lastObject];
            if([st.relation count] < [st.relationDriving count]) {
                if(last.driving == 0) last.driving = [[st.relationDriving lastObject] intValue];
                [st.relationDriving removeLastObject];
            }
            if(![st.relation count] && [stations count]) {
                // создаём простые связи
                [last addSibling:st];
            }
            [stations addObject:st];
        }
        // создаём отложенные связи
        for (Station *st in stations) {
            for(NSString *rel in st.relation) {
                for(Station *st2 in stations) {
                    if([st2.name isEqualToString:rel]) {
                        [st addSibling:st2];
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

-(void)drawSegment:(CGContextRef)context from:(NSString *)station1 to:(NSString *)station2 width:(float)lineWidth
{
	CGContextSetStrokeColorWithColor(context, [_color CGColor]);
    CGContextSetFillColorWithColor(context, [_color CGColor]);
    for (Station *s in stations) {
        if([s.name isEqualToString:station1] || [s.name isEqualToString:station2]) {
            for (Segment *seg in s.segment) {
                if([seg.end.name isEqualToString:station1] || [seg.end.name isEqualToString:station2]) {
                    [seg draw:context width:lineWidth];
                    [s draw:context];
                    [seg.end draw:context];
                    [s drawName:context];
                    [seg.end drawName:context];
                    return;
                }
            }
        }
    }
}

-(void)additionalPointsBetween:(NSString *)station1 and:(NSString *)station2 points:(NSArray *)points
{
    Station *ss1 = nil;
    Station *ss2 = nil;
    for (Station *s in stations) {
        BOOL search = NO;
        BOOL rev = NO;
        if([s.name isEqualToString:station1]) {
            search = YES;
            ss1 = s;
        }
        else if([s.name isEqualToString:station2]) {
            search = rev = YES;
            ss2 = s;
        }
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
                    return;
                }
            }
        }
    }
    // сюда попадают какие-то лишние сплайны, которых на карте быть не должно
    /*if(ss1 && ss2) {
        int drv = ss1.driving;
        if(!drv) drv = ss2.driving;
        Segment *seg = [[Segment alloc] initFromStation:ss1 toStation:ss2 withDriving:drv];
        [ss1.segment addObject:seg];
        [ss1.sibling addObject:ss2];
        for (NSString *p in points) {
            NSArray *coord = [p componentsSeparatedByString:@","];
            [seg appendPoint:CGPointMake([[coord objectAtIndex:0] intValue], [[coord objectAtIndex:1] intValue])];
        }
        [seg calcSpline];
    }*/
}

-(Station*)getStation:(NSString *)stName
{
    for (Station *s in stations) {
        if([s.name isEqualToString:stName]) return s;
    }
    return nil;
}

@end

@implementation CityMap

@synthesize linesCount;
@synthesize utils;
@synthesize graph;
@synthesize gpsCoords;
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
    transfers = [[NSMutableArray alloc] init];
    kLineWidth = 4.f;
    kFontSize = 7.0f;
	utils = [[[Utils alloc] init] autorelease];
	gpsCoords = [[NSMutableDictionary alloc] init];
	graph = [[Graph graph] retain];
    mapLines = [[NSMutableArray alloc] init];
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

	//expected 3+ elements
	//separate line sations info
	NSArray *stations = [[elements objectAtIndex:0] componentsSeparatedByString:@","];
	
	NSString *lineName = [stations objectAtIndex:0];
	
    for (Line* l in mapLines) {
        if([l.name isEqualToString:lineName]) {
            [l additionalPointsBetween:[stations objectAtIndex:1] and:[stations objectAtIndex:2] points:[elements objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [elements count]-2)]]];
            break;
        }
    }
}

-(void) processLinesStations:(NSString*) stations :(NSUInteger) line{

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

			NSString *newstring = [remained_station substringToIndex:location2];
			
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
			NSString *newstring = [remained_station substringToIndex:location2]; // +1 

			NSUInteger location3 = [newstring rangeOfString:@"("].location;
			NSString *stationname = [newstring substringToIndex:location3];
			
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
	for (int j = 0 ; j < coord.count; j++) {
		NSArray *coord_x_y = [[coord objectAtIndex:j] componentsSeparatedByString:@","];
		
		NSString *xxs = [coord_x_y objectAtIndex:0];
		NSString *yys = [coord_x_y objectAtIndex:1];
		
		NSNumber *x = [NSNumber numberWithFloat:[xxs intValue]];
		NSNumber *y = [NSNumber numberWithFloat:[yys intValue]];
        minX = MIN(minX, [x floatValue]);
        maxX = MAX(maxX, [x floatValue]);
        minY = MIN(minY, [y floatValue]);
        maxY = MAX(maxY, [y floatValue]);
	}
}

-(void) processLinesCoordForText:(NSArray*) coord{
	for (int j = 0 ; j < coord.count; j++) {
		NSArray *coord_x_y = [[coord objectAtIndex:j] componentsSeparatedByString:@","];
		
		NSString *xxs = [coord_x_y objectAtIndex:0];
		NSString *yys = [coord_x_y objectAtIndex:1];
		NSString *wws = [coord_x_y objectAtIndex:2];
		NSString *hhs = [coord_x_y objectAtIndex:3];
		
		NSNumber *x = [NSNumber numberWithFloat:[xxs intValue]];
		NSNumber *y = [NSNumber numberWithFloat:[yys intValue]];
		NSNumber *ww = [NSNumber numberWithFloat:[wws intValue]];
		NSNumber *hh = [NSNumber numberWithFloat:[hhs intValue]];

        minX = MIN(minX, [x floatValue]);
        maxX = MAX(maxX, [x floatValue] + [ww floatValue]);
        minY = MIN(minY, [y floatValue]);
        maxY = MAX(maxY, [y floatValue] + [hh floatValue]);
	}
}


-(void) calcGraph {
	//for each line
    for (int i=0; i<[mapLines count]; i++) {
        Line *l = [mapLines objectAtIndex:i];
        for (Station *s in l.stations) {
            NSString *st1Name = [NSString stringWithFormat:@"%@|%d",s.name,i+1];
            for (Segment *seg in s.segment) {
                NSString *st2Name = [NSString stringWithFormat:@"%@|%d",seg.end.name,i+1];
				[graph addEdgeFromNode:[GraphNode nodeWithValue:st1Name] toNode:[GraphNode nodeWithValue:st2Name] withWeight:seg.driving];
				[graph addEdgeFromNode:[GraphNode nodeWithValue:st2Name] toNode:[GraphNode nodeWithValue:st1Name] withWeight:seg.driving];
            }
        }
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

- (void)dealloc {
    [super dealloc];
    [drawedStations dealloc];
	[gpsCoords dealloc];
    [mapLines dealloc];
	[graph dealloc];
    [transfers release];
}

// drawing

-(void) drawMap:(CGContextRef) context 
{
    CGContextSaveGState(context);
    CGContextScaleCTM(context, koef, koef);
    CGContextTranslateCTM(context, -minX, -minY);
	//for each line
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
    CGContextRestoreGState(context);
}

// рисует часть карты
-(void) drawPathMap:(CGContextRef) context :(NSArray*) pathMap {
	
    CGContextSaveGState(context);
    CGContextScaleCTM(context, koef, koef);
    CGContextTranslateCTM(context, -minX, -minY);
	[drawedStations removeAllObjects];

    NSMutableArray *ltransfers = [[NSMutableArray alloc] init];
	//for each line
	int count_ = [pathMap count];
	for (int i=0; i< count_; i++) {
		
		NSString *rawString1 = (NSString*)[[pathMap objectAtIndex:i] value];
		NSArray *el1  = [rawString1 componentsSeparatedByString:@"|"];
		NSString *stationName1 = [el1 objectAtIndex:0];
		NSInteger lineNum1 = [[el1 objectAtIndex:1] intValue]; 
        
		if ((i+1)!=count_) {
			NSString *rawString2 = (NSString*)[[pathMap objectAtIndex:i+1] value];
			NSArray *el2  = [rawString2 componentsSeparatedByString:@"|"];
			NSString *stationName2 = [el2 objectAtIndex:0];
			NSInteger lineNum2 = [[el2 objectAtIndex:1] intValue]; 
			
			if (lineNum1==lineNum2) {
                Line* l = [mapLines objectAtIndex:lineNum1-1];
                [l drawSegment:context from:stationName1 to:stationName2 width:kLineWidth];
			} else {
                NSString *lineName1 = [[MHelper sharedHelper] lineByIndex:lineNum1].name;
                NSString *lineName2 = [[MHelper sharedHelper] lineByIndex:lineNum2].name;
                NSArray *transfer = [NSArray arrayWithObjects:[[MHelper sharedHelper] getStationWithName:stationName1 forLine:lineName1], [[MHelper sharedHelper] getStationWithName:stationName2 forLine:lineName2], nil];
                [ltransfers addObject:transfer];
            }
		}
	}
    for (NSArray *t in ltransfers) {
        [self drawTransfer:context stations:t];
    }
    
    [ltransfers release];
    
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

-(void) drawFilledCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r{
	
    
	CGContextTranslateCTM(context, 0, 0);
	// Draw a circle (filled)
	//	CGContextMoveToPoint(context, x, y);
	CGContextFillEllipseInRect(context, CGRectMake(x-r, y-r, 2*r, 2*r));
}

-(void) drawTransfer:(CGContextRef) context stations:(NSArray*)stations
{
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
    for(int i = 0; i<[stations count]; i++) {
        MStation *st = [stations objectAtIndex:i];
        CGPoint p1 = [[mapLines objectAtIndex:[st.lines.index intValue]-1] getStation:st.name].pos;
        [self drawFilledCircle:context :p1.x :p1.y :4.5];
        for(int j = i+1; j<[stations count]; j++) {
            MStation *st2 = [stations objectAtIndex:j];
            CGPoint p2 = [[mapLines objectAtIndex:[st2.lines.index intValue]-1] getStation:st2.name].pos;
            [self drawLine:context :p1.x :p1.y :p2.x :p2.y :2.5];
        }
    }
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    for(int i = 0; i<[stations count]; i++) {
        MStation *st = [stations objectAtIndex:i];
        CGPoint p1 = [[mapLines objectAtIndex:[st.lines.index intValue]-1] getStation:st.name].pos;
        [self drawFilledCircle:context :p1.x :p1.y :3.5];
        for(int j = i+1; j<[stations count]; j++) {
            MStation *st2 = [stations objectAtIndex:j];
            CGPoint p2 = [[mapLines objectAtIndex:[st2.lines.index intValue]-1] getStation:st2.name].pos;
            [self drawLine:context :p1.x :p1.y :p2.x :p2.y :1.5];
        }
    }
    for (MStation *st in stations) {
        CGPoint p1 = [[mapLines objectAtIndex:[st.lines.index intValue]-1] getStation:st.name].pos;
        CGContextSetFillColorWithColor(context, [st.lines.color CGColor]);
        [self drawFilledCircle:context :p1.x :p1.y :1.5];
    }
}

-(void) drawTransfers:(CGContextRef) context 
{
    CGContextSaveGState(context);
    CGContextScaleCTM(context, koef, koef);
    CGContextTranslateCTM(context, -minX, -minY);
    
    //CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    //CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
    
    NSArray *transfers = [[MHelper sharedHelper] getTransferList];
    for (MTransfer *tr in transfers) {
        NSArray *stations = [tr.stations allObjects];
        [self drawTransfer:context stations:stations];
        /*for(int i = 0; i<[stations count]; i++) {
            MStation *st = [stations objectAtIndex:i];
            CGPoint p1 = [[mapLines objectAtIndex:[st.lines.index intValue]-1] getStation:st.name].pos;
            [self drawFilledCircle:context :p1.x :p1.y :3.5];
            for(int j = i+1; j<[stations count]; j++) {
                MStation *st2 = [stations objectAtIndex:j];
                CGPoint p2 = [[mapLines objectAtIndex:[st2.lines.index intValue]-1] getStation:st2.name].pos;
                [self drawLine:context :p1.x :p1.y :p2.x :p2.y :2.5];
            }
        }*/
    }
    
    /*CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    
    for (MTransfer *tr in transfers) {
        NSArray *stations = [tr.stations allObjects];
        for(int i = 0; i<[stations count]; i++) {
            MStation *st = [stations objectAtIndex:i];
            CGPoint p1 = [[mapLines objectAtIndex:[st.lines.index intValue]-1] getStation:st.name].pos;
            [self drawFilledCircle:context :p1.x :p1.y :2.5];
            for(int j = i+1; j<[stations count]; j++) {
                MStation *st2 = [stations objectAtIndex:j];
                CGPoint p2 = [[mapLines objectAtIndex:[st2.lines.index intValue]-1] getStation:st2.name].pos;
                [self drawLine:context :p1.x :p1.y :p2.x :p2.y :1.5];
            }
        }
    }*/
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
        Line *l = [mapLines objectAtIndex:[st.lines.index intValue]-1];
        Station *s = [l getStation:st.name];
        if(CGRectContainsPoint(s.textRect, point)) {
            [stationName setString:st.name];
            return [st.lines.index intValue];
        }
    }
    return -1;
}

@end
