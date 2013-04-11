//
// Created by bsideup on 4/3/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <RaptureXML/RXMLElement.h>
#import "AnswerViewController.h"

@implementation AnswerViewController
{
	UIBarStyle oldBarStyle;
	UIBarStyle oldToolbarBarStyle;
	UIStatusBarStyle oldStatusBarStyle;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
	UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackTranslucent;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	oldBarStyle = self.navigationController.navigationBar.barStyle;
	oldToolbarBarStyle = self.navigationController.toolbar.barStyle;
	oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;

	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
	UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackTranslucent;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];

	self.navigationController.navigationBar.barStyle = oldBarStyle;
	self.navigationController.toolbar.barStyle = oldToolbarBarStyle;
	UIApplication.sharedApplication.statusBarStyle = oldStatusBarStyle;
}

@end