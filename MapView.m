//
//  MapView.m
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapView.h"
#import "CityMap.h"
#import <Foundation/Foundation.h>
#import "tubeAppDelegate.h"
#import "MyTiledLayer.h"
#import "Schedule.h"
#import "ManagedObjects.h"
#import "SSTheme.h"

@implementation MapView
@synthesize cityMap;
@synthesize mainLabel;
@synthesize selectedStationName;
@synthesize stationSelected;
@synthesize selectedStationLine;
@synthesize nearestStationName;
@synthesize nearestStationImage;
@synthesize selectedStationLayer;
@synthesize Scale;
@synthesize MaxScale;
@synthesize MinScale;
@synthesize vcontroller;
@synthesize midground1;
@synthesize midground2;
@synthesize previewImage;
@synthesize activeLayer;
@synthesize foundPaths;

+ (Class)layerClass
{
    return [MyTiledLayer class];
}

-(void) setTransform:(CGAffineTransform)transform
{
    super.transform = transform;
    activeLayer.transform = transform;
}

- (CGSize) size {
    return CGSizeMake(cityMap.w, cityMap.h);
}

-(UIView*) labelView {
    return labelBg;
}

-(UIColor*) backgroundColor
{
    return cityMap.backgroundColor;
}

-(DrawNameType) drawName
{
    return cityMap.drawName;
}

-(void) setDrawName:(DrawNameType)drawName
{
    if(drawName != cityMap.drawName) {
        cityMap.drawName = drawName;
        if(cityMap.drawName == drawName)
            [self setNeedsDisplay];
    }
}

#pragma mark gps stuff 
-(BOOL) enableUserLocation
{
    [locationManager release];
    locationManager = nil;
    if([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.distanceFilter = 500;
        [locationManager startUpdatingLocation];
        return YES;
    } else return NO;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CGPoint curPos = CGPointMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] setUserGeoPosition:curPos];
    selectedStationLayer.contents=(id)[nearestStationImage CGImage];
    Station *st = [cityMap findNearestStationTo:curPos];
	
	if (![st.name isEqualToString:nearestStationName])
	{
        [self.superview setContentOffset:CGPointMake(st.pos.x * self.Scale - self.superview.frame.size.width*0.5f, st.pos.y * self.Scale - self.superview.frame.size.height*0.5f) animated:YES];

		nearestStationName=st.name;
        selectedStationLayer.position = st.pos;
        
        [self setNeedsDisplay];
	};
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] errorWithGeoLocation];
    selectedStationLayer.contents=(id)[nearestStationImageBw CGImage];
    NSLog(@"%@", error);
}

