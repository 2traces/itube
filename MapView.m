//
//  MapView.m
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapView.h"
#import "CityMap.h"
#import "CatmullRomSpline.h"
#import <Foundation/Foundation.h>
//#import <CoreText/CoreText.h>


@implementation MapView
@synthesize cityMap;
@synthesize drawPath;
@synthesize mainLabel;
@synthesize selectedStationName;
@synthesize stationSelected;
@synthesize stationPath;
@synthesize selectedStationLine;
@synthesize nearestStationName;
@synthesize nearestStationImage;
@synthesize selectedStationLayer;
@synthesize Scale;

+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (CGSize) size {
    return CGSizeMake(cityMap.w, cityMap.h);
}

- (CGFloat) MaxScale {
    return MaxScale / Scale;
}

- (CGFloat) MinScale {
    return MinScale / Scale;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        [self.layer setLevelsOfDetail:5];
        [self.layer setLevelsOfDetailBias:2];

		DLog(@" InitMapView	initWithFrame; ");
		
        updateComplete = NO;
		//близжайщней станции пока нет
		nearestStationName = @"";
        mapLayer = nil;
        pathLayer = nil;
        pathArray = [[NSMutableArray alloc] init];
        MinScale = 0.15f;
        MaxScale = 4.f;
        selectedStationName = [[NSMutableString alloc] init];
        drawLock = [[NSConditionLock alloc] init];
		
		int scale;
		if ([self respondsToSelector:@selector(setContentScaleFactor:)])
		{
			scale = [[UIScreen mainScreen] scale];
		}
		self.contentScaleFactor = scale;
		self.layer.contentsScale = scale;

		cityMap = [[[CityMap alloc] init] retain];
        cityMap.view = self;
        Scale = 2.0f;
        cityMap.koef = Scale;
		[cityMap loadMap:@"parisp"];
		drawPath = false;
        self.frame = CGRectMake(0, 0, cityMap.w, cityMap.h);
        MinScale = MIN( (float)frame.size.width / cityMap.size.width, (float)frame.size.height / cityMap.size.height);
		
		mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,100,100,25)];
		mainLabel.font = [UIFont systemFontOfSize:12];
        mainLabel.textAlignment = UITextAlignmentCenter;
		mainLabel.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.9f];
		
		//метка которая показывает названия станций
		mainLabel.hidden=true;

		[self initData];
		
		selectedStationLayer = [[CALayer layer] retain];
		
		[self addSubview:mainLabel];

        NSTimer *myTimer = [NSTimer timerWithTimeInterval:0.1f target:self selector:@selector(postUpdate:) userInfo:nil repeats:YES];                                                      
        [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes];
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [self drawLayer:nil inContext:UIGraphicsGetCurrentContext()];
}

- (void)dealloc {
    [super dealloc];
    CGLayerRelease(mapLayer);
    CGLayerRelease(pathLayer);
	[cityMap dealloc];
	[nearestStationImage release];
    [pathArray release];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {

    if(mainLabel.superview == self) [self.superview addSubview:mainLabel];
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, CGContextGetClipBoundingBox(context));

    [cityMap drawMap:context];
    [cityMap drawTransfers:context];
    [cityMap drawStations:context]; 

    /*if(mapLayer == nil) {
        CGSize size = CGSizeMake(cityMap.w, cityMap.h);
        mapLayer = CGLayerCreateWithContext(context, size, NULL);
        [self drawMap:cityMap toLayer:mapLayer];
    }
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    //CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, CGContextGetClipBoundingBox(context));
    CGContextDrawLayerAtPoint(context, CGPointZero, mapLayer);
    
	if(pathLayer != nil && drawPath) {
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.7);
        CGContextFillRect(context, CGContextGetClipBoundingBox(context));
        CGContextDrawLayerAtPoint(context, CGPointZero, pathLayer);
    }*/
}

-(void) initData {
	nearestStationImage = [[UIImage imageWithContentsOfFile: 
						   [[NSBundle mainBundle] pathForResource:@"select_near_station" ofType:@"png"]]retain];

}

#pragma mark -
#pragma mark Draw Map Stuff 

- (void)viewDidLoad 
{
    //[super viewDidLoad];
    DLog(@"viewDidLoad mapView\n");
}

-(void) updateLayers
{
    CGSize size = CGSizeMake(cityMap.w, cityMap.h);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGLayerRef mapLayer2 = CGLayerCreateWithContext(context, size, NULL);
    [self drawMap:cityMap toLayer:mapLayer2];
    if(mapLayer != nil) CGLayerRelease(mapLayer);
    mapLayer = mapLayer2;
    //CGSize ss = CGLayerGetSize(mapLayer);
    //printf("%d:%d\n", (int)ss.width, (int)ss.height);
    if(drawPath) {
        CGLayerRef pathLayer2 = CGLayerCreateWithContext(context, size, NULL);
        [self drawPath:pathArray toLayer:pathLayer2];
        if(pathLayer != nil) CGLayerRelease(pathLayer);
        pathLayer = pathLayer2;
    }
}

- (void) drawMap :(CityMap*) map toLayer:(CGLayerRef)layer
{
    CGContextRef c2 = CGLayerGetContext(layer);
    
    //CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    //CGContextSetShouldAntialias(context, true);
    //CGContextSetShouldSmoothFonts(cgContext, true);
    //CGContextSetAllowsFontSmoothing(context, true);       
    
    [map drawMap:c2];
    [map drawTransfers:c2];
    [map drawStations:c2]; 
}

