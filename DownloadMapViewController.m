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
    [gl downloadVisibleMap:3 withOffset:0];
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
    if (IS_IPAD) {
        
    }
    else {
        CGRect frame = self.cancelBt.frame;
        
        frame.origin.x = 0;
        frame.size.height = frame.size.height * (160.0f/frame.size.width);
        frame.size.width = 160;
        
        self.cancelBt.frame = frame;
        self.cancelBt.autoresizingMask = UIViewAutoresizingNone;
        
        frame = self.downloadBt.frame;
        
        frame.origin.x = 160;
        frame.size.height = frame.size.height * (160.0f/frame.size.width);
        frame.size.width = 160;
        
        self.downloadBt.frame = frame;
        self.downloadBt.autoresizingMask = UIViewAutoresizingNone;

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
