//
//  SettingsViewController.h
//  tube
//
//  Created by sergey on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <QuartzCore/QuartzCore.h>
#import "Server.h"

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate,ServerListener>
{
    IBOutlet UITableView *mytableView;
}


@property (retain, nonatomic) IBOutlet UITableView *mytableView;
@property (retain, nonatomic) IBOutlet UIButton *cityButton;
@property (retain, nonatomic) IBOutlet UIButton *buyButton;

-(IBAction)cityPress:(id)sender;
-(IBAction)buyPress:(id)sender;
-(IBAction)showMailComposer:(id)sender;

@end
