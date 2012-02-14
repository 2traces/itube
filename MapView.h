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
#import "VectorLayer.h"

extern int const imagesCount;

@class MainViewController;

// включает дополнительное промежуточное кеширование
//#define AGRESSIVE_CACHE
// количество слоёв кеширования
#define MAXCACHE 8

@interface MapView : UIView <UIScrollViewDelegate> {

	UILabel *mainLabel;
    UILabel *lineLabel;
    UIView *circleLabel;
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
    // background prerendered images (normal and gray)
    UIImageView *background1, *background2, *backgroundVector, *backgroundVector2;
    VectorLayer *vectorLayer;
    BOOL showVectorLayer;
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
@property (nonatomic, readonly) UIImageView* backgroundNormal;
@property (nonatomic, readonly) UIImageView* backgroundDisabled;
@property (nonatomic, readonly) UIImageView* backgroundVector;
@property (nonatomic, readonly) UIImageView* backgroundVectorDisabled;
@property (nonatomic, readonly) UIView* labelView;
@property (nonatomic, assign) BOOL showVectorLayer;

- (void)viewDidLoad;
// 

-(void) drawString: (NSString*) s withFont: (UIFont*) font inRect: (CGRect) contextRect ;
-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl ;
-(void) clearPath;
//
-(void) initData ;
-(void) loadVectorLayer:(NSString*)file;


//gps stuff
-(NSString*) calcNearStations:(CLLocation*) new_location;
-(void) checkGPSCoord:(CLLocation*) new_location;

@end
