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

@interface Station : NSObject {
@private
    CGPoint pos;
    CGRect textRect;
    int index;
    NSString *name;
    // сегменты пути
    NSMutableArray *segment;
    // соседние станции
    NSMutableArray *sibling;
    // имена соседних станций
    NSMutableArray *relation;
}

@property (nonatomic, readonly) NSMutableArray* relation;
@property (nonatomic, readonly) NSMutableArray* segment;
@property (nonatomic, readonly) NSMutableArray* sibling;
@property (nonatomic, readonly) CGPoint pos;
@property (nonatomic, readonly) int index;
@property (nonatomic, readonly) NSString* name;

-(id) initWithName:(NSString*)sname pos:(CGPoint)p index:(int)i andRect:(CGRect)r;
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
    NSMutableArray* splinePoints;
}
@property (nonatomic, readonly) Station* start;
@property (nonatomic, readonly) Station* end;

-(id)initFromStation:(Station*)from toStation:(Station*)to;
-(void)appendPoint:(CGPoint)p;
-(void)calcSpline;
-(void)draw:(CGContextRef)context width:(CGFloat)lineWidth;
-(void)draw:(CGContextRef)context fromPoint:(CGPoint)p toTangentPoint:(TangentPoint*)tp;
-(void)draw:(CGContextRef)context fromTangentPoint:(TangentPoint*)tp toPoint:(CGPoint)p;
-(void)draw:(CGContextRef)context fromTangentPoint:(TangentPoint*)tp1 toTangentPoint:(TangentPoint*)tp2;
@end

@interface Line : NSObject {
@private
    NSString *name;
    NSMutableArray* stations;
    UIColor* _color;
}
@property (nonatomic, retain) UIColor* color;
@property (nonatomic, readonly) NSString* name;

-(id)initWithName:(NSString*)n stations:(NSString*)stations driving:(NSString*)driving coordinates:(NSString*)coordinates rects:(NSString*)rects;
-(void)draw:(CGContextRef)context width:(CGFloat)lineWidth;
-(void)drawNames:(CGContextRef)context;
-(void)additionalPointsBetween:(NSString*)station1 and:(NSString*)station2 points:(NSArray*)points;
@end

@interface CityMap : NSObject {

	Graph *graph;
	NSInteger _w;
	NSInteger _h;
	NSInteger linesCount;
	NSInteger addNodesCount;
	NSInteger gpsCoordsCount;
	NSMutableArray *linesCoord;
	NSMutableArray *linesCoordForText;
	NSMutableArray *stationsData;
    NSMutableArray *mapLines;
	NSMutableDictionary *addNodes;
	NSMutableDictionary *gpsCoords;
	NSMutableDictionary *allStationsNames;
	Utils *utils;

    CGFloat kLineWidth;
    CGFloat kFontSize;
	NSInteger currentLineNum;
    // метка отрисовки для каждой станции
	NSMutableDictionary *drawedStations;
    // текущий коэффициент масштабирования
	float koef;
    UIView *view;
    // края графического контента
    // от них будет считаться эффективный размер
    float minX, maxX, minY, maxY;
}

@property float koef;  
@property (nonatomic,retain) NSMutableDictionary *allStationsNames;
@property (nonatomic,retain) NSMutableDictionary *gpsCoords;
// размер карты в масштабе
@property (readonly) NSInteger w;
@property (readonly) NSInteger h;
// размер карты настоящий
@property (readonly) CGSize size;
@property NSInteger linesCount;
@property NSInteger addNodesCount;
@property NSInteger gpsCoordsCount;
@property (nonatomic, retain) Graph *graph;
@property (nonatomic, retain) NSMutableArray *linesCoord;
@property (nonatomic, retain) NSMutableArray *linesCoordForText;
@property (nonatomic, retain) NSMutableArray *stationsData;
@property (nonatomic, retain) NSMutableDictionary *addNodes;
@property (nonatomic, retain) Utils *utils;

@property NSInteger currentLineNum;
@property (nonatomic, retain) NSMutableDictionary *drawedStations;
@property (nonatomic, assign) UIView *view;
@property (nonatomic, assign) CGFloat LineWidth;
@property (nonatomic, assign) CGFloat FontSize;

- (UIColor *) colorForHex:(NSString *)hexColor;
//
-(void) loadMap:(NSString *)mapName;
-(void) initVars ;

//make graph stuff 
-(void) calcGraph;
-(void) calcOneLineGraph: (NSDictionary*)lineStationsData :(NSInteger)lineNum;
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
-(void) processLinesTime:(NSString*) lineTime :(NSUInteger) line;

// drawing
-(void) drawMap:(CGContextRef) context;
-(void) drawStations:(CGContextRef) context;

//-(void) drawMetroLine:(CGContextRef) context :(NSArray*)lineCoords :(UIColor*)lineColor 
//					 :(NSDictionary*)lineStationsData :(NSInteger)line;
//-(void) drawMetroLineStationName:(CGContextRef) context :(UIColor*)lineColor 
//								:(NSDictionary*)lineStationsData :(NSInteger)line;


-(void) drawStationName:(CGContextRef) context  :(NSDictionary*) text_coord  :(NSDictionary*) point_coord :(NSString*) stationName :(NSInteger) line;
-(void) drawStationName:(CGContextRef) context :(float) x :(float) y  :(float) ww :(float)hh :(NSString*) stationName :(UITextAlignment) mode :(NSInteger) line;

-(void) drawStationPoint: (CGContextRef) context coord: (NSDictionary*) coord lineColor: (UIColor *) lineColor ;
-(void) drawStationPoint: (CGContextRef) context y: (float) y x: (float) x lineColor: (UIColor *) lineColor ;
-(void) draw2Station:(CGContextRef)context :(UIColor*)lineColor :(NSDictionary*) coord1 :(NSDictionary*)coord2 :(NSArray*) splineCoords :(Boolean) reverse;

-(void) drawSpline :(CGContextRef)context :(CGFloat)x1 :(CGFloat)y1 :(CGFloat)x2 :(CGFloat)y2 :(NSArray*) coordSpline :(Boolean) reverse;

-(void) drawPathMap:(CGContextRef) context :(NSArray*) pathMap;

//CG Helpers	
-(void) drawCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r;
-(void) drawFilledCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r;
-(void) drawLine :(CGContextRef) context :(CGFloat)x1 :(CGFloat)y1 :(CGFloat)x2 :(CGFloat)y2 :(int)lineWidth;

-(void) drawTransfers:(CGContextRef) context;

@end
