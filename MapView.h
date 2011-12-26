//
//  MapView.h
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CityMap.h"
#import "SelectedPathMap.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

extern int const imagesCount;

@interface MapView : UIView <UIScrollViewDelegate> {

	UILabel *mainLabel;
	CityMap *cityMap;
	Boolean stationSelected;
	Boolean drawPath;
	
	NSArray *stationPath;
	
	NSString *selectedStationName;
	NSInteger selectedStationLine;
		
    CGLayerRef mapLayer;
    CGLayerRef pathLayer;
	
	CALayer *selectedStationLayer;
	NSString *nearestStationName;
	//
	UIImage *nearestStationImage;
    float Scale;
    NSMutableArray *pathArray;
}

@property (assign) NSString *nearestStationName;

@property (nonatomic, retain) CALayer *selectedStationLayer;

//
@property (nonatomic, retain) UIImage *nearestStationImage;

@property Boolean stationSelected;
@property Boolean drawPath;
@property NSInteger selectedStationLine;
@property (nonatomic, retain) CityMap *cityMap;
@property (nonatomic, retain) UILabel *mainLabel;
@property (nonatomic, retain) NSString *selectedStationName;
@property (nonatomic, retain) NSArray *stationPath;
@property (nonatomic, readonly) CGSize size;


- (void)viewDidLoad;
// 

-(void) updateLayers;
-(void) drawMapLayer :(CityMap*) map;
- (void) drawPathLayer :(NSArray*) pathMap;

//
-(void) drawString: (NSString*) s withFont: (UIFont*) font inRect: (CGRect) contextRect ;
-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl ;

//
-(void) initData ;

//gps stuff
-(NSString*) calcNearStations:(CLLocation*) new_location;
-(void) checkGPSCoord:(CLLocation*) new_location;

@end
