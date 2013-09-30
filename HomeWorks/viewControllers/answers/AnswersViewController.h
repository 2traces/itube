//
//  AnswersViewController.h
//  HomeWorks
//
//  Created by Sergey Egorov on 4/3/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RXMLElement;

@interface AnswersViewController : UICollectionViewController

@property (nonatomic, weak) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) UIView *buyView;
@property (nonatomic, strong) UIViewController *buyViewController;
@property(nonatomic) RXMLElement *term;
@property(nonatomic) RXMLElement *subject;
@property(nonatomic) RXMLElement *book;

- (IBAction)hidePurchaseView:(id)sender;


@end
