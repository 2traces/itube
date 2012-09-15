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
@class LeftiPadPathViewController;

@interface TubeSplitViewController : UIViewController {
    UIView *pathView;
    UIView *mapView;
    MainViewController *mainViewController;
    LeftiPadPathViewController *leftPathController;
    BOOL isLeftShown;
}

@property (nonatomic,retain) UIView *pathView;
@property (nonatomic,retain) UIView *mapView;
@property (nonatomic,retain) MainViewController *mainViewController;
@property (nonatomic,retain) LeftiPadPathViewController *leftPathController;

-(void)refreshPath;
-(void)showLeftView;
-(void)hideLeftView;

@end
