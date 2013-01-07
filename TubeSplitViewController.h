//
//  TubeSplitViewController.h
//  tube
//
//  Created by Sergey Mingalev on 04.08.12.
//
//

#import "MainViewController.h"

#import <UIKit/UIKit.h>

@class MainViewController;
@class LeftiPadPathViewController;
@class TopTwoStationsView;

@interface TubeSplitViewController : UIViewController {
    UIView *pathView;
    UIView *mapView;
    MainViewController *mainViewController;
    LeftiPadPathViewController *leftPathController;
    UINavigationController * navController;
    BOOL isLeftShown;
}

@property (nonatomic,retain) UIView *pathView;
@property (nonatomic,retain) UIView *mapView;
@property (nonatomic,retain) MainViewController *mainViewController;
@property (nonatomic,retain) LeftiPadPathViewController *leftPathController;
@property (nonatomic, readonly) UINavigationController *navigationController;
@property (nonatomic, retain) TopTwoStationsView *topStationsView;
@property (nonatomic, retain) UIImageView *shadowView;

-(void)refreshPath;
-(void)showLeftView;
-(void)hideLeftView;
-(void)refreshStatusInfo;
-(void)changeStatusView;

@end
