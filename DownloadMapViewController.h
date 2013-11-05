//
//  DownloadMapViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 5/11/13.
//
//

#import <UIKit/UIKit.h>

@interface DownloadMapViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *topBg;
@property (nonatomic, retain) IBOutlet UIImageView *bottomBg;
@property (nonatomic, retain) IBOutlet UIButton *cancelBt;
@property (nonatomic, retain) IBOutlet UIButton *downloadBt;

- (IBAction)close:(id)sender;
- (IBAction)download:(id)sender;

@end
