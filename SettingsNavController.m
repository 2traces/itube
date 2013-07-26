//
//  SettingsNavController.m
//  tube
//
//  Created by sergey on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsNavController.h"
#import "SettingsViewController.h"
#import "CrossDeviceMarcos.h"

@interface SettingsNavController ()

@end

@implementation SettingsNavController
@synthesize navController;

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
    NSString *controllerName;
    if (IS_IPAD) {
        controllerName = @"SettingsViewController_iPad";
    }else{
        controllerName = @"SettingsViewController";
    }
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:controllerName bundle:[NSBundle mainBundle]];
    
    controller.delegate = self;
    controller.purchaseIndex = purchaseIndex;
    
    [navController pushViewController:controller animated:NO];
    
    [controller release];

    [self.view addSubview:[navController view]];
}

-(void)donePressed
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation -= UIInterfaceOrientationPortrait);
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void) dealloc
{
    [navController release];
    [super dealloc];
}

@end
