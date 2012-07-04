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
#import "SettingsNavController.h"

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

    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect scrollSize = CGRectMake(0,44,(320),(480-64));
	mapView = [[[MapView alloc] initWithFrame:scrollSize] autorelease];
    mapView.cityMap = appDelegate.cityMap;
    mapView.vcontroller = self.vcontroller;
    self.backgroundColor = mapView.backgroundColor;

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
	containerView.minimumZoomScale = mapView.MinScale;
	//containerView.directionalLockEnabled = YES;
//	containerView.userInteractionEnabled = YES;
//	mapView.exclusiveTouch = NO;

    [containerView addSubview:mapView.previewImage];
    containerView.scrolledView = mapView;
	containerView.delegate = mapView;
	[containerView addSubview: mapView];
    [containerView setZoomScale:mapView.Scale animated:NO];
	[self addSubview:containerView];
    [containerView addSubview:mapView.midground1];
    [containerView addSubview:mapView.activeLayer];
    [containerView addSubview:mapView.midground2];
    
	//TODO
    CGPoint pos;
    int level;
    [appDelegate getDefaultExtent:&pos level:&level];
    CGFloat scale = mapView.MinScale * (1 << level);
    [containerView setZoomScale:scale animated:YES];
	[containerView setContentOffset:CGPointMake(mapView.size.width * pos.x * scale, mapView.size.height * pos.y * scale ) animated:YES];
	
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

    stationMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin"]];
    stationMark.hidden = YES;
    [self addSubview:stationMark];
    [self addSubview:mapView.labelView];
	
    /*sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sourceButton setImage:[UIImage imageNamed:@"src_button_normal"] forState:UIControlStateNormal];
    [sourceButton setImage:[UIImage imageNamed:@"src_button_pressed"] forState:UIControlStateHighlighted];
    [sourceButton addTarget:self action:@selector(selectFromStationByButton) forControlEvents:UIControlEventTouchUpInside];
    [sourceButton setFrame:CGRectMake(-90, 190, 96, 96)];
     */
    
    /*destinationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [destinationButton setImage:[UIImage imageNamed:@"dst_button_normal"] forState:UIControlStateNormal];
    [destinationButton setImage:[UIImage imageNamed:@"dst_button_pressed"] forState:UIControlStateHighlighted];
    [destinationButton addTarget:self action:@selector(selectToStationByButton) forControlEvents:UIControlEventTouchUpInside];
    [destinationButton setFrame:CGRectMake(315, 190, 96, 96)];
     */
    
    //[self addSubview:sourceButton];
    //[self addSubview:destinationButton];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [settings setImage:[UIImage imageNamed:@"settings_btn_normal"] forState:UIControlStateNormal];
    [settings setImage:[UIImage imageNamed:@"settings_btn"] forState:UIControlStateHighlighted];
    settings.frame = CGRectMake(285, 420, 27, 27);
    [settings addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settings];
    
    sourceData = [UIButton buttonWithType:UIButtonTypeCustom];
    [sourceData setImage:[UIImage imageNamed:@"vector"] forState:UIControlStateNormal];
    [sourceData setImage:[UIImage imageNamed:@"terrain"] forState:UIControlStateSelected];
    sourceData.frame = CGRectMake(15, 420, 44, 27);
    [sourceData addTarget:self action:@selector(changeSource) forControlEvents:UIControlStateHighlighted];
    [self addSubview:sourceData];
    
    userPosition = [UIButton buttonWithType:UIButtonTypeCustom];
    [userPosition setImage:[UIImage imageNamed:@"navigate_btn"] forState:UIControlStateNormal];
    userPosition.frame = CGRectMake(0, 44, 40, 40);
    [userPosition addTarget:self action:@selector(getUserPosition) forControlEvents:UIControlStateHighlighted];
    [self addSubview:userPosition];
    
    UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]] autorelease];
    shadow.frame = CGRectMake(0, 44, 320, 61);
    [self addSubview:shadow];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(supervisor) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)setCityMap:(CityMap*)cm
{
    [mapView removeFromSuperview];
    [containerView removeFromSuperview];
    [containerView release];
    CGRect scrollSize = CGRectMake(0,44,(320),(480-64));
    containerView = [[MyScrollView alloc] initWithFrame:scrollSize];
    
    mapView = [[[MapView alloc] initWithFrame:scrollSize] autorelease];
    mapView.cityMap = cm;
	[containerView setContentSize:mapView.size];
	containerView.scrollEnabled = YES;
	containerView.decelerationRate = UIScrollViewDecelerationRateFast ;
	containerView.showsVerticalScrollIndicator = NO;
	containerView.showsHorizontalScrollIndicator = NO;	
	containerView.clipsToBounds = NO;//YES;
	containerView.bounces = YES;
    [containerView setBouncesZoom:NO];
	containerView.maximumZoomScale = mapView.MaxScale;
	containerView.minimumZoomScale = mapView.MinScale;
    
    [containerView addSubview:mapView.previewImage];
    containerView.scrolledView = mapView;
	containerView.delegate = mapView;
	[containerView addSubview: mapView];
    [containerView setZoomScale:mapView.Scale animated:NO];
    [containerView addSubview:mapView.midground1];
    [containerView addSubview:mapView.activeLayer];
    [containerView addSubview:mapView.midground2];
    [self insertSubview:containerView atIndex:0];
    
    if(cm != nil)
        [containerView setContentOffset:CGPointMake(mapView.size.width * 0.25f * mapView.Scale, mapView.size.height * 0.25f * mapView.Scale ) animated:NO];
    else 
        [containerView setContentOffset:CGPointZero];
    //[self insertSubview:mapView.labelView belowSubview:sourceButton];
    self.backgroundColor = mapView.backgroundColor;
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

    //[UIView animateWithDuration:0.25f animations:^{ sourceButton.center = CGPointMake(pos.x-60, pos.y+20); }];
    //[UIView animateWithDuration:0.25f animations:^{ destinationButton.center = CGPointMake(pos.x+60, pos.y+20); }];

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
    /*CGPoint p = sourceButton.center;
    p.x = -40;
    [UIView animateWithDuration:0.125f animations:^{ sourceButton.center = p; } ];
     */
    /*p = destinationButton.center;
    p.x = 360;
    [UIView animateWithDuration:0.125f animations:^{ destinationButton.center = p; }];
     */
}

