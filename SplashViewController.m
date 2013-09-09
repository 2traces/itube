//
//  SplashViewController.m
//  tube
//
//  Created by sergey on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "tubeAppDelegate.h"

@implementation SplashViewController

@synthesize splashImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// Init the view
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *view = [[UIView alloc] initWithFrame:appFrame];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.view = view;
	[view release];
	
	self.splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash.png"]];
	self.splashImageView.frame = CGRectMake(0, 0, 320, 480);
	[self.view addSubview:self.splashImageView];
    
    [self performSelector:@selector(fadeScreen) withObject:nil afterDelay:0.01];
}

- (void)fadeScreen
{
    tubeAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	delegate.glViewController.view.alpha = 0.0;
//	[self.view addSubview:delegate.mainViewController.view];
    [delegate.window addSubview:delegate.glViewController.view];
	
//	timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(fadeScreen) userInfo:nil repeats:NO];

	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:0.75];        // sets animation duration
	[UIView setAnimationDelegate:self];        // sets delegate for this block
	[UIView setAnimationDidStopSelector:@selector(finishedFading)];   // calls the finishedFading method when the animation is done (or done fading out)	
	self.view.alpha = 0.0;       // Fades the alpha channel of this view to "0.0" over the animationDuration of "0.75" seconds
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
}


- (void) finishedFading
{
    tubeAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	
	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:0.75];        // sets animation duration
	self.view.alpha = 1.0;   // fades the view to 1.0 alpha over 0.75 seconds
	delegate.glViewController.view.alpha = 1.0;
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
	[splashImageView removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
