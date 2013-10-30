//
//  SpotInfoViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 30/10/13.
//
//

#import <UIKit/UIKit.h>
#import "GlViewController.h"

@interface SpotInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) Object *spotInfo;
@property (nonatomic, retain) IBOutlet UIView *shareView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
