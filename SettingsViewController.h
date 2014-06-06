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
#import "ProductMarcos.h"

@class MyNavigationBar;

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate, UIScrollViewDelegate>
{
    
    
    NSIndexPath *selectedPath;
    MBProgressHUD *_hud;
    
    
    NSMutableArray *selectedLanguages;
    
    NSTimer *timer;
    BOOL isFirstTime;
    
    id <SettingsViewControllerDelegate> delegate;
    
    NSObject * purchaseCell;
}

@property (nonatomic, assign) id <SettingsViewControllerDelegate> delegate;
@property (retain) IBOutlet UIScrollView *imagesScrollView;
@property (retain) IBOutlet UIButton *buyButton;
@property (retain) IBOutlet UIButton *buyAllButton;
@property (retain) IBOutlet UIButton *reloadButton;
@property (retain) IBOutlet UIButton *quitButton;
@property (retain) IBOutlet UIPageControl *paging;
@property (retain) NSMutableDictionary *subviewPositions;

@property (nonatomic, retain) NSIndexPath *selectedPath;
@property (assign) int purchaseIndex;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIImageView *progressArrows;
@property (nonatomic, retain) NSArray *languages;
@property (nonatomic, retain) NSArray *feedback;
@property BOOL fullProductPurchased;

-(IBAction)donePressed:(id)sender;
- (IBAction)buyFullProduct:(id)sender;


@end

@protocol SettingsViewControllerDelegate


@end
