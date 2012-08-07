//
//  TubeSplitViewController.h
//  tube
//
//  Created by sergey on 04.08.12.
//
//

#import "MainViewController.h"

#import <UIKit/UIKit.h>

@interface TubeSplitViewController : UIViewController {
//    UIView *pathView;
    UIView *mapView;
    MainViewController *mainViewController;
}

//@property (nonatomic,retain) IBOutlet UIView *pathView;
@property (nonatomic,retain) UIView *mapView;
@property (nonatomic,retain) MainViewController *mainViewController;

@end
