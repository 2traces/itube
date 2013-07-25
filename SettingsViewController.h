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
#import "DemoMapViewController.h"

@class MyNavigationBar;

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate,DownloadServerListener>
{
    NSArray *maps;
    
    NSString *mapID;
    
    NSIndexPath *selectedPath;
    MBProgressHUD *_hud;
    
    int requested_file_type;
    
    NSMutableArray *servers;
    NSMutableArray *selectedLanguages;
    
    NSTimer *timer;
    BOOL isFirstTime;
    
    id <SettingsViewControllerDelegate> delegate;
    
    NSObject * purchaseCell;
}

@property (nonatomic, assign) id <SettingsViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray *maps;
@property (nonatomic, retain) IBOutlet UIScrollView *imagesScrollView;
@property (nonatomic, retain) NSIndexPath *selectedPath;
@property (assign) int purchaseIndex;
@property (nonatomic, retain) NSMutableArray *servers;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIImageView *progressArrows;
@property (nonatomic, retain) NSArray *languages;
@property (nonatomic, retain) NSArray *feedback;

-(BOOL)isProductInstalled:(NSString*)prodID;
-(BOOL)isProductPurchased:(NSString*)prodID;
-(BOOL)isProductAvailable:(NSString*)prodID;
-(IBAction)donePressed:(id)sender;


@end

@protocol SettingsViewControllerDelegate


@end
