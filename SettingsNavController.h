//
//  SettingsNavController.h
//  tube
//
//  Created by sergey on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface SettingsNavController : UIViewController <SettingsViewControllerDelegate>
{
    IBOutlet UINavigationController *navController;
    int purchaseIndex;
}
@property (nonatomic,retain) IBOutlet UINavigationController *navController;

@end
