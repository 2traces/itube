//
//  AnswersViewController.h
//  HomeWorks
//
//  Created by Sergey Egorov on 4/3/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RXMLElement;

@interface AnswersViewController : PSUICollectionViewController

@property(nonatomic, strong) RXMLElement *book;
@end