- (void) drawPath :(NSArray*) pathMap toLayer:(CGLayerRef)layer
{
    if(layer == nil) {
        CGSize size;
        if(pathLayer != nil) {
            CGLayerRelease(pathLayer);
        }
        CGContextRef context = UIGraphicsGetCurrentContext();
        size = CGSizeMake(cityMap.w, cityMap.h);
        pathLayer = CGLayerCreateWithContext(context, size, NULL);
        [cityMap drawPathMap:CGLayerGetContext(pathLayer) :pathMap];
    } else {
        CGContextRef context = CGLayerGetContext(layer);
        CGContextClearRect(context, CGContextGetClipBoundingBox(context));
        [cityMap drawPathMap:context :pathMap];
    }
}

#pragma mark -
#pragma mark CGDraw Functions




#pragma mark -
#pragma mark -
// CG helpers end 

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
	mainLabel.hidden=true;
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
    CGPoint superPosition = [touch locationInView:self.superview];
	
    selectedStationLine = [cityMap checkPoint:currentPosition Station:selectedStationName];
    
    if(selectedStationLine > 0) {
		stationSelected=true;
		CGRect frame = mainLabel.frame;
		frame.origin = CGPointMake(superPosition.x - frame.size.width/2, superPosition.y - frame.size.height - 30);
        printf("pos x=%d y=%d\n", (int) frame.origin.x, (int) frame.origin.y);
		mainLabel.frame = frame;
		mainLabel.hidden=false;
		mainLabel.text = selectedStationName;
        [self bringSubviewToFront:mainLabel];
    } else {
        stationSelected=false;
		mainLabel.hidden=true;
    }
    
	/*UIView *hitView = [self hitTest:currentPosition withEvent:event];
	
	if([hitView isKindOfClass:[UILabel class]]) {
		
		//[self checkGPSCoord:nil];
		[hitView becomeFirstResponder];
		stationSelected=true;
		CGRect frame = mainLabel.frame;
		frame.origin = CGPointMake(currentPosition.x - frame.size.width/2, currentPosition.y - frame.size.height - 30);
		mainLabel.frame = frame;
		
		mainLabel.hidden=false;
        [self bringSubviewToFront:mainLabel];
		selectedStationName = ((UILabel*)hitView).text;
		selectedStationLine = ((UILabel*)hitView).tag;
		
		mainLabel.text = selectedStationName;
		DLog(@" under label ");
		DLog(@" %@",((UILabel*)hitView).text);
	}
	else {
		stationSelected=false;
		mainLabel.hidden=true;
	}

	DLog(@" !!!!!! ");
     */
}

-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl {

    [pathArray removeAllObjects];
    [pathArray addObjectsFromArray:[cityMap calcPath:fSt :sSt :fStl :sStl]];
	[pathArray insertObject:[GraphNode nodeWithValue:[NSString stringWithFormat:@"%@|%d",fSt,fStl ] ] atIndex:0];
	
	[self drawPath :pathArray toLayer:pathLayer];
		
	drawPath=true;

	[self setNeedsDisplay];
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *) scrollView{
	return self;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)_scrollView withView:(UIView *)view atScale:(float)scale
{
	if(scale == 1.f) return;
    Scale *= scale;
    if(Scale < MinScale) Scale = MinScale;
    if(Scale > MaxScale) Scale = MaxScale;

    [scrollView setZoomScale:1.f animated:NO];
    [scrollView setMaximumZoomScale:MaxScale / Scale];
    [scrollView setMinimumZoomScale:MinScale / Scale];
    self.layer.sublayerTransform = CATransform3DMakeScale(scale, scale, 1.0);
    return;
    
    cityMap.koef = Scale;
    scrollView = _scrollView;
    /*
    [self updateLayers];
    
    CGPoint offset = scrollView.contentOffset;
    [scrollView setZoomScale:1.f animated:NO];
    [scrollView setMaximumZoomScale:MaxScale / Scale];
    [scrollView setMinimumZoomScale:MinScale / Scale];
    [scrollView setContentSize:CGSizeMake(cityMap.w, cityMap.h)];
    [scrollView setContentOffset:offset animated:NO];
    [self setNeedsDisplay];
    */
    NSLog(@"zoom event");
    [drawLock lockWhenCondition:0];
    [drawLock unlockWithCondition:1];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //printf("offset is %d %d\n", (int)scrollView.contentOffset.x, (int)scrollView.contentOffset.y);
}

-(void)drawThread
{
    while(YES) {
        [drawLock lockWhenCondition:1];
        [drawLock unlockWithCondition:0];
        
        [self updateLayers];
        updateComplete = YES;
        NSLog(@"draw update");
    }
}

-(void)postUpdate:(NSTimer*)timer
{
    if(updateComplete) {
        CGPoint offset = scrollView.contentOffset;
        [scrollView setZoomScale:1.f animated:NO];
        [scrollView setMaximumZoomScale:MaxScale / Scale];
        [scrollView setMinimumZoomScale:MinScale / Scale];
        [scrollView setContentSize:CGSizeMake(cityMap.w, cityMap.h)];
        [scrollView setContentOffset:offset animated:NO];
        [self setNeedsDisplay];
        updateComplete = NO;
        NSLog(@"post update");
    }
}

@end
