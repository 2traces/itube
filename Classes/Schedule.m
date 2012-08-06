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
#import "MainView.h"

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
            int len = (ch == 0 || (ch2 != 0 && ch2 < ch)) ? ch2-string : ch-string-1;
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
    if(weight > p.weight + dw) {
        weight = p.weight + dw;
        backPath = p;
        return YES;
    }
    return NO;
}

-(BOOL)setWeightFrom:(SchPoint *)p withTransferTime:(double)tt
{
    double dw = time - (p.time+tt);
    while (dw < 0) dw += 24*60*60;
    if(weight > p.weight + dw + tt) {
        weight = p.weight + dw + tt;
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

-(id)initWithName:(NSString *)name fastFile:(NSString *)fileName path:(NSString *)path stations:(NSArray *)stations
{
    if((self = [super init])) {
        lineName = [name retain];
        index = 0;
        dateForm = [[NSDateFormatter alloc] init];
        [dateForm setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateForm setDateFormat:@"HH:mm"];
        catalog = [[NSMutableDictionary alloc] init];
        [self appendFastFile:fileName path:path stations:stations];
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
#ifdef DEBUG
    if(error) NSLog(@"%@", error);
#endif
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
                            p.line = index;
                            if(lastPoint != nil) {
                                lastPoint.next = p;
#ifdef DEBUG
                                float dt = p.time - lastPoint.time;
                                if(dt < 0 && dt > -23*60*60) {
                                    NSLog(@"wrong schedule time from %@ (at %d) to %@ (at %d) dT is %d", lastPoint.name, (int)lastPoint.time/60, p.name, (int)p.time/60, (int)dt/60);
                                }
#endif
                            }
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

-(void) appendFastFile:(NSString *)fileName path:(NSString *)path stations:(NSArray *)stations
{
    NSString *fn = nil;
    if(path == nil)
        fn = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    else 
        fn = [NSString stringWithFormat:@"%@/%@",path,fileName];

    lastPoint = nil;
    NSString *contents = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:nil];
    [contents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if([line length] <= 1) {
            lastPoint = nil;
        } else {
            NSArray *com = [line componentsSeparatedByString:@"\t"];
            int stId = [[com objectAtIndex:0] intValue];
            double time = 60.f * [[com objectAtIndex:1] intValue];
            SchPoint *p = [[[SchPoint alloc] initWithStation:[stations objectAtIndex:stId] andTime:time] autorelease];
            p.line = index;
            if(lastPoint != nil) {
                lastPoint.next = p;
#ifdef DEBUG
                float dt = p.time - lastPoint.time;
                if(dt < 0 && dt > -23*60*60) {
                    NSLog(@"wrong schedule time from %@ (at %d) to %@ (at %d) dT is %d", lastPoint.name, (int)lastPoint.time/60, p.name, (int)p.time/60, (int)dt/60);
                }
#endif
            }
            if([catalog valueForKey:p.name] == nil)
                [catalog setValue:[NSMutableArray array] forKey:p.name];
            else 
                p.name = [[[catalog valueForKey:p.name] objectAtIndex:0] name];
            [[catalog valueForKey:p.name] addObject:p];
            lastPoint = p;
        }
    }];
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
    /*for (NSString* key in [catalog allKeys]) {
        for (SchPoint* p in [catalog valueForKey:key]) {
            p.line = index;
        }
    }*/
}

-(void)setIndexFor:(NSString *)stationName
{
    for (SchPoint* p in [catalog valueForKey:stationName]) {
        p.line = index;
    }
}

-(void)removeUncheckedPoints
{
    NSMutableArray *rm = [NSMutableArray array];
    for (NSString* key in [catalog allKeys]) {
        for (SchPoint* p in [catalog valueForKey:key]) {
            if(p.line == 0) [rm addObject:p];
            else if(p.next.line == 0) p.next = nil;
        }
    }
    for (SchPoint *p in rm) {
        [[catalog valueForKey:p.name] removeObject:p]; 
    }
    [rm removeAllObjects];
}

-(void)clean
{
    for (NSString* key in [catalog allKeys]) {
        for (SchPoint* p in [catalog valueForKey:key]) {
            [p clean];
        }
    }
}

-(void)removeAllPoints
{
    [catalog removeAllObjects];
}

@end

/***** Schedule *****/

@implementation Schedule

-(id)initSchedule:(NSString *)fileName path:(NSString *)path
{
    if((self = [super init])) {
        loadTime = -1;
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
#ifdef DEBUG
            NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
#endif
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
    return self;
}

-(BOOL) loadFastSchedule:(int)hours
{
    for (NSString *ln in lines) {
        [[lines valueForKey:ln ] removeAllPoints];
    }
    NSError *error = nil;
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:xmlFile];
    TBXML *tbxml = [TBXML tbxmlWithXMLData:xmlData error:&error];
    if(error) {
#ifdef DEBUG
        NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
#endif
        [xmlData release];
        return NO;
    }
    [xmlData release];
    NSMutableArray *stationList = [NSMutableArray array];
    NSString *stations = [NSString stringWithContentsOfFile:stationsFile encoding:NSUTF8StringEncoding error:nil];
    [stations enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [stationList addObject:[[line componentsSeparatedByString:@"\t"] objectAtIndex:1]];
    }];
    loadTime = [self getNowTime];
    int now = (int)(loadTime / 60.f);
    TBXMLElement * el = [TBXML childElementNamed:@"route" parentElement:tbxml.rootXMLElement];
    while (el != nil) {
        @autoreleasepool {
            NSString * route = [TBXML valueOfAttributeNamed:@"route" forElement:el];
            SchLine *l = [lines valueForKey:route];
            TBXMLElement *f = [TBXML childElementNamed:@"file" parentElement:[TBXML childElementNamed:@"files" parentElement:el]];
            while(f != nil) {
                int from = [[TBXML valueOfAttributeNamed:@"time_from" forElement:f] intValue];
                int to = [[TBXML valueOfAttributeNamed:@"time_to" forElement:f] intValue];
                if(to < from) {
                    if(now >= from-60*hours) to += 60*24;
                    else from -= 60*24;
                }
                if(to >= now && from - now <= 60*hours) {
                    NSString * file = [NSString stringWithUTF8String:f->text];
                    if(l == nil) {
                        l = [[[SchLine alloc] initWithName:route fastFile:file path:_path stations:stationList] autorelease];
                        [lines setValue:l forKey:route];
                    } else {
                        [l appendFastFile:file path:_path stations:stationList];
                    }
                }
                f = [TBXML nextSiblingNamed:@"file" searchFromElement:f];
            }
            el = [TBXML nextSiblingNamed:@"route" searchFromElement:el];
        }
    }
    return YES;
}

-(id) initFastSchedule:(NSString *)fileName path:(NSString *)path
{
    if((self = [super init])) {
        cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        lines = [[NSMutableDictionary alloc] init];
        _path = [path retain];
        if(path == nil) {
            xmlFile = [[[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"] retain];
            stationsFile = [[[NSBundle mainBundle] pathForResource:@"stations" ofType:@"txt"] retain];
        } else {
            xmlFile = [[NSString stringWithFormat:@"%@/%@.xml",path,fileName] retain];
            //fn = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml" inDirectory:path];
            stationsFile = [[NSString stringWithFormat:@"%@/stations.txt", path] retain];
        }
        if(xmlFile == nil) {
            [self release];
            return nil;
        }
        if(![self loadFastSchedule:4]) {
            [self release];
            return nil;
        }
    }
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
#ifdef DEBUG
        NSLog(@"Error: line %@ not found in %@", line, _path);
#endif
        return NO;
    }
}

-(BOOL)checkStation:(NSString *)station line:(NSString *)line
{
    SchLine *l = [lines valueForKey:line];
    if(l != nil) {
        if([l.catalog valueForKey:station] != nil) {
            [l setIndexFor:station];
            return YES;
        } else {
#ifdef DEBUG
            NSLog(@"Error: Station %@ at line %@ not found", station, line);
#endif
            return NO;
        }
    } else {
        return NO;
    }
}

-(BOOL)existStation:(NSString *)station line:(NSString *)line
{
    SchLine *l = [lines valueForKey:line];
    if(l != nil) {
        if([l.catalog valueForKey:station] != nil) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

-(BOOL)existLine:(NSString*)line
{
    SchLine *l = [lines valueForKey:line];
    if(l != nil) {
        if([l.catalog count] > 0) return YES;
    }
    return NO;
}

-(NSTimeInterval)getNowTime
{
    //return 43200;
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
    NSArray *res = nil;
    NSTimeInterval now = [self getNowTime];
    int hours = 2;
    if(loadTime >= 0) {
        if(now > loadTime+900 || (now < loadTime && now+24*60*60 > loadTime+900)) {
            // we will try to update the schedule every 15 minutes
            [self loadFastSchedule:hours];
        }
    }
    do {
        res = [self internalFindPathFrom:fromStation to:toStation];
        if(res != nil && [res count] > 0) break;
        hours += 2;
        if(hours > 24) break;
        NSTimeInterval now2 = [self getNowTime];
        // time out
        if(now2-now >= 15.0) return res;
        [self loadFastSchedule:hours];
    } while (true);
    return res;
}

-(NSArray*)internalFindPathFrom:(NSString*)fromStation to:(NSString*)toStation
{
    if([fromStation isEqualToString:toStation]) {
        return [NSArray array];
    }
    NSTimeInterval now = [self getNowTime];
    [self clean];
    SortedArray *propagate = [[SortedArray alloc] init];
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
        SchPoint *p = [propagate objectAtIndex:0]; //[self nearestPoint:propagate];
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
                        CGFloat trtime = FindTransferTime(np.line, np.name, tp.line, tp.name);
                        if(tp.backPath != nil) [tp setWeightFrom:np withTransferTime:trtime];
                        else {
                            [tp setWeightFrom:np withTransferTime:trtime];
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

-(void) removeUncheckedStations
{
    for (NSString *ln in lines) {
        [[lines valueForKey:ln] removeUncheckedPoints];
    }
}

-(SchLine*)lineByIndex:(int)index
{
    for (NSString *lname in lines) {
        SchLine *l = [lines objectForKey:lname];
        if(l.index == index) return l;
    }
    return nil;
}

-(BOOL)findRestOfPath:(NSArray*)graphNodes points:(NSMutableArray*)schPoints wait:(BOOL)wait
{
    if([graphNodes count] == 0) return YES;
    SchPoint *lastP = [schPoints lastObject];
    GraphNode *node = [graphNodes objectAtIndex:0];
    BOOL nextWait = [node.edgesIn count] > 2 || [node.edgesOut count] > 2;
    SortedArray *propagate = [[SortedArray alloc] init];
    if(lastP.line != node.line) {
        // transfer
        SchLine *l = [self lineByIndex:node.line];
        NSArray *sts = [l.catalog valueForKey:node.name];
        [propagate removeAllObjects];
        for (SchPoint *tp in sts) {
            CGFloat trtime = 0;
            trtime = FindTransferTime(lastP.line, lastP.name, node.line, node.name);
            if([tp setWeightFrom:lastP withTransferTime:trtime])
                [propagate addObject:tp];
        }
        for(int i=0; i<[propagate count]; i++) {
            [schPoints addObject:[propagate objectAtIndex:i]];
            NSRange range;
            range.location = 1;
            range.length = [graphNodes count]-1;
            if([self findRestOfPath:[graphNodes subarrayWithRange:range] points:schPoints wait:NO]) {
                [propagate release];
                return YES;
            } else {
                [schPoints removeLastObject];
            }
        }
    } else {
        // line
        SchPoint *nextP = lastP.next;
        if(nextP != nil) {
            [nextP setWeightFrom:lastP];
            [schPoints addObject:nextP];
            for(int i=0; i<[graphNodes count]; i++) {
                if([nextP.name isEqualToString:[[graphNodes objectAtIndex:i] name]] && nextP.line == [[graphNodes objectAtIndex:i] line] ) {
                    NSRange range;
                    range.location = i+1;
                    range.length = [graphNodes count]-range.location;
                    if([self findRestOfPath:[graphNodes subarrayWithRange:range] points:schPoints wait:nextWait]) {
                        [propagate release];
                        return YES;
                    }
                }
            }
            [schPoints removeLastObject];
        }
        if(wait) {
            // check transfer within the same line
            SchLine *l = [self lineByIndex:lastP.line];
            NSArray *sts = [l.catalog valueForKey:lastP.name];
            [propagate removeAllObjects];
            for (SchPoint *tp in sts) {
                if(tp.next == nil) continue;
                if([tp setWeightFrom:lastP withTransferTime:2])
                    [propagate addObject:tp];
            }
            for(int i=0; i<[propagate count]; i++) {
                SchPoint * curP = [propagate objectAtIndex:i];
                if(curP.weight > 60*60*4) break;
                [schPoints addObject:curP];
                if([self findRestOfPath:graphNodes points:schPoints wait:NO]) {
                    [propagate release];
                    return YES;
                } else {
                    [schPoints removeLastObject];
                }
            }
        }
    }
    [propagate release];
    return NO;
}

-(NSArray*)translatePath:(NSArray *)graphNodes
{
    if([graphNodes count] == 0) return nil;
    NSMutableArray *result = [NSMutableArray array];
    NSTimeInterval now = [self getNowTime];
    SortedArray *propagate = [[SortedArray alloc] init];
    [self clean];
    GraphNode *node = [graphNodes objectAtIndex:0];
    SchLine *l = [self lineByIndex:node.line];
    NSArray *sts = [l.catalog valueForKey:node.name];
    [propagate removeAllObjects];
    for (SchPoint *tp in sts) {
        [tp setWeightBy:now];
        [propagate addObject:tp];
    }
    for(int i=0; i<[propagate count]; i++) {
        [result removeAllObjects];
        [result addObject:[propagate objectAtIndex:i]];
        NSRange range;
        range.location = 1;
        range.length = [graphNodes count]-1;
        if([self findRestOfPath:[graphNodes subarrayWithRange:range] points:result wait:NO]) {
            if([result count] > 1 && [[result objectAtIndex:0] line] != [[result objectAtIndex:1] line]) {
                NSRange range;
                range.location = 1;
                range.length = [result count] -1;
                [propagate release];
                return [result subarrayWithRange:range];
            }
            [propagate release];
            return result;
        }
    }
    [propagate release];
    
    
    /*GraphNode *prevNode = nil;
    int curnode = 0;
    for (; curnode < [graphNodes count]; curnode++) {
        GraphNode *node = [graphNodes objectAtIndex:curnode];
        if(prevNode == nil || prevNode.line != node.line) {
            // transfer or first point
            SchLine *l = [self lineByIndex:node.line];
            NSArray *sts = [l.catalog valueForKey:node.name];
            [propagate removeAllObjects];
            for (SchPoint *tp in sts) {
                CGFloat trtime = 0;
                if(prevNode != nil) trtime = FindTransferTime(prevNode.line, prevNode.name, node.line, node.name);
                if([result count] > 0) [tp setWeightFrom:[result lastObject] withTransferTime:trtime];
                else [tp setWeightBy:now];
                [propagate addObject:tp];
            }
            if([result count] == 1) 
                [result removeAllObjects];
            [result addObject:[propagate objectAtIndex:0]];
        } else {
            SchPoint *nextP = [[result lastObject] next];
            while(![nextP.name isEqualToString:node.name]) {
                curnode++;
                if(curnode < [graphNodes count]) node = [graphNodes objectAtIndex:curnode];
                else break;
            }
            if(curnode >= [graphNodes count]) {
                // error
                NSLog(@"path not found!");
            } else {
                [result addObject:nextP];
            }
        }
        prevNode = node;
    }*/
    NSLog(@"path not found!");
    return nil;
}

@end

/***** SortedArray *****/

@implementation SortedArray

+(id) array
{
    SortedArray *sa = [[SortedArray alloc] init];
    return [sa autorelease];
}

-(id) init
{
    if((self = [super init])) {
        size = 0;
        maxSize = 10;
        data = malloc(maxSize * sizeof(SchPoint*));
    }
    return self;
}

-(void) addObject:(SchPoint*)point
{
    if(size == maxSize) {
        maxSize *= 2;
        data = realloc(data, maxSize * sizeof(SchPoint*));
    }
    if(size > 0) {
        int b1 = 0, b2 = size-1, ind = -1;
        float pw = point->weight;
        if(data[b1]->weight >= pw) {
            ind = b1;
        }
        if(data[b2]->weight <= pw) {
            ind = b2+1;
        }
        while (ind < 0) {
            int b = (b1+b2)/2;
            float w = data[b]->weight;
            if(w < pw) {
                b1 = b;
            } else if(w > pw) {
                b2 = b;
            } else {
                ind = b;
            }
            if(b2-b1 <= 1) ind = b2;
        }
        memmove(data + ind + 1, data + ind, (size-ind)*sizeof(SchPoint*));
        data[ind] = point;
        size ++;
    } else {
        data[0] = point;
        size = 1;
    }
}

-(BOOL) removeObject:(SchPoint*)point
{
    if(data[0] == point) {
        memmove(data, data+1, (size-1)*sizeof(SchPoint*));
        size --;
        return YES;
    }
    if(data[size-1] == point) {
        size --;
        return YES;
    }
    int b1 = 0, b2 = size-1, ind = -1, ind2 = -1;
    float pw = point->weight;
    if(data[b1]->weight > pw) {
        return NO;
    }
    if(data[b2]->weight < pw) {
        return NO;
    }
    while (ind < 0) {
        int b = (b1+b2)/2;
        float w = data[b]->weight;
        if(w < pw) {
            b1 = b;
        } else if(w > pw) {
            b2 = b;
        } else {
            ind = b;
        }
        if(b2-b1 < 1) ind = b2;
    }
    for(int i=ind; ind2 < 0 && data[i]->weight == pw; i--) {
        if(data[i] == point) ind2 = i;
    }
    for(int i=ind; ind2 < 0 && data[i]->weight == pw; i++) {
        if(data[i] == point) ind2 = i;
    }
    if(ind2 < 0) return NO;
    memmove(data + ind2, data + ind2 + 1, (size-ind2-1)*sizeof(SchPoint*));
    size --;
    return YES;
}

-(void) removeAllObjects
{
    size = 0;
}

-(int) count
{
    return size;
}

-(SchPoint*) objectAtIndex:(int)index
{
    NSAssert1(index < size, @"Index %d out of range", index);
    return data[index];
}

-(void)dealloc
{
    free(data);
    [super dealloc];
}

@end