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
#import "DownloadServer.h"

@class MyNavigationBar;

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate,ServerListener,DownloadServerListener>
{
    IBOutlet UITableView *langTableView;
    IBOutlet UITableView *cityTableView;
    
    IBOutlet UILabel *textLabel1;
    IBOutlet UILabel *textLabel2;   
    IBOutlet UILabel *textLabel3;   
    
    IBOutlet MyNavigationBar *navBar;
    IBOutlet UINavigationItem *navItem;
    
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UIButton *buyAllButton;
    IBOutlet UIButton *sendMailButton;   
    
    NSArray *maps;
    
    NSIndexPath *selectedPath;
    
    int requested_file_type;
}


@property (retain, nonatomic) IBOutlet UITableView *langTableView;
@property (nonatomic,retain) IBOutlet UITableView *cityTableView;
@property (retain, nonatomic) IBOutlet UIButton *cityButton;
@property (retain, nonatomic) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) NSArray *maps;
@property (nonatomic, retain) IBOutlet UILabel *textLabel1;
@property (nonatomic, retain) IBOutlet UILabel *textLabel2;
@property (nonatomic, retain) IBOutlet MyNavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSIndexPath *selectedPath;
@property (nonatomic, retain) IBOutlet UIButton *buyAllButton;
@property (nonatomic, retain) IBOutlet UIButton *sendMailButton;
@property (nonatomic, retain) IBOutlet UILabel *textLabel3;


-(IBAction)cityPress:(id)sender;
-(IBAction)buyPress:(id)sender;


@end
