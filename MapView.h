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
#import "ActiveView.h"

extern int const imagesCount;

@class MainViewController;

// включает дополнительное промежуточное кеширование
//#define AGRESSIVE_CACHE
// количество слоёв кеширования
#define MAXCACHE 8

@interface MapView : UIView <UIScrollViewDelegate, CLLocationManagerDelegate> {

    CGRect visualFrame;
	UILabel *mainLabel;
    UILabel *lineLabel;
    UIView *circleLabel;
    UIImageView *labelBg;
	CityMap *cityMap;
	Boolean stationSelected;
	
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
    UIView *midground1, *midground2;
    // prerendered image
    UIImageView *previewImage;
    VectorLayer *vectorLayer;
    ActiveView *activeLayer;
    NSDictionary *foundPaths;
    CLLocationManager *locationManager;
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
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) CGFloat Scale;
@property (nonatomic, readonly) CGFloat MaxScale;
@property (nonatomic, readonly) CGFloat MinScale;
@property (nonatomic, assign) MainViewController *vcontroller;
@property (nonatomic, readonly) UIView* midground1;
@property (nonatomic, readonly) UIView* midground2;
@property (nonatomic, readonly) UIImageView* previewImage;
@property (nonatomic, readonly) UIView* labelView;
@property (nonatomic, readonly) ActiveView *activeLayer;
@property (nonatomic, readonly) NSDictionary *foundPaths;

- (void)viewDidLoad;
// 

-(void) drawString: (NSString*) s withFont: (UIFont*) font inRect: (CGRect) contextRect ;
// find several paths and select first one
-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl ;
// forget all paths
-(void) clearPath;
// number of paths which have been found
-(int)  pathsCount;
// select one of the paths (num must be less then pathsCount)
-(void) selectPath:(int)num;
//
-(void) initData ;

@end
