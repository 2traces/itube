//
//  UnlockerView.h
//  tube
//
//  Created by alex on 23.07.13.
//
//

#import <UIKit/UIKit.h>
#import "tubeAppDelegate.h"


@interface UnlockerView : UIView

- (id) initWithFrame:(CGRect)frame withAppDelegate:(tubeAppDelegate*)tubeAppDelegate;

@property (retain) UIImageView *bg;
@property (retain) UIButton *showSettingsButton;
@property (retain) tubeAppDelegate *appDelegate;
@property (retain) UITapGestureRecognizer *tapGR;

@end
