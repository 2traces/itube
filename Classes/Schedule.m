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

double TimeParser(const char* ts)
{
    char * ss = 0;
    long t = strtol(ts, &ss, 10);
    if(*ss != ':') return -1;
    else ss++;
    t *= 3600;
    t += strtol(ss, 0, 10) * 60;
    return (double)t;
}

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
}

-(id)initWithStation:(NSString *)st andTime:(double)t
{
    if((self = [super init])) {
        const char *string = [st UTF8String];
        dock = 0;
        char *ch = index(string, '\"');
        if(ch) {
            ch ++;
            dock = *ch; 
        }
        char *ch2 = index(string, '(');
        if(ch == 0 && ch2 == 0) {
            name = [[st stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] retain];
        } else {
            int len = (ch == 0 || (ch2 != 0 && ch2 < ch)) ? ch2-string : ch-string;
            name = [[[[[NSString alloc] initWithBytes:string length:len encoding:NSUTF8StringEncoding] autorelease]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] retain];
        }
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
        //routes = [[NSMutableArray alloc] init];
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
    NSError *error = nil;
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:fn];
    TBXML *tbxml = [[TBXML alloc] initWithXMLData:xmlData error:&error];
    if(error) NSLog(@"%@", error);
    TBXMLElement *dir = [TBXML childElementNamed:@"direction" parentElement:tbxml.rootXMLElement];
    while (dir) {
        TBXMLElement *tts = [TBXML childElementNamed:@"timetables" parentElement:dir];
        while (tts) {
            TBXMLElement *tt = [TBXML childElementNamed:@"timetable" parentElement:tts];
            while (tt) {
                lastPoint = nil;
                //[routes addObject:[NSMutableArray array]];

                TBXMLElement *t = [TBXML childElementNamed:@"time" parentElement:[TBXML childElementNamed:@"times" parentElement:tt]];
                while (t) {
                    @autoreleasepool {
                        currentStation = [TBXML valueOfAttributeNamed:@"station" forElement:t];
                        NSTimeInterval t0 = TimeParser(t->text);
                        if(t0 >= 0) {
                            SchPoint *p = [[[SchPoint alloc] initWithStation:currentStation andTime:t0] autorelease];
                            if(lastPoint != nil) lastPoint.next = p;
                            //[[routes lastObject] addObject:p];
                            if([catalog valueForKey:p.name] == nil)
                                [catalog setValue:[NSMutableArray array] forKey:p.name];
                            else 
                                p.name = [[[catalog valueForKey:p.name] objectAtIndex:0] name];
                            [[catalog valueForKey:p.name] addObject:p];
                            lastPoint = p;
                        }
                    }
                    t = [TBXML nextSiblingNamed:@"time" searchFromElement:t];
                }
                tt = [TBXML nextSiblingNamed:@"timetable" searchFromElement:tt];
            }
            tts = [TBXML nextSiblingNamed:@"timetables" searchFromElement:tts];
        }
        dir = [TBXML nextSiblingNamed:@"direction" searchFromElement:dir];
    }
    [tbxml release];
    [xmlData release];
}

-(void) dealloc
{
    [lineName release];
    [dateForm release];
    //[routes release];
    [catalog release];
    [super dealloc];
}

-(void)setIndex:(int)_index
{
    index = _index;
    /*for (NSArray* r in routes) {
        for (SchPoint *p in r) {
            p.line = index;
        }
    }*/
    for (NSString* key in [catalog allKeys]) {
        for (SchPoint* p in [catalog valueForKey:key]) {
            p.line = index;
        }
    }
}

-(void)clean
{
    /*for (NSArray* r in routes) {
        for (SchPoint *p in r) {
            [p clean];
        }
    }*/
    for (NSString* key in [catalog allKeys]) {
        for (SchPoint* p in [catalog valueForKey:key]) {
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
        NSError *error = nil;
        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:fn];
        TBXML *tbxml = [TBXML tbxmlWithXMLData:xmlData error:&error];
        if(error) {
            NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
            [xmlData release];
            [self release];
            return nil;
        }
        TBXMLElement * el = [TBXML childElementNamed:@"route" parentElement:tbxml.rootXMLElement];
        while (el != nil) {
            @autoreleasepool {
                NSString * route = [TBXML valueOfAttributeNamed:@"route" forElement:el];
                NSString * file = [TBXML valueOfAttributeNamed:@"file" forElement:el];
                SchLine *l = [lines valueForKey:route];
                if(l == nil) {
                    l = [[[SchLine alloc] initWithName:route file:file path:_path] autorelease];
                    [lines setValue:l forKey:route];
                } else {
                    [l appendFile:file path:_path];
                }
                el = [TBXML nextSiblingNamed:@"route" searchFromElement:el];
            }
        }
        [xmlData release];
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

