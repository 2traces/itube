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
@synthesize drawedStations;
@synthesize drawPath;
@synthesize mainLabel;
@synthesize stationNameTemp;
@synthesize stationSelected;
@synthesize stationPath;
@synthesize stationLineTemp;
@synthesize labelPlaced;
@synthesize selectedMap;
@synthesize drawedMap,drawedPath,drawedMap2,drawedMap3,drawedMap4;
@synthesize mapLayer,selectedPathLayer;
@synthesize nearestStationName;
@synthesize nearestStationImage;
@synthesize selectedStationLayer;
@synthesize images;

int const imagesCount = 4;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code

		DLog(@" InitMapView	initWithFrame; ");
		
		//близжайщней станции пока нет
		nearestStationName = @"";
		drawedStations =  [[NSMutableDictionary alloc] init];

		
		int scale;
		if ([self respondsToSelector:@selector(setContentScaleFactor:)])
		{
			scale = [[UIScreen mainScreen] scale];
		}
		

		self.contentScaleFactor = scale;
		self.layer.contentsScale = scale;

		images = [[NSMutableArray alloc] init];
		
		cityMap = [[[CityMap alloc] init] retain];
		[cityMap initMap:@"parisp"];
		drawPath = false;
		
		mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,25)];
		mainLabel.font = [UIFont systemFontOfSize:12];
		//mainLabel.backgroundColor = [UIColor redColor];
		
		//метка которая показывает названия станций
		mainLabel.hidden=true;
		//обе метки с названиями еще не выставлены
		labelPlaced = false;

		/*
		drawedMap = [[self drawToImage :cityMap] retain];
		
		drawedMap2 = [[MapView resizedImageWithContentMode:UIViewContentModeScaleAspectFill 
								imageToScale:drawedMap  
									  bounds:CGSizeMake(1700, 1700) 
						interpolationQuality:kCGInterpolationHigh] retain];
		
		drawedMap3 = [[MapView resizedImageWithContentMode:UIViewContentModeScaleAspectFill 
											  imageToScale:drawedMap  
													bounds:CGSizeMake(1200, 1200) 
									  interpolationQuality:kCGInterpolationHigh] retain];
				
		drawedMap4 = [[MapView resizedImageWithContentMode:UIViewContentModeScaleAspectFill 
											  imageToScale:drawedMap  
													bounds:CGSizeMake(900, 900) 
									  interpolationQuality:kCGInterpolationHigh] retain];
		
		 */
		[self initData];
		[self makeImages];
		
		selectedMap = [[SelectedPathMap alloc] initWithFrame:CGRectMake(0, 0, cityMap.w, cityMap.h)];
		selectedMap.userInteractionEnabled=YES;
		
		
//
		//[self saveImage:drawedMap4];
	//	[self saveImage:drawedMap];		
		//init layer's

		selectedStationLayer = [[CALayer layer] retain];
		
		selectedPathLayer = [[CALayer layer] retain];
		selectedPathLayer.frame = CGRectMake(0, 0, cityMap.w, cityMap.h);
		//selectedPathLayer.contentsScale = scale;
		
		mapLayer = [[CALayer layer] retain];
		mapLayer.contentsScale = scale;
		//mapLayer =  (CATiledLayer *) [self layer];
		//mapLayer.frame = CGRectMake(0, 0, cityMap.w, cityMap.h);
		mapLayer.bounds = self.frame;
		mapLayer.frame = CGRectMake(0, 0, cityMap.w, cityMap.h);
		mapLayer.contents=(id)[[images objectAtIndex:0] CGImage];
		mapLayer.contentsRect = CGRectMake(0,0,1,1);
	//	mapLayer.delegate = self;
		
		
		//tiledLayer.anchorPoint = CGPointMake(0.0f, 1.0f);
	//	mapLayer.bounds = self.bounds;
		
		//self.layer.opaque = true;
		
		[self.layer addSublayer:mapLayer];
		[self.layer addSublayer:selectedPathLayer];
