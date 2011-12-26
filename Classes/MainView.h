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

extern NSInteger const toolbarHeight;
extern NSInteger const toolbarWidth;



//@interface MainView : UIView <UIScrollViewDelegate, UITextFieldDelegate , CoreLocationControllerDelegate>{

@interface MainView : UIView <UITextFieldDelegate> {
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

- (void) processStationSelect;
- (void) initVar;
- (UIView *) viewForZoomingInScrollView:(UIScrollView *) scrollView;
- (void) viewInit;
-(void) findPathFrom :(NSString*) fs To:(NSString*) ss FirstLine:(NSInteger) fsl LastLine:(NSInteger) ssl ;
@end
