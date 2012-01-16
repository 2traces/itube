//
//  MainViewController.h
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "FlipsideViewController.h"
#import "SelectingTabBarViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate,SelectingTabBarProtocol> {
    int currentSelection;
}

- (IBAction)showInfo;
-(void)pressedSelectFromStation;
-(void)pressedSelectToStation;


@end