//		[mapLayer setNeedsDisplay];
		
		//UIImage *im = [[UIImage alloc] init];
		//im = [self drawToImage:im :cityMap];
		//[im drawInRect:CGRectMake(0,0,100,100)];
		[self addSubview:mainLabel];
    }
    return self;
}

- (void) makeImages {
	
	float deltaw = (cityMap.w )/ (imagesCount+1);
	float deltah = (cityMap.h )/ (imagesCount+1);	
	
	UIImage *temp = [self drawToImage :cityMap];
	
	for (int i=0; i<imagesCount-1; i++) {
		[images insertObject: 
		[MapView resizedImageWithContentMode:UIViewContentModeScaleAspectFill 
								 imageToScale:temp  
									   bounds:CGSizeMake(deltaw*(i+1), deltah*(i+1)) 
						 interpolationQuality:kCGInterpolationHigh]
		 atIndex:0];
	}
	[images insertObject:temp atIndex:0];

}

- (void)dealloc {
    [super dealloc];
	[cityMap dealloc];
	[drawedStations dealloc];
	[drawedMap4 dealloc];	
	[drawedMap3 dealloc];	
	[drawedMap2 dealloc];
	[drawedMap dealloc];
	[drawedPath dealloc];
	[mapLayer release];
	[selectedPathLayer release];
	[nearestStationImage release];
}

- (void)drawLayer:(CALayer *)layer 
        inContext:(CGContextRef)context {

	/*CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(context, 
					  CGContextGetClipBoundingBox(context));
	 */
	//[self drawMap:context :cityMap];
	
	
}

-(void) initData {
	nearestStationImage = [[UIImage imageWithContentsOfFile: 
						   [[NSBundle mainBundle] pathForResource:@"select_near_station" ofType:@"png"]]retain];

}

#pragma mark -
#pragma mark Draw Map Stuff 

-(void) drawSelectedMap  {
	[self addSubview:selectedMap];
}

- (void)viewDidLoad 
{
    //[super viewDidLoad];
    DLog(@"viewDidLoad mapView\n");
}

- (UIImage *) drawToImage :(CityMap*) map {
	

	if (UIGraphicsBeginImageContextWithOptions != NULL) {
		DLog(@" retina");
//		UIGraphicsBeginImageContextWithOptions(CGSizeMake(cityMap.w, cityMap.h), NO, 0.0);
        UIGraphicsBeginImageContext(CGSizeMake(cityMap.w, cityMap.h));							
	}
    else {
        UIGraphicsBeginImageContext(CGSizeMake(cityMap.w, cityMap.h));					
    }

	CGContextRef context = UIGraphicsGetCurrentContext();		
	
	// push context to make it current 
	// (need to do this manually because we are not drawing in a UIView)
	//
	UIGraphicsPushContext(context);						

	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, CGRectMake(0,0,cityMap.w,cityMap.h));

	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	
	//CGContextSetShouldAntialias(context, true);
	//CGContextSetShouldSmoothFonts(cgContext, true);
	//CGContextSetAllowsFontSmoothing(context, true);
	
	
	// drawing code comes here- look at CGContext reference
	// for available operations
	//
	// this example draws the inputImage into the context
	//
    [drawedStations removeAllObjects];
	[map drawMap:context];
	labelPlaced=true;
	[self processTransfers:context];

	//[inputImage drawInRect:CGRectMake(0, 0, width, height)];
	
	// pop context 
	//
	UIGraphicsPopContext();								
	
	// get a UIImage from the image context- enjoy!!!
	//
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// clean up drawing environment
	//
	UIGraphicsEndImageContext();
 	return outputImage;
	
	/*CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	 
	 // create the bitmap context
	 CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
	 0, colorSpace,
	 // this will give us an optimal BGRA format for the device:
	 (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	 CGColorSpaceRelease(colorSpace);
*/
	

	
//CGImageRef bgimage = [image CGImage];
	/*
	float width = cityMap.w;
	float height = cityMap.h;
	
	// Create a temporary texture data buffer
	void *data = malloc(width * height * 4);
	
	// Draw image to buffer
	CGContextRef ctx = CGBitmapContextCreate(data,
											 width,
											 height,
											 8,
											 width * 4,
											 CGColorSpaceCreateDeviceRGB(),
											 kCGImageAlphaPremultipliedLast);
	//CGContextDrawImage(ctx, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height), bgimage);
	
	[self drawMap:ctx :map];
	
	// write it to a new image
	CGImageRef cgimage = CGBitmapContextCreateImage(ctx);
	UIImage *newImage = [UIImage imageWithCGImage:cgimage];
	CFRelease(cgimage);
	CGContextRelease(ctx);
	
	// auto-released
	return newImage;
	*/
	 

}

