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
    MStation *fromStation;
    MStation *toStation;
    NSArray *route;
    
    TopTwoStationsView *stationsView;
    UIScrollView *scrollView;
    UIScrollView *pathScrollView;
}

@property (nonatomic, retain) MStation *fromStation;
@property (nonatomic, retain) MStation *toStation;
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
-(FastAccessTableViewController*)showTableView;
-(void)removeTableView;

-(void)changeMapTo:(NSString*)newMap andCity:(NSString*)cityName;


@end
