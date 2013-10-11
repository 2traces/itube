//
//  LeftiPadPathViewController.m
//  tube
//
//  Created by sergey on 13.08.12.
//
//

#import "RightiPadPathViewController.h"
#import "Classes/tubeAppDelegate.h"

@implementation RightiPadPathViewController

@synthesize timer;
@synthesize switchButton;
@synthesize toolbar;
@synthesize statusLabel;
@synthesize statusShadowView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isPathExists=NO;
    
	// Do any additional setup after loading the view.
    self.toolbar = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)] autorelease];
    [self.toolbar setImage:[[UIImage imageNamed:@"toolbar_bg1.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:0]];
    [self.toolbar setUserInteractionEnabled:YES];
    self.toolbar.autoresizesSubviews = YES;
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.toolbar];
    
    self.statusLabel = [[[UILabel alloc] initWithFrame:CGRectMake(90, 6, 300, 40)] autorelease];
    self.statusLabel.backgroundColor=[UIColor clearColor];
    self.statusLabel.textColor = [UIColor grayColor];
    self.statusLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:22.0];
    self.statusLabel.text = NSLocalizedString(@"CurrentStatus", @"CurrentStatus");
    [self.view addSubview:self.statusLabel];
    self.statusLabel.hidden=YES;
    
    self.switchButton = [self createSwitchButton];
    [self.view addSubview:switchButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)isReadyToShow
{
    
    if (isPathExists) {
        return YES;
    }
    
    return NO;
}

-(void)prepareToShow
{
    isPathExists=NO;
    
    [self layoutSubviews];
}

-(void)refreshUITextView
{
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
}


-(void)layoutSubviews
{

}

#pragma mark - Horizontal path views

-(void)requestChangeActivePath:(NSNumber*)pathNumb {
    [self performSelector:@selector(changeActivePath:) withObject:pathNumb afterDelay:0.1];
}

-(BOOL)helpNeeded
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"scrollHelp"])
	{
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"scrollHelp"]<15) {
            return YES;
        } else {
            return NO;
        }
	} else {
        NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:1 forKey:@"scrollHelp"];
        [prefs synchronize];
        return YES;
    }
}

-(void)animationDidEnd
{
    NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"scrollHelp"]+1 forKey:@"scrollHelp"];
    [prefs synchronize];
    
    
    [self.timer invalidate];
    self.timer=nil;
}

#pragma mark - Vertical path views

-(UIButton*)createSwitchButton
{
    UIButton *changeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"statusButton.png"];
    [changeViewButton setImage:img forState:UIControlStateNormal];
    [changeViewButton setImage:[UIImage imageNamed:@"statusButtonPressed.png"] forState:UIControlStateHighlighted];
    [changeViewButton addTarget:self action:@selector(changeMapToPathView:) forControlEvents:UIControlEventTouchUpInside];
    
    [changeViewButton setFrame:CGRectMake(34 , 44 , img.size.width, img.size.height)];
    
    return changeViewButton;
}

-(void)dealloc
{
    [timer release];
    [statusShadowView release];
    [switchButton release];
    [toolbar release];
    [statusLabel release];
    
    [super dealloc];
}
@end
