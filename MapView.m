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

#define SIZE 5120
#define SCALE 20

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
    return CGSizeMake(SIZE, SIZE);
}

-(UIView*) labelView {
    return labelBg;
}

-(UIColor*) backgroundColor
{
    return [UIColor whiteColor];
}

-(void)redraw
{
    //NSLog(@"redraw map");
    //[self.layer invalidateContents];
    [self setNeedsDisplay];
}

-(void)redrawRect:(NSValue*)value
{
    CGRect rect = [value CGRectValue];
    [self setNeedsDisplayInRect:rect];
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
    CGPoint p = CGPointMake(newLocation.coordinate.longitude, newLocation.coordinate.latitude);
    p.x = p.x / 360.f + 0.5f;
    p.y = 1.f - (p.y / 360.f + 0.5f);
    while(p.x < 0.f) p.x += 1.f;
    while(p.x > 1.f) p.x -= 1.f;
    while(p.y < 0.f) p.y += 1.f;
    while(p.y > 1.f) p.y -= 1.f;
    p.x *= SIZE;
    p.y *= SIZE;
    selectedStationLayer.position = p;
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
    /*[vectorLayer draw:context inRect:r];
    [cityMap drawMap:context inRect:r];
    [cityMap drawTransfers:context inRect:r];
    [cityMap drawStations:context inRect:r]; 
    [vectorLayer2 draw:context inRect:r];
     */
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
        [self.layer setLevelsOfDetail:10];
        [self.layer setLevelsOfDetailBias:5];
        for(int i=0; i<MAXCACHE; i++) cacheLayer[i] = nil;

		DLog(@" InitMapView	initWithFrame; ");
		
		//близжайщней станции пока нет
		nearestStationName = @"";
        MinScale = 0.05f;
        MaxScale = 100.f;
        Scale = 0.05f;
        selectedStationName = [[NSMutableString alloc] init];
		
		int scale = 1;
		if ([self respondsToSelector:@selector(setContentScaleFactor:)])
		{
			scale = [[UIScreen mainScreen] scale];
            self.contentScaleFactor = scale;
            self.layer.contentsScale = scale;
		}

		//метка которая показывает названия станций
		mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 33, 220, 65)];
		mainLabel.font = [UIFont fontWithName:@"Arial" size:12.0];
        mainLabel.textAlignment = UITextAlignmentCenter;
		mainLabel.backgroundColor = [UIColor clearColor];
        mainLabel.shadowColor = [UIColor whiteColor];
        mainLabel.shadowOffset = CGSizeMake(0.5f, 1.f);
        mainLabel.lineBreakMode = UILineBreakModeWordWrap;
        mainLabel.numberOfLines = 3;
        lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, 220, 23)];
        lineLabel.font = [UIFont fontWithName:@"Arial" size:18.f];
        lineLabel.textAlignment = UITextAlignmentCenter;
        lineLabel.textColor = [UIColor whiteColor];
        lineLabel.text = @"";
        lineLabel.backgroundColor = [UIColor clearColor];
        //lineLabel.shadowColor = [UIColor whiteColor];
        //lineLabel.shadowOffset = CGSizeMake(0.5f, 1.f);
        /*circleLabel = [[UIView alloc] initWithFrame:CGRectMake(25, 23, 21, 21)];
        circleLabel.layer.cornerRadius = 11.f;
        circleLabel.backgroundColor = [UIColor redColor];
        [circleLabel addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"embossed_circle"]]];
         */
        
        labelBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box"]];
        [labelBg addSubview:mainLabel];
        [labelBg addSubview:lineLabel];
        //[labelBg addSubview:circleLabel];
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
        
        //timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(redraw) userInfo:nil repeats:YES];
        //[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

    }
    return self;
}

