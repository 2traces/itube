//
//  RatePopupViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 20/12/12.
//
//

#import <UIKit/UIKit.h>

@interface RatePopupViewController : UIViewController {
    UILabel *upperText;
    UILabel *lowerText;
    UIButton *btRateNow;
    UIButton *btFeedback;
    UIButton *btDismiss;
}

@property (nonatomic, retain) IBOutlet UILabel *upperText;
@property (nonatomic, retain) IBOutlet UILabel *lowerText;
@property (nonatomic, retain) IBOutlet UIButton *btRateNow;
@property (nonatomic, retain) IBOutlet UIButton *btFeedback;
@property (nonatomic, retain) IBOutlet UIButton *btDismiss;

- (IBAction)rateNow:(id)sender;
- (IBAction)getFeedback:(id)sender;
- (IBAction)dismissForever:(id)sender;

@end
