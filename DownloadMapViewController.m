//
//  DownloadMapViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 5/11/13.
//
//

#import "DownloadMapViewController.h"
#import "CrossDeviceMarcos.h"
#import "GlViewController.h"
#import "tubeAppDelegate.h"

@interface DownloadMapViewController ()

@end

@implementation DownloadMapViewController


- (IBAction)close:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)download:(id)sender {
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    GlViewController *gl = appDelegate.glViewController;
    
#ifdef SPOTS_FULL
    self.loadingView.hidden = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [gl downloadVisibleMap:3 withOffset:1];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.loadingView.hidden = YES;
            [self close:nil];
        });
    });
#elif SPOTS_FREE
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Free version heading", @"") message:NSLocalizedString(@"Free version message 2", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Free version appstore button", @""), nil];
    [alertView show];
    [alertView release];
#endif


    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL_FULL]];
            break;
        default:
            break;
    }
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (IS_IPAD) {
        
    }
    else {
        CGRect frame = self.cancelBt.frame;
        
        frame.origin.x = 20;
        frame.origin.y += 30;

        frame.size.height = frame.size.height * (140.0f/frame.size.width);
        frame.size.width = 140;
        
        self.cancelBt.frame = frame;
        self.cancelBt.autoresizingMask = UIViewAutoresizingNone;
        
        frame = self.downloadBt.frame;
        
        frame.origin.x = 160;
        frame.origin.y += 30;
        frame.size.height = frame.size.height * (140.0f/frame.size.width);
        frame.size.width = 140;
        
        self.downloadBt.frame = frame;
        self.downloadBt.autoresizingMask = UIViewAutoresizingNone;
        
        UIFont *font = self.downloadBt.titleLabel.font;
        
        self.downloadBt.titleLabel.font = [font fontWithSize:14];
        self.cancelBt.titleLabel.font = [font fontWithSize:14];
        
        frame = self.downloadLb.frame;
        frame.size.width -= 50;
        frame.origin.x += 25;
        self.downloadLb.frame = frame;
        
        frame = self.bottomBg.frame;
        frame.origin.y += 50;
        self.bottomBg.frame = frame;
        
    }
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
    // Do any additional setup after loading the view from its nib.
    self.bottomBg.image = [[UIImage imageNamed:@"download_lower_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    self.topBg.image = [[UIImage imageNamed:@"download_upper_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];

    
    [self.downloadBt setTitle:NSLocalizedString(@"Download button", @"") forState:UIControlStateNormal];
    [self.cancelBt setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    self.downloadLb.text = NSLocalizedString(@"Download label", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
