//
//  TubeSplitViewController.h
//  tube
//
//  Created by sergey on 04.08.12.
//
//

#import <UIKit/UIKit.h>

@class RightiPadPathViewController;
@class GlViewController;

@interface TubeSplitViewController : UIViewController {
    UIView *pathView;
    UIView *mapView;
    GlViewController *glViewController;
    RightiPadPathViewController *rightPathController;
    UINavigationController * navController;
    BOOL isRightShown;
    BOOL isListShown;
}

@property (nonatomic,retain) UIView *pathView;
@property (nonatomic,retain) UIView *mapView;
@property (nonatomic, retain) GlViewController* glViewController;
@property (nonatomic,retain) UIViewController *rightPathController;
@property (nonatomic,retain) UIViewController *listViewController;
@property (nonatomic,retain) UIViewController *mapViewController;
@property (nonatomic, readonly) UINavigationController *navigationController;

-(void)refreshPath;
-(void)showLeftView;
-(void)hideLeftView;
-(void)refreshStatusInfo;
-(void)changeStatusView;
- (CGSize)viewSize;


@end
