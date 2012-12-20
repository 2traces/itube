//
//  RatePopupViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 20/12/12.
//
//

#import "RatePopupViewController.h"
#import "tubeAppDelegate.h"

@interface RatePopupViewController ()

@end

@implementation RatePopupViewController

@synthesize upperText;
@synthesize lowerText;
@synthesize btDismiss;
@synthesize btFeedback;
@synthesize btRateNow;

- (IBAction)rateNow:(id)sender {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate rateNowFromPopup:self];
    [self updateButtons];

}

- (IBAction)getFeedback:(id)sender {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate rateFeedbackFromPopup:self];
    [self updateButtons];

}

- (IBAction)dismissForever:(id)sender {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate rateDismissFromPopup:self];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    self.view.frame = windowBounds;
    
    // Do any additional setup after loading the view from its nib.
    NSString *cancelButtonLabel = NSLocalizedString(@"No, Thanks", @"No, Thanks");
    NSString *rateButtonLabel = NSLocalizedString(@"Rate It Now", @"Rate It Now");
    NSString *mailButtonLabel = NSLocalizedString(@"Drop Us An EMail", @"Drop Us An EMail");
    NSString *rateLabel = NSLocalizedString(@"Rate", @"Rate");
    NSString *rateMessageLabel =NSLocalizedString(@"RateMessage", @"RateMessage");
    NSString *rateMessageBold =NSLocalizedString(@"RateBoldMessage", @"RateBoldMessage");
    
    self.upperText.text = rateMessageLabel;
    self.lowerText.text = rateLabel;
    [self.btRateNow setTitle:rateButtonLabel forState:UIControlStateNormal];
    [self.btFeedback setTitle:mailButtonLabel forState:UIControlStateNormal];
    [self.btDismiss setTitle:cancelButtonLabel forState:UIControlStateNormal];
    
    self.upperText.font = self.lowerText.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0f];
    self.btRateNow.titleLabel.font = self.btFeedback.titleLabel.font = self.btDismiss.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:19.0f];
    
    [self.btRateNow setTitleEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)];
    [self.btFeedback setTitleEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)];
    [self.btDismiss setTitleEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)];
    
    
    if ([self.upperText respondsToSelector:@selector(setAttributedText:)])
    {
        // iOS6 and above : Use NSAttributedStrings
        UIFont *boldFont = [UIFont fontWithName:@"MyriadPro-Semibold" size:16.0f];
        UIFont *regularFont = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0f];
        
        // Create the attributes
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               regularFont, NSFontAttributeName,
                               nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  boldFont, NSFontAttributeName, nil];
        const NSRange range = [rateMessageLabel rangeOfString:rateMessageBold]; // range of " 2012/10/14 ". Ideally this should not be hardcoded
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:rateMessageLabel
                                               attributes:attrs];
        [attributedText setAttributes:subAttrs range:range];
        
        // Set it in our UILabel and we are done!
        [self.upperText setAttributedText:attributedText];
    } else {
        // iOS5 and below

        
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
