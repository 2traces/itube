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
#import "tubeAppDelegate.h"
#import "ManagedObjects.h"
#import "SettingsViewController.h"

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
    buttonsVisible = NO;
	DLog(@"ViewDidLoad main View");	

    CGRect scrollSize = CGRectMake(0,44,(320),(480-64));
	mapView = [[[MapView alloc] initWithFrame:scrollSize] autorelease];
    [mapView loadVectorLayer:@"2012"];
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
    [containerView setBouncesZoom:NO];
	containerView.maximumZoomScale = mapView.MaxScale;
	containerView.minimumZoomScale = mapView.MinScale * 0.5f;
	//containerView.directionalLockEnabled = YES;
//	containerView.userInteractionEnabled = YES;
//	mapView.exclusiveTouch = NO;

    [containerView addSubview:mapView.backgroundVector];
    //[containerView addSubview:mapView.backgroundVectorDisabled];
    //[containerView addSubview:mapView.backgroundNormal];
    //[containerView addSubview:mapView.backgroundDisabled];
    containerView.scrolledView = mapView;
	containerView.delegate = mapView;
	[containerView addSubview: mapView];
    [containerView setZoomScale:mapView.Scale animated:NO];
	[self addSubview:containerView];
    [containerView addSubview:mapView.activeLayer];
    
	//TODO
	[containerView setContentOffset:CGPointMake(650, 650) animated:NO];
	
	stationNameView = [[UIView alloc] initWithFrame:self.frame];
	[stationNameView setOpaque:YES];

	stationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];

	stationNameLabel.text = @"some text";
	[stationNameView addSubview:stationNameLabel];
    
    stationNameLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
	
	//œ[self addSubview:stationNameView];
	stationNameView.userInteractionEnabled = YES;	
	/*
	CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
	[CLController.locMgr startUpdatingLocation];
	*/
	//UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
	//[containerView addGestureRecognizer:singleTap];    

    stationMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"station_mark"]];
    stationMark.hidden = YES;
    [self addSubview:stationMark];
    [self addSubview:mapView.labelView];
	
    sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sourceButton setImage:[UIImage imageNamed:@"src_button_normal"] forState:UIControlStateNormal];
    [sourceButton setImage:[UIImage imageNamed:@"src_button_pressed"] forState:UIControlStateHighlighted];
    [sourceButton addTarget:self action:@selector(selectFromStationByButton) forControlEvents:UIControlEventTouchUpInside];
    [sourceButton setFrame:CGRectMake(-80, 200, 76, 76)];
    [sourceButton.layer setShadowOffset:CGSizeMake(0, 0)];
    [sourceButton.layer setShadowOpacity:0.3f];
    [sourceButton.layer setShadowRadius:10.0];
    
    destinationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [destinationButton setImage:[UIImage imageNamed:@"dst_button_normal"] forState:UIControlStateNormal];
    [destinationButton setImage:[UIImage imageNamed:@"dst_button_pressed"] forState:UIControlStateHighlighted];
    [destinationButton addTarget:self action:@selector(selectToStationByButton) forControlEvents:UIControlEventTouchUpInside];
    [destinationButton setFrame:CGRectMake(325, 200, 76, 76)];
    [destinationButton.layer setShadowOffset:CGSizeMake(0, 0)];
    [destinationButton.layer setShadowOpacity:0.3f];
    [destinationButton.layer setShadowRadius:10.0];
    
    [self addSubview:sourceButton];
    [self addSubview:destinationButton];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [settings setImage:[UIImage imageNamed:@"settings_btn_normal"] forState:UIControlStateNormal];
    [settings setImage:[UIImage imageNamed:@"settings_btn"] forState:UIControlStateHighlighted];
    settings.frame = CGRectMake(285, 420, 23, 23);
    [settings addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    [settings.layer setShadowRadius:5.f];
    [settings.layer setShadowOpacity:0.5f];
    [settings.layer setShadowOffset:CGSizeMake(0, 0)];
    [self addSubview:settings];
    
    zones = [UIButton buttonWithType:UIButtonTypeCustom];
    //[zones setTitle:@"Zones" forState:UIControlStateNormal];
    //[zones setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    //[zones setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [zones setImage:[UIImage imageNamed:@"zones_btn_normal"] forState:UIControlStateNormal];
    [zones setImage:[UIImage imageNamed:@"zones_btn_pressed"] forState:UIControlStateSelected];
    //zones.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:11.f];
    zones.frame = CGRectMake(20, 420, 42, 23);
    [zones addTarget:self action:@selector(switchZones) forControlEvents:UIControlEventTouchUpInside];
    [zones setSelected:mapView.showVectorLayer];
    [zones.layer setShadowRadius:5.f];
    [zones.layer setShadowOpacity:0.5f];
    [zones.layer setShadowOffset:CGSizeMake(0, 0)];
    [self addSubview:zones];
    
    UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]];
    shadow.frame = CGRectMake(0, 44, 320, 61);
    [self addSubview:shadow];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(supervisor) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)showButtons:(CGPoint)pos
{
    buttonsVisible = YES;
    if(stationMark.hidden) {
        stationMark.center = pos;
        stationMark.hidden = NO;
        stationMark.alpha = 0.f;
        [UIView animateWithDuration:0.25f animations:^{ stationMark.alpha = 1.f; }];
    } else {
        [UIView animateWithDuration:0.25f animations:^{ stationMark.center = pos; }];
    }
    
    pos.y -= 80;
    
    if(pos.x < 120) pos.x = 120;
    if(pos.x > 200) pos.x = 200;
    if(pos.y < 130) pos.y += 200;
    if(pos.y > 380) pos.y = 380;

    [UIView animateWithDuration:0.25f animations:^{ sourceButton.center = CGPointMake(pos.x-60, pos.y+20); }];
    [UIView animateWithDuration:0.25f animations:^{ destinationButton.center = CGPointMake(pos.x+60, pos.y+20); }];

    if(mapView.labelView.hidden) {
        mapView.labelView.center = CGPointMake(pos.x, pos.y-55);
        mapView.labelView.hidden=false;
        mapView.labelView.alpha = 0.f;
        [UIView animateWithDuration:0.25f animations:^{ mapView.labelView.alpha = 1.f; }];
    } else {
        [UIView animateWithDuration:0.25f animations:^{ mapView.labelView.center = CGPointMake(pos.x, pos.y-55); }];
    }
}