-(void) makePreview {
    [previewImage release];
    previewImage = nil;
    if(cityMap == nil) return;
    // make background image
    CGFloat backScale = MinScale * 2.f;
    CGSize minSize = CGSizeMake(cityMap.w * backScale, cityMap.h * backScale);
    CGRect r = CGRectMake(0, 0, minSize.width, minSize.height);
    UIGraphicsBeginImageContext(minSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,r);
    CGContextScaleCTM(context, backScale, backScale);
    r.size.width /= backScale;
    r.size.height /= backScale;
    [vectorLayer draw:context inRect:r];
    [cityMap drawMap:context inRect:r];
    [cityMap drawTransfers:context inRect:r];
    [cityMap drawStations:context inRect:r]; 
    [vectorLayer2 draw:context inRect:r];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    previewImage = [[UIImageView alloc] initWithImage:img];
    previewImage.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    previewImage.contentMode = UIViewContentModeScaleAspectFit;
    previewImage.hidden = NO;
    UIGraphicsEndImageContext();
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        visualFrame = frame;
        [self.layer setLevelsOfDetail:5];
        [self.layer setLevelsOfDetailBias:2];
        for(int i=0; i<MAXCACHE; i++) cacheLayer[i] = nil;

		DLog(@" InitMapView	initWithFrame; ");
		
		//близжайщней станции пока нет
		nearestStationName = @"";
        MinScale = 0.25f;
        MaxScale = 4.f;
        Scale = 2.f;
        selectedStationName = [[NSMutableString alloc] init];
		
		int scale = 1;
		if ([self respondsToSelector:@selector(setContentScaleFactor:)])
		{
			scale = [[UIScreen mainScreen] scale];
            self.contentScaleFactor = scale;
            self.layer.contentsScale = scale;
		}

		//метка которая показывает названия станций
		mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 27, 140, 25)]; //
        [[SSThemeManager sharedTheme] decorMapViewMainLabel:mainLabel];
        lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 27, 40, 25)]; //
        [[SSThemeManager sharedTheme] decorMapViewLineLabel:lineLabel];
        circleLabel = [[UIView alloc] initWithFrame:CGRectMake(25, 23, 21, 21)]; //
        [[SSThemeManager sharedTheme] decorMapViewCircleLabel:circleLabel];
        circleLabel.layer.cornerRadius = 11.f;
        circleLabel.backgroundColor = [UIColor redColor];
        [circleLabel addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"embossed_circle"]]];
        
        labelBg = [[UIImageView alloc] initWithImage:[[SSThemeManager sharedTheme] mapViewLabelView]];
        [labelBg addSubview:mainLabel];
        [labelBg addSubview:lineLabel];
        [labelBg addSubview:circleLabel];
		labelBg.hidden=true;
        
        midground1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        midground1.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.7f];
        midground1.hidden = YES;
        midground2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        midground2.backgroundColor = [UIColor whiteColor];
        midground2.hidden = YES;

		[self initData];
		
		selectedStationLayer = [[CALayer layer] retain];
        selectedStationLayer.frame = CGRectMake(0, 0, nearestStationImage.size.width, nearestStationImage.size.height);
        selectedStationLayer.contents=(id)[nearestStationImage CGImage];
        [self.layer addSublayer:selectedStationLayer];

        activeLayer = [[ActiveView alloc] initWithFrame:frame];
        activeLayer.hidden = YES;
        
        [self enableUserLocation];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:@"kLangChanged" object:nil];
    }
    return self;
}

