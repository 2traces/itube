//
//  SettingsViewController.h
//  tube
//
//  Created by Sergey Mingalev on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <QuartzCore/QuartzCore.h>
#import "Server.h"
#import "DownloadServer.h"
#import "MBProgressHUD.h"
#import "DemoMapViewController.h"

@class MyNavigationBar;

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate,DownloadServerListener,DemoMapProtocol>
{
    IBOutlet UITableView *langTableView;
    IBOutlet UITableView *cityTableView;
    IBOutlet UITableView *feedbackTableView;
    
    IBOutlet UILabel *textLabel1;
    IBOutlet UILabel *textLabel2;   
    IBOutlet UILabel *textLabel3;   
    IBOutlet UILabel *textLabel4;   
    
    IBOutlet UIButton *updateButton;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *updateImageView;
    
    NSArray *maps;
    
    NSIndexPath *selectedPath;
    MBProgressHUD *_hud;
    
    IBOutlet UIImageView *progressArrows;
    
    int requested_file_type;
    
    NSMutableArray *servers;
    NSMutableArray *selectedLanguages;
    
    NSTimer *timer;
    BOOL isFirstTime;
    NSObject * purchaseCell;
    NSString *mapID;

    id <SettingsViewControllerDelegate> delegate;
}

@property (assign) int purchaseIndex;
@property (nonatomic, assign) id <SettingsViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableView *langTableView;
@property (nonatomic, retain) IBOutlet UITableView *cityTableView;
@property (nonatomic, retain) IBOutlet UITableView *feedbackTableView;
@property (nonatomic, retain) NSArray *maps;
@property (nonatomic, retain) IBOutlet UILabel *textLabel1;
@property (nonatomic, retain) IBOutlet UILabel *textLabel2;
@property (nonatomic, retain) IBOutlet UILabel *textLabel3;
@property (nonatomic, retain) IBOutlet UILabel *textLabel4;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSIndexPath *selectedPath;
@property (retain) MBProgressHUD *hud;
@property (nonatomic, retain) NSMutableArray *servers;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIImageView *progressArrows;
@property (nonatomic, retain) NSArray *languages;
@property (nonatomic, retain) NSMutableArray *feedback;
@property (nonatomic, retain) IBOutlet UIButton *updateButton;
@property (nonatomic, retain) IBOutlet UIImageView *updateImageView;

-(BOOL)isProductInstalled:(NSString*)prodID;
-(BOOL)isProductPurchased:(NSString*)prodID;
-(BOOL)isProductAvailable:(NSString*)prodID;
+ (BOOL) isOfflineMapInstalled;

@end

@protocol SettingsViewControllerDelegate

-(void)donePressed;

@end