- (UIImage *) drawPathToImage :(NSArray*) pathMap {
	
// max 1024 due to Core Graphics limitations
			// input image to be composited over new image as example
	
	// create a new bitmap image context
	//
	if (UIGraphicsBeginImageContextWithOptions != NULL) {
		DLog(@" retina");
		//UIGraphicsBeginImageContextWithOptions(CGSizeMake(cityMap.w, cityMap.h), NO, 0.0);
		UIGraphicsBeginImageContext(CGSizeMake(cityMap.w, cityMap.h));							
	}
	else {
		UIGraphicsBeginImageContext(CGSizeMake(cityMap.w, cityMap.h));					
	}
	

	// get context
	//
	CGContextRef context = UIGraphicsGetCurrentContext();		
	
	// push context to make it current 
	// (need to do this manually because we are not drawing in a UIView)
	//
	UIGraphicsPushContext(context);								

//	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
//	CGContextFillRect(context, CGRectMake(0,0,cityMap.w,cityMap.h));
	
	CGContextSetRGBFillColor (context, 1, 1, 1, 0.5); 
	CGContextFillRect(context, CGRectMake(0,0,cityMap.w,cityMap.h));
	
	// drawing code comes here- look at CGContext reference
	// for available operations
	//
	// this example draws the inputImage into the context
	//
	[self drawPathMap:context :pathMap];
	
	// pop context 
	UIGraphicsPopContext();								
	
	// get a UIImage from the image context- enjoy!!!
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// clean up drawing environment
	UIGraphicsEndImageContext();
	
	return outputImage;
}



