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
    float weight;
    SchPoint *backPath;
    char dock;
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
-(void) setWeightBy:(double)time;
-(void) clean;
-(BOOL) greaterThan:(SchPoint*)p;
+(void) cleanup;
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
@end

/***** Schedule *****/

@interface Schedule : NSObject {
    NSCalendar *cal;
    NSMutableDictionary *lines;
    NSString* _path;
}

-(id) initSchedule:(NSString*)fileName path:(NSString*)path;
-(BOOL) setIndex:(int)ind forLine:(NSString*)line;
-(BOOL) checkStation:(NSString*)station line:(NSString*)line;
-(NSDate*) getPointDate:(SchPoint*)p;

-(NSArray*)findPathFrom:(NSString *)fromStation to:(NSString*)toStation;
@end
