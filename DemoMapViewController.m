//
//  DemoMapViewController.m
//  tube
//
//  Created by sergey on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DemoMapViewController.h"

@interface DemoMapViewController ()

@end

@implementation DemoMapViewController

@synthesize scrollView;
@synthesize text1;
@synthesize text2;
@synthesize text3;
@synthesize image1;
@synthesize image2;
@synthesize image3;
@synthesize cityName;
@synthesize delegate;
@synthesize filename,prodID;

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
    
    scrollView.frame = CGRectMake(0.0, 0.0, 320, 416);
    scrollView.contentSize = CGSizeMake(320, 939);
    
    text1.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0];
    text2.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0];
    text3.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0];
    
    NSString *fn1 = [NSString stringWithFormat:@"%@1.png",filename];
    [image1 setImage:[UIImage imageNamed:fn1]];

    NSString *fn2 = [NSString stringWithFormat:@"%@2.png",filename];
    [image2 setImage:[UIImage imageNamed:fn2]];

    NSString *fn3 = [NSString stringWithFormat:@"%@3.png",filename];
    [image3 setImage:[UIImage imageNamed:fn3]];

    [self.view addSubview:scrollView];
    
    [scrollView scrollsToTop];
    
    // Do any additional setup after loading the view from its nib.
    
    
    UIView *iv = [[UIView alloc] initWithFrame:CGRectMake(0,0,160,44)];
    CGRect frame = CGRectMake(0, 3, 160, 44);
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0];
    //	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor darkGrayColor];
    label.text = cityName;
    [iv addSubview:label];
    self.navigationItem.titleView=iv;
	
    UIImage *back_image=[UIImage imageNamed:@"settings_back_button.png"];
	UIButton *back_button = [UIButton buttonWithType:UIButtonTypeCustom];
	back_button.bounds = CGRectMake( 0, 0, back_image.size.width, back_image.size.height );    
	[back_button setBackgroundImage:back_image forState:UIControlStateNormal];
	[back_button addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];    
	UIBarButtonItem *barButtonItem_back = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    self.navigationItem.leftBarButtonItem = barButtonItem_back;
    self.navigationItem.hidesBackButton=YES;
	[barButtonItem_back release];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)donePressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)buyPressed:(id)sender
{
    [delegate returnWithPurchase:prodID];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
