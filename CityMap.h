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
	int koef;
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


- (UIColor *) colorForHex:(NSString *)hexColor;
//
-(void) prepareStationForTable:(NSString*) stationName :(NSInteger)line;
	
-(void) initMap:(NSString*) mapName;
-(void) loadMap:(NSString*) mapName;
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

@end
