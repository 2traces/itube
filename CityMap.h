//
//  CityMap.h
//  tube
//
//  Created by Alex 1 on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Graph.h"
//#import <CoreLocation/CoreLocation.h>

NSMutableArray * Split(NSString* s);
//CG Helpers	
void drawFilledCircle(CGContextRef context, CGFloat x, CGFloat y, CGFloat r);
void drawLine(CGContextRef context, CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2, int lineWidth);

// visual type of stations & transfers
typedef enum {LIKE_PARIS, LIKE_LONDON, LIKE_MOSCOW} StationKind;

@class Station;
@class Line;

@interface Transfer : NSObject {
@private
    NSMutableSet* stations;
    CGFloat time;
    CGRect boundingBox;
    CGLayerRef transferLayer;
    BOOL active;
}
@property (nonatomic, readonly) NSMutableSet* stations;
@property (nonatomic, assign) CGFloat time;
@property (nonatomic, readonly) CGRect boundingBox;
@property (nonatomic, assign) BOOL active;

-(void) addStation:(Station*)station;
-(void) draw:(CGContextRef)context;
-(void) predraw:(CGContextRef)context;
@end

@interface Station : NSObject {
@private
    CGPoint pos;
    CGRect boundingBox;
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
    BOOL drawName;
    BOOL active;
    BOOL acceptBackLink;
    CGLayerRef predrawedName;
    int links;
}

@property (nonatomic, readonly) NSMutableArray* relation;
@property (nonatomic, readonly) NSMutableArray* relationDriving;
@property (nonatomic, readonly) NSMutableArray* segment;
@property (nonatomic, readonly) NSMutableArray* sibling;
@property (nonatomic, readonly) CGPoint pos;
@property (nonatomic, readonly) CGRect boundingBox;
@property (nonatomic, readonly) CGRect textRect;
@property (nonatomic, readonly) int index;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, assign) int driving;
@property (nonatomic, assign) Transfer* transfer;
@property (nonatomic, assign) Line* line;
@property (nonatomic, assign) BOOL drawName;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, readonly) BOOL acceptBackLink;
// number of links with other stations
@property (nonatomic, assign) int links;
// is a station the last one (or the first one) in the line
@property (nonatomic, readonly) BOOL terminal;

-(id) initWithName:(NSString*)sname pos:(CGPoint)p index:(int)i rect:(CGRect)r andDriving:(NSString*)dr;
-(void) addSibling:(Station*)st;
-(void) drawName:(CGContextRef)context;
-(void) drawStation:(CGContextRef)context;
-(void) draw:(CGContextRef)context;
-(void) draw:(CGContextRef)context inRect:(CGRect)rect;
-(void) makeSegments;
-(void) predraw:(CGContextRef)context;
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
    CGRect boundingBox;
    BOOL active;
}
@property (nonatomic, readonly) Station* start;
@property (nonatomic, readonly) Station* end;
@property (nonatomic, readonly) int driving;
@property (nonatomic, readonly) CGRect boundingBox;
@property (nonatomic, assign) BOOL active;

-(id)initFromStation:(Station*)from toStation:(Station*)to withDriving:(int)dr;
-(void)appendPoint:(CGPoint)p;
-(void)calcSpline;
-(void)draw:(CGContextRef)context;
@end

@interface Line : NSObject {
@private
    NSString *name;
    NSMutableArray* stations;
    UIColor* _color;
    int index;
    CGLayerRef stationLayer;
    CGRect boundingBox;
}
@property (nonatomic, retain) UIColor* color;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSMutableArray* stations;
@property (nonatomic, assign) int index;
@property (nonatomic, readonly) CGRect boundingBox;

-(id)initWithName:(NSString*)n stations:(NSString*)stations driving:(NSString*)driving coordinates:(NSString*)coordinates rects:(NSString*)rects;
-(void)draw:(CGContextRef)context;
-(void)drawNames:(CGContextRef)context;
-(void)draw:(CGContextRef)context inRect:(CGRect)rect;
-(void)drawNames:(CGContextRef)context inRect:(CGRect)rect;
-(void)additionalPointsBetween:(NSString*)station1 and:(NSString*)station2 points:(NSArray*)points;
-(Station*)getStation:(NSString*)stName;
-(Segment*)activateSegmentFrom:(NSString*)station1 to:(NSString*)station2;
-(void)setEnabled:(BOOL)en;
-(void)predraw:(CGContextRef)context;
@end

@interface CityMap : NSObject {

	Graph *graph;
	NSInteger _w;
	NSInteger _h;
    NSMutableArray *mapLines;
	NSMutableDictionary *gpsCoords;
    NSMutableArray* transfers;
    CGFloat currentScale;
    CGRect activeExtent;
    NSMutableArray *activePath;
}

@property (nonatomic,retain) NSMutableDictionary *gpsCoords;
// размер карты 
@property (readonly) NSInteger w;
@property (readonly) NSInteger h;
@property (readonly) CGSize size;
@property (nonatomic, retain) Graph *graph;
@property (nonatomic, assign) CGFloat currentScale;
@property (nonatomic, readonly) CGRect activeExtent;
@property (nonatomic, assign) CGFloat predrawScale;
@property (nonatomic, readonly) NSArray* activePath;
@property (nonatomic, assign) StationKind stationKind;
@property (nonatomic, assign) StationKind transferKind;

- (UIColor *) colorForHex:(NSString *)hexColor;
//
-(void) loadMap:(NSString *)mapName;
-(void) initVars ;
// предварительная отрисовка трансферов и названий станций
-(void) predraw;

//make graph stuff 
-(void) calcGraph;
-(void) processTransfersForGraph;

//graph func
-(NSArray*) calcPath :(NSString*) firstStation :(NSString*) secondStation :(NSInteger) firstStationLineNum :(NSInteger)secondStationLineNum ;

-(NSInteger) checkPoint:(CGPoint)point Station:(NSMutableString*)stationName;
	
// load stuff 
-(void) processGPS: (NSString*) station :(NSString*) lineCoord;
-(void) processTransfers:(NSString*)transferInfo;
-(void) processAddNodes:(NSString*)addNodeInfo;
-(void) processLinesStations:(NSString*) stations :(NSUInteger) line;

// drawing
-(void) drawMap:(CGContextRef) context;
-(void) drawMap:(CGContextRef) context inRect:(CGRect)rect;
-(void) drawStations:(CGContextRef) context;
-(void) drawStations:(CGContextRef) context inRect:(CGRect)rect;
-(void) drawTransfers:(CGContextRef) context;
-(void) drawTransfers:(CGContextRef) context inRect:(CGRect)rect;

-(void) activatePath:(NSArray*)pathMap;
-(void) resetPath;
@end
