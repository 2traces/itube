//
//  StatusViewController.m
//  tube
//
//  Created by sergey on 04.09.12.
//
//

#import "StatusViewController.h"
#import "Classes/tubeAppDelegate.h"
#import "Reachability.h"

@implementation StatusViewController

@synthesize swipeRecognizerU,swipeRecognizerD;
@synthesize textView;

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

    self.textView = [[UITextView alloc] init];
    textView.editable=NO;
    textView.scrollEnabled=NO;
    textView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:textView];
    textView.font = [UIFont systemFontOfSize:15.0f];
    
    if (IS_IPAD) {
        textView.frame = CGRectMake(10.0, 10.0, 300.0, 600.0);
    } else {
        self.swipeRecognizerD = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
        [self.swipeRecognizerD setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.view addGestureRecognizer:self.swipeRecognizerD];
        
        self.swipeRecognizerU = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
        [self.swipeRecognizerU setDirection:UISwipeGestureRecognizerDirectionUp];
        [self.view addGestureRecognizer:self.swipeRecognizerU];
        
        textView.frame = CGRectMake(10.0, 375.0, 300.0, 20.0);
    }
}

-(NSString*)getStatusInfoURL
{
    NSString *url;
    
    NSString *currentMap = [[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName];
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSArray *mapIDs = [dict allKeys];
    for (NSString* mapID in mapIDs) {
        NSDictionary *map = [dict objectForKey:mapID];
        if ([[map objectForKey:@"filename"] isEqual:currentMap]) {
            url = [map objectForKey:@"statusURL"];
        }
    }
    
    return url;
}


-(void)statusInfoDidLoad:(NSString*)statusInfo
{
    [[self textView] setText:statusInfo];

    if (IS_IPAD) {

    } else {
        [self showInitialSizeView];
        [self  performSelector:@selector(hideInitialSizeView) withObject:nil afterDelay:3];
    }
}

-(void)recieveStatusInfo
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    NSString *url = [self getStatusInfoURL];
    
    if (url) {
        if (netStatus != NotReachable) {
            StatusDownloader *statusDownloader = [[StatusDownloader alloc] init];
            statusDownloader.delegate = self;
            statusDownloader.imageURLString=url;
            [statusDownloader startDownload];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)handleSwipeDown:(UISwipeGestureRecognizer*)recognizer
{
    [StatusViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideInitialSizeView) object:nil];
    [self showFullSizeView];
}

-(void)handleSwipeUp:(UISwipeGestureRecognizer*)recognizer
{
    [self hideFullSizeView];
}

-(void)showInitialSizeView
{
    CGFloat newY;
    
    newY = -326.0;
    
    [UIView animateWithDuration:0.55 animations:^{
        self.view.frame = CGRectMake(0, newY, 320, 400);
    }];

}

-(void)hideInitialSizeView
{
    CGFloat newY;
    
    newY = -400.0;
    
    [UIView animateWithDuration:0.55 animations:^{
        self.view.frame = CGRectMake(0, newY, 320, 400);
    }];
    
}

-(void)showFullSizeView
{
    CGFloat newY;
    
    newY = 0.0;
    
    [UIView animateWithDuration:0.55 animations:^{
        self.view.frame = CGRectMake(0, newY, 320, 400);
        textView.frame = CGRectMake(10.0, 10.0, 300.0, 380.0);
    }];
}

-(void)hideFullSizeView
{
    CGFloat newY;
    
    newY = -400.0;
    
    [UIView animateWithDuration:0.55 animations:^{
        self.view.frame = CGRectMake(0, newY, 320, 400);
        textView.frame = CGRectMake(10.0, 375.0, 300.0, 20.0);
    }];
}

@end