-(void) selectFromStationByButton {
    if(!mapView.stationSelected || mapView.selectedStationLine < 1 || !mapView.selectedStationName) return;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainViewController.currentSelection=0;
    
    MCategory *line = [[MHelper sharedHelper] categoryByIndex:mapView.selectedStationLine];
    MItem *station = [[MHelper sharedHelper] getItemWithName:mapView.selectedStationName forCategories:[NSArray arrayWithObject:[line name]]];
    [appDelegate.mainViewController returnFromSelection:[NSArray arrayWithObject:station]];
    
	mapView.stationSelected=false;
    [self hideButtons];
}

-(void) selectToStationByButton {
    if(!mapView.stationSelected || mapView.selectedStationLine < 1 || !mapView.selectedStationName) return;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainViewController.currentSelection=1;
    
    MCategory *line = [[MHelper sharedHelper] categoryByIndex:mapView.selectedStationLine];
    MItem *station = [[MHelper sharedHelper] getItemWithName:mapView.selectedStationName forCategories:[NSArray arrayWithObject:[line name]]];
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
    //[sourceButton release];
    //[destinationButton release];
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
    [[MHelper sharedHelper] addHistory:[NSDate date] item:fs categories:fsl];
}

-(void) supervisor
{
    if(buttonsVisible && !mapView.stationSelected) [self hideButtons];
}

