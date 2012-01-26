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

@class MainViewController;

#define MAXCACHE 20

@interface MapView : UIView <UIScrollViewDelegate> {

	UILabel *mainLabel;
    UIImageView *labelBg;
	CityMap *cityMap;
	Boolean stationSelected;
	
	NSArray *stationPath;
	
	NSMutableString *selectedStationName;
	NSInteger selectedStationLine;
		
	CALayer *selectedStationLayer;
	NSString *nearestStationName;
	//
	UIImage *nearestStationImage;
    CGFloat Scale, MaxScale, MinScale;
    UIScrollView *scrollView;
    CGLayerRef cacheLayer[MAXCACHE];
    int currentCacheLayer;
    UIImage *background;
}

@property (assign) NSString *nearestStationName;

@property (nonatomic, retain) CALayer *selectedStationLayer;

//
@property (nonatomic, retain) UIImage *nearestStationImage;

@property Boolean stationSelected;
@property NSInteger selectedStationLine;
@property (nonatomic, retain) CityMap *cityMap;
@property (nonatomic, retain) UILabel *mainLabel;
@property (nonatomic, readonly) NSMutableString *selectedStationName;
@property (nonatomic, retain) NSArray *stationPath;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) CGFloat Scale;
@property (nonatomic, readonly) CGFloat MaxScale;
@property (nonatomic, readonly) CGFloat MinScale;
@property (nonatomic, assign) MainViewController *vcontroller;
@property (nonatomic, readonly) UIImage* background;

- (void)viewDidLoad;
// 

-(void) drawString: (NSString*) s withFont: (UIFont*) font inRect: (CGRect) contextRect ;
-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl ;
-(void) clearPath;
//
-(void) initData ;

//gps stuff
-(NSString*) calcNearStations:(CLLocation*) new_location;
-(void) checkGPSCoord:(CLLocation*) new_location;

@end
