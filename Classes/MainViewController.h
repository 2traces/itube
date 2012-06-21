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

@class TopTwoStationsView;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate,SelectingTabBarProtocol,UIScrollViewDelegate,PathDrawProtocol> {
    int currentSelection;
    MItem *fromStation;
    MItem *toStation;
    NSArray *route;
    
    TopTwoStationsView *stationsView;
    UIScrollView *scrollView;
    UIScrollView *pathScrollView;
}

@property (nonatomic, retain) MItem *fromStation;
@property (nonatomic, retain) MItem *toStation;
@property (nonatomic, retain) NSArray *route;
@property (nonatomic, retain) TopTwoStationsView *stationsView;
@property (nonatomic, assign) int currentSelection;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIScrollView *pathScrollView;

- (IBAction)showInfo;
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
