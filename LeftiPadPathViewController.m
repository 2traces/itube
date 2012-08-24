//
//  LeftiPadPathViewController.m
//  tube
//
//  Created by sergey on 13.08.12.
//
//

#import "LeftiPadPathViewController.h"
#import "Classes/tubeAppDelegate.h"
#import "CityMap.h"
#import "Classes/MainView.h"
#import "MapView.h"

@implementation LeftiPadPathViewController

@synthesize horizontalPathesScrollView;
@synthesize timer;
@synthesize pathScrollView;

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
	// Do any additional setup after loading the view.
    UIImageView *toolbar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    [toolbar setImage:[[UIImage imageNamed:@"toolbar_bg1.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:0]];
    [toolbar setUserInteractionEnabled:YES];
    toolbar.autoresizesSubviews = YES;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:toolbar];
}

-(void)viewWillAppear:(BOOL)animated
{
    tubeAppDelegate * delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([[[delegate cityMap] activePath] count]>0) {
        [self showHorizontalPathesScrollView];
    }
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

#pragma mark - Horizontal path views

-(void)showHorizontalPathesScrollView
{
    
    if (!self.horizontalPathesScrollView) {
        
        PathScrollView *pathView = [[PathScrollView alloc] initWithFrame:CGRectMake(0.0, 4.0, 320.0, 40.0)];
        self.horizontalPathesScrollView = pathView;
        self.horizontalPathesScrollView.delegate = self;
        [pathView release];
        
        [self.view addSubview:horizontalPathesScrollView];
        [self.view bringSubviewToFront:horizontalPathesScrollView];
        
    } else {
        
        [self.horizontalPathesScrollView refreshContent];
    }
    
    if ([self.horizontalPathesScrollView numberOfPages]>1) {
        if ([self helpNeeded]) {
            [self.timer invalidate];
            self.timer = nil;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                          target:horizontalPathesScrollView
                                                        selector:@selector(animateScrollView)
                                                        userInfo:nil
                                                         repeats:NO];
            
        }
    }
}

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

-(void)removeHorizontalPathesScrollView
{
    [self.horizontalPathesScrollView removeFromSuperview];
    self.horizontalPathesScrollView=nil;
}

#pragma mark - Vertical path views

-(void)redrawPathScrollView
{
    NSArray *subviews = [self.pathScrollView subviews];
    for (UIView *v in subviews) {
        [v removeFromSuperview];
    }
    
    [self.pathScrollView drawPathScrollView];
}

-(void)changeActivePath:(NSNumber*)pathNumb
{

    tubeAppDelegate *delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    MainView *mainView = (MainView*)[delegate.mainViewController view];
    [mainView.mapView selectPath:[pathNumb intValue]];
    
    if (self.pathScrollView) {
        [self performSelector:@selector(redrawPathScrollView) withObject:nil afterDelay:0.1];
    }
}

-(void)showVerticalPathScrollView
{
    if (!self.pathScrollView ) {
        
        VertPathScrollView *scview= [[VertPathScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0f, self.view.frame.size.height-44.0)];
        self.pathScrollView = scview;
        tubeAppDelegate * delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
        scview.mainController=delegate.mainViewController;
        [scview release];
        
        [self.pathScrollView drawPathScrollView];
        
        [self.view addSubview:self.pathScrollView];
        
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]] autorelease];
        shadow.frame = CGRectMake(0, 44, 320, 61);
        [shadow setIsAccessibilityElement:YES];
        shadow.tag = 2321;
        [self.view addSubview:shadow];
    }
}

@end
