//
//  Schedule.m
//  tube
//
//  Created by vasiliym on 07.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Schedule.h"
#import "tubeAppDelegate.h"
#import "CityMap.h"

/***** SchPoint *****/

NSCharacterSet *pCharacterSet = nil;

@implementation SchPoint
@synthesize name;
@synthesize line;
@synthesize time;
@synthesize next;
@synthesize weight;
@synthesize backPath;
@synthesize dock;

+(void)cleanup
{
    [pCharacterSet release];
    pCharacterSet = nil;
}

-(id)initWithStation:(NSString *)st andTime:(double)t
{
    if((self = [super init])) {
        if(pCharacterSet == nil) pCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"()"] retain];
        dock = 0;
        NSArray *s = [st componentsSeparatedByString:@"\""];
        int sc = [s count];
        for(int i=1; i<sc; i++) {
            if([[s objectAtIndex:i] length] > 0) {
                dock = [[s objectAtIndex:i] characterAtIndex:0];
                break;
            }
        } 
        NSArray *ss = [[s objectAtIndex:0] componentsSeparatedByCharactersInSet:pCharacterSet];
        name = [[[ss objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] retain];
        time = t;
    }
    return self;
}

-(void)setWeightBy:(double)_time
{
    weight = time - _time;
    while (weight < 0) weight += 24*60*60;
    backPath = nil;
}

-(BOOL)setWeightFrom:(SchPoint *)p
{
    double dw = time - p.time;
    while (dw < 0) dw += 24*60*60;
    if(weight >= p.weight + dw) {
        weight = p.weight + dw;
        backPath = p;
        return YES;
    }
    return NO;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ at %d:%d", name, (int)time/3600, ((int)time%3600)/60];
}

-(void)clean
{
    weight = INFINITY;
    backPath = nil;
}

-(BOOL) greaterThan:(SchPoint *)p
{
    return weight > p.weight;
}

-(void)dealloc
{
    [name release];
    [super dealloc];
}

@end

/***** SchLine *****/

@implementation SchLine
@synthesize lineName;
@synthesize index;
@synthesize catalog;

-(id)initWithName:(NSString*)name file:(NSString *)fileName path:(NSString *)path
{
    if((self = [super init])) {
        lineName = [name retain];
        index = 0;
        dateForm = [[NSDateFormatter alloc] init];
        [dateForm setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateForm setDateFormat:@"HH:mm"];
        routes = [[NSMutableArray alloc] init];
        catalog = [[NSMutableDictionary alloc] init];
        [self appendFile:fileName path:path];
    }
    return self;
}

-(void) appendFile:(NSString *)fileName path:(NSString *)path
{
    NSString *fn = nil;
    if(path == nil)
        fn = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"];
    else 
        fn = [NSString stringWithFormat:@"%@/%@.xml",path,fileName];
    // fn = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml" inDirectory:path];
    NSData *xmlData = [NSData dataWithContentsOfFile:fn];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    parser.delegate = self;
    if(![parser parse]) {
        NSLog(@"Can't load xml file: %@", fn);
    }
    [parser release];
    [currentStation release];
    currentStation = nil;
}

-(void) dealloc
{
    [lineName release];
    [dateForm release];
    [routes release];
    [catalog release];
    [super dealloc];
}

-(void)setIndex:(int)_index
{
    index = _index;
    for (NSArray* r in routes) {
        for (SchPoint *p in r) {
            p.line = index;
        }
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"timetable"]) {
        lastPoint = nil;
        [routes addObject:[NSMutableArray array]];
    } else if([elementName isEqualToString:@"time"]) {
        currentStation = [[attributeDict objectForKey:@"station"] retain];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"time"]) {
        [currentStation release];
        currentStation = nil;
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(currentStation == nil) return;
    @autoreleasepool {
        NSArray * tcom = [string componentsSeparatedByString:@":"];
        if([tcom count] >= 2) {
            NSTimeInterval t0 = [[tcom objectAtIndex:0] doubleValue] * 3600 + [[tcom objectAtIndex:1] doubleValue] * 60;
            SchPoint *p = [[[SchPoint alloc] initWithStation:currentStation andTime:t0] autorelease];
            if(lastPoint != nil) lastPoint.next = p;
            [[routes lastObject] addObject:p];
            if([catalog valueForKey:p.name] == nil)
                [catalog setValue:[NSMutableArray array] forKey:p.name];
            [[catalog valueForKey:p.name] addObject:p];
            lastPoint = p;
        }
    }
}

-(void)clean
{
    for (NSArray* r in routes) {
        for (SchPoint *p in r) {
            [p clean];
        }
    }
}

@end

/***** Schedule *****/

@implementation Schedule

