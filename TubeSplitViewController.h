//
//  TubeSplitViewController.h
//  tube
//
//  Created by sergey on 04.08.12.
//
//

#import "MainViewController.h"

#import <UIKit/UIKit.h>

@class MainViewController;
@class RightiPadPathViewController;

@interface TubeSplitViewController : UIViewController {
    UIView *pathView;
    UIView *mapView;
    MainViewController *mainViewController;
    RightiPadPathViewController *rightPathController;
    UINavigationController * navController;
    BOOL isRightShown;
}

@property (nonatomic,retain) UIView *pathView;
@property (nonatomic,retain) UIView *mapView;
@property (nonatomic,retain) MainViewController *mainViewController;
@property (nonatomic,retain) RightiPadPathViewController *rightPathController;
@property (nonatomic, readonly) UINavigationController *navigationController;

-(void)refreshPath;
-(void)showLeftView;
-(void)hideLeftView;
-(void)refreshStatusInfo;
-(void)changeStatusView;

@end
