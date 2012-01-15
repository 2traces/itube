//
//  InAppProductsViewController.h
//  tube
//
//  Created by sergey on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface InAppProductsViewController : UIViewController {
    MBProgressHUD *_hud;
    IBOutlet UITableView *mytableView;
}

@property (retain) MBProgressHUD *hud;
@property (nonatomic,retain) IBOutlet UITableView *mytableView;

-(IBAction)closeScreen:(id)sender;

@end
