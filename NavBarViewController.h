//
//  NavBarViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 1/11/13.
//
//

#import <UIKit/UIKit.h>

@class SpotsListViewController;
@class SpotInfoViewController;

@interface NavBarViewController : UIViewController

@property (nonatomic, retain) IBOutlet UINavigationBar *bar;
@property (nonatomic, retain) IBOutlet UIView *container;
@property (nonatomic, retain) SpotsListViewController *list;
@property (nonatomic, retain) SpotInfoViewController *info;

- (void)pushVC:(SpotInfoViewController*)vc animated:(BOOL)animated;
- (void)popVCAnimated:(BOOL)animated;

@end
