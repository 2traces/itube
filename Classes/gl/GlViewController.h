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
-(void)setGeoPosition:(CGPoint)geoCoords withZoom:(CGFloat)zoom;
-(void)setUserGeoPosition:(CGPoint)point;
-(void)setStationsPosition:(NSArray*)coords;
-(CGPoint)translateFromGeoToMap:(CGPoint)pm;

@end
