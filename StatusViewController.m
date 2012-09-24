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
#import "CityMap.h"

@implementation StatusViewController

@synthesize swipeRecognizerU,swipeRecognizerD;
@synthesize textView,updateTextView;
@synthesize isShown;
@synthesize infoURL;
@synthesize shadowView;
@synthesize isNewMapAvailable;
@synthesize servers;
@synthesize tapRecognizer;
@synthesize yellowView;
@synthesize isStatusRecieved;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {

        UIImageView *imv;
        if (!IS_IPAD) {
            imv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statusViewBG.png"]];
            self.view.frame=CGRectMake(0.0, -354, 320, 354);
        } else {
            imv = [[UIImageView alloc] init];
            imv.hidden=YES;
            self.view.frame=CGRectMake(0.0, 0.0, 320, 1004);
            self.view.backgroundColor = [UIColor whiteColor];
        }

        [self.view addSubview:imv];
        [imv setUserInteractionEnabled:YES];
        [self.view sendSubviewToBack:imv];
        
        self.shadowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow.png"]] autorelease];
        shadowView.frame = CGRectMake(0, 0, 320, 61);
        [shadowView setIsAccessibilityElement:YES];
        [shadowView setUserInteractionEnabled:YES];
        [self.view insertSubview:shadowView aboveSubview:imv];
        
        self.yellowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statViewYellowBG.png"]] autorelease];
        yellowView.frame = CGRectMake(0, 44, 320, 63);
        [yellowView setUserInteractionEnabled:YES];
        [self.view insertSubview:yellowView aboveSubview:imv];
        [yellowView setHidden:YES];
        
        [imv release];
        
        self.servers=[NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isShown=NO;
    isNewMapAvailable=NO;
    isStatusRecieved=NO;
    
    self.textView = [[[UITextView alloc] initWithFrame:CGRectZero] autorelease];
    textView.editable=NO;
    textView.scrollEnabled=NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
    textView.text=NSLocalizedString(@"NoStatusInfo", @"NoStatusInfo");
    
    self.updateTextView = [[[UITextView alloc] init] autorelease];
    updateTextView.editable=NO;
    updateTextView.scrollEnabled=NO;
    updateTextView.backgroundColor = [UIColor clearColor];
    updateTextView.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
    updateTextView.text=NSLocalizedString(@"UpdateMaps", @"UpdateMaps");
    
    self.tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateMaps)] autorelease];
    [self.tapRecognizer setNumberOfTapsRequired:1];
    [self.updateTextView addGestureRecognizer:self.tapRecognizer];
    
    if (IS_IPAD) {
        
        self.view.frame = CGRectMake(0.0, 0.0, 320.0, 600.0);
        textView.frame = CGRectMake(10.0, 10.0, 300.0, 600.0);
        
    } else {
        
        self.swipeRecognizerD = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)] autorelease];
        [self.swipeRecognizerD setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.view addGestureRecognizer:self.swipeRecognizerD];
        
//        self.swipeRecognizerU = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)] autorelease];
//        [self.swipeRecognizerU setDirection:UISwipeGestureRecognizerDirectionUp];
//        [self.view addGestureRecognizer:self.swipeRecognizerU];
        
        self.tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)] autorelease];
        [self.tapRecognizer setNumberOfTapsRequired:1];
        [self.view addGestureRecognizer:self.tapRecognizer];
        
        textView.frame = CGRectMake(10.0, 322.0, 300.0, 25.0);
    }
    
    [self.view addSubview:updateTextView];
    [self.view addSubview:textView];
    [self.view bringSubviewToFront:textView];
}



-(void)statusInfoDidLoad:(NSString*)statusInfo server:(StatusDownloader*)server
{
    if (statusInfo) {
        [[self textView] setText:statusInfo];
        isStatusRecieved=YES;
        
        if (IS_IPAD) {
            if ([statusInfo length]>600) {
                [[self textView] setText:[statusInfo substringToIndex:600]];
            } else {
                [[self textView] setText:statusInfo];
            }
        } else {
            if (!isShown) {
                [self  performSelector:@selector(showInitialSizeView) withObject:nil afterDelay:3];
            }
        }
    }
    
    [servers removeObject:server];
}

-(void)recieveStatusInfo
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus != NotReachable) {
        StatusDownloader *statusDownloader = [[StatusDownloader alloc] init];
        statusDownloader.delegate = self;
        statusDownloader.imageURLString=infoURL;
        [statusDownloader startDownload];
        
        [servers addObject:statusDownloader];
        [statusDownloader release];
        
        [self checkNewMaps];
        
    } else {
        textView.text=NSLocalizedString(@"CheckInternet", @"CheckInternet");
    }
}

-(void)refreshStatusInfo
{
    isNewMapAvailable=NO;
    isStatusRecieved=NO;
    textView.text=NSLocalizedString(@"NoStatusInfo", @"NoStatusInfo");
    [self recieveStatusInfo];
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self showFullSizeView];
}

-(void)handleSwipeUp:(UISwipeGestureRecognizer*)recognizer
{
    [self hideFullSizeView];
}

