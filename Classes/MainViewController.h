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

@class TopTwoStationsView;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate,SelectingTabBarProtocol> {
    int currentSelection;
    MStation *fromStation;
    MStation *toStation;
    NSArray *route;
    
    TopTwoStationsView *stationsView;
}

@property (nonatomic, retain) MStation *fromStation;
@property (nonatomic, retain) MStation *toStation;
@property (nonatomic, retain) NSArray *route;
@property (nonatomic, retain) TopTwoStationsView *stationsView;
@property (nonatomic, assign) int currentSelection;

- (IBAction)showInfo;
-(void)pressedSelectFromStation;
-(void)pressedSelectToStation;
-(void)returnFromSelectionFastAccess:(NSArray *)stations;


@end
