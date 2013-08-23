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

- (IBAction)buyMonth:(id)sender;
- (IBAction)buyYear:(id)sender;

@end