-(void)showInitialSizeView
{
    if (!isShown) {
        
        CGFloat newY;
        
        newY = -280.0;
        
        textView.scrollEnabled=NO;
        [textView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
        
        self.shadowView.frame=CGRectMake(0, 324, 320, 20);
        
        [UIView animateWithDuration:0.55 animations:^{
            self.view.frame = CGRectMake(0, newY, 320, 354);
        }];
        
        isShown=YES;
        
        [self  performSelector:@selector(hideInitialSizeView) withObject:nil afterDelay:4];
        
    }
}

-(void)hideInitialSizeView
{
    CGFloat newY;
    
    newY = -354.0;
    
    [UIView animateWithDuration:0.55 animations:^{
        self.view.frame = CGRectMake(0, newY, 320, 354);
    }];
    
    isShown=NO;
}

-(void)showFullSizeView
{
    isShown=YES;
    
    textView.scrollEnabled=YES;
    [textView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    
    [UIView animateWithDuration:0.55 animations:^{
        [self layoutSubviews];
    }];
}

-(void)hideFullSizeView
{
    isShown=NO;
    
    textView.scrollEnabled=NO;
    [UIView animateWithDuration:0.55 animations:^{
        [self layoutSubviews];
    }];
}

-(void)layoutSubviews
{
    if (IS_IPAD) {
        self.view.frame = CGRectMake(0.0, 44.0, 320.0, 1004.0-44.0);
        if (isNewMapAvailable) {
            updateTextView.hidden=NO;
            yellowView.hidden=NO;
            updateTextView.frame = CGRectMake(10.0, 44.0, 300.0, 60.0);
            textView.frame = CGRectMake(10.0, 68+40, 300.0, 600.0-10.0-68.0-44);
            yellowView.frame = CGRectMake(0, 40, 320, 63);
        } else {
            textView.frame = CGRectMake(10.0, 44, 300.0, 600.0-10.0-44);
            updateTextView.hidden=YES;
            yellowView.hidden=YES;
        }
    } else {
        if (isShown) {
            self.view.frame = CGRectMake(0, 0, 320, 354);
            self.shadowView.frame=CGRectMake(0, 44, 320, 20);
            if (isNewMapAvailable) {
                updateTextView.hidden=NO;
                yellowView.hidden=NO;
                updateTextView.frame = CGRectMake(10.0, 48.0, 300.0, 60.0);
                textView.frame = CGRectMake(10.0, 44.0+68, 300.0, 354.0-44.0-10.0-68);
            } else {
                textView.frame = CGRectMake(10.0, 44.0, 300.0, 354.0-44.0-10.0);
                updateTextView.hidden=YES;
                yellowView.hidden=YES;
            }
        } else {
            self.view.frame = CGRectMake(0, -354, 320, 354);
            textView.frame = CGRectMake(10.0, 322.0, 300.0, 25.0);
            
        }
    }
}

-(void)checkNewMaps
{
    DownloadServer *server = [[[DownloadServer alloc] init] autorelease];
    server.listener=self;
    
    [servers addObject:server];
    
    NSString *bundleName = [NSString stringWithFormat:@"%@.plist",[[NSBundle mainBundle] bundleIdentifier]];
    [server loadFileAtURL:bundleName];
}

-(void)downloadDone:(NSMutableData *)data prodID:(NSString*)prodID server:(DownloadServer *)myid
{
    [self processPlistFromServer:data];
    [servers removeObject:myid];
}

-(void)processPlistFromServer:(NSMutableData*)data
{
    NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
    
    NSString *newVersionN = [self getCurrentMapVersionFromDict:dict];
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    
    NSMutableDictionary *mapFile = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString *oldVersionN = [self getCurrentMapVersionFromDict:mapFile];
    
    if (newVersionN && oldVersionN) {
        if ([oldVersionN integerValue]<[newVersionN integerValue]) {
            isNewMapAvailable=YES;
        } else {
            isNewMapAvailable=NO;
        }
    }
    
    [mapFile release];
}

-(NSString*)getCurrentMapVersionFromDict:(NSDictionary*)dict
{
    NSString *verNumber = nil;
    
    NSString *currentMap = [[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName];
    
    NSArray *mapIDs = [dict allKeys];
    
    for (NSString* mapID in mapIDs) {
        NSDictionary *map = [dict objectForKey:mapID];
        if ([[map objectForKey:@"filename"] isEqual:currentMap]) {
            verNumber = [NSString stringWithString:[map objectForKey:@"ver"]];
        }
    }
    
    return verNumber;
}

-(void)updateMaps
{
    if (IS_IPAD) {
        // show setting modal
        [[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] mainViewController] showiPadSettingsModalView];
    } else {
        [self hideFullSizeView];
        [[[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] mainViewController] view] showSettings];
    }
}

-(void)startDownloading:(NSString*)prodID
{
    
}

-(void)downloadedBytes:(float)part prodID:(NSString*)prodID
{
    
}

-(void)downloadFailed:(DownloadServer*)myid
{
    
}

-(void)dealloc
{
    [tapRecognizer release];
    [swipeRecognizerD release];
    [swipeRecognizerU release];
    [updateTextView release];
    [textView release];
    [infoURL release];
    [shadowView release];
    [servers release];
    [super dealloc];
}

@end
