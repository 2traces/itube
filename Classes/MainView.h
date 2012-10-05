//
//  MainView.h
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import "MyScrollView.h"
#import "SelectedPathMap.h"
#import "CoreLocationController.h"
#import "MBProgressHUD.h"

extern NSInteger const toolbarHeight;
extern NSInteger const toolbarWidth;

@class MainViewController;

MBProgressHUD *commonActivityIndicator;

//@interface MainView : UIView <UIScrollViewDelegate, UITextFieldDelegate , CoreLocationControllerDelegate>{

@interface MainView : UIView  {
//	CoreLocationController *CLController;
	MapView *mapView;
	MyScrollView *containerView;
	UIToolbar *toolbar; 
	UITextField *firstStation;
	UITextField *secondStation;	
	NSInteger firstStationLineNum;
	NSInteger secondStationLineNum;
	NSNumber *xw;
	NSNumber *yh;
	UIView *stationNameView;
	UILabel *stationNameLabel;
    UIButton *sourceButton, *destinationButton;
    UIImageView *stationMark;
    BOOL buttonsVisible;
}

@property (nonatomic, retain) UIView *stationNameView;
@property (nonatomic, retain) UILabel *stationNameLabel;
//@property (nonatomic, retain) CoreLocationController *CLController;
@property NSInteger firstStationLineNum;
@property NSInteger secondStationLineNum;
@property (assign) NSNumber *xw,*yw;
@property (nonatomic, retain) MapView *mapView;

@property (nonatomic, retain) UIScrollView * containerView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UITextField *firstStation;
@property (nonatomic, retain) UITextField *secondStation;

@property(nonatomic,assign) MainViewController *vcontroller;

- (void) initVar;
- (void) viewInit:(MainViewController*)vcontroller;
-(void) findPathFrom :(NSString*) fs To:(NSString*) ss FirstLine:(NSInteger) fsl LastLine:(NSInteger) ssl ;
-(void)setCityMap:(CityMap*)cm;
-(void)changeShadowFrameToRect:(CGRect)rect;
-(CGRect)getMapVisibleRect;

@end
