//
//  CityMap.h
//  tube
//
//  Created by Alex 1 on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"
#import "Graph.h"
//#import <CoreLocation/CoreLocation.h>

extern NSInteger const kDataShift;
extern NSInteger const kDataRowForLine;

NSMutableArray * Split(NSString* s);

@class Station;
@class Line;

@interface Transfer : NSObject {
@private
    NSMutableSet* stations;
    CGFloat time;
    BOOL draw;
}
@property (nonatomic, readonly) NSMutableSet* stations;
@property (nonatomic, assign) CGFloat time;
@property (nonatomic, assign) BOOL draw;

-(void) addStation:(Station*)station;
@end

@interface Station : NSObject {
@private
    CGPoint pos;
    CGRect textRect;
    int index;
    int driving;
    NSString *name;
    // сегменты пути
    NSMutableArray *segment;
    // соседние станции
    NSMutableArray *sibling;
    // имена соседних станций
    NSMutableArray *relation;
    NSMutableArray *relationDriving;
    Transfer *transfer;
    Line *line;
}

@property (nonatomic, readonly) NSMutableArray* relation;
@property (nonatomic, readonly) NSMutableArray* relationDriving;
@property (nonatomic, readonly) NSMutableArray* segment;
@property (nonatomic, readonly) NSMutableArray* sibling;
@property (nonatomic, readonly) CGPoint pos;
@property (nonatomic, readonly) CGRect textRect;
@property (nonatomic, readonly) int index;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, assign) int driving;
@property (nonatomic, assign) Transfer* transfer;
@property (nonatomic, assign) Line* line;

-(id) initWithName:(NSString*)sname pos:(CGPoint)p index:(int)i rect:(CGRect)r andDriving:(NSString*)dr;
-(void) addSibling:(Station*)st;
-(void) draw:(CGContextRef)context;
-(void) drawName:(CGContextRef)context;
-(void) drawLines:(CGContextRef)context width:(CGFloat)lineWidth;
-(void) makeSegments;
@end

@interface TangentPoint : NSObject {
@private
    CGPoint base;
    CGPoint backTang;
    CGPoint frontTang;
}
@property (nonatomic, readonly) CGPoint base;
@property (nonatomic, readonly) CGPoint backTang;
@property (nonatomic, readonly) CGPoint frontTang;

-(id)initWithPoint:(CGPoint)p;
-(void)calcTangentFrom:(CGPoint)p1 to:(CGPoint)p2;
@end

@interface Segment : NSObject {
@private
    Station *start;
    Station *end;
    int driving;
    NSMutableArray* splinePoints;
}
@property (nonatomic, readonly) Station* start;
@property (nonatomic, readonly) Station* end;
@property (nonatomic, readonly) int driving;

-(id)initFromStation:(Station*)from toStation:(Station*)to withDriving:(int)dr;
-(void)appendPoint:(CGPoint)p;
-(void)calcSpline;
-(void)draw:(CGContextRef)context width:(CGFloat)lineWidth;
@end

@interface Line : NSObject {
@private
    NSString *name;
    NSMutableArray* stations;
    UIColor* _color;
    int index;
}
@property (nonatomic, retain) UIColor* color;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSMutableArray* stations;
@property (nonatomic, assign) int index;

-(id)initWithName:(NSString*)n stations:(NSString*)stations driving:(NSString*)driving coordinates:(NSString*)coordinates rects:(NSString*)rects;
-(void)draw:(CGContextRef)context width:(CGFloat)lineWidth;
-(void)drawNames:(CGContextRef)context;
-(void)drawSegment:(CGContextRef)context from:(NSString*)station1 to:(NSString*)station2 width:(float)lineWidth;
-(void)additionalPointsBetween:(NSString*)station1 and:(NSString*)station2 points:(NSArray*)points;
-(Station*)getStation:(NSString*)stName;
@end

@interface CityMap : NSObject {

	Graph *graph;
	NSInteger _w;
	NSInteger _h;
	NSInteger linesCount;
	NSInteger gpsCoordsCount;
    NSMutableArray *mapLines;
	NSMutableDictionary *gpsCoords;
    NSMutableArray* transfers;
	Utils *utils;

    CGFloat kLineWidth;
    CGFloat kFontSize;
	NSInteger currentLineNum;
    // текущий коэффициент масштабирования
	float koef;
    UIView *view;
    // края графического контента
    // от них будет считаться эффективный размер
    float minX, maxX, minY, maxY;
}

@property float koef;  
@property (nonatomic,retain) NSMutableDictionary *gpsCoords;
// размер карты в масштабе
@property (readonly) NSInteger w;
@property (readonly) NSInteger h;
// размер карты настоящий
@property (readonly) CGSize size;
@property NSInteger linesCount;
@property NSInteger gpsCoordsCount;
@property (nonatomic, retain) Graph *graph;
@property (nonatomic, retain) Utils *utils;

@property NSInteger currentLineNum;
@property (nonatomic, assign) UIView *view;
@property (nonatomic, assign) CGFloat LineWidth;
@property (nonatomic, assign) CGFloat FontSize;

- (UIColor *) colorForHex:(NSString *)hexColor;
//
-(void) loadMap:(NSString *)mapName;
-(void) initVars ;

//make graph stuff 
-(void) calcGraph;
-(void) processTransfersForGraph;

//graph func
-(NSArray*) calcPath :(NSString*) firstStation :(NSString*) secondStation :(NSInteger) firstStationLineNum :(NSInteger)secondStationLineNum ;

-(NSInteger) checkPoint:(CGPoint)point Station:(NSMutableString*)stationName;
	
// load stuff 
-(void) processGPS: (NSString*) station :(NSString*) lineCoord ;
-(void) processTransfers:(NSString*)transferInfo;
-(void) processAddNodes:(NSString*)addNodeInfo;
-(void) processLinesCoord:(NSArray*) coord;
-(void) processLinesCoordForText:(NSArray*) coord;

-(void) processLinesStations:(NSString*) stations :(NSUInteger) line;

// drawing
-(void) drawMap:(CGContextRef) context;
-(void) drawStations:(CGContextRef) context;

-(void) drawPathMap:(CGContextRef) context :(NSArray*) pathMap;

//CG Helpers	
-(void) drawFilledCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r;
-(void) drawLine :(CGContextRef) context :(CGFloat)x1 :(CGFloat)y1 :(CGFloat)x2 :(CGFloat)y2 :(int)lineWidth;

-(void) drawTransfers:(CGContextRef) context;

@end
