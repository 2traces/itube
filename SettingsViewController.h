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
#import "DownloadServer.h"
#import "ProductMarcos.h"

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate,DownloadServerListener, UIScrollViewDelegate>
{
    NSArray *maps;
    
    NSString *mapID;
    
    NSIndexPath *selectedPath;
    
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
@property (retain) IBOutlet UIScrollView *imagesScrollView;
@property (retain) IBOutlet UIButton *buyButton;
@property (retain) IBOutlet UIButton *buyAllButton;
@property (retain) IBOutlet UIButton *reloadButton;
@property (retain) IBOutlet UIButton *quitButton;
@property (retain) IBOutlet UIPageControl *paging;
@property (retain) NSMutableDictionary *subviewPositions;

@property (nonatomic, retain) NSIndexPath *selectedPath;
@property (assign) int purchaseIndex;
@property (nonatomic, retain) NSMutableArray *servers;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIImageView *progressArrows;
@property (nonatomic, retain) NSArray *languages;
@property (nonatomic, retain) NSArray *feedback;
@property BOOL fullProductPurchased;

-(BOOL)isProductInstalled:(NSString*)prodID;
-(BOOL)isProductPurchased:(NSString*)prodID;
-(BOOL)isProductAvailable:(NSString*)prodID;
-(IBAction)donePressed:(id)sender;
- (IBAction)buyFullProduct:(id)sender;


@end

@protocol SettingsViewControllerDelegate


@end