-(void)hideButtons
{
    buttonsVisible = NO;
    [UIView animateWithDuration:0.25f animations:^{ stationMark.alpha = 0.f; } completion:^(BOOL finished) { stationMark.hidden = YES; }];
    [UIView animateWithDuration:0.125f animations:^{ mapView.labelView.alpha = 0.f; } completion:^(BOOL finished){ if(finished) {mapView.labelView.hidden = YES; } }];
    CGPoint p = sourceButton.center;
    p.x = -40;
    [UIView animateWithDuration:0.125f animations:^{ sourceButton.center = p; } ];
    p = destinationButton.center;
    p.x = 360;
    [UIView animateWithDuration:0.125f animations:^{ destinationButton.center = p; }];
}

-(void) selectFromStationByButton {
    if(!mapView.stationSelected || mapView.selectedStationLine < 1 || !mapView.selectedStationName) return;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainViewController.currentSelection=0;
    
    MLine *line = [[MHelper sharedHelper] lineByIndex:mapView.selectedStationLine];
    MStation *station = [[MHelper sharedHelper] getStationWithName:mapView.selectedStationName forLine:[line name]];
    [appDelegate.mainViewController returnFromSelection:[NSArray arrayWithObject:station]];
    
	mapView.stationSelected=false;
    [self hideButtons];
}

-(void) selectToStationByButton {
    if(!mapView.stationSelected || mapView.selectedStationLine < 1 || !mapView.selectedStationName) return;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainViewController.currentSelection=1;
    
    MLine *line = [[MHelper sharedHelper] lineByIndex:mapView.selectedStationLine];
    MStation *station = [[MHelper sharedHelper] getStationWithName:mapView.selectedStationName forLine:[line name]];
    [appDelegate.mainViewController returnFromSelection:[NSArray arrayWithObject:station]];
	mapView.stationSelected=false;
    [self hideButtons];
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
    [sourceButton release];
    [destinationButton release];
}

-(void)selectStationAt:(CGPoint)currentPosition
{
	if (mapView.stationSelected) {
        [self showButtons:currentPosition];
	} else {
        [self hideButtons];
    }
}

-(void) findPathFrom :(NSString*) fs To:(NSString*) ss FirstLine:(NSInteger) fsl LastLine:(NSInteger) ssl  {
	[mapView findPathFrom:fs To:ss FirstLine:fsl LastLine:ssl];
    [[MHelper sharedHelper] addHistory:[NSDate date] :fs To:ss FirstLine:fsl LastLine:ssl];
}

-(void) supervisor
{
    if(buttonsVisible && !mapView.stationSelected) [self hideButtons];
}

-(void) showSettings
{
//    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
//    [self.vcontroller presentModalViewController:controller animated:YES];
//    [controller release];
}

-(void) switchZones
{
    return;
    if(mapView.showVectorLayer) {
        mapView.showVectorLayer = NO;
        [zones setSelected:NO];
    } else {
        mapView.showVectorLayer = YES;
        [zones setSelected:YES];
    }
}

@end
