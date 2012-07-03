//
//  Schedule.h
//  tube
//
//  Created by vasiliym on 07.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

/***** SchPoint *****/

@interface SchPoint : NSObject {
@private
    NSString *name;
    int line;
    float time;
    SchPoint *next;
    SchPoint *backPath;
    char dock;
@public
    float weight;
}
@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) int line;
@property (nonatomic, readonly) float time;
@property (nonatomic, assign) SchPoint *next;
@property (nonatomic, readonly) float weight;
@property (nonatomic, readonly) SchPoint *backPath;
@property (nonatomic, readonly) char dock;

-(id) initWithStation:(NSString*)st andTime:(double)t;
-(BOOL) setWeightFrom:(SchPoint*)p;
-(BOOL) setWeightFrom:(SchPoint *)p withTransferTime:(double)tt;
-(void) setWeightBy:(double)time;
-(void) clean;
-(BOOL) greaterThan:(SchPoint*)p;
@end

/***** SchLine *****/

@interface SchLine : NSObject {
@private
    NSString *lineName;
    int index;
    NSDateFormatter *dateForm;
    NSString *currentStation;
    SchPoint *lastPoint;

    //NSMutableArray *routes;
    NSMutableDictionary *catalog;
}
@property (nonatomic, readonly) NSString* lineName;
@property (nonatomic, assign) int index;
@property (nonatomic, readonly) NSDictionary *catalog;

-(id)initWithName:(NSString*)name file:(NSString*)fileName path:(NSString*)path;
-(void)appendFile:(NSString*)fileName path:(NSString*)path;
-(id)initWithName:(NSString*)name fastFile:(NSString*)fileName path:(NSString*)path stations:(NSArray*)stations;
-(void)appendFastFile:(NSString*)fileName path:(NSString*)path stations:(NSArray*)stations;
-(void)removeAllPoints;
-(void)setIndexFor:(NSString*)stationName;
-(void)removeUncheckedPoints;
@end

/***** Schedule *****/

@interface Schedule : NSObject {
    NSCalendar *cal;
    NSMutableDictionary *lines;
    NSString* _path;
    NSTimeInterval loadTime;
    NSString *xmlFile;
    NSString *stationsFile;
    
    SchLine *currentLine;
    int currentIndex;
}

-(id) initSchedule:(NSString*)fileName path:(NSString*)path;
-(id) initFastSchedule:(NSString *)fileName path:(NSString *)path;
-(BOOL) setIndex:(int)ind forLine:(NSString*)line;
-(BOOL) checkStation:(NSString*)station line:(NSString*)line;
-(BOOL) existStation:(NSString*)station line:(NSString*)line;
-(NSDate*) getPointDate:(SchPoint*)p;
-(void) removeUncheckedStations;

-(NSArray*)findPathFrom:(NSString *)fromStation to:(NSString*)toStation;
-(NSArray*)translatePath:(NSArray*)graphNodes;
@end

/***** SortedArray *****/

@interface SortedArray : NSObject {
    int maxSize;
    int size;
    SchPoint** data;
}

+(id) array;
-(id) init;
-(void) addObject:(SchPoint*)point;
-(BOOL) removeObject:(SchPoint*)point;
-(void) removeAllObjects;
-(int) count;
-(SchPoint*) objectAtIndex:(int)index;

@end