// рисует часть карты
-(void) drawPathMap:(CGContextRef) context :(NSArray*) pathMap {
	
	[drawedStations removeAllObjects];

	//for each line
	int count_ = [pathMap count];
	for (int i=0; i< count_; i++) {
		
		NSString *rawSrting1 = (NSString*)[[pathMap objectAtIndex:i] value];
		NSArray *el1  = [rawSrting1 componentsSeparatedByString:@"|"];
		NSString *stationName1 = [el1 objectAtIndex:0];
		NSInteger lineNum1 = [[el1 objectAtIndex:1] intValue]; 

		if ((i+1)!=count_)
		{
			NSString *rawSrting2 = (NSString*)[[pathMap objectAtIndex:i+1] value];
			NSArray *el2  = [rawSrting2 componentsSeparatedByString:@"|"];
			NSString *stationName2 = [el2 objectAtIndex:0];
			NSInteger lineNum2 = [[el2 objectAtIndex:1] intValue]; 
			
			//NSArray *lineCoord = [NSArray arrayWithArray:[cityMap.linesCoord objectAtIndex:lineNum-1]];
			NSArray *lineColor = [NSArray arrayWithArray:[cityMap.linesColors objectAtIndex:lineNum1-1]];
			
			if (lineNum1==lineNum2)
			{
				NSDictionary *lineStations = [cityMap.stationsData objectAtIndex:lineNum1-1];
				//			NSArray *lineStationNames = [[NSArray alloc] initWithObjects:stationName1,nil];			
				
				NSDictionary* stationDict1 = [lineStations objectForKey:stationName1];
				NSDictionary* stationDict2 = [lineStations objectForKey:stationName2];				

				NSDictionary* coords = [stationDict1 objectForKey:@"coord"];
				NSDictionary* next_coords = [stationDict2 objectForKey:@"coord"];
				
				NSDictionary *text_coords = [stationDict1 objectForKey:@"text_coord"];
				NSDictionary *next_text_coords = [stationDict2 objectForKey:@"text_coord"];

				Boolean reverse=false;
				NSArray *splineCoords;
				splineCoords = [cityMap.addNodes objectForKey: 
								[NSString stringWithFormat:@"%d,%@,%@" , (lineNum1),stationName1,stationName2]];
								//[[stationName1 stringByAppendingString:@","] stringByAppendingString:stationName2]];
			 	if (splineCoords == nil)
				{
					reverse=true;	
					splineCoords = [cityMap.addNodes objectForKey: 
									[NSString stringWithFormat:@"%d,%@,%@" , (lineNum1),stationName2,stationName1]];
									//[[stationName2 stringByAppendingString:@","] stringByAppendingString:stationName1]];
				}
				
				//NSArray *splineCoords = [cityMap.addNodes objectForKey: [[stationName1 stringByAppendingString:@","] stringByAppendingString:stationName2]];

				[self draw2Station:context :lineColor :coords :next_coords :splineCoords :reverse];
				
				[self drawStationPoint: context coord:coords lineColor: lineColor];
				[self drawStationName:context :text_coords :coords :stationName1 :lineNum1-1];

				[self drawStationPoint: context coord:next_coords lineColor: lineColor];
				[self drawStationName:context :next_text_coords :next_coords :stationName2 :lineNum1-1];

			}
		}
		//[self drawMetroLine:context :lineCoord :lineColor :lineStations :lineStationNames :cityMap];
	}
	
	/*for (int i=0; i< count_; i++) {
		NSString *rawSrting1 = (NSString*)[[pathMap objectAtIndex:i] value];
		NSArray *el1  = [rawSrting1 componentsSeparatedByString:@"|"];
		NSString *stationName1 = [el1 objectAtIndex:0];
		NSInteger lineNum1 = [[el1 objectAtIndex:1] intValue]; 
		
		NSArray *lineColor = [NSArray arrayWithArray:[cityMap.linesColors objectAtIndex:lineNum1-1]];
		NSDictionary *lineStations = [cityMap.stationsData objectAtIndex:lineNum1-1];
		//NSArray *lineStationNames = [NSArray arrayWithArray:[cityMap.stationsName objectAtIndex:lineNum1-1]];
		NSArray *lineStationNames = [NSArray arrayWithObjects:stationName1,nil];
		[self drawMetroLineStationName:context :lineColor :lineStations :lineStationNames :cityMap :lineNum1-1];
		
	}
	 */
	labelPlaced=true;;
}

