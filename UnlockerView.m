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

- (id)initWithFrame:(CGRect)frame withAppDelegate:(tubeAppDelegate *)tubeAppDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.appDelegate = tubeAppDelegate;
        self.backgroundColor = [ColorFactory lightGrayColor];
        self.bg = [[UIImageView alloc] initWithFrame:frame];
        self.bg.contentMode = UIViewContentModeScaleAspectFit;
        [self.bg setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        if (IS_IPAD) {
            self.bg.image = [UIImage imageNamed:@"unlocker_bg-ipad.jpg"];
        }else{
            self.bg.image = [UIImage imageNamed:@"unlocker_bg.png"];
        }
        self.bg.userInteractionEnabled = YES;
        self.tapGR = [[UITapGestureRecognizer alloc] init];
        [self.bg addGestureRecognizer:self.tapGR];
        [self addSubview:self.bg];
        self.showSettingsButton = [[UIButton alloc] initWithFrame:frame];
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
