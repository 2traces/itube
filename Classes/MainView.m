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
#import "GlViewController.h"

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
    
    CGRect scrollSize,settingsRect,shadowRect,zonesRect,cornerRect;
    
    scrollSize = CGRectMake(0, 44,(320),(480-64));
    settingsRect=CGRectMake(285, 420, 27, 27);
    shadowRect = CGRectMake(0, 44, 480, 61);
    
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    CGRect selfFrame = self.frame;
    
    if ([appDelegate isIPHONE5]) {
        zonesRect=CGRectMake(250, 498, 71, 43);
        cornerRect=CGRectMake(0, 498, 36, 60);
        selfFrame.size.height = 568;
    }
    else {
        zonesRect=CGRectMake(250, 410, 71, 43);
        cornerRect=CGRectMake(0, 410, 36, 60);

    }
    
    self.frame = selfFrame;
    
    if (IS_IPAD) {
        scrollSize = CGRectMake(0, 44, 768, (1024-74));
        settingsRect=CGRectMake(-285, -420, 27, 27);
        shadowRect = CGRectMake(0, 44, 1024, 61);
        zonesRect=CGRectMake(self.bounds.size.width-70, self.bounds.size.height-50, 43, 25);
    } else {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 1136){
                scrollSize = CGRectMake(0,44,(320),(568-64));
                settingsRect=CGRectMake(285, 508, 27, 27);
                shadowRect = CGRectMake(0, 44, 568, 61);
                settingsRect=CGRectMake(55, 508, 27, 27);
            }
        }
    }
    
    self.vcontroller = vc;
	self.userInteractionEnabled = YES;
    buttonsVisible = NO;
	DLog(@"ViewDidLoad main View");
    MBProgressHUD *aiv = [[MBProgressHUD alloc] initWithView:self];
    commonActivityIndicator = aiv;
    [self addSubview:aiv];
    
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
	containerView.clipsToBounds = YES;//YES;
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
	[containerView setContentOffset:CGPointMake(mapView.size.width * 0.25f * mapView.Scale, mapView.size.height * 0.25f * mapView.Scale ) animated:NO];
	
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
//	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
//	[containerView addGestureRecognizer:singleTap];
    
    stationMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"station_mark"]];
    stationMark.hidden = YES;
    [self addSubview:stationMark];
    [self addSubview:mapView.labelView];
	
    sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sourceButton setImage:[UIImage imageNamed:@"src_button_normal"] forState:UIControlStateNormal];
    [sourceButton setImage:[UIImage imageNamed:@"src_button_pressed"] forState:UIControlStateHighlighted];
    [sourceButton addTarget:self action:@selector(selectFromStationByButton) forControlEvents:UIControlEventTouchUpInside];
    [sourceButton setFrame:CGRectMake(-90, 190, 96, 96)];
    sourceButton.hidden = YES;
    
    cornerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cornerButton setImage:[UIImage imageNamed:@"bt_corner"] forState:UIControlStateNormal];
    [cornerButton setFrame:zonesRect];
    [cornerButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cornerButton];

    destinationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [destinationButton setImage:[UIImage imageNamed:@"dst_button_normal"] forState:UIControlStateNormal];
    [destinationButton setImage:[UIImage imageNamed:@"dst_button_pressed"] forState:UIControlStateHighlighted];
    [destinationButton addTarget:self action:@selector(selectToStationByButton) forControlEvents:UIControlEventTouchUpInside];
    if (IS_IPAD) {
        [destinationButton setFrame:CGRectMake(1024, 190, 96, 96)];
    } else {
        [destinationButton setFrame:CGRectMake(570, 190, 96, 96)];
    }
    [self addSubview:sourceButton];
    [self addSubview:destinationButton];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [settings setImage:[UIImage imageNamed:@"settings_btn_normal"] forState:UIControlStateNormal];
    [settings setImage:[UIImage imageNamed:@"settings_btn"] forState:UIControlStateHighlighted];
    settings.frame = settingsRect;
    [settings addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    //[self addSubview:settings];

    zones = [UIButton buttonWithType:UIButtonTypeCustom];
    [zones setImage:[UIImage imageNamed:@"bt_mode_maps_up"] forState:UIControlStateNormal];
    [zones setImage:[UIImage imageNamed:@"bt_mode_maps"] forState:UIControlStateHighlighted];
    zones.frame = zonesRect;
    [zones addTarget:self action:@selector(changeZones) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:zones];

    UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]] autorelease];
    shadow.frame = shadowRect;
    [self addSubview:shadow];
    shadow.tag=717;
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(supervisor) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self bringSubviewToFront:commonActivityIndicator];
    [self moveModeButtonToCutScreen];
}

- (void) centerMapOnUser {
    [self setGeoPosition:mapView.nearestStation.gpsCoords withZoom:-1];
}


