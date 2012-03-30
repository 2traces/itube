//
//  PathDrawView.h
//  tube
//
//  Created by sergey on 31.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PathDrawProtocol;
@class Station;

@interface PathDrawView : UIView {
    NSMutableDictionary *pathInfo; 
    NSInteger travelTime;
    NSMutableArray *points;
    
    id <PathDrawProtocol> delegate;
    NSArray *zpath;
    NSMutableArray *apath;
}

@property (nonatomic, retain) NSMutableArray *apath;
@property (nonatomic, retain) NSArray *zpath;
@property (nonatomic, retain) NSMutableDictionary *pathInfo;
@property (nonatomic, assign) NSInteger travelTime;
@property (nonatomic, assign) id <PathDrawProtocol> delegate;

-(void) drawCircleInRect:(CGRect)circleRect color:(UIColor*)color context:(CGContextRef)c;
- (id)initWithFrame:(CGRect)frame path:(NSMutableArray*)thisPath;

@end

@protocol PathDrawProtocol

-(NSInteger)dsGetTravelTime;
-(NSArray*)dsGetLinesColorArray;
-(NSArray*)dsGetLinesTimeArray;
-(NSArray*)dsGetStationsArray;
-(NSMutableArray*)dsGetExitForStations;
-(BOOL)dsIsStartingTransfer;
-(BOOL)dsIsEndingTransfer;
-(UIColor*)dsFirstStationSaturatedColor;
-(UIColor*)dsLastStationSaturatedColor;

@end