-(void)setCityMap:(CityMap *)_cityMap
{
    [cityMap release];
    cityMap = [_cityMap retain];
    self.frame = CGRectMake(0, 0, cityMap.w, cityMap.h);
    MinScale = MIN( (float)visualFrame.size.width / cityMap.size.width, (float)visualFrame.size.height / cityMap.size.height);
    MaxScale = cityMap.maxScale;
    Scale = MinScale * 2.f;
    selectedStationLayer.frame = CGRectMake(0, 0, cityMap.gpsCircleScale*nearestStationImage.size.width, cityMap.gpsCircleScale*nearestStationImage.size.height);

    midground1.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    midground1.hidden = YES;
    midground2.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    midground2.hidden = NO;
    midground2.alpha = 1.f;
    [UIView animateWithDuration:0.5f animations:^(void) { midground2.alpha = 0.f; } completion:^(BOOL finish) { midground2.hidden = YES; } ];

    activeLayer.cityMap = cityMap;
    if(cityMap.backgroundImageFile != nil) {
        if(vectorLayer != nil) [vectorLayer loadFrom:cityMap.backgroundImageFile directory:cityMap.thisMapName];
        else vectorLayer = [[VectorLayer alloc] initWithFile:cityMap.backgroundImageFile andDir:cityMap.thisMapName];
    } else {
        [vectorLayer release];
        vectorLayer = nil;
    }
    if(cityMap.foregroundImageFile != nil) {
        if(vectorLayer2 != nil) [vectorLayer2 loadFrom:cityMap.foregroundImageFile directory:cityMap.thisMapName];
        else vectorLayer2 = [[VectorLayer alloc] initWithFile:cityMap.foregroundImageFile andDir:cityMap.thisMapName];
    } else {
        [vectorLayer2 release];
        vectorLayer2 = nil;
    }
    [self makePreview];
    // это недокументированный метод, так что если он в будущем изменится, то ой
    [self.layer invalidateContents];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

-(void)showLabel
{
    if(labelBg.hidden) {
        labelBg.hidden=false;
        labelBg.alpha = 0.f;
        [UIView animateWithDuration:0.25f animations:^{ labelBg.alpha = 1.f; }];
    }
}

-(void)hideLabel
{
    if(!labelBg.hidden) {
        [UIView animateWithDuration:0.25f animations:^{ labelBg.alpha = 0.f; } completion:^(BOOL finished){ if(finished) {labelBg.hidden = YES; } }];
    }
}

-(void)drawRect:(CGRect)rect
{
    [self drawLayer:nil inContext:UIGraphicsGetCurrentContext()];
}

-(void)languageChanged:(NSNotification*)note
{
    [self setDrawName:[[MHelper sharedHelper] languageIndex]];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [labelBg removeFromSuperview];
    [previewImage removeFromSuperview];
    [midground1 removeFromSuperview];
    [midground2 removeFromSuperview];
    [activeLayer removeFromSuperview];
    locationManager.delegate = nil;
    [locationManager release];
    [vectorLayer release];
    [vectorLayer2 release];
    [mainLabel release];
    [labelBg release];
	[cityMap release];
	[nearestStationImage release];
    [nearestStationImageBw release];
    for(int i=0; i<MAXCACHE; i++) CGLayerRelease(cacheLayer[i]);
    [midground1 release];
    [midground2 release];
    [previewImage release];
    [selectedStationName release];
    [super dealloc];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {

    CGContextSaveGState(context);
    CGRect r = CGContextGetClipBoundingBox(context);
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, r);

#ifdef AGRESSIVE_CACHE
    CGFloat drawScale = 1024.f / MAX(r.size.width, r.size.height);
    CGFloat presentScale = 1.f/drawScale;
    int cc = currentCacheLayer;
    currentCacheLayer++;
    if(currentCacheLayer >= MAXCACHE) currentCacheLayer = 0;
    if(cacheLayer[cc] != nil) CGLayerRelease(cacheLayer[cc]);
    cacheLayer[cc] = CGLayerCreateWithContext(context, CGSizeMake(512, 512), NULL);
    CGContextRef ctx = CGLayerGetContext(cacheLayer[cc]);
    CGContextScaleCTM(ctx, drawScale, drawScale);
    CGContextTranslateCTM(ctx, -r.origin.x, -r.origin.y);
#else
    CGContextRef ctx = context;
#endif
    CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetShouldSmoothFonts(ctx, false);
    CGContextSetAllowsFontSmoothing(ctx, false);
    
    if(vectorLayer) [vectorLayer draw:context inRect:r];
    cityMap.currentScale = scrollView.zoomScale / MaxScale;
    [cityMap drawMap:ctx inRect:r];
    [cityMap drawTransfers:ctx inRect:r];
    if(vectorLayer2) [vectorLayer2 draw:context inRect:r];
    [cityMap drawStations:ctx inRect:r]; 

#ifdef AGRESSIVE_CACHE
    CGContextTranslateCTM(context, r.origin.x, r.origin.y);
    CGContextScaleCTM(context, presentScale, presentScale);
    CGContextDrawLayerAtPoint(context, CGPointZero, cacheLayer[cc]);
#endif
    CGContextRestoreGState(context);
}

-(void) initData {
	nearestStationImage = [[UIImage imageWithContentsOfFile: 
						   [[NSBundle mainBundle] pathForResource:@"select_near_station" ofType:@"png"]]retain];
	nearestStationImageBw = [[UIImage imageWithContentsOfFile:
                            [[NSBundle mainBundle] pathForResource:@"select_near_station_bw" ofType:@"png"]]retain];

}

#pragma mark -

- (void)viewDidLoad 
{
    //[super viewDidLoad];
    DLog(@"viewDidLoad mapView\n");
}

- (void) drawString: (NSString*) s withFont: (UIFont*) font inRect: (CGRect) contextRect {
	
    CGFloat fontHeight = font.pointSize;
    CGFloat yOffset = (contextRect.size.height - fontHeight) / 2.0;
	
    CGRect textRect = CGRectMake(0, yOffset, contextRect.size.width, fontHeight);
	
    [s drawInRect: textRect withFont: font lineBreakMode: UILineBreakModeWordWrap 
		alignment: UITextAlignmentCenter];
}

-(void)selectStationAt:(CGPoint*)currentPosition
{
    Station *s = [cityMap checkPoint:currentPosition Station:selectedStationName];
    if(s != nil) {
        selectedStationLine = s.line.index;
		stationSelected=true;
        switch (cityMap.drawName) {
            case NAME_ALTERNATIVE:
                mainLabel.text = s.altText.string;
                break;
            case NAME_NORMAL:
                mainLabel.text = selectedStationName;
                break;
            case NAME_BOTH:
                // TODO which one should I prefer?
                mainLabel.text = selectedStationName;
                break;
        }
        Line *l = [cityMap.mapLines objectAtIndex:selectedStationLine-1];
        circleLabel.backgroundColor = l.color;
        lineLabel.text = l.shortName;
    } else {
        stationSelected=false;
    }
}

-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl {

    [foundPaths release];
    foundPaths = [[cityMap calcPath:fSt :sSt :fStl :sStl] retain];
    if([foundPaths count] > 0) {
        [self selectPath:0];
    } else {
        [foundPaths release];
        foundPaths = nil;
        // path not found
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoPathHeader", @"") message:NSLocalizedString(@"NoPathText", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"NoPathButton", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(void) clearPath
{
    [foundPaths release];
    foundPaths = nil;
    if([cityMap.activePath count] > 0) {
        [cityMap resetPath];
        // это недокументированный метод, так что если он в будущем изменится, то ой
        //[self.layer invalidateContents];
        //[self setNeedsDisplay];
        activeLayer.hidden = YES;
        midground1.hidden = YES;
        midground2.hidden = YES;
    }
}

-(int) pathsCount
{
    if(foundPaths != nil) return [foundPaths count];
    else return 0;
}

-(void) selectPath:(int)num
{
    NSArray *keys = [[foundPaths allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *pathArray = [foundPaths objectForKey:[keys objectAtIndex:num]];
    if(pathArray == nil || [pathArray count] == 0) return;

    [cityMap activatePath:pathArray];
    // это недокументированный метод, так что если он в будущем изменится, то ой
    //[self.layer invalidateContents];
	//[self setNeedsDisplay];
    activeLayer.hidden = NO;
    activeLayer.alpha = 0;
    midground1.hidden = NO;
    midground1.alpha = 0;
    midground2.hidden = NO;
    midground2.alpha = 1.f;
    [UIView animateWithDuration:0.5f animations:^(void) { activeLayer.alpha = 1.f; midground1.alpha = 1.f; midground2.alpha = 0.f; } completion:^(BOOL finish) { midground2.hidden = YES;
        [scrollView zoomToRect:cityMap.activeExtent animated:YES];
    }];

}

-(void)adjustMap
{
    activeLayer.hidden = NO;
    activeLayer.alpha = 0;
    midground1.hidden = NO;
    midground1.alpha = 0;
    midground2.hidden = NO;
    midground2.alpha = 1.f;
    [UIView animateWithDuration:0.5f animations:^(void) { activeLayer.alpha = 1.f; midground1.alpha = 1.f; midground2.alpha = 0.f; } completion:^(BOOL finish) { midground2.hidden = YES;
        [scrollView zoomToRect:cityMap.activeExtent animated:YES];
    }];    
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *) _scrollView{
    scrollView = _scrollView;
	return self;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    Scale = scale;
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //printf("offset is %d %d\n", (int)scrollView.contentOffset.x, (int)scrollView.contentOffset.y);
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(stationSelected) {
        stationSelected = NO;
    }
}

-(void) scrollViewDidZoom:(UIScrollView *)scrollView
{
    if(stationSelected) {
        stationSelected = NO;
    }
}

@end
