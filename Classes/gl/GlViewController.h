//
//  GlViewController.h
//  test
//
//  Created by Vasiliy Makarov on 22.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "FastAccessTableViewController.h"
#import "ManagedObjects.h"
#import "TopRasterView.h"
#import "NavigationViewController.h"
#import "GlSprite.h"
#import "GlPanel.h"

@interface Pin : NSObject {
     int _id;
     CGPoint pos;
     GlSprite *sprite;
     SmallPanel *sp;
     CGFloat size;
     CGFloat offset, speed;
     float lastScale;
     float distanceToUser;
}

@property (nonatomic, readonly) int Id;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) CGFloat distanceToUser;

-(id)initWithId:(int)pinId andColor:(int)color;
-(void)draw;
-(void)drawWithScale:(CGFloat)scale;
-(void)drawPanelWithScale:(CGFloat)scale;
-(void)fallFrom:(CGFloat)distance at:(CGFloat)speed;
-(CGRect)bounds;
@end

@class NavigationViewController;

@interface GlViewController : GLKViewController 

@property (nonatomic, assign) MItem *currentSelection;
@property (nonatomic, retain) MItem *fromStation;
@property (nonatomic, retain) MItem *toStation;
@property (nonatomic, retain) TopRasterView *stationsView;
@property (nonatomic, retain) NavigationViewController *navigationViewController;

-(FastAccessTableViewController*)showTableView;
-(void)returnFromSelectionFastAccess:(NSArray *)stations;
-(void)setGeoPosition:(CGRect)rect;

//Center map on point with long/lat
-(void)setGeoPosition:(CGPoint)geoCoords withZoom:(CGFloat)zoom;
// scroll map to some geo point
-(void)scrollToGeoPosition:(CGPoint)geoCoords withZoom:(CGFloat)zoom;
//Calculate distance
-(CGFloat)calcGeoDistanceFrom:(CGPoint)p1 to:(CGPoint)p2;
//Set pin
-(int)newPin:(CGPoint)coordinate color:(int)color name:(NSString*)name;

- (void) centerMapOnUser;

-(void)setUserGeoPosition:(CGPoint)point;
-(void)setStationsPosition:(NSArray*)coords withNames:(NSArray*)names andMarks:(BOOL)marks;
-(void)errorWithGeoLocation;
-(int)newPin:(CGPoint)coordinate color:(int)color name:(NSString*)name;
-(int)newStar:(CGPoint)coordinate color:(int)color name:(NSString*)name;
-(void)removePin:(int)pinId;
-(void)removeAllPins;
-(Pin*)getPin:(int)pinId;

- (CGFloat) setPinAtPlace:(MPlace*)place color:(int)color;
- (void) removePinAtPlace:(MPlace*)place;
// direction from user to geo point
- (CGFloat) radialOffsetToPoint:(CGPoint)point;
// direction from one geo point to another one
- (CGFloat) radialOffsetFromPoint:(CGPoint)p1 toAnotherPoint:(CGPoint)p2;
- (void) moveModeButtonToFullScreen;
- (void) moveModeButtonToCutScreen;



@end