-(void) showSettings
{
    SettingsNavController *controller = [[SettingsNavController alloc] initWithNibName:@"SettingsNavController" bundle:[NSBundle mainBundle]];
    [self.vcontroller presentModalViewController:controller animated:YES];
    [controller release];
}

- (void) getUserPosition {
    [mapView enableUserLocation];
}

-(void) changeSource
{
    BOOL s = [mapView changeSource];
    [sourceData setSelected:s];
}

- (CGPoint) pointOnMapViewForPointOnVisibleRect:(CGPoint)point
{
    CGPoint p;
    p = [self convertPoint:point fromView:containerView];
    p = [self convertPoint:p toView:mapView];
    return p;
}

- (BOOL) centerGalleryShiftedMapOnItemWithID:(NSInteger)itemID {
    CGPoint p = [mapView pointOnMapViewForItemWithID:itemID];
    CGPoint p2 = mapView.userPosition;
    if(p.x != 0 || p.y != 0) { 
        CGRect rect;
        rect.size.width = fabsf(p.x - p2.x) * 2.2f;
        rect.size.height = fabsf(p.y - p2.y) * 2.2f;
        rect.origin.x = p.x - rect.size.width * 0.5f;
        rect.origin.y = p.y - rect.size.height * 0.5f - rect.size.height * 0.5f;
        [containerView zoomToRect:rect animated:YES];
        return YES;
    } else return NO;
}


- (BOOL) centerMapOnItemWithID:(NSInteger)itemID
{
    CGPoint p = [mapView pointOnMapViewForItemWithID:itemID];
    CGPoint p2 = mapView.userPosition;
    if(p.x != 0 || p.y != 0) { 
        CGRect rect;
        rect.size.width = fabsf(p.x - p2.x) * 2.2f;
        rect.size.height = fabsf(p.y - p2.y) * 2.2f;
        rect.origin.x = p.x - rect.size.width * 0.5f;
        rect.origin.y = p.y - rect.size.height * 0.5f;
        [containerView zoomToRect:rect animated:YES];
        return YES;
    } else return NO;
}

- (BOOL) centerMapOnUserAndItemWithID:(NSInteger)itemID 
{
    CGPoint p = [mapView pointOnMapViewForItemWithID:itemID];
    CGPoint p2 = mapView.userPosition;
    if(p.x != 0 || p.y != 0) { 
        CGRect rect;
        rect.size.width = fabsf(p.x - p2.x) * 1.2f;
        rect.size.height = fabsf(p.y - p2.y) * 1.2f;
        rect.origin.x = (p.x + p2.x - rect.size.width) * 0.5f;
        rect.origin.y = (p.y + p2.y - rect.size.height) * 0.5f;
        [containerView zoomToRect:rect animated:YES];
        return YES;
    } else return NO;
}

- (CGFloat) distanceToItemWithID:(NSInteger)itemID
{
    CGPoint p = [mapView pointOnMapViewForItemWithID:itemID];
    CGPoint p2 = mapView.userPosition;
    if(p.x != 0 || p.y != 0) { 
        p = CGPointMake(2 * M_PI * (p.x / mapView.size.width - 0.5f), 2 * M_PI * (0.5f - p.y / mapView.size.height));
        p2 = CGPointMake(2 *M_PI * (p2.x / mapView.size.width - 0.5f), 2 * M_PI * (0.5f - p2.y / mapView.size.height));
        double cosd = sin(p.y)*sin(p2.y) + cos(p.y)*cos(p2.y)*cos(p.x-p2.x);
        double d = acos(cosd) * 6371;
        return d;
    } else return 0;
}

- (CGFloat) radialOffsetToPoint:(CGPoint)point
{
    CGPoint off = containerView.contentOffset;
    CGSize size = containerView.bounds.size;
    off.x += size.width*0.5f / containerView.zoomScale;
    off.y += size.height*0.5f / containerView.zoomScale;
    
    return atan2f(point.y - off.y, point.x - off.x);
}

@end
