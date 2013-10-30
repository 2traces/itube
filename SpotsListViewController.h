//
//  SpotsListViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 25/10/13.
//
//

#import <UIKit/UIKit.h>

@interface SpotsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)loadItems:(NSArray*)items;

@end
