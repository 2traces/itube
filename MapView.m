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
@synthesize background;

+ (Class)layerClass
{
    return [MyTiledLayer class];
}

- (CGSize) size {
    return CGSizeMake(cityMap.w, cityMap.h);
}

-(UIView*) labelView {
    return labelBg;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        [self.layer setLevelsOfDetail:5];
        [self.layer setLevelsOfDetailBias:2];
        for(int i=0; i<MAXCACHE; i++) cacheLayer[i] = nil;

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
        Scale = 1.f;//MaxScale / 2;
		
		//метка которая показывает названия станций
		mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,10,150,25)];
		mainLabel.font = [UIFont systemFontOfSize:12];
        mainLabel.textAlignment = UITextAlignmentCenter;
		mainLabel.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.9f];
        
        labelBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"station_label"]];
        [labelBg addSubview:mainLabel];
		labelBg.hidden=true;
        [labelBg.layer setShadowOffset:CGSizeMake(3, 5)];
        [labelBg.layer setShadowOpacity:0.3];
        [labelBg.layer setShadowRadius:5.0];
        
		[self initData];
		
		selectedStationLayer = [[CALayer layer] retain];
        
        // make background image
        CGFloat backScale = MinScale * 2.f;
        CGSize minSize = CGSizeMake(cityMap.w * backScale, cityMap.h * backScale);
        CGRect r = CGRectMake(0, 0, minSize.width, minSize.height);
		UIGraphicsBeginImageContext(minSize);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
		CGContextFillRect(context,r);
		CGContextSaveGState(context);
		CGContextScaleCTM(context, backScale, backScale);
        r.size.width /= backScale;
        r.size.height /= backScale;
        [cityMap drawMap:context inRect:r];
        [cityMap drawTransfers:context inRect:r];
        [cityMap drawStations:context inRect:r]; 
		CGContextRestoreGState(context);
		background = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

    }
    return self;
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
    [mainLabel release];
    [labelBg release];
    [super dealloc];
	[cityMap dealloc];
	[nearestStationImage release];
    for(int i=0; i<MAXCACHE; i++) CGLayerRelease(cacheLayer[i]);
    [background release];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {

    CGContextSaveGState(context);
    CGRect r = CGContextGetClipBoundingBox(context);
    CGFloat drawScale = 512.f / MAX(r.size.width, r.size.height);
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, r);

#ifdef AGRESSIVE_CACHE
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

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
    [self hideLabel];
	[[self superview] touchesEnded:touches withEvent:event];
	//[self.nextResponder touchesEnded:touches withEvent:event];
	DLog(@" touch 1 ");
	DLog(@"  %@ ",[self superview] );
}

- (void) drawString: (NSString*) s withFont: (UIFont*) font inRect: (CGRect) contextRect {
	
    CGFloat fontHeight = font.pointSize;
    CGFloat yOffset = (contextRect.size.height - fontHeight) / 2.0;
	
    CGRect textRect = CGRectMake(0, yOffset, contextRect.size.width, fontHeight);
	
    [s drawInRect: textRect withFont: font lineBreakMode: UILineBreakModeWordWrap 
		alignment: UITextAlignmentCenter];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	DLog(@" touchCancelled");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[[self superview] touchesMoved:touches withEvent:event];

	UITouch *touch = [touches anyObject];
	CGPoint currentPosition = [touch locationInView:self];
    CGPoint superPosition = [touch locationInView:labelBg.superview];
	
    selectedStationLine = [cityMap checkPoint:currentPosition Station:selectedStationName];
    
    if(selectedStationLine > 0) {
		stationSelected=true;
		CGRect frame = labelBg.frame;
		frame.origin = CGPointMake(superPosition.x - frame.size.width/2, superPosition.y - frame.size.height - 30);
        printf("pos x=%d y=%d\n", (int) frame.origin.x, (int) frame.origin.y);
		labelBg.frame = frame;
		mainLabel.text = selectedStationName;
        [self showLabel];
    } else {
        stationSelected=false;
        [self hideLabel];
    }
}

-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl {

    NSMutableArray *pathArray = [[NSMutableArray alloc] init];
    [pathArray addObjectsFromArray:[cityMap calcPath:fSt :sSt :fStl :sStl]];
	[pathArray insertObject:[GraphNode nodeWithValue:[NSString stringWithFormat:@"%@|%d",fSt,fStl ] ] atIndex:0];
	
    [cityMap activatePath:pathArray];
    [scrollView zoomToRect:cityMap.activeExtent animated:YES];
    // это недокументированный метод, так что если он в будущем изменится, то ой
    [self.layer invalidateContents];
	[self setNeedsDisplay];
    [pathArray release];
}

-(void) clearPath
{
    if([cityMap.activePath count] > 0) {
        [cityMap resetPath];
        // это недокументированный метод, так что если он в будущем изменится, то ой
        [self.layer invalidateContents];
        [self setNeedsDisplay];
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

@end
