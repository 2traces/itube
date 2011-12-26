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


- (CGSize) size {
    return CGSizeMake(cityMap.w, cityMap.h);
}

- (id)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 100, 100)]) {
        // Initialization code

		DLog(@" InitMapView	initWithFrame; ");
		
		//близжайщней станции пока нет
		nearestStationName = @"";
        mapLayer = nil;
        pathLayer = nil;

		
		int scale;
		if ([self respondsToSelector:@selector(setContentScaleFactor:)])
		{
			scale = [[UIScreen mainScreen] scale];
		}
		self.contentScaleFactor = scale;
		self.layer.contentsScale = scale;

		cityMap = [[[CityMap alloc] init] retain];
        cityMap.view = self;
        Scale = 2.f;
        cityMap.koef = Scale;
		[cityMap loadMap:@"parisp"];
		drawPath = false;
        self.frame = CGRectMake(0, 0, cityMap.w, cityMap.h);
		
		mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,25)];
		mainLabel.font = [UIFont systemFontOfSize:12];
		//mainLabel.backgroundColor = [UIColor redColor];
		
		//метка которая показывает названия станций
		mainLabel.hidden=true;

		[self initData];
		
		selectedStationLayer = [[CALayer layer] retain];
		
		[self addSubview:mainLabel];
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

    if(mapLayer == nil) {
        CGSize size = CGSizeMake(cityMap.w, cityMap.h);
        mapLayer = CGLayerCreateWithContext(context, size, NULL);
        [self drawMapLayer:cityMap];
    }
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    //CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, CGContextGetClipBoundingBox(context));
    CGContextDrawLayerAtPoint(context, CGPointZero, mapLayer);
    
	if(pathLayer != nil && drawPath) {
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.5);
        CGContextFillRect(context, CGContextGetClipBoundingBox(context));
        CGContextDrawLayerAtPoint(context, CGPointZero, pathLayer);
    }
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
    if(mapLayer != nil) CGLayerRelease(mapLayer);
    mapLayer = CGLayerCreateWithContext(context, size, NULL);
    [self drawMapLayer:cityMap];

    if(drawPath) {
        if(pathLayer != nil) CGLayerRelease(pathLayer);
        pathLayer = CGLayerCreateWithContext(context, size, NULL);
        [self drawPathLayer :pathArray];
    }
}

- (void) drawMapLayer :(CityMap*) map 
{
    CGContextRef c2 = CGLayerGetContext(mapLayer);
    
    //CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    //CGContextSetShouldAntialias(context, true);
    //CGContextSetShouldSmoothFonts(cgContext, true);
    //CGContextSetAllowsFontSmoothing(context, true);       
    
    [map drawMap:c2];
    [map drawStations:c2]; 
    [map drawTransfers:c2];
}

- (void) drawPathLayer :(NSArray*) pathMap 
{
    if(pathLayer != nil) CGLayerRelease(pathLayer);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize size = CGSizeMake(cityMap.w, cityMap.h);
    pathLayer = CGLayerCreateWithContext(context, size, NULL);
    
	[cityMap drawPathMap:CGLayerGetContext(pathLayer) :pathMap];

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
	
	UIView *hitView = [self hitTest:currentPosition withEvent:event];
	
	if([hitView isKindOfClass:[UILabel class]]) {
		
		//[self checkGPSCoord:nil];
		[hitView becomeFirstResponder];
		stationSelected=true;
		CGRect frame = mainLabel.frame;
		frame.origin = currentPosition;
		mainLabel.frame = frame;
		
		mainLabel.hidden=false;
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
}

-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl {

    [pathArray removeAllObjects];
    [pathArray addObjectsFromArray:[cityMap calcPath:fSt :sSt :fStl :sStl]];
	[pathArray insertObject:[GraphNode nodeWithValue:[NSString stringWithFormat:@"%@|%d",fSt,fStl ] ] atIndex:0];
	
	[self drawPathLayer :pathArray];
		
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
		nearestStationName=new_station;

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
	};
	
}
 
#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *) scrollView{
	return self;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    const float MinScale = 0.15f;
    const float MaxScale = 2.f;
	if(scale == 1.f) return;
    Scale *= scale;
    cityMap.koef = Scale;
    if(Scale < MinScale) Scale = MinScale;
    if(Scale > MaxScale) Scale = MaxScale;
    
    [self updateLayers];

    CGPoint offset = scrollView.contentOffset;
    [scrollView setZoomScale:1.f animated:NO];
    [scrollView setMaximumZoomScale:MaxScale / Scale];
    [scrollView setMinimumZoomScale:MinScale / Scale];
    [scrollView setContentSize:CGSizeMake(cityMap.w, cityMap.h)];
    [scrollView setContentOffset:offset animated:NO];
    [self setNeedsDisplay];
}


@end
