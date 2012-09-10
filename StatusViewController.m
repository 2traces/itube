//
//  StatusViewController.m
//  tube
//
//  Created by sergey on 04.09.12.
//
//

#import "StatusViewController.h"
#import "Classes/tubeAppDelegate.h"
#import "Reachability.h"

@implementation StatusViewController

@synthesize swipeRecognizerU,swipeRecognizerD;
@synthesize textView;
@synthesize isShown;
@synthesize infoURL;
@synthesize shadowView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.view.frame=CGRectMake(0.0, -354, 320, 354);
        UIImageView *imv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statusViewBG.png"]];
        [self.view addSubview:imv];
        [imv setUserInteractionEnabled:YES];
        [self.view sendSubviewToBack:imv];
        
        self.shadowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow.png"]] autorelease];
        shadowView.frame = CGRectMake(0, 0, 320, 61);
        [shadowView setIsAccessibilityElement:YES];
        [shadowView setUserInteractionEnabled:YES];
        [self.view insertSubview:shadowView aboveSubview:imv];

        [imv release];
    }
    return self;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isShown=NO;
    
    self.textView = [[UITextView alloc] init];
    textView.editable=NO;
    textView.scrollEnabled=NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
    textView.text=NSLocalizedString(@"NoStatusInfo", @"NoStatusInfo");
    
    if (IS_IPAD) {
        
        textView.frame = CGRectMake(10.0, 10.0, 300.0, 600.0);
    
    } else {
 
        self.swipeRecognizerD = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
        [self.swipeRecognizerD setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.view addGestureRecognizer:self.swipeRecognizerD];
        
        self.swipeRecognizerU = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
        [self.swipeRecognizerU setDirection:UISwipeGestureRecognizerDirectionUp];
        [self.view addGestureRecognizer:self.swipeRecognizerU];
        
        textView.frame = CGRectMake(10.0, 322.0, 300.0, 25.0);
    }
    
    [self.view addSubview:textView];
    [self.view bringSubviewToFront:textView];
}

-(void)statusInfoDidLoad:(NSString*)statusInfo
{
    if (statusInfo) {
            [[self textView] setText:statusInfo];
            
            if (IS_IPAD) {
                
            } else {
                if (!isShown) {
                    [self  performSelector:@selector(showInitialSizeView) withObject:nil afterDelay:3];
                }
            }
    }
}

-(void)recieveStatusInfo
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus != NotReachable) {
        StatusDownloader *statusDownloader = [[StatusDownloader alloc] init];
        statusDownloader.delegate = self;
        statusDownloader.imageURLString=infoURL;
        [statusDownloader startDownload];
    } else {
        textView.text=NSLocalizedString(@"CheckInternet", @"CheckInternet");
    }
}

-(void)refreshStatusInfo
{
    textView.text=NSLocalizedString(@"NoStatusInfo", @"NoStatusInfo");
    [self recieveStatusInfo];
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

-(void)handleSwipeDown:(UISwipeGestureRecognizer*)recognizer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self showFullSizeView];
}

-(void)handleSwipeUp:(UISwipeGestureRecognizer*)recognizer
{
    [self hideFullSizeView];
}

-(void)showInitialSizeView
{
    if (!isShown) {
        
    CGFloat newY;
    
    newY = -280.0;
    
    self.shadowView.frame=CGRectMake(0, 324, 320, 20);
    
    [UIView animateWithDuration:0.55 animations:^{
        self.view.frame = CGRectMake(0, newY, 320, 354);
    }];
    
    isShown=YES;
    
    [self  performSelector:@selector(hideInitialSizeView) withObject:nil afterDelay:4];

    }
}

-(void)hideInitialSizeView
{
    CGFloat newY;
    
    newY = -354.0;
    
    [UIView animateWithDuration:0.55 animations:^{
        self.view.frame = CGRectMake(0, newY, 320, 354);
    }];
    
    isShown=NO;
}

-(void)showFullSizeView
{
    CGFloat newY;
    
    newY = 0.0;
    
    shadowView.frame = CGRectMake(0, 44, 320, 61);
    
    [UIView animateWithDuration:0.55 animations:^{
        self.view.frame = CGRectMake(0, newY, 320, 354);
        textView.frame = CGRectMake(10.0, 44.0, 300.0, 354.0-44.0-10.0);
    }];
    
    isShown=YES;
}

-(void)hideFullSizeView
{
    CGFloat newY;
    
    newY = -354.0;
    
    [UIView animateWithDuration:0.55 animations:^{
        self.view.frame = CGRectMake(0, newY, 320, 354);
        textView.frame = CGRectMake(10.0, 322.0, 300.0, 25.0);
    }];
    
    isShown=NO;
}

@end
