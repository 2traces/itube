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
#import "TopTwoStationsView.h"
#import "SelectingTabBarViewController.h"
#import "CoreLocationController.h"

@interface GlViewController : GLKViewController <SelectingTabBarProtocol, CoreLocationControllerDelegate>

@property (nonatomic, assign) MItem *currentSelection;
@property (nonatomic, retain) MItem *fromStation;
@property (nonatomic, retain) MItem *toStation;
@property (nonatomic, retain) TopTwoStationsView *stationsView;

-(FastAccessTableViewController*)showTableView;
-(void)returnFromSelectionFastAccess:(NSArray *)stations;
-(void)setGeoPosition:(CGRect)rect;
-(void)setUserGeoPosition:(CGPoint)point;

@end
