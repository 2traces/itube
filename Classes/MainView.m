//
//  MainView.m
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "MainView.h"
#import "MapView.h"
#import "MainViewController.h"
#import "ManagedObjects.h"
#import "TopTwoStationsView.h"

NSInteger const toolbarHeight=44;
NSInteger const toolbarWidth=320;

@implementation MainView
@synthesize stationNameView;
@synthesize mapView;
@synthesize containerView;
@synthesize toolbar;
@synthesize secondStation;
@synthesize firstStation;
@synthesize firstStationLineNum;
@synthesize secondStationLineNum;
@synthesize stationNameLabel;
//@synthesize CLController;
@synthesize xw,yw;
@synthesize vcontroller;


- (id)initWithFrame:(CGRect)frame {

	DLog(@"initWithFrame ");
    if (self = [super initWithFrame:frame]) {

        // Initialization code

    }
    return self;
}

-(void) initVar{
	xw = [NSNumber numberWithDouble:48.865499];
	yw = [NSNumber numberWithDouble:2.135647];
}

-(void)viewInit:(MainViewController*)vc
{
	[self initVar];
    self.vcontroller = vc;
	self.userInteractionEnabled = YES;
	DLog(@"ViewDidLoad main View");	

    CGRect scrollSize = CGRectMake(0,44,(320),(480-44));
	mapView = [[[MapView alloc] initWithFrame:scrollSize] autorelease];
    mapView.vcontroller = self.vcontroller;

	containerView = [[MyScrollView alloc] initWithFrame:scrollSize];
	[containerView setContentSize:mapView.size];
	containerView.scrollEnabled = YES;
	containerView.decelerationRate = UIScrollViewDecelerationRateFast ;
	containerView.showsVerticalScrollIndicator = NO;
	containerView.showsHorizontalScrollIndicator = NO;	
//	containerView.pagingEnabled = YES;
	containerView.clipsToBounds = NO;//YES;
	containerView.bounces = YES;
	containerView.maximumZoomScale = mapView.MaxScale;
	containerView.minimumZoomScale = mapView.MinScale;
	//containerView.directionalLockEnabled = YES;
//	containerView.userInteractionEnabled = YES;
//	mapView.exclusiveTouch = NO;

	containerView.delegate = mapView;
	[containerView addSubview: mapView];
	[self addSubview:containerView];
    [containerView setZoomScale:mapView.Scale animated:NO];
    	
	//TODO
	[containerView setContentOffset:CGPointMake(650, 650) animated:NO];
	
	stationNameView = [[UIView alloc] initWithFrame:self.frame];
	[stationNameView setOpaque:YES];

	stationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];

	stationNameLabel.text = @"some text";
	[stationNameView addSubview:stationNameLabel];
	
	//œ[self addSubview:stationNameView];
	stationNameView.userInteractionEnabled = YES;	
	/*
	CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
	[CLController.locMgr startUpdatingLocation];
	*/
	//UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
	//[containerView addGestureRecognizer:singleTap];    
	
}

- (void)locationUpdate:(CLLocation *)location {
	//locLabel.text = [location description];
	DLog(@" update %@ ",[location description]);
	[mapView calcNearStations:location];
}

- (void)locationError:(NSError *)error {
	//locLabel.text = [error description];
	DLog(@" error %@ ",[error description]);
}

- (void)dealloc {
	//[CLController release];
    [super dealloc];
	[stationNameView release];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
	DLog(@" touch 2");
	// If not dragging, send event to next responder
	/*
	if (!self.containerView.dragging) 
		[self.nextResponder touchesEnded: touches withEvent:event]; 
	else
		[super touchesEnded: touches withEvent: event];
	 */
	if (mapView.stationSelected)
	{
		[self processStationSelect];
	}
	/*else if ((firstStation.text!=nil) &&(secondStation.text!=nil)){
//		firstStation=nil;
//		secondStation=nil;
		[mapView removePath];
		firstStation.text=nil;
		secondStation.text=nil;
	}
	 */
}


-(void) processStationSelect {
	if (firstStation.text==nil)
	{
        [self didFirstStationSelected:mapView.selectedStationName line:mapView.selectedStationLine];
        [mapView clearPath];
	}
	else if ((firstStation.text!=nil && secondStation.text!=nil)) {
        [self didFirstStationSelected:mapView.selectedStationName line:mapView.selectedStationLine];
        [self didSecondStationSelected:nil line:0];
        [mapView clearPath];
	}
	else {
        [self didSecondStationSelected:mapView.selectedStationName line:mapView.selectedStationLine];
		[self findPathFrom:firstStation.text To:secondStation.text FirstLine:firstStationLineNum LastLine:secondStationLineNum];
	}

	mapView.stationSelected=false;
}

-(void) processStationSelect2 {

}

-(void) findPathFrom :(NSString*) fs To:(NSString*) ss FirstLine:(NSInteger) fsl LastLine:(NSInteger) ssl  {
	[mapView findPathFrom:fs To:ss FirstLine:fsl LastLine:ssl];
    [[MHelper sharedHelper] addHistory:[NSDate date] :fs To:ss FirstLine:fsl LastLine:ssl];
}


@end