-(void) processTransfers:(CGContextRef) context {

	for(id key in cityMap.transfersTime) {
		NSArray *transfers = [cityMap.transfersTime objectForKey:key];
		for (int i=0; i<[transfers count]; i++) {
			NSDictionary *transferDict = [transfers objectAtIndex:i];


			NSString *station1 = [transferDict objectForKey:@"stationName1"];
			int line1 = [[transferDict objectForKey:@"lineStation1"] intValue];

			NSString *station2 = [transferDict objectForKey:@"stationName2"];
			int line2 = [[transferDict objectForKey:@"lineStation2"] intValue];
			
			NSDictionary *lineStations1 = [cityMap.stationsData objectAtIndex:line1-1];
			NSDictionary *lineStations2 = [cityMap.stationsData objectAtIndex:line2-1];			

			NSDictionary *stationDict1 = [lineStations1 objectForKey:station1];
			NSDictionary *stationDict2 = [lineStations2 objectForKey:station2];
			
			NSDictionary *coords1 = [stationDict1 objectForKey:@"coord"];
			NSDictionary *coords2 = [stationDict2 objectForKey:@"coord"];	

			float x1 = [[coords1 objectForKey:@"x"] floatValue];
			float y1 = [[coords1 objectForKey:@"y"] floatValue];
			float x2 = [[coords2 objectForKey:@"x"] floatValue];
			float y2 = [[coords2 objectForKey:@"y"] floatValue];

			CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
			
			[self drawFilledCircle:context :x1 :y1 :7.0];
			[self drawFilledCircle:context :x2 :y2 :7.0];

			[self drawLine:context :x1 :y1 :x2 :y2 :5];
		}
	}	

	for(id key in cityMap.transfersTime) {
		NSArray *transfers = [cityMap.transfersTime objectForKey:key];
		for (int i=0; i<[transfers count]; i++) {
			NSDictionary *transferDict = [transfers objectAtIndex:i];
			
			
			NSString *station1 = [transferDict objectForKey:@"stationName1"];
			int line1 = [[transferDict objectForKey:@"lineStation1"] intValue];
 			NSString *station2 = [transferDict objectForKey:@"stationName2"];
			int line2 = [[transferDict objectForKey:@"lineStation2"] intValue];
			
			NSDictionary *lineStations1 = [cityMap.stationsData objectAtIndex:line1-1];
			NSDictionary *lineStations2 = [cityMap.stationsData objectAtIndex:line2-1];			
			
			NSDictionary *stationDict1 = [lineStations1 objectForKey:station1];
			NSDictionary *stationDict2 = [lineStations2 objectForKey:station2];
			
			NSDictionary *coords1 = [stationDict1 objectForKey:@"coord"];
			NSDictionary *coords2 = [stationDict2 objectForKey:@"coord"];	
			
			float x1 = [[coords1 objectForKey:@"x"] floatValue];
			float y1 = [[coords1 objectForKey:@"y"] floatValue];
			float x2 = [[coords2 objectForKey:@"x"] floatValue];
			float y2 = [[coords2 objectForKey:@"y"] floatValue];
			
		
			CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
			CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);				
			[self drawFilledCircle:context :x1 :y1 :5.0];
			[self drawFilledCircle:context :x2 :y2 :5.0];

			[self drawLine:context :x1 :y1 :x2 :y2 :3];
		}
	}	
	
}
-(void) processTransfers2:(CGContextRef) context {
	
	for(id key in cityMap.transfersTime) {
		NSArray *transfers = [cityMap.transfersTime objectForKey:key];
		for (int i=0; i<[transfers count]; i++) {
			NSDictionary *transferDict = [transfers objectAtIndex:i];
			
			
			NSString *station1 = [transferDict objectForKey:@"stationName1"];
			int line1 = [[transferDict objectForKey:@"lineStation1"] intValue];
			
			NSString *station2 = [transferDict objectForKey:@"stationName2"];
			int line2 = [[transferDict objectForKey:@"lineStation2"] intValue];
			
			NSDictionary *lineStations1 = [cityMap.stationsData objectAtIndex:line1-1];
			NSDictionary *lineStations2 = [cityMap.stationsData objectAtIndex:line2-1];			
			
			NSDictionary *stationDict1 = [lineStations1 objectForKey:station1];
			NSDictionary *stationDict2 = [lineStations2 objectForKey:station2];
			
			NSDictionary *coords1 = [stationDict1 objectForKey:@"coord"];
			NSDictionary *coords2 = [stationDict2 objectForKey:@"coord"];	
			
			float x1 = [[coords1 objectForKey:@"x"] floatValue];
			float y1 = [[coords1 objectForKey:@"y"] floatValue];
			float x2 = [[coords2 objectForKey:@"x"] floatValue];
			float y2 = [[coords2 objectForKey:@"y"] floatValue];
			
			CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
			
			[self drawFilledCircle:context :x1 :y1 :7.0];
			[self drawFilledCircle:context :x2 :y2 :7.0];
			
			[self drawLine:context :x1 :y1 :x2 :y2 :5];
			

			CGMutablePathRef path = CGPathCreateMutable();
//			CGContextSetLineWidth(context, 40);
			CGPathAddArc(path, NULL, 100, 100, 45, 0*3.142/180, 270*3.142/180, 0);
			CGContextAddPath(context, path);
			CGContextStrokePath(context);
			CGPathRelease(path);
		 }
	}	
	
	for(id key in cityMap.transfersTime) {
		NSArray *transfers = [cityMap.transfersTime objectForKey:key];
		for (int i=0; i<[transfers count]; i++) {
			NSDictionary *transferDict = [transfers objectAtIndex:i];
			
			
			NSString *station1 = [transferDict objectForKey:@"stationName1"];
			int line1 = [[transferDict objectForKey:@"lineStation1"] intValue];
 			NSString *station2 = [transferDict objectForKey:@"stationName2"];
			int line2 = [[transferDict objectForKey:@"lineStation2"] intValue];
			
			NSDictionary *lineStations1 = [cityMap.stationsData objectAtIndex:line1-1];
			NSDictionary *lineStations2 = [cityMap.stationsData objectAtIndex:line2-1];			
			
			NSDictionary *stationDict1 = [lineStations1 objectForKey:station1];
			NSDictionary *stationDict2 = [lineStations2 objectForKey:station2];
			
			NSDictionary *coords1 = [stationDict1 objectForKey:@"coord"];
			NSDictionary *coords2 = [stationDict2 objectForKey:@"coord"];	
			
			float x1 = [[coords1 objectForKey:@"x"] floatValue];
			float y1 = [[coords1 objectForKey:@"y"] floatValue];
			float x2 = [[coords2 objectForKey:@"x"] floatValue];
			float y2 = [[coords2 objectForKey:@"y"] floatValue];
			
			
			CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
			CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);				
			[self drawFilledCircle:context :x1 :y1 :5.0];
			[self drawFilledCircle:context :x2 :y2 :5.0];
			
			[self drawLine:context :x1 :y1 :x2 :y2 :3];
		}
	}	
	
}

