//
//  LeftiPadPathViewController.h
//  tube
//
//  Created by sergey on 13.08.12.
//
//

#import <UIKit/UIKit.h>

@interface RightiPadPathViewController : UIViewController
{
    NSTimer *timer;
    BOOL isPathExists;
}

@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) UIButton *switchButton;
@property (nonatomic,retain) UIImageView *toolbar;
@property (nonatomic,retain) UILabel *statusLabel;
@property (nonatomic,retain) UIImageView *statusShadowView;

-(void)showHorizontalPathesScrollView;
-(void)showVerticalPathScrollView;
-(void)redrawPathScrollView;

-(BOOL)isReadyToShow;
-(void)prepareToShow;

@end