-(void)setCityMap:(CityMap *)_cityMap
{
    self.frame = CGRectMake(0, 0, SIZE, SIZE);
    /*[cityMap release];
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
     */
    if(rasterLayer == nil) {
        rasterLayer = [[RasterLayer alloc] initWithRect:self.frame];
        [rasterLayer setSignal:self selector:@selector(redrawRect:)];
    }
    
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

- (void)dealloc {
    [timer release];
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
	//[cityMap release];
	[nearestStationImage release];
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
    CGFloat drawScale = 256.f / MAX(r.size.width, r.size.height);
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
    
    /*if(vectorLayer) [vectorLayer draw:context inRect:r];
    cityMap.currentScale = scrollView.zoomScale / MaxScale;
    [cityMap drawMap:ctx inRect:r];
    [cityMap drawTransfers:ctx inRect:r];
    if(vectorLayer2) [vectorLayer2 draw:context inRect:r];
    [cityMap drawStations:ctx inRect:r]; 
     */
    [rasterLayer draw:context inRect:r withScale:Scale*SCALE];

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
    if([rasterLayer checkPoint:currentPosition]) {
        NSLog(@"select object №%d %@", rasterLayer.currentObjectNumber, rasterLayer.currentObject.name);
        stationSelected = YES;
        lineLabel.text = rasterLayer.currentObject.name;
		mainLabel.text = rasterLayer.currentObject.description;
    } else {
        stationSelected = NO;
    }
    /*selectedStationLine = [cityMap checkPoint:currentPosition Station:selectedStationName];
    if(selectedStationLine > 0) {
		stationSelected=true;
		mainLabel.text = selectedStationName;
        Line *l = [cityMap.mapLines objectAtIndex:selectedStationLine-1];
        circleLabel.backgroundColor = l.color;
        lineLabel.text = l.shortName;
    } else {
        stationSelected=false;
    }*/
}

-(void) findPathFrom :(NSString*) fSt To:(NSString*) sSt FirstLine:(NSInteger) fStl LastLine:(NSInteger)sStl {

    /*[foundPaths release];
    foundPaths = [[cityMap calcPath:fSt :sSt :fStl :sStl] retain];
    if([foundPaths count] > 0) {
        [self selectPath:0];
    } else {
        [foundPaths release];
        foundPaths = nil;
    }
     */
}

-(void) clearPath
{
    /*[foundPaths release];
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
     */
}

-(int) pathsCount
{
    if(foundPaths != nil) return [foundPaths count];
    else return 0;
}

-(void) selectPath:(int)num
{
    /*NSArray *keys = [[foundPaths allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *pathArray = [foundPaths objectForKey:[keys objectAtIndex:num]];
    if(pathArray == nil || [pathArray count] == 0) return;

    [cityMap activatePath:pathArray];
    [scrollView zoomToRect:cityMap.activeExtent animated:YES];
    // это недокументированный метод, так что если он в будущем изменится, то ой
    //[self.layer invalidateContents];
	//[self setNeedsDisplay];
    activeLayer.hidden = NO;
    activeLayer.alpha = 0;
    midground1.hidden = NO;
    midground1.alpha = 0;
    midground2.hidden = NO;
    midground2.alpha = 1.f;
    [UIView animateWithDuration:0.5f animations:^(void) { activeLayer.alpha = 1.f; midground1.alpha = 1.f; midground2.alpha = 0.f; } completion:^(BOOL finish) { midground2.hidden = YES; }];
     */
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *) _scrollView{
    scrollView = _scrollView;
	return self;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    int z = 0;
    if (scale < Scale) z = -1;
    if (scale > Scale) z = 1;
    rasterLayer.cacheZoom = z;
    Scale = scale;
    if([rasterLayer checkLevel:Scale*SCALE]) {
        [rasterLayer stopLoadingBut:Scale*SCALE];
        [self redraw];
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGPoint offset = scrollView.contentOffset;
    float dx = offset.x - oldOffset.x;
    float dy = offset.y - oldOffset.y;
    if(fabs(dx) > fabs(dy)) {
        if(dx > 0) rasterLayer.cacheDirection = 1;
        else rasterLayer.cacheDirection = 3;
    } else {
        if(dy > 0) rasterLayer.cacheDirection = 2;
        else rasterLayer.cacheDirection = 4;
    }
    oldOffset = offset;
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

-(BOOL) changeSource
{
    BOOL r = [rasterLayer changeSource];
    [self.layer invalidateContents];
    [self setNeedsDisplay];
    return r;
}

@end
