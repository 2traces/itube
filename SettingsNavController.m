//
//  SettingsNavController.m
//  tube
//
//  Created by Sergey Mingalev on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsNavController.h"
#import "SettingsViewController.h"
#import "SSTheme.h"

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
    
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    
    controller.delegate = self;
    
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)supportedInterfaceOrientations
{
    return 1 << UIInterfaceOrientationPortrait;
}

-(void) dealloc
{
    self.navController=nil;
    [navController release];
    [super dealloc];
}

@end
