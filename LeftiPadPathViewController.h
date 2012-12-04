//
//  LeftiPadPathViewController.h
//  tube
//
//  Created by Sergey Mingalev on 13.08.12.
//
//

#import <UIKit/UIKit.h>
#import "PathScrollView.h"
#import "VertPathScrollView.h"
#import "StatusViewController.h"

@interface LeftiPadPathViewController : UIViewController <PathScrollViewProtocol>
{
    NSTimer *timer;
    BOOL isPathExists;
    BOOL isStatusAvailable;
}

@property (nonatomic,retain) PathScrollView *horizontalPathesScrollView;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) VertPathScrollView *pathScrollView;
@property (nonatomic,retain) StatusViewController *statusViewController;
@property (nonatomic,retain) UIButton *switchButton;
@property (nonatomic,retain) UIImageView *toolbar;
@property (nonatomic,retain) UILabel *statusLabel;
@property (nonatomic,retain) UIImageView *statusShadowView;

-(void)showHorizontalPathesScrollView;
-(void)showVerticalPathScrollView;
-(void)redrawPathScrollView;

-(BOOL)isReadyToShow;
-(void)prepareToShow;
-(void)refreshStatusInfo;
-(void)changeStatusView;

@end
