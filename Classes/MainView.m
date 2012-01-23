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

-(void)drawInitialToolbar
{
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
    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
    
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
    secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
    
	[toolbar addSubview:secondStation];
    
    [toolbar release];
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
    
    [self drawInitialToolbar];
	
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
	
    buttonsView = [[UIView alloc] initWithFrame:CGRectMake(45, 180, 230, 80)];
    UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sourceButton setImage:[UIImage imageNamed:@"src_button_normal"] forState:UIControlStateNormal];
    [sourceButton setImage:[UIImage imageNamed:@"src_button_pressed"] forState:UIControlStateHighlighted];
    [sourceButton addTarget:self action:@selector(selectFromStationByButton) forControlEvents:UIControlEventTouchUpInside];
    [sourceButton setFrame:CGRectMake(0,0, 76, 76)];
    [buttonsView addSubview:sourceButton];
    UIButton *destinationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [destinationButton setImage:[UIImage imageNamed:@"dst_button_normal"] forState:UIControlStateNormal];
    [destinationButton setImage:[UIImage imageNamed:@"dst_button_pressed"] forState:UIControlStateHighlighted];
    [destinationButton addTarget:self action:@selector(selectToStationByButton) forControlEvents:UIControlEventTouchUpInside];
    [destinationButton setFrame:CGRectMake(154, 0, 76, 76)];
    [buttonsView addSubview:destinationButton];
    [self addSubview:buttonsView];
    buttonsView.hidden = YES;
}

-(void) selectFromStation {
    [self.vcontroller pressedSelectFromStation];
	DLog(@"station 1");
}

-(void) selectToStation {
    [self.vcontroller pressedSelectToStation];
	DLog(@"station 2");
}

-(void) selectFromStationByButton {
    [self didFirstStationSelected:mapView.selectedStationName line:mapView.selectedStationLine];

	if ((firstStation.text!=nil && secondStation.text!=nil)) {
        if([firstStation.text isEqualToString:secondStation.text]) {
            // одна и та же станция начало и конец пути
            [self didFirstStationSelected:nil line:0];
            [self didSecondStationSelected:nil line:0];
        } else {
            [self findPathFrom:firstStation.text To:secondStation.text FirstLine:firstStationLineNum LastLine:secondStationLineNum];
        }
	}
	mapView.stationSelected=false;
    [UIView animateWithDuration:0.25f animations:^{ buttonsView.alpha = 0.f; } completion:^(BOOL finished){ if(finished) {buttonsView.hidden = YES; } }];
}

-(void) selectToStationByButton {
    [self didSecondStationSelected:mapView.selectedStationName line:mapView.selectedStationLine];
    
	if ((firstStation.text!=nil && secondStation.text!=nil)) {
        if([firstStation.text isEqualToString:secondStation.text]) {
            // одна и та же станция начало и конец пути
            [self didFirstStationSelected:nil line:0];
            [self didSecondStationSelected:nil line:0];
        } else {
            [self findPathFrom:firstStation.text To:secondStation.text FirstLine:firstStationLineNum LastLine:secondStationLineNum];
        }
	}
	mapView.stationSelected=false;
    [UIView animateWithDuration:0.25f animations:^{ buttonsView.alpha = 0.f; } completion:^(BOOL finished){ if(finished) {buttonsView.hidden = YES; } }];
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
    [buttonsView release];
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
		//[self processStationSelect];
        buttonsView.hidden = NO;
        buttonsView.alpha = 0.f;
        [UIView animateWithDuration:0.25f animations:^{ buttonsView.alpha = 1.f; }];
        [self bringSubviewToFront:buttonsView];
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

-(void)didFirstStationSelected:(NSString*)stationName line:(int)lineNum
{
    firstStation.text = stationName; 
    firstStationLineNum = lineNum;
}

-(void)didSecondStationSelected:(NSString*)stationName line:(int)lineNum
{
    secondStation.text = stationName; 
    secondStationLineNum = lineNum;
}

-(void) processStationSelect {
	if (firstStation.text==nil)
	{
        [self didFirstStationSelected:mapView.selectedStationName line:mapView.selectedStationLine];
	}
	else if ((firstStation.text!=nil && secondStation.text!=nil)) {
        [self didFirstStationSelected:mapView.selectedStationName line:mapView.selectedStationLine];
        [self didSecondStationSelected:nil line:0];
        [mapView clearPath];
	}
	else {
        if([firstStation.text isEqualToString:mapView.selectedStationName]) {
            // одна и та же станция начало и конец пути
            [self didFirstStationSelected:nil line:0];
            [self didSecondStationSelected:nil line:0];
        } else {
            [self didSecondStationSelected:mapView.selectedStationName line:mapView.selectedStationLine];
            [self findPathFrom:firstStation.text To:secondStation.text FirstLine:firstStationLineNum LastLine:secondStationLineNum];
        }
	}

	mapView.stationSelected=false;
}

-(void) processStationSelect2 {
    if ((firstStation.text==nil || secondStation.text==nil)) {
        [mapView clearPath];
	} else {
        if([firstStation.text isEqualToString:secondStation.text]) {
            // одна и та же станция начало и конец пути
            [self didFirstStationSelected:nil line:0];
            [self didSecondStationSelected:nil line:0];
        } else {
            [self findPathFrom:firstStation.text To:secondStation.text FirstLine:firstStationLineNum LastLine:secondStationLineNum];
        }
	}

	mapView.stationSelected=false;
}

-(void) findPathFrom :(NSString*) fs To:(NSString*) ss FirstLine:(NSInteger) fsl LastLine:(NSInteger) ssl  {
	[mapView findPathFrom:fs To:ss FirstLine:fsl LastLine:ssl];
    [[MHelper sharedHelper] addHistory:[NSDate date] :fs To:ss FirstLine:fsl LastLine:ssl];
}

// UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
	DLog(@"Here5");
}

@end
