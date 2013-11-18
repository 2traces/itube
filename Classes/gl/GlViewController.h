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
#import "NavigationViewController.h"
#import "GlSprite.h"
#import "GlPanel.h"
#import "GlView.h"
#import "SettingsViewController.h"
#import <CoreLocation/CoreLocation.h>

typedef enum {PIN_DEFAULT=0, PIN_USER=1, PIN_OBJECT=2, PIN_CLUSTER=3, PIN_FAVORITE=4} PinType;

#define nSEARCH_RESULTS_READY @"Search results ready"

@interface WifiObject: NSObject <NSCoding> {
}

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSArray *comments;
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
@property (nonatomic, assign) CGFloat distance;

-(id)initWithDictionary:(NSDictionary*)data;

@end

@interface Cluster : NSObject {
    //CGFloat radius;
    NSMutableArray *_objects;
    //CGPoint sumCoord;
}

@property (nonatomic, assign) CGPoint center;
@property (nonatomic, readonly) NSArray *objects;
@property (nonatomic, assign) NSInteger pinID;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) BOOL empty;
@property (nonatomic, assign) NSInteger clid;
//@property (nonatomic, readonly) CGFloat radius;

-(id)initWithCenter:(CGPoint)p;
-(BOOL)accept:(id)element;
-(void)unload;

@end

@interface Pin : NSObject {
    int _id;
    CGPoint pos, geoPos;
    GlSprite *sprite;
    BigPanel *sp;
    CGFloat size;
    CGFloat offset, speed, constOffset;
    float lastScale;
    float distanceToUser;
    PinType type;
    CGFloat alpha, targetAlpha, alphaSpeed;
    
    NSString *pinText, *pinSubtitle, *pinTexture, *pinActiveTexture;
}

@property (nonatomic, readonly) int Id;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, readonly) CGPoint geoPosition;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) CGFloat distanceToUser;
@property (nonatomic, readonly) PinType type;
@property (nonatomic, assign) double rotation;
@property (nonatomic, readonly) BOOL loaded;

-(id)initUserPos;
-(id)initObjectPos;
-(id)initWithId:(int)pinId andColor:(int)color;
-(id)initWithId:(int)pinId color:(int)color andText:(NSString*)text;
-(id)initWithId:(int)pinId color:(int)color text:(NSString*)text andSubtitle:(NSString*)subtitle;
-(id)initClusterWithId:(int)pinId color:(int)color andText:(NSString*)text;
-(id)initFavWithId:(int)pinId color:(int)color andText:(NSString*)text;
//-(void)draw;
-(void)drawWithScale:(CGFloat)scale;
-(void)drawPanelWithScale:(CGFloat)scale;
-(void)fallFrom:(CGFloat)distance at:(CGFloat)speed;
-(void)fadeIn:(CGFloat)time;
-(void)fadeOut:(CGFloat)time;
-(CGRect)bounds;
-(CGRect)panelBounds;
-(void)load;
-(void)unload;
@end

@class NavigationViewController;

@interface GlViewController : GLKViewController<UIPopoverControllerDelegate,SettingsViewControllerDelegate, CLLocationManagerDelegate> {
    UIPopoverController *popover;
}

@property (nonatomic, assign) MItem *currentSelection;
@property (nonatomic, retain) NavigationViewController *navigationViewController;
@property (nonatomic, assign) BOOL followUserGPS;
@property (nonatomic, readonly) NSArray *searchResults;
@property (nonatomic, strong) IBOutlet GlView* glView;

-(FastAccessTableViewController*)showTableView;
-(void)setGeoPosition:(CGRect)rect;

//Center map on point with long/lat
-(void)setGeoPosition:(CGPoint)geoCoords withZoom:(CGFloat)zoom;
// scroll map to some geo point
-(void)scrollToGeoPosition:(CGPoint)geoCoords withZoom:(CGFloat)zoom;
//Calculate distance
-(CGFloat)calcGeoDistanceFrom:(CGPoint)p1 to:(CGPoint)p2;
//Set pin
-(int)newPin:(CGPoint)coordinate color:(int)color name:(NSString*)name;
// activate pin and center map on it
-(void)setPinForObject:(WifiObject*)ob active:(BOOL)active;

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
//-(void)setPin:(int)pinID active:(BOOL)active;

- (CGFloat) setPinAtPlace:(MPlace*)place color:(int)color;
- (CGFloat) setStarAtPlace:(MPlace*)place color:(int)color;
- (void) removePinAtPlace:(MPlace*)place;
// direction from user to geo point
- (CGFloat) radialOffsetToPoint:(CGPoint)point;
// direction from one geo point to another one
- (CGFloat) radialOffsetFromPoint:(CGPoint)p1 toAnotherPoint:(CGPoint)p2;
- (void) moveModeButtonToFullScreen;
- (void) moveModeButtonToCutScreen;

- (CGFloat)distanceToMapCenter;
- (CGFloat) radialOffsetToMapCenter;

-(void)removeTableView;
-(void)purgeUnusedCache;
-(void)showSettings;
-(void)showPurchases:(int)index;

-(void)loadObjectsOnScreen;
//-(void)loadObjectsForRect:(CGRect)rect;
-(void)loadClustersForRect:(CGRect)rect withObjects:(BOOL)loadObjects;
-(void)loadObjectsForClusters:(NSArray*)clusters andSave:(BOOL)needSave;

-(NSArray*)getObjectsNear:(CGPoint)center withRadius:(CGFloat)radius;
-(NSArray*)getObjectsNearUserWithRadius:(CGFloat)radius;
-(void)loadCitiesLikeThis:(NSString*)cityName;

-(void)downloadVisibleMap:(NSInteger)depth withOffset:(NSInteger)offset;
-(NSArray*)getObjectsNearUserWithRadius:(CGFloat)radius;

@end
