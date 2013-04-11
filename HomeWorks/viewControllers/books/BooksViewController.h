//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "HomeworksTableViewController.h"

@class RXMLElement;


@interface BooksViewController : HomeworksTableViewController

@property(nonatomic) RXMLElement *term;
@property(nonatomic) RXMLElement *subject;

@end