-(id)initSchedule:(NSString *)fileName path:(NSString *)path
{
    if((self = [super init])) {
        cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        lines = [[NSMutableDictionary alloc] init];
        _path = [path retain];
        NSString *fn = nil;
        if(path == nil) 
            fn = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"];
        else {
            fn = [NSString stringWithFormat:@"%@/%@.xml",path,fileName];
            //fn = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml" inDirectory:path];
        }
        if(fn == nil) {
            [self release];
            return nil;
        }
        if(fn == nil) {
            [self release];
            return nil;
        }
        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:fn];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
        [xmlData release];
        parser.delegate = self;
        if(![parser parse]) {
            NSLog(@"Can't load xml file %@", fileName);
            [self release];
            return nil;
        }
        [parser release];
    }
    [SchPoint cleanup];
    return self;
}

-(void)dealloc
{
    [cal release];
    [lines release];
    [_path release];
    [super dealloc];
}

-(BOOL)setIndex:(int)ind forLine:(NSString *)line
{
    SchLine *l = [lines valueForKey:line];
    if(l != nil) {
        [l setIndex:ind];
        return YES;
    } else {
        NSLog(@"Error: line %@ not found in %@", line, _path);
        return NO;
    }
}

-(BOOL)checkStation:(NSString *)station line:(NSString *)line
{
    SchLine *l = [lines valueForKey:line];
    if(l != nil) {
        if([l.catalog valueForKey:station] != nil)
            return YES;
        else {
            NSLog(@"Error: Station %@ not found", station);
            return NO;
        }
    } else {
        return NO;
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"route"]) {
        @autoreleasepool {
            NSString *lineName = [attributeDict valueForKey:@"route"];
            SchLine *l = [lines valueForKey:lineName];
            if(l == nil) {
                l = [[[SchLine alloc] initWithName:lineName file:[attributeDict valueForKey:@"file"] path:_path] autorelease];
            } else {
                [l appendFile:[attributeDict valueForKey:@"file"] path:_path];
            }
            [lines setValue:l forKey:lineName];
        }
    }
}

-(NSTimeInterval)getNowTime
{
    NSDateComponents *comp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    NSDate *midnight = [cal dateFromComponents:comp];
    return [[NSDate date] timeIntervalSinceDate:midnight];
}

-(NSDate*) getPointDate:(SchPoint*)p
{
    NSDateComponents *comp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    NSDate *midnight = [cal dateFromComponents:comp];
    return [midnight dateByAddingTimeInterval:p.time];
}

-(void)clean
{
    for (NSString* l in lines) {
        [[lines valueForKey:l] clean];
    }
}

-(SchPoint*) nearestPoint:(NSArray*) points
{
    double weight = INFINITY;
    SchPoint *nearest = nil;
    for (SchPoint *s in points) {
        if(s.weight < weight) {
            weight = s.weight;
            nearest = s;
        }
    }
    return nearest;
}

-(NSArray*)findPathFrom:(NSString *)fromStation to:(NSString*)toStation
{
    if([fromStation isEqualToString:toStation]) return [NSArray array];
    [self clean];
    
    NSTimeInterval now = [self getNowTime];
    NSMutableArray *propagate = [[NSMutableArray alloc] init];
    NSMutableDictionary *flag = [NSMutableDictionary dictionary];
    for (NSString *ln in lines) {
        SchLine *l = [lines valueForKey:ln];
        NSArray *sts = [l.catalog valueForKey:fromStation];
        for (SchPoint *p in sts) {
            [p setWeightBy:now];
            [propagate addObject:p];
        }
    }
    [flag setValue:@"YES" forKey:fromStation];
    SchPoint *target = nil;
    while ([propagate count] > 0) {
        //[propagate sortUsingSelector:@selector(greaterThan:)];
        SchPoint *p = [self nearestPoint:propagate];// [propagate objectAtIndex:0];
        if([p.name isEqualToString:toStation]) {
            // found a path
            target = p;
            break;
        }
        SchPoint *np = p.next;
        if(np != nil) {
            if(np.backPath != nil) [np setWeightFrom:p];
            else {
                [np setWeightFrom:p];
                [propagate addObject:np];
            }
            if([flag valueForKey:np.name] == nil) {
                [flag setValue:@"YES" forKey:np.name];
                for (NSString *ln in lines) {
                    SchLine *l = [lines valueForKey:ln];
                    NSArray *sts = [l.catalog valueForKey:np.name];
                    for (SchPoint *tp in sts) {
                        if(tp == np) continue;
                        if(tp.backPath != nil) [tp setWeightFrom:np];
                        else {
                            [tp setWeightFrom:np];
                            [propagate addObject:tp];
                        }
                    }
                }
            }
        }
        [propagate removeObject:p];
    }
    [propagate release];
    if(target != nil) {
        NSMutableArray *result = [NSMutableArray array];
        while (target != nil) {
            [result insertObject:target atIndex:0];
            if([target.name isEqualToString:fromStation]) break;
            target = target.backPath;
        }
        return result;
    }
    return [NSArray array];
}

@end
