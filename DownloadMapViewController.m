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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Free version" message:@"You can't download offline map in a free version. Please, purchase a full version." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show in AppStore", nil];
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
