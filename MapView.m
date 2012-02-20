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

@implementation MapView
@synthesize cityMap;
@synthesize mainLabel;
@synthesize selectedStationName;
@synthesize stationSelected;
@synthesize stationPath;
@synthesize selectedStationLine;
@synthesize nearestStationName;
@synthesize nearestStationImage;
@synthesize selectedStationLayer;
@synthesize Scale;
@synthesize MaxScale;
@synthesize MinScale;
@synthesize vcontroller;
@synthesize backgroundNormal = background1;
@synthesize backgroundDisabled = background2;
@synthesize backgroundVector;
@synthesize backgroundVectorDisabled = backgroundVector2;
@synthesize showVectorLayer;
@synthesize activeLayer;

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

-(void)setShowVectorLayer:(BOOL)_showVectorLayer
{
    if(showVectorLayer != _showVectorLayer) {
        showVectorLayer = _showVectorLayer;
        if(_showVectorLayer) {
            backgroundVector.hidden = background1.hidden;
            backgroundVector2.hidden = background2.hidden;
        } else {
            backgroundVector.hidden = YES;
            backgroundVector2.hidden = YES;
        }
        // это недокументированный метод, так что если он в будущем изменится, то ой
        [self.layer invalidateContents];
        [self setNeedsDisplay];
    }
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        [self.layer setLevelsOfDetail:5];
        [self.layer setLevelsOfDetailBias:2];
        for(int i=0; i<MAXCACHE; i++) cacheLayer[i] = nil;
        showVectorLayer = NO;

		DLog(@" InitMapView	initWithFrame; ");
		
		//близжайщней станции пока нет
		nearestStationName = @"";
        MinScale = 0.25f;
        MaxScale = 4.f;
        selectedStationName = [[NSMutableString alloc] init];
		
		int scale = 1;
		if ([self respondsToSelector:@selector(setContentScaleFactor:)])
		{
			scale = [[UIScreen mainScreen] scale];
            self.contentScaleFactor = scale;
            self.layer.contentsScale = scale;
		}

        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.cityMap = appDelegate.cityMap;
        // для ретиновских устройств перегенерируем предварительно отрисованные данные в двойном размере
        if(scale > 1) cityMap.predrawScale *= scale;
        
        self.frame = CGRectMake(0, 0, cityMap.w, cityMap.h);
        MinScale = MIN( (float)frame.size.width / cityMap.size.width, (float)frame.size.height / cityMap.size.height);
        MaxScale = cityMap.maxScale;
        Scale = MaxScale / 2;
        
		//метка которая показывает названия станций
		mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 27, 140, 25)];
		mainLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:21.0];
        mainLabel.textAlignment = UITextAlignmentCenter;
		mainLabel.backgroundColor = [UIColor clearColor];
        mainLabel.shadowColor = [UIColor whiteColor];
        mainLabel.shadowOffset = CGSizeMake(0.5f, 1.f);
        lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 27, 40, 25)];
        lineLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:21.f];
        lineLabel.textAlignment = UITextAlignmentCenter;
        lineLabel.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
        lineLabel.text = @"1";
        lineLabel.backgroundColor = [UIColor clearColor];
        lineLabel.shadowColor = [UIColor whiteColor];
        lineLabel.shadowOffset = CGSizeMake(0.5f, 1.f);
        circleLabel = [[UIView alloc] initWithFrame:CGRectMake(25, 23, 21, 21)];
        circleLabel.layer.cornerRadius = 11.f;
        circleLabel.backgroundColor = [UIColor redColor];
        [circleLabel addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"embossed_circle"]]];
        
        labelBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"station_label"]];
        [labelBg addSubview:mainLabel];
        [labelBg addSubview:lineLabel];
        [labelBg addSubview:circleLabel];
		labelBg.hidden=true;
        
		[self initData];
		
		selectedStationLayer = [[CALayer layer] retain];
        activeLayer = [[ActiveView alloc] initWithFrame:frame];
        activeLayer.hidden = YES;
        
        // make normal background image
        /*CGFloat backScale = MinScale * 2.f;
        CGSize minSize = CGSizeMake(cityMap.w * backScale, cityMap.h * backScale);
        CGRect r = CGRectMake(0, 0, minSize.width, minSize.height);
		UIGraphicsBeginImageContext(minSize);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
		//CGContextFillRect(context,r);
		CGContextScaleCTM(context, backScale, backScale);
        r.size.width /= backScale;
        r.size.height /= backScale;
        [cityMap drawMap:context inRect:r];
        [cityMap drawTransfers:context inRect:r];
        [cityMap drawStations:context inRect:r]; 
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        background1 = [[UIImageView alloc] initWithImage:img];
        background1.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        background1.contentMode = UIViewContentModeScaleAspectFit;

        // make disabled background image
        [cityMap activatePath:[NSArray array]];
		CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
		//CGContextFillRect(context,r);
        [cityMap drawMap:context inRect:r];
        [cityMap drawTransfers:context inRect:r];
        [cityMap drawStations:context inRect:r]; 
        img = UIGraphicsGetImageFromCurrentImageContext();
        background2 = [[UIImageView alloc] initWithImage:img];
        background2.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        background2.contentMode = UIViewContentModeScaleAspectFit;
        background2.hidden = YES;
        UIGraphicsEndImageContext();
        [cityMap resetPath];
        */
    }
    return self;
}