#pragma mark -
#pragma mark CGDraw Functions


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
	
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode imageToScale:(UIImage*)imageToScale bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality {
    //Get the size we want to scale it to
    CGFloat horizontalRatio = bounds.width / imageToScale.size.width;
    CGFloat verticalRatio = bounds.height / imageToScale.size.height;
    CGFloat ratio;
	
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
			
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
			
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", contentMode];
    }
	
    //...and here it is
    CGSize newSize = CGSizeMake(imageToScale.size.width * ratio, imageToScale.size.height * ratio);
	
	
    //start scaling it
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = imageToScale.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
	
    CGContextSetInterpolationQuality(bitmap, quality);
	
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, newRect, imageRef);
	
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
	
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
	
    return newImage;
}

// CG Helpres
-(void) drawLine :(CGContextRef) context :(CGFloat)x1 :(CGFloat)y1 :(CGFloat)x2 :(CGFloat)y2 :(int)lineWidth{

	CGContextTranslateCTM(context, 0, 0);

//	CGContextSetLineWidth(context, 4.5);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, lineWidth);
	CGContextMoveToPoint(context, x1, y1);
	CGContextAddLineToPoint(context, x2, y2);
	CGContextStrokePath(context);
}

-(void) drawCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r{
	CGContextTranslateCTM(context, 0, 0);
	
	CGContextSetLineWidth(context, 2.5);
	// Draw a circle (border only)
	//	CGContextMoveToPoint(context, x, y);
	CGContextStrokeEllipseInRect(context, CGRectMake(x-r, y-r, 2*r, 2*r));
}

-(void) drawFilledCircle :(CGContextRef) context :(CGFloat)x :(CGFloat)y :(CGFloat)r{
	

	CGContextTranslateCTM(context, 0, 0);
	// Draw a circle (filled)
	//	CGContextMoveToPoint(context, x, y);
	CGContextFillEllipseInRect(context, CGRectMake(x-r, y-r, 2*r, 2*r));
}


