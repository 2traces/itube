//
//  SpotsListViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 25/10/13.
//
//

#import <UIKit/UIKit.h>

@class NavBarViewController;
@class Object;

@interface SpotsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NavBarViewController *navBarVC;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)updateData;
- (void)showInfoForObject:(Object*)item animated:(BOOL)animated;

@end
