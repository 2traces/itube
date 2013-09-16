//
// Created by Sergey Egorov on 6/30/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "HomeworksTableViewController.h"


@protocol BuyViewControllerDelegate

- (void)buyControllerDidFinish:(BOOL)success;

@end

@interface BuyViewController : HomeworksTableViewController

@property (nonatomic, assign) id<BuyViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UILabel *lbHeading1;
@property (nonatomic, weak) IBOutlet UILabel *lbHeading2;
@property (nonatomic, weak) IBOutlet UILabel *lbHeadingM;
@property (nonatomic, weak) IBOutlet UILabel *lbHeadingY;

@property (nonatomic, weak) IBOutlet UIImageView *bgImage;

- (IBAction)buyMonth:(id)sender;
- (IBAction)buyYear:(id)sender;

@end