#pragma mark -
#pragma mark -
// CG helpers end 

- (void)refreshLayersScale:(float)scale{
	
	/*
	if ((scale<0.35) )
	{
		mapLayer.contents=(id)[drawedMap4 CGImage];
		//self.frame = CGRectMake(0, 0, 900, 900);
		//900
	} else 	if ((scale>0.34)&&(scale<0.8) ){
	
		mapLayer.contents=(id)[drawedMap3 CGImage];
		//self.frame = CGRectMake(0, 0, 900, 900);
		//900
	} else 	if ((scale>0.8)&&(scale<1.15) ){
		mapLayer.contents=(id)[drawedMap2 CGImage];
		//self.frame = CGRectMake(0, 0, 1200, 1200);
		//1200
	}else 	if ((scale>1.14)){
		mapLayer.contents=(id)[drawedMap CGImage];
		//self.frame = CGRectMake(0, 0, 2000, 2000);
		//2000
	}*/
	
	
	 if ((scale<0.14)){
		 mapLayer.contents=(id)[[images objectAtIndex:3] CGImage];
	 }
	 else if ((scale>=0.14)&&(scale<0.55) ){
		 mapLayer.contents=(id)[[images objectAtIndex:2] CGImage];
	 }
	 else if ((scale>=0.55)&&(scale<1.16) ){
		 mapLayer.contents=(id)[[images objectAtIndex:1] CGImage];
	 }
	 else if ((scale>=1.36)){
		 mapLayer.contents=(id)[[images objectAtIndex:0] CGImage];
	 }
	 

	
	//8 
//	1.8  0.2  0.15 
	/*
	if ((scale<0.14)){
		mapLayer.contents=(id)[[images objectAtIndex:7] CGImage];
	}else if ((scale>=0.14)&&(scale<0.35) ){
		mapLayer.contents=(id)[[images objectAtIndex:6] CGImage];
	}else if ((scale>=0.35)&&(scale<0.56) ){
		mapLayer.contents=(id)[[images objectAtIndex:5] CGImage];
	}else if ((scale>=0.56)&&(scale<0.76) ){
		mapLayer.contents=(id)[[images objectAtIndex:4] CGImage];
	}else if ((scale>=0.76)&&(scale<0.96) ){
		mapLayer.contents=(id)[[images objectAtIndex:3] CGImage];
	}else if ((scale>=0.96)&&(scale<1.16) ){
		mapLayer.contents=(id)[[images objectAtIndex:2] CGImage];
	}else if ((scale>=1.16)&&(scale<1.36) ){
		mapLayer.contents=(id)[[images objectAtIndex:1] CGImage];
	}else if ((scale>=1.36)){
		mapLayer.contents=(id)[[images objectAtIndex:0] CGImage];
	}
	 */
	/*
	 if ((scale<0.15)){
	 mapLayer.contents=(id)[[images objectAtIndex:7] CGImage];
	 }else if ((scale>=0.15)&&(scale<0.25) ){
	 mapLayer.contents=(id)[[images objectAtIndex:6] CGImage];
	 }else if ((scale>=0.25)&&(scale<0.35) ){
	 mapLayer.contents=(id)[[images objectAtIndex:5] CGImage];
	 }else if ((scale>=0.35)&&(scale<0.45) ){
	 mapLayer.contents=(id)[[images objectAtIndex:4] CGImage];
	 }else if ((scale>=0.45)&&(scale<0.75) ){
	 mapLayer.contents=(id)[[images objectAtIndex:3] CGImage];
	 }else if ((scale>=0.75)&&(scale<0.95) ){
	 mapLayer.contents=(id)[[images objectAtIndex:2] CGImage];
	 }else if ((scale>=1.25)&&(scale<1.55) ){
	 mapLayer.contents=(id)[[images objectAtIndex:1] CGImage];
	 }else if ((scale>=1.55)){
	 mapLayer.contents=(id)[[images objectAtIndex:0] CGImage];
	 }
	 */
	

	/*
	[CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithBool:YES] 
                     forKey:kCATransactionDisableActions];
	mapLayer.contentsScale=scale;
	selectedPathLayer.contentsScale=scale;
    [CATransaction commit];
	*/
	
	/*
	[CATransaction begin];
    [CATransaction setDisableActions:YES];
	CATransform3D thisIsHowYouEnable3DForALayer = CATransform3DIdentity; 
	thisIsHowYouEnable3DForALayer.m34 = -1.0/scale;
	mapLayer.sublayerTransform = thisIsHowYouEnable3DForALayer;
    [CATransaction commit];
	*/
	
	 
	
	[self setNeedsDisplay];
	
}



- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
	mainLabel.hidden=true;
	[[self superview] touchesEnded:touches withEvent:event];
	//[self.nextResponder touchesEnded:touches withEvent:event];
	DLog(@" touch 1 ");
	DLog(@"  %@ ",[self superview] );

	if (firstStation==nil)
	{
		firstStation=stationNameTemp;
		firstStationNum = stationLineTemp;
	}
	else if (secondStation==nil) {
		secondStation=stationNameTemp;
		secondStationNum = stationLineTemp;
	}

	
//	[self setZoomScale:2];
	// If not dragging, send event to next responder
//	if (!self.containerView.dragging) 
//		[self.nextResponder touchesEnded: touches withEvent:event]; 
//	else
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
		stationNameTemp = ((UILabel*)hitView).text;
		stationLineTemp = ((UILabel*)hitView).tag;
		
		mainLabel.text = stationNameTemp;
		DLog(@" under label ");
		DLog(@" %@",((UILabel*)hitView).text);
	}
	else {
		stationSelected=false;
		mainLabel.hidden=true;
	}

	DLog(@" !!!!!! ");
}

-(void) finPath :(NSString*) fSt :(NSString*) sSt :(NSInteger) fStl :(NSInteger)sStl {

	NSMutableArray *pathArray = [NSMutableArray arrayWithArray:[cityMap calcPath:fSt :sSt :fStl :sStl]];
	
	/*
	DLog(@"-------------")
	for (int i = 0 ; i<[pathArray count]; i++) {
		DLog(@" %@ ",[ [pathArray objectAtIndex:i] value]);
	}
	 */

	[pathArray insertObject:[GraphNode nodeWithValue:[NSString stringWithFormat:@"%@|%d",firstStation,firstStationNum ] ] atIndex:0];
	
	//CGContextRef cgContext = UIGraphicsGetCurrentContext();	
	
	//UIGraphicsPushContext(cgContext);
	
	drawedPath = [[self drawPathToImage :pathArray] retain];
	selectedPathLayer.contents = (id)[drawedPath CGImage];
		
	//[im drawInRect:CGRectMake(0,0,2000,2000)];
	
	//UIGraphicsPopContext();
	
	drawPath=true;

	
	//[selectedPathLayer setNeedsDisplay];
	//[self.layer addSublayer:selectedPathLayer];
	[self setNeedsDisplay];
	//[self addSubview:selectedMap];
	
	//[self drawPathMap:cgContext :pathArray];
}


-(void) saveImage :(UIImage*)mm
{
	NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
	NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
	
	// Write a UIImage to JPEG with minimum compression (best quality)
	// The value 'image' must be a UIImage object
	// The value '1.0' represents image compression quality as value from 0.0 to 1.0
	[UIImageJPEGRepresentation(mm, 1.0) writeToFile:jpgPath atomically:YES];
	
	// Write image to PNG
	[UIImagePNGRepresentation(mm) writeToFile:pngPath atomically:YES];
	// Let's check to see if files were successfully written...
	
	// Create file manager
	  NSError *error;
	  NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	// Point to Document directory
	    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	
	// Write out the contents of home directory to console
		//NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
	
}
-(void) removePath{
	[selectedMap removeFromSuperview];
	
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
	
	
	for (NSString* key in cityMap.gpsCoords ){
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
 
@end
