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
#import "SSTheme.h"

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

//    self.layer.cornerRadius=10;
    
    CGRect scrollSize,settingsRect,shadowRect,zonesRect;
    
    scrollSize = CGRectMake(0, 44,(320),(480-64));
    settingsRect = CGRectMake(285, 440, 27, 27);
    shadowRect = CGRectMake(0, 44, 480, 61);
    zonesRect = CGRectMake(25, 440, 43, 25);
    
    if (IS_IPAD) {
        scrollSize = CGRectMake(0, 44, 768, (1024-74));
        settingsRect = CGRectMake(-285, -420, 27, 27);
        shadowRect = CGRectMake(0, 44, 1024, 61);
        zonesRect = CGRectMake(self.bounds.size.width-70, self.bounds.size.height-50, 43, 25);
    } else {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 1136){
                scrollSize = CGRectMake(0,44,(320),(568-64));
                settingsRect = CGRectMake(285, 528, 27, 27);
                shadowRect = CGRectMake(0, 44, 568, 61);
                zonesRect = CGRectMake(25, 528, 43, 25);
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
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
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
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    containerView.autoresizesSubviews = YES;

    
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
	//UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
	//[containerView addGestureRecognizer:singleTap];
    
    stationMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"station_mark"]];
    stationMark.hidden = YES;
    [self addSubview:stationMark];
    [self addSubview:mapView.labelView];
	
    sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sourceButton setImage:[[SSThemeManager sharedTheme] mapViewEntryButton:UIControlStateNormal] forState:UIControlStateNormal];
    [sourceButton setImage:[[SSThemeManager sharedTheme] mapViewEntryButton:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [sourceButton addTarget:self action:@selector(selectFromStationByButton) forControlEvents:UIControlEventTouchUpInside];
    [sourceButton setFrame:CGRectMake(-90, 190, 96, 96)];
    
    destinationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [destinationButton setImage:[[SSThemeManager sharedTheme] mapViewExitButton:UIControlStateNormal] forState:UIControlStateNormal];
    [destinationButton setImage:[[SSThemeManager sharedTheme] mapViewExitButton:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [destinationButton addTarget:self action:@selector(selectToStationByButton) forControlEvents:UIControlEventTouchUpInside];
    if (IS_IPAD) {
        [destinationButton setFrame:CGRectMake(1024, 190, 96, 96)];
    } else {
        [destinationButton setFrame:CGRectMake(570, 190, 96, 96)];
    }
    [self addSubview:sourceButton];
    [self addSubview:destinationButton];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [settings setImage:[[SSThemeManager sharedTheme] mapViewSettingsButton:UIControlStateNormal] forState:UIControlStateNormal];
    [settings setImage:[[SSThemeManager sharedTheme] mapViewSettingsButton:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    settings.frame = settingsRect;
    [settings addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settings];

    zones = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [zones setBackgroundImage:[[SSThemeManager sharedTheme] mapsSwitchButtonImage] forState:UIControlStateNormal];

    [zones setTitle:NSLocalizedString(@"MapsButton", @"MapsButton") forState:UIControlStateNormal];
    [[zones titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:10.0]];
    [zones setTitleEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
    [zones setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    zones.frame = zonesRect;
    [zones addTarget:self action:@selector(changeZones) forControlEvents:UIControlEventTouchUpInside];
    
    if (![appDelegate isIPodTouch4thGen]) {
        [self addSubview:zones];
    }
    if (![[SSThemeManager sharedTheme] isNewTheme]) {
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]] autorelease];
        shadow.frame = shadowRect;
        [shadow setUserInteractionEnabled:NO];
        [self addSubview:shadow];
        shadow.tag=717;
    }
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(supervisor) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self bringSubviewToFront:commonActivityIndicator];
}

-(void)layoutSubviews
{
    if (IS_IPAD) {
        CGRect zonesRect=CGRectMake(self.bounds.size.width-70, self.bounds.size.height-50, 43, 25);
        [zones setFrame:zonesRect];
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
    
    if (IS_IPAD) {
        if(pos.x < 120) pos.x = 120;
        if(pos.x > self.frame.size.width-120.0) pos.x = self.frame.size.width-120.0;
        if(pos.y < 130) pos.y += 200;
        if(pos.y > self.frame.size.height-130.0) pos.x = self.frame.size.height-130.0;
    } else {
        if(pos.x < 120) pos.x = 120;
        if(pos.x > 200) pos.x = 200;
        if(pos.y < 130) pos.y += 200;
        if(pos.y > 380) pos.y = 380;
    }
    
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
    SettingsNavController *controller = [[SettingsNavController alloc] initWithNibName:@"SettingsNavController" bundle:[NSBundle mainBundle]];
    [self.vcontroller presentModalViewController:controller animated:YES];
    [controller release];
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

-(CGRect)getMapVisibleRect
{
    CGRect rect = containerView.bounds;
    rect = [self convertRect:rect fromView:containerView];
    rect = [self convertRect:rect toView:mapView];
    return rect;
}

-(void)setGeoPosition:(CGPoint)geoPosition withZoom:(CGFloat)zoom
{
    // будет выбрана не реальная гео позиция, а станция метро с ближайшими координатами
    Station *st = [mapView.cityMap findNearestStationTo:geoPosition];
	
    [containerView setContentScaleFactor:zoom];
    [containerView setContentOffset:CGPointMake(st.pos.x * mapView.Scale - containerView.bounds.size.width*0.5f, st.pos.y * mapView.Scale - containerView.bounds.size.height*0.75f ) animated:YES];
}

//- (UIView*)listSubviewsOfView:(UIView *)view {
//    
//    // Get the subviews of the view
//    NSArray *subviews = [view subviews];
//    
//    // Return if there are no subviews
//    if ([subviews count] == 0) return nil;
//    
//    for (UIView *subview in subviews) {
//        
//        if (subview.tag==555 || subview.tag==6843) {
//            NSLog(@"%@", subview);
//            return subview;
//        }
//        // List the subviews of subview
//        [self listSubviewsOfView:subview];
//    }
//    
//    return nil;
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UIView *view = [self listSubviewsOfView:self];
//    if (view) {
//        [view touchesBegan: touches withEvent: event];
//    }
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UIView *view = [self listSubviewsOfView:self];
//    if (view) {
//        [view touchesMoved: touches withEvent: event];
//    }
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UIView *view = [self listSubviewsOfView:self];
//    if (view) {
//        [view touchesEnded: touches withEvent: event];
//    }
//}


@end
