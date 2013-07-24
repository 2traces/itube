//
//  UnlockerView.m
//  tube
//
//  Created by alex on 23.07.13.
//
//

#import "UnlockerView.h"
#import "ColorFactory.h"

@implementation UnlockerView

@synthesize bg = _bg;
@synthesize showSettingsButton = _showSettingsButton;
@synthesize appDelegate = _appDelegate;
@synthesize tapGR = _tapGR;

#define BUTTON_FRAME_IPAD CGRectMake(210, 650, 360, 60);
#define BUTTON_FRAME_IPHONE CGRectMake(29, 240, 262, 43);
#define BUTTON_FRAME_IPHONE5 CGRectMake(29, 322, 262, 43);

- (id)initWithFrame:(CGRect)frame withAppDelegate:(tubeAppDelegate *)tubeAppDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.appDelegate = tubeAppDelegate;
        self.backgroundColor = [ColorFactory lightGrayColor];
        self.bg = [[UIImageView alloc] initWithFrame:frame];
        self.bg.contentMode =  UIViewContentModeScaleAspectFill;
        [self.bg setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        CGRect buttonFrame;
        NSString *bgImageName;
        NSString *buttonBgPressedName;
        NSString *buttonBgName;
        NSString *buttonTitle = @"Unlock Full Guide";//TODO: localize that
        if (IS_IPAD) {
            bgImageName = @"unlocker_bg-ipad.jpg";
            buttonFrame = BUTTON_FRAME_IPAD;
            buttonBgName = @"unlocker_button_ipad_unpressed";
            buttonBgPressedName = @"unlocker_button_ipad_pressed";
        }else{
            buttonBgName = @"unlocker_button_unpressed";
            buttonBgPressedName = @"unlocker_button_pressed";
            if([tubeAppDelegate isIPHONE5]){
                bgImageName = @"unlocker_bg-iphone5.png";
                buttonFrame = BUTTON_FRAME_IPHONE5;
            }else{
                bgImageName = @"unlocker_bg-iphone.png";
                buttonFrame = BUTTON_FRAME_IPHONE;
            }
        }
        self.bg.image = [UIImage imageNamed:bgImageName];
        self.bg.userInteractionEnabled = YES;
        self.tapGR = [[UITapGestureRecognizer alloc] init];
        [self.bg addGestureRecognizer:self.tapGR];
        [self addSubview:self.bg];
        
        self.showSettingsButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [self.showSettingsButton setBackgroundImage:[UIImage imageNamed:buttonBgName] forState:UIControlStateNormal];
        [self.showSettingsButton setBackgroundImage:[UIImage imageNamed:buttonBgPressedName] forState:UIControlStateHighlighted];
        [self.showSettingsButton setTitle:buttonTitle forState:UIControlStateNormal];
        [self.showSettingsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:self.showSettingsButton];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc{
    [self.bg removeGestureRecognizer:self.tapGR];
    [_tapGR release];
    
    [self.bg removeFromSuperview];
    [_bg release];
    
    [self.showSettingsButton removeFromSuperview];
    [_showSettingsButton release];
    
    
    [super dealloc];
}

@end
