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

@interface CityMap : NSObject {

	Graph *graph;
	NSInteger w;
	NSInteger h;
	NSInteger linesCount;
	NSInteger addNodesCount;
	NSInteger transfersCount;
	NSInteger gpsCoordsCount;
	NSMutableArray *linesCoord;
	NSMutableArray *linesCoordForText;
	NSMutableArray *stationsData;
	NSMutableArray *stationsName;	
	NSMutableArray *linesColors;
	NSMutableArray *stationsTime;
	NSMutableDictionary *addNodes;
	NSMutableDictionary *transfersTime;	
	NSMutableDictionary *contentAZForTableView;
	NSMutableDictionary *contentLinesForTableView;	
	NSMutableDictionary *gpsCoords;
	NSMutableDictionary *allStationsNames;
	NSMutableDictionary *linesIndex;
	NSMutableArray *linesNames;
	Utils *utils;

    CGFloat kLineWidth;
	NSInteger currentLineNum;
	NSMutableDictionary *drawedStations;
	int koef;
    Boolean labelPlaced;
    UIView *view;
}

@property (nonatomic,retain) NSMutableDictionary *linesIndex;
@property (nonatomic,retain) NSMutableArray *linesNames;
@property int koef;
@property (nonatomic,retain) NSMutableDictionary *allStationsNames;
@property (nonatomic,retain) NSMutableDictionary *contentAZForTableView;
@property (nonatomic,retain) NSMutableDictionary *contentLinesForTableView;
@property (nonatomic,retain) NSMutableDictionary *gpsCoords;
@property NSInteger w;
@property NSInteger h;
@property NSInteger linesCount;
@property NSInteger addNodesCount;
@property NSInteger transfersCount;
@property NSInteger gpsCoordsCount;
@property (nonatomic, retain) Graph *graph;
@property (nonatomic, retain) NSMutableArray *linesCoord;
@property (nonatomic, retain) NSMutableArray *linesCoordForText;
@property (nonatomic, retain) NSMutableArray *stationsData;
@property (nonatomic, retain) NSMutableArray *stationsName;
@property (nonatomic, retain) NSMutableArray *linesColors;
@property (nonatomic, retain) NSMutableArray *stationsTime;
@property (nonatomic, retain) NSMutableDictionary *addNodes;
@property (nonatomic, retain) NSMutableDictionary *transfersTime;	
@property (nonatomic, retain) Utils *utils;

@property NSInteger currentLineNum;
@property (nonatomic, retain) NSMutableDictionary *drawedStations;
@property (nonatomic, assign) UIView *view;
@property Boolean labelPlaced;


- (UIColor *) colorForHex:(NSString *)hexColor;
//
-(void) prepareStationForTable:(NSString*) stationName :(NSInteger)line;
	
-(void) initMap:(NSString*) mapName;
-(void) loadMap:(NSString *)mapName;
-(void) initVars ;

//make graph stuff 
-(void) calcGraph;
-(void) calcOneLineGraph: (NSDictionary*)lineStationsData :(NSArray*) lineStationsName :(NSArray*) lineStationsTime :(NSInteger)lineNum;
-(void) processTransfersForGraph;

//graph func
-(NSArray*) calcPath :(NSString*) firstStation :(NSString*) secondStation :(NSInteger) firstStationLineNum :(NSInteger)secondStationLineNum ;

	
// load stuff 
-(void) processGPS: (NSString*) station :(NSString*) lineCoord ;
-(void) processTransfers:(NSString*)transferInfo;
-(void) processAddNodes:(NSString*)addNodeInfo;
-(void) processLinesCoord:(NSArray*) coord;
-(void) processLinesCoordForText:(NSArray*) coord;
-(void) processLinesColors:(NSString*) colors;

-(void) processLinesStations:(NSString*) stations :(NSUInteger) line;
-(void) processLinesTime:(NSString*) lineTime :(NSUInteger) line;

// drawing
-(void) drawMap:(CGContextRef) context;
-(void) drawMetroLine:(CGContextRef) context :(NSArray*)lineCoords :(NSArray*)lineColor 
					 :(NSDictionary*)lineStationsData :(NSArray*) lineStationsName :(NSInteger)line;
-(void) drawMetroLineStationName:(CGContextRef) context :(NSArray*)lineColor 
								:(NSDictionary*)lineStationsData :(NSArray*) lineStationsName :(NSInteger)line;


-(void) drawStationName:(CGContextRef) context  :(NSDictionary*) text_coord  :(NSDictionary*) point_coord :(NSString*) stationName :(NSInteger) line;
-(void) drawStationName:(CGContextRef) context :(float) x :(float) y  :(float) ww :(float)hh :(NSString*) stationName :(UITextAlignment) mode :(NSInteger) line;
-(void) drawStationPoint: (CGContextRef) context coord: (NSDictionary*) coord lineColor: (NSArray *) lineColor ;
-(void) drawStationPoint: (CGContextRef) context y: (float) y x: (float) x lineColor: (NSArray *) lineColor ;
-(void) draw2Station:(CGContextRef)context :(NSArray*)lineColor :(NSDictionary*) coord1 :(NSDictionary*)coord2 :(NSArray*) splineCoords :(Boolean) reverse;

-(void) drawSpline :(CGContextRef)context :(CGFloat)x1 :(CGFloat)y1 :(CGFloat)x2 :(CGFloat)y2 :(NSArray*) coordSpline :(Boolean) reverse;

-(void) drawPathMap:(CGContextRef) context :(NSArray*) pathMap;

//CG Helpers	
-(void) drawCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r;
-(void) drawFilledCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r;
-(void) drawLine :(CGContextRef) context :(CGFloat)x1 :(CGFloat)y1 :(CGFloat)x2 :(CGFloat)y2 :(int)lineWidth;

-(void) drawTransfers2:(CGContextRef) context;
-(void) drawTransfers:(CGContextRef) context;

@end
