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
#import "MBProgressHUD.h"

@class MyNavigationBar;

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate,DownloadServerListener>
{
    IBOutlet UITableView *langTableView;
    IBOutlet UITableView *cityTableView;
    
    IBOutlet UILabel *textLabel1;
    IBOutlet UILabel *textLabel2;   
    IBOutlet UILabel *textLabel3;   
    
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UIButton *buyAllButton;
    IBOutlet UIButton *sendMailButton;   
    
    NSArray *maps;
    
    NSIndexPath *selectedPath;
    MBProgressHUD *_hud;
    
    int requested_file_type;
    
    id <SettingsViewControllerDelegate> delegate;
}

@property (nonatomic,assign) id <SettingsViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableView *langTableView;
@property (nonatomic,retain) IBOutlet UITableView *cityTableView;
@property (retain, nonatomic) IBOutlet UIButton *cityButton;
@property (retain, nonatomic) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) NSArray *maps;
@property (nonatomic, retain) IBOutlet UILabel *textLabel1;
@property (nonatomic, retain) IBOutlet UILabel *textLabel2;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSIndexPath *selectedPath;
@property (nonatomic, retain) IBOutlet UIButton *buyAllButton;
@property (nonatomic, retain) IBOutlet UIButton *sendMailButton;
@property (nonatomic, retain) IBOutlet UILabel *textLabel3;
@property (retain) MBProgressHUD *hud;

-(BOOL)isProductInstalled:(NSString*)prodID;
-(BOOL)isProductPurchased:(NSString*)prodID;
-(BOOL)isProductAvailable:(NSString*)prodID;

@end

@protocol SettingsViewControllerDelegate

-(void)donePressed;

@end
