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

@interface TubeSplitViewController : UIViewController {
    UIView *pathView;
    UIView *mapView;
    MainViewController *mainViewController;
}

@property (nonatomic,retain) UIView *pathView;
@property (nonatomic,retain) UIView *mapView;
@property (nonatomic,retain) MainViewController *mainViewController;

@end
