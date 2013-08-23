//
//  LoginViewController.m
//  TutorialBase
//
//  Created by Antonio MG on 6/23/12.
//  Copyright (c) 2012 AMG. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "HomeworksIAPHelper.h"
#import <Parse/Parse.h>
#import "DejalActivityView.h"

@implementation LoginViewController

@synthesize userTextField = _userTextField, passwordTextField = _passwordTextField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([PFUser currentUser].isAuthenticated) {
        [PFUser logOut];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.userTextField = nil;
    self.passwordTextField = nil;
}


#pragma mark IB Actions

//Login button pressed
-(IBAction)logInPressed:(id)sender
{
    [DejalBezelActivityView activityViewForView:self.view.window withLabel:@""].showNetworkActivityIndicator = YES;
    [PFUser logInWithUsernameInBackground:self.userTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            if ([[user objectForKey:@"emailVerified"] boolValue]) {
                [[HomeworksIAPHelper sharedInstance] updateSubscriptionInfo];
            }
            else  {
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Внимание" message:@"Пожалуйста, подтвердите свой адрес электронной почты." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [errorAlertView show];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            //Something bad has ocurred
            NSNumber *errorCode = [[error userInfo] objectForKey:@"code"];
            NSString *errorString = [[HomeworksIAPHelper sharedInstance] errorWithCode:errorCode];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
        [DejalActivityView removeView];
    }];
}

@end
