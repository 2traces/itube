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
#import "SettingsViewController.h"

typedef enum {PIN_DEFAULT=0, PIN_USER=1, PIN_OBJECT=2, PIN_CLUSTER=3, PIN_FAVORITE=4} PinType;

@interface Object: NSObject {
}

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *hours;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *kind;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) CGPoint geoP;
@property (nonatomic, assign) CGPoint coords;
@property (nonatomic, assign) NSInteger pinID;

-(id)initWithDictionary:(NSDictionary*)data;

@end

@interface Cluster : NSObject {
    CGFloat radius;
    NSMutableArray *_objects;
    CGPoint sumCoord;
}

@property (nonatomic, assign) CGPoint center;
@property (nonatomic, readonly) NSArray *objects;
@property (nonatomic, assign) NSInteger pinID;

-(id)initWithRadius:(CGFloat)r;

-(BOOL)accept:(id)element;

@end

@interface Pin : NSObject {
    int _id;
    CGPoint pos, geoPos;
    GlSprite *sprite;
    SmallPanel *sp;
    CGFloat size;
    CGFloat offset, speed, constOffset;
    float lastScale;
    float distanceToUser;
    PinType type;
}

@property (nonatomic, readonly) int Id;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) CGFloat distanceToUser;
@property (nonatomic, readonly) PinType type;
@property (nonatomic, assign) double rotation;

-(id)initUserPos;
-(id)initObjectPos;
-(id)initWithId:(int)pinId andColor:(int)color;
-(id)initWithId:(int)pinId color:(int)color andText:(NSString*)text;
-(id)initClusterWithId:(int)pinId color:(int)color andText:(NSString*)text;
-(id)initFavWithId:(int)pinId color:(int)color andText:(NSString*)text;
-(void)draw;
-(void)drawWithScale:(CGFloat)scale;
-(void)drawPanelWithScale:(CGFloat)scale;
-(void)fallFrom:(CGFloat)distance at:(CGFloat)speed;
-(CGRect)bounds;
@end

@class NavigationViewController;

@interface GlViewController : GLKViewController<UIPopoverControllerDelegate,SettingsViewControllerDelegate> {
    UIPopoverController *popover;
    NSMutableArray *clusters;
}

@property (nonatomic, assign) MItem *currentSelection;
@property (nonatomic, retain) MItem *fromStation;
@property (nonatomic, retain) MItem *toStation;
@property (nonatomic, retain) TopRasterView *stationsView;
@property (nonatomic, retain) NavigationViewController *navigationViewController;
@property (nonatomic, assign) BOOL followUserGPS;

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
-(CGPoint)getCenterMapGeoCoordinates;

-(void)setUserHeading:(double)heading;
-(void)setUserGeoPosition:(CGPoint)point;
-(void)setStationsPosition:(NSArray*)data withMarks:(BOOL)marks;
-(void)errorWithGeoLocation;
-(int)newPin:(CGPoint)coordinate color:(int)color name:(NSString*)name;
-(int)newStar:(CGPoint)coordinate color:(int)color name:(NSString*)name;
-(void)removePin:(int)pinId;
-(void)removeAllPins;
-(int)setLocation:(CGPoint)coordinate;
-(Pin*)getPin:(int)pinId;

- (CGFloat) setPinAtPlace:(MPlace*)place color:(int)color;
- (CGFloat) setStarAtPlace:(MPlace*)place color:(int)color;
- (void) removePinAtPlace:(MPlace*)place;
// direction from user to geo point
- (CGFloat) radialOffsetToPoint:(CGPoint)point;
// direction from one geo point to another one
- (CGFloat) radialOffsetFromPoint:(CGPoint)p1 toAnotherPoint:(CGPoint)p2;
- (void) moveModeButtonToFullScreen;
- (void) moveModeButtonToCutScreen;

-(void)removeTableView;
-(void)pressedSelectFromStation;
-(void)pressedSelectToStation;
-(void)purgeUnusedCache;
-(void)showSettings;
-(void)showPurchases:(int)index;

-(void)loadObjectsOnScreen;
-(void)loadObjectsForRect:(CGRect)rect;

@end