- (void) moveModeButtonToFullScreen {
    CGRect zonesRect, cornerRect;
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([appDelegate isIPHONE5]) {
        zonesRect=CGRectMake(250, 498, 71, 43);
        cornerRect=CGRectMake(0, 488, 36, 60);
    }
    else {
        zonesRect=CGRectMake(250, 410, 71, 43);
        cornerRect=CGRectMake(0, 400, 36, 60);
    }
    
    zones.frame = zonesRect;
    cornerButton.frame = cornerRect;
}

- (void) moveModeButtonToCutScreen {
    CGRect zonesRect, cornerRect;
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate isIPHONE5]) {
        zonesRect=CGRectMake(250, 498, 71, 43);
        cornerRect=CGRectMake(0, 488, 36, 60);

    }
    else {
        zonesRect=CGRectMake(250, 410, 71, 43);
        cornerRect=CGRectMake(0, 400, 36, 60);
    }
    
    zonesRect.origin.y -= 265;
    cornerRect.origin.y -= 265;
    
    zones.frame = zonesRect;
    cornerButton.frame = cornerRect;
}

-(void)layoutSubviews
{
    if (IS_IPAD) {
        CGRect zonesRect=CGRectMake(self.bounds.size.width-70, self.bounds.size.height-50, 43, 25);
        [zones setFrame:zonesRect];
        [containerView setFrame:CGRectMake(0, 44,self.bounds.size.width,self.bounds.size.height-74)];
    } else {
        [containerView setFrame:CGRectMake(0, 44,self.bounds.size.width,self.bounds.size.height-44)];
    }
}

-(void)setCityMap:(CityMap*)cm
{
    [containerView removeFromSuperview];
    [containerView release];
    CGRect scrollSize;
    
    scrollSize = CGRectMake(0,44,(320),(480-64));
    
    if (IS_IPAD) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            scrollSize = CGRectMake(0, 44, 768, (1024-64));
        } else {
            scrollSize = CGRectMake(0, 44, 1024, (768-64));
        }
    } else {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 1136){
                scrollSize = CGRectMake(0,44,(320),(568-64));
            }
        }
    }
    
    containerView = [[MyScrollView alloc] initWithFrame:scrollSize];
    
    mapView = [[[MapView alloc] initWithFrame:scrollSize] autorelease];
    mapView.cityMap = cm;
	[containerView setContentSize:mapView.size];
	containerView.scrollEnabled = YES;
	containerView.decelerationRate = UIScrollViewDecelerationRateFast ;
	containerView.showsVerticalScrollIndicator = NO;
	containerView.showsHorizontalScrollIndicator = NO;
	containerView.clipsToBounds = YES;//YES;
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
    
    if(cm != nil) {
        [containerView setContentOffset:CGPointMake(mapView.size.width * 0.25f * mapView.Scale, mapView.size.height * 0.25f * mapView.Scale ) animated:NO];
        cm.drawName = [[MHelper sharedHelper] languageIndex];
    } else
        [containerView setContentOffset:CGPointZero];
    [self insertSubview:mapView.labelView belowSubview:sourceButton];
    self.backgroundColor = mapView.backgroundColor;
    [self bringSubviewToFront:commonActivityIndicator];
    
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
    sourceButton.hidden = NO;

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
    [UIView animateWithDuration:0.125f animations:^{ sourceButton.center = p; } completion:^(BOOL finished) {
        sourceButton.hidden = YES;
    
    }];
    p = destinationButton.center;
    if (IS_IPAD) {
        p.x = 1064;
    } else {
        p.x = 610;
    }
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
        if (landscapeMode) {
            [self showButtons:currentPosition];
        }
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
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showSettings];
}

-(void) changeZones
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showRasterMap];
}

-(void)changeShadowFrameToRect:(CGRect)rect
{
    UIImageView *shadow = (UIImageView*)[self viewWithTag:717];
    shadow.frame = rect;
}

- (void)changedToLandscape:(BOOL)landscape {
    landscapeMode = landscape;
    if (!landscape) {
        [self hideButtons];
    }
}


-(CGRect)getMapVisibleRect
{
    CGRect rect = containerView.bounds;
    rect = [self convertRect:rect fromView:containerView];
    rect = [self convertRect:rect toView:mapView];
    return rect;
}

- (Station*) stationNearestToGeoPosition:(CGPoint)position {
    return [mapView.cityMap findNearestStationTo:position];
}

-(void)setGeoPosition:(CGPoint)geoPosition withZoom:(CGFloat)zoom
{
    // будет выбрана не реальная гео позиция, а станция метро с ближайшими координатами
    Station *st = [mapView.cityMap findNearestStationTo:geoPosition];
    NSLog(@"Closest station is: %@", st.name);
    [mapView setLocationAt:st];
    
    if(zoom > mapView.MaxScale) zoom = mapView.MaxScale;
    if (zoom != -1) {
        [containerView setZoomScale:zoom animated:NO];
    } else {
        zoom = mapView.Scale;
    }
    
    [containerView setContentOffset:CGPointMake(st.pos.x * zoom - containerView.bounds.size.width*0.5f, st.pos.y * zoom - containerView.bounds.size.height*0.5f ) animated:YES];

}

@end
