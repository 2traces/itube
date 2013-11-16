//
//  SpotInfoViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 30/10/13.
//
//

#import <UIKit/UIKit.h>
#import "GlViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@class NavBarViewController;

@interface SpotInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, retain) Object *spotInfo;
@property (nonatomic, retain) IBOutlet UIView *shareView;
@property (nonatomic, retain) IBOutlet UILabel *shareLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NavBarViewController *navBarVC;
@property (nonatomic, retain) SLComposeViewController *mySLComposerSheet;

- (IBAction)shareFacebook:(id)sender;
- (IBAction)shareTwitter:(id)sender;
- (IBAction)shareMail:(id)sender;
- (IBAction)shareSMS:(id)sender;

- (void)setup;

@end
