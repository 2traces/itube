//
//  SelectingTabBarViewController.h
//  tube
//
//  Created by Sergey Mingalev on 10.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMapChanged @"kMapChanged"
#define kLangChanged @"kLangChanged"

@protocol SelectingTabBarProtocol;

@interface SelectingTabBarViewController : UIViewController
{
    IBOutlet UIButton *stationButton;
    IBOutlet UIButton *linesButton; 
    IBOutlet UIButton *bookmarkButton;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *historyButton;
    IBOutlet UIButton *settingsButton;
    
    IBOutlet UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIButton *stationButton;
@property (nonatomic, retain) IBOutlet UIButton *linesButton;
@property (nonatomic, retain) IBOutlet UIButton *bookmarkButton;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *historyButton;
@property (nonatomic, retain) IBOutlet UIButton *settingsButton;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, assign) id <SelectingTabBarProtocol> delegate;

-(IBAction)stationsPressed:(id)sender;
-(IBAction)linesPresses:(id)sender;
-(IBAction)bookmarkPressed:(id)sender;
-(IBAction)historyPressed:(id)sender;
-(IBAction)settingsPressed:(id)sender;
-(IBAction)backPressed:(id)sender;

@end

@protocol SelectingTabBarProtocol

-(void)returnFromSelection:(NSArray*)stations;    

@end