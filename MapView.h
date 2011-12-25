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

@interface MapView : UIView {

	UILabel *mainLabel;
	CityMap *cityMap;
	NSMutableDictionary *drawedStations;
	Boolean stationSelected;
	Boolean drawPath;
	
	NSArray *stationPath;
	
	NSString *stationNameTemp;
	NSInteger stationLineTemp;
	
	NSString *firstStation;
	NSString *secondStation;	
	NSInteger firstStationNum;
	NSInteger secondStationNum;	
	
	Boolean labelPlaced;
	SelectedPathMap *selectedMap;
	UIImage *drawedMap,*drawedMap2,*drawedMap3,*drawedMap4;
	UIImage *drawedPath;
	NSMutableArray *images;
	
	CATiledLayer *mapLayer;
	CALayer *selectedPathLayer;
	CALayer *selectedStationLayer;
	NSString *nearestStationName;
	//
	UIImage *nearestStationImage;
}

@property (nonatomic, retain) NSMutableArray *images;

@property (assign) NSString *nearestStationName;

@property (nonatomic, retain) CALayer *selectedStationLayer;
@property (nonatomic, retain) CALayer *selectedPathLayer;
@property (nonatomic, retain) CATiledLayer *mapLayer;

@property (nonatomic, retain) UIImage *drawedMap,*drawedMap2,*drawedMap3,*drawedMap4;
@property (nonatomic, retain) UIImage* drawedPath;

//
@property (nonatomic, retain) UIImage *nearestStationImage;

@property (nonatomic, retain) SelectedPathMap *selectedMap;
@property Boolean stationSelected;
@property Boolean labelPlaced;
@property Boolean drawPath;
@property NSInteger stationLineTemp;
@property (nonatomic, retain) NSMutableDictionary *drawedStations;
@property (nonatomic, retain) CityMap *cityMap;
@property (nonatomic, retain) UILabel *mainLabel;
@property (nonatomic, retain) NSString *stationNameTemp;
@property (nonatomic, retain) NSArray *stationPath;



- (void) makeImages;
- (void)viewDidLoad;
+ (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode imageToScale:(UIImage*)imageToScale bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality ;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
// 

//
- (void)refreshLayersScale:(float)scale;

//

//
-(void) processTransfers2:(CGContextRef) context;
-(void) processTransfers:(CGContextRef) context;
-(UIImage *) drawToImage :(CityMap*) map;
- (UIImage *) drawPathToImage :(NSArray*) pathMap;


-(void) drawPathMap:(CGContextRef) context :(NSArray*) pathMap;

//
-(void) drawString: (NSString*) s withFont: (UIFont*) font inRect: (CGRect) contextRect ;
-(void) finPath :(NSString*) fSt :(NSString*) sSt :(NSInteger) fStl :(NSInteger)sStl ;
-(void) drawSelectedMap;
-(void) removePath;

//
-(void) initData ;

//debug
-(void) saveImage :(UIImage*)mm;
	

//CG Helpers	
-(void) drawCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r;
-(void) drawFilledCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r;
-(void) drawLine :(CGContextRef) context :(CGFloat)x1 :(CGFloat)y1 :(CGFloat)x2 :(CGFloat)y2 :(int)lineWidth;
//gps stuff
-(NSString*) calcNearStations:(CLLocation*) new_location;
-(void) checkGPSCoord:(CLLocation*) new_location;

@end
