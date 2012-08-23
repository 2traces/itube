//
//  MainViewController.h
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "FlipsideViewController.h"
#import "SelectingTabBarViewController.h"
#import "ManagedObjects.h"
#import "PathDrawView.h"
#import "MBProgressHUD.h"
#import "PathScrollView.h"
#import "VertPathScrollView.h"
#import "TubeSplitViewController.h"
#import "SettingsViewController.h"

@class TopTwoStationsView;
@class VertPathScrollView;
@class TubeSplitViewController;

@interface MainViewController : UIViewController <SelectingTabBarProtocol,UIScrollViewDelegate,MBProgressHUDDelegate,PathScrollViewProtocol,UIPopoverControllerDelegate,SettingsViewControllerDelegate> {
    
    int currentSelection;
    MStation *fromStation;
    MStation *toStation;
    NSArray *route;
    
    TopTwoStationsView *stationsView;
    PathScrollView *horizontalPathesScrollView;
    VertPathScrollView *pathScrollView;
    TubeSplitViewController *spltViewController;
    
    NSTimer *timer;
    UIPopoverController *popover;
}

@property (nonatomic, retain) MStation *fromStation;
@property (nonatomic, retain) MStation *toStation;
@property (nonatomic, retain) NSArray *route;
@property (nonatomic, retain) TopTwoStationsView *stationsView;
@property (nonatomic, assign) int currentSelection;
@property (nonatomic, retain) PathScrollView *horizontalPathesScrollView;
@property (nonatomic, retain) VertPathScrollView *pathScrollView;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) TubeSplitViewController *spltViewController;

//- (IBAction)showInfo;
-(void)pressedSelectFromStation;
-(void)pressedSelectToStation;
-(void)returnFromSelectionFastAccess:(NSArray *)stations;
-(void)resetFromStation;
-(void)resetToStation;
-(void)resetBothStations;
-(FastAccessTableViewController*)showTableView;
-(void)removeTableView;

-(void)changeMapTo:(NSString*)newMap andCity:(NSString*)cityName;


@end
