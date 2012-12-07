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
//Calculate distance
-(CGFloat)calcGeoDistanceFrom:(CGPoint)p1 to:(CGPoint)p2;
//Set pin
-(int)newPin:(CGPoint)coordinate color:(int)color name:(NSString*)name;


-(void)setUserGeoPosition:(CGPoint)point;
-(void)setStationsPosition:(NSArray*)coords withNames:(NSArray*)names andMarks:(BOOL)marks;
-(void)errorWithGeoLocation;

@end
