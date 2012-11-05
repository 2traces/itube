//
//  CategoriesViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
//
//

#import <UIKit/UIKit.h>

@interface CategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tableView;
    UIScrollView *scrollView;
    UIButton *buttonSettings;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton *buttonSettings;

@end
