//
//  SuggestionsViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 4/11/13.
//
//

#import <UIKit/UIKit.h>

@class NavigationViewController;

@interface SuggestionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) IBOutlet UIImageView *headingBg;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NavigationViewController *navVC;

@end