-(void) loadVectorLayer:(NSString *)file
{
    if(vectorLayer != nil) [vectorLayer release];
    vectorLayer = [[VectorLayer alloc] initWithFile:file];
    showVectorLayer = YES;
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
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    [backgroundVector release];
    backgroundVector = [[UIImageView alloc] initWithImage:img];
    backgroundVector.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    backgroundVector.contentMode = UIViewContentModeScaleAspectFit;
    backgroundVector.hidden = NO;
    UIGraphicsEndImageContext();
    /*
    //disabled vector background
    UIGraphicsBeginImageContext(minSize);
    context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,CGRectMake(0, 0, minSize.width, minSize.height));
    CGContextScaleCTM(context, backScale, backScale);
    vectorLayer.enabled = NO;
    [vectorLayer draw:context inRect:r];
    img = UIGraphicsGetImageFromCurrentImageContext();
    [backgroundVector2 release];
    backgroundVector2 = [[UIImageView alloc] initWithImage:img];
    backgroundVector2.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    backgroundVector2.contentMode = UIViewContentModeScaleAspectFit;
    backgroundVector2.hidden = NO;
    UIGraphicsEndImageContext();
    vectorLayer.enabled = YES;*/
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

- (void)dealloc {
    [vectorLayer release];
    [mainLabel release];
    [labelBg release];
    [super dealloc];
	[cityMap dealloc];
	[nearestStationImage release];
    for(int i=0; i<MAXCACHE; i++) CGLayerRelease(cacheLayer[i]);
    [background1 release];
    [background2 release];
    [backgroundVector release];
    [backgroundVector2 release];
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
    
    if(showVectorLayer && vectorLayer) [vectorLayer draw:context inRect:r];
    cityMap.currentScale = scrollView.zoomScale / MaxScale;
    [cityMap drawMap:ctx inRect:r];
    [cityMap drawTransfers:ctx inRect:r];
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
    NSLog(@"select station at");
    selectedStationLine = [cityMap checkPoint:currentPosition Station:selectedStationName];
    if(selectedStationLine > 0) {
		stationSelected=true;
		mainLabel.text = selectedStationName;
        Line *l = [cityMap.mapLines objectAtIndex:selectedStationLine-1];
        circleLabel.backgroundColor = l.color;
        lineLabel.text = l.shortName;
    } else {
        stationSelected=false;
    }
}

-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl {

    NSMutableArray *pathArray = [[NSMutableArray alloc] init];
    [pathArray addObjectsFromArray:[cityMap calcPath:fSt :sSt :fStl :sStl]];
	[pathArray insertObject:[GraphNode nodeWithName:fSt andLine:fStl ] atIndex:0];
	
    //vectorLayer.enabled = false;
    background1.hidden = YES;
    background2.hidden = NO;
    backgroundVector.hidden = YES;
    backgroundVector2.hidden = NO;
    [cityMap activatePath:pathArray];
    [scrollView zoomToRect:cityMap.activeExtent animated:YES];
    // это недокументированный метод, так что если он в будущем изменится, то ой
    //[self.layer invalidateContents];
	//[self setNeedsDisplay];
    activeLayer.hidden = NO;
    [pathArray release];
}

-(void) clearPath
{
    if([cityMap.activePath count] > 0) {
        //vectorLayer.enabled = true;
        background1.hidden = NO;
        background2.hidden = YES;
        backgroundVector.hidden = NO;
        backgroundVector2.hidden = YES;
        [cityMap resetPath];
        // это недокументированный метод, так что если он в будущем изменится, то ой
        //[self.layer invalidateContents];
        //[self setNeedsDisplay];
        activeLayer.hidden = YES;
    }
}

#pragma mark -
#pragma mark gps stuff 


-(NSString*) calcNearStations:(CLLocation*) new_location {
	//
	
	CLLocation *et = new_location;
	//расскоментировать для тестов
	//CLLocation *et = [[[CLLocation alloc] initWithLatitude:41.873917 longitude:1.294598] autorelease];
	//CLLocationManager *lm = [[[CLLocationManager alloc] init] autorelease];
	
	CLLocationDistance distance=-1;
	NSString* station=nil;
	
	
	for (NSString* key in cityMap.gpsCoords ) {
		CLLocation  *location = (CLLocation*)[cityMap.gpsCoords objectForKey:key];
		if (distance==-1)
		{
			distance = [location distanceFromLocation:et];
			station = key;
		}
		else {
			CLLocationDistance new_distance = [location distanceFromLocation:et];
			if (new_distance<distance)
			{
				distance=new_distance;
				station = key;
			}
		}
	}
	
	DLog(@"");
	//[lm ]
	return station;
} 

-(void) checkGPSCoord:(CLLocation*) new_location{
	NSString *new_station = [self calcNearStations:new_location];
	
	if (![new_station isEqualToString:nearestStationName])
	{
        // TODO remake
		/*nearestStationName=new_station;

		NSNumber *line = [cityMap.allStationsNames objectForKey:nearestStationName];
		
		NSMutableDictionary *allStations = [cityMap.stationsData objectAtIndex:[line intValue]];
		
		NSDictionary *stationData = [allStations objectForKey:nearestStationName];
		
		NSDictionary *coords = [stationData objectForKey:@"coord"];
		
		NSNumber *x = [coords objectForKey:@"x"];
		NSNumber *y = [coords objectForKey:@"y"];
		
		[selectedStationLayer removeFromSuperlayer];
		selectedStationLayer.frame = CGRectMake(0, 0, nearestStationImage.size.width, nearestStationImage.size.height);
		selectedStationLayer.contents=(id)[nearestStationImage CGImage];
 
	
		selectedStationLayer.position=CGPointMake([x floatValue],
													  [y floatValue]);
		
		[self.layer addSublayer:selectedStationLayer];
		[self setNeedsDisplay];
         */
	};
	
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
