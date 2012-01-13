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

+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (CGSize) size {
    return CGSizeMake(cityMap.w, cityMap.h);
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        [self.layer setLevelsOfDetail:5];
        [self.layer setLevelsOfDetailBias:2];

		DLog(@" InitMapView	initWithFrame; ");
		
		//близжайщней станции пока нет
		nearestStationName = @"";
        MinScale = 0.25f;
        MaxScale = 4.f;
        selectedStationName = [[NSMutableString alloc] init];
		
		int scale;
		if ([self respondsToSelector:@selector(setContentScaleFactor:)])
		{
			scale = [[UIScreen mainScreen] scale];
            self.contentScaleFactor = scale;
            self.layer.contentsScale = scale;
		}

		cityMap = [[CityMap alloc] init];
        Scale = 2.0f;
		[cityMap loadMap:@"parisp"];
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
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [self drawLayer:nil inContext:UIGraphicsGetCurrentContext()];
}

- (void)dealloc {
    [super dealloc];
	[cityMap dealloc];
	[nearestStationImage release];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {

    if(mainLabel.superview == self) [self.superview addSubview:mainLabel];
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGRect r = CGContextGetClipBoundingBox(context);
	CGContextFillRect(context, r);

    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextSetShouldAntialias(context, true);
    CGContextSetShouldSmoothFonts(context, false);
    CGContextSetAllowsFontSmoothing(context, false);
    
    CGFloat drawScale = 256.f / MAX(r.size.width, r.size.height);

    [cityMap drawMap:context inRect:r];
    [cityMap drawTransfers:context inRect:r];
    // слишком мелко тексты не рисуем
    if(drawScale > 0.5f) [cityMap drawStations:context inRect:r]; 
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
}

-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl {

    NSMutableArray *pathArray = [[NSMutableArray alloc] init];
    [pathArray addObjectsFromArray:[cityMap calcPath:fSt :sSt :fStl :sStl]];
	[pathArray insertObject:[GraphNode nodeWithValue:[NSString stringWithFormat:@"%@|%d",fSt,fStl ] ] atIndex:0];
	
    [cityMap activatePath:pathArray];
		
	[self setNeedsDisplay];
    [pathArray release];
}

-(void) clearPath
{
    [cityMap resetPath];
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    Scale = scale;
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //printf("offset is %d %d\n", (int)scrollView.contentOffset.x, (int)scrollView.contentOffset.y);
}

@end
