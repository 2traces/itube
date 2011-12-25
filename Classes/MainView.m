//
//  MainView.m
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "MainView.h"
#import "MapView.h"

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


- (id)initWithFrame:(CGRect)frame {

	DLog(@"initWithFrame ");
    if (self = [super initWithFrame:frame]) {

        // Initialization code

    }
    return self;
}

-(void) initVar{
//	selectedMap = [[SelectedPathMap alloc] initWithFrame:CGRectMake(0, toolbarHeight, 2000, 2000)];
	
	xw = [NSNumber numberWithDouble:48.865499];
	yw = [NSNumber numberWithDouble:2.135647];
}

-(void)viewInit
{
	[self initVar];
	self.userInteractionEnabled = YES;
	DLog(@"ViewDidLoad main View");	

	//[self addSubview:[[[MapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease]];
	//mapView = [[[MapView alloc] initWithFrame:CGRectMake(0,0,6*(320),4*(480-44))] autorelease];
	
	mapView = [[[MapView alloc] initWithFrame:CGRectMake(0,0,2600,2600-44)] autorelease];

	containerView = [[MyScrollView alloc] initWithFrame:CGRectMake(0,44,(320),(480-44))];
//	[containerView setContentSize:CGRectMake(10,10,1000,1000)];
	[containerView setContentSize:CGSizeMake(2600, 2600)];
	containerView.scrollEnabled = YES;
	containerView.decelerationRate = UIScrollViewDecelerationRateFast ;
	containerView.showsVerticalScrollIndicator = NO;
	containerView.showsHorizontalScrollIndicator = NO;	
//	containerView.pagingEnabled = YES;
	containerView.clipsToBounds = YES;
	containerView.bounces = YES;
	containerView.maximumZoomScale = 1.8;
	containerView.minimumZoomScale = 0.15;
	//containerView.directionalLockEnabled = YES;
//	containerView.userInteractionEnabled = YES;
//	mapView.exclusiveTouch = NO;

	containerView.delegate = self;
	[containerView addSubview: mapView];
	[self addSubview:containerView];
//	[self containerView];
	
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, toolbarWidth,toolbarHeight)];
	[self addSubview:toolbar];
	

	UIImage *imageOpenList = [UIImage imageNamed:@"openlist.png"];
	
	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[refreshButton setImage:imageOpenList forState:UIControlStateNormal];
	[refreshButton setImage:imageOpenList forState:UIControlStateHighlighted];
	refreshButton.imageEdgeInsets = UIEdgeInsetsMake(0, -imageOpenList.size.width/2, 0, 0);
	[refreshButton addTarget:self action:@selector(selectFromStation) forControlEvents:UIControlEventTouchUpInside];
	refreshButton.bounds = CGRectMake(0,0, imageOpenList.size.width, imageOpenList.size.height);


	firstStation = [[UITextField alloc] initWithFrame:CGRectMake(0,5, 157, 36)];
	firstStation.delegate = self;
	firstStation.borderStyle = UITextBorderStyleNone;
	firstStation.rightView = refreshButton;
	firstStation.background = [UIImage imageNamed:@"textfield.png"];
	firstStation.textAlignment = UITextAlignmentCenter;
	firstStation.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	firstStation.rightViewMode = UITextFieldViewModeAlways;
	[firstStation setReturnKeyType:UIReturnKeyDone];
	[firstStation setClearButtonMode:UITextFieldViewModeWhileEditing];
	
	
	[toolbar addSubview:firstStation];	

	UIButton *refreshButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
	[refreshButton2 setImage:imageOpenList forState:UIControlStateNormal];
	[refreshButton2 setImage:imageOpenList forState:UIControlStateHighlighted];
	refreshButton2.imageEdgeInsets = UIEdgeInsetsMake(0, -imageOpenList.size.width/2, 0, 0);
	[refreshButton2 addTarget:self action:@selector(selectToStation) forControlEvents:UIControlEventTouchUpInside];
	refreshButton2.bounds = CGRectMake(0,0, imageOpenList.size.width, imageOpenList.size.height);
	
	secondStation = [[UITextField alloc] initWithFrame:CGRectMake(160,5, 157, 36)];
	secondStation.delegate=self;
	secondStation.borderStyle = UITextBorderStyleNone;
	secondStation.rightView = refreshButton2;
	secondStation.background = [UIImage imageNamed:@"textfield.png"];
	secondStation.textAlignment = UITextAlignmentCenter;
	secondStation.rightViewMode = UITextFieldViewModeAlways;
	[secondStation setReturnKeyType:UIReturnKeyDone];
	[secondStation setClearButtonMode:UITextFieldViewModeWhileEditing];
	secondStation.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

	
    
	
	[toolbar addSubview:secondStation];	
	
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

-(void) selectFromStation {
	DLog(@"station 1");
}

-(void) selectToStation {
	DLog(@"station 2");
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *) scrollView{
	return mapView;
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(float)scale
{
	
	
	[mapView refreshLayersScale:scale];
	DLog(@" scale %f ",scale);
	/*
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithBool:YES] 
                     forKey:kCATransactionDisableActions];
    uglyBlurryTextLayer.contentsScale = scale;
    [CATransaction commit];
	*/
}

-(void) processStationSelect{
	if ((firstStation.text==nil))
	{
		firstStation.text = mapView.stationNameTemp; 
		firstStationLineNum = mapView.stationLineTemp;
	}
	else if ((firstStation.text!=nil && secondStation.text!=nil)) {
		firstStation.text = mapView.stationNameTemp; 
		secondStation.text = nil; 
	}
	else {
		secondStation.text = mapView.stationNameTemp; 
		secondStationLineNum = mapView.stationLineTemp;
		mapView.drawPath = true;
		//[mapView setNeedsDisplay];
		//[mapView drawSelectedMap];
		[self findPath:firstStation.text :secondStation.text :firstStationLineNum :secondStationLineNum];
	}
	mapView.stationSelected=false;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
	DLog(@"Here5");
}

-(void) findPath :(NSString*) fs :(NSString*) ss :(NSInteger) fsl :(NSInteger) ssl  {
	[mapView finPath:fs :ss :fsl :ssl];
}

@end
