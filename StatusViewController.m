//
//  StatusViewController.m
//  tube
//
//  Created by Sergey Mingalev on 04.09.12.
//
//

#import "StatusViewController.h"
#import "Classes/tubeAppDelegate.h"
#import "Reachability.h"
#import "CityMap.h"
#import "SSTheme.h"
#import <QuartzCore/QuartzCore.h>

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

        CGFloat viewWidth = [[SSThemeManager sharedTheme] statusViewWidth];
        CGFloat viewStartX = [[SSThemeManager sharedTheme] statusViewStartX];
        
        if (!IS_IPAD) {
            self.view.frame=CGRectMake(viewStartX, -454, viewWidth, 354);
            self.view.backgroundColor = [UIColor colorWithPatternImage:[[SSThemeManager sharedTheme] statusViewBackground]];
            self.view.layer.cornerRadius=5.0f;
            self.view.layer.shadowColor=[[UIColor blackColor] CGColor];
            self.view.layer.shadowOpacity = 0.8;
            self.view.layer.shadowRadius = 2;
            self.view.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);

        } else {
            self.view.frame=CGRectMake(viewStartX, 0.0, viewWidth, 1004);
            self.view.backgroundColor = [UIColor whiteColor];
        }

        self.shadowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow.png"]] autorelease];
        shadowView.frame = CGRectMake(0, 0, viewWidth, 61);
        [shadowView setIsAccessibilityElement:YES];
        [shadowView setUserInteractionEnabled:YES];
        [self.view addSubview:shadowView];
        
        self.yellowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statViewYellowBG.png"]] autorelease];
        yellowView.frame = CGRectMake(0, 44, viewWidth, 63);
        [yellowView setUserInteractionEnabled:YES];
        [self.view addSubview:yellowView];
        [yellowView setHidden:YES];
        
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
    textView.textColor = [[SSThemeManager sharedTheme] statusViewFontColor];
    
    self.updateTextView = [[[UITextView alloc] init] autorelease];
    updateTextView.editable=NO;
    updateTextView.scrollEnabled=NO;
    updateTextView.backgroundColor = [UIColor clearColor];
    updateTextView.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
    updateTextView.text=NSLocalizedString(@"UpdateMaps", @"UpdateMaps");
    updateTextView.textColor = [[SSThemeManager sharedTheme] statusViewFontColor];
    
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        textView.layer.shadowColor = [[UIColor whiteColor] CGColor];
        textView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        textView.layer.shadowOpacity = 1.0f;
        textView.layer.shadowRadius = 1.0f;
        textView.backgroundColor = [UIColor clearColor];

        updateTextView.layer.shadowColor = [[UIColor whiteColor] CGColor];
        updateTextView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        updateTextView.layer.shadowOpacity = 1.0f;
        updateTextView.layer.shadowRadius = 1.0f;
        updateTextView.backgroundColor = [UIColor clearColor];
        
        self.view.layer.cornerRadius=5.0f;
    }
    
    self.tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateMaps)] autorelease];
    [self.tapRecognizer setNumberOfTapsRequired:1];
    [self.updateTextView addGestureRecognizer:self.tapRecognizer];
    
    CGFloat viewWidth = [[SSThemeManager sharedTheme] statusViewWidth];
    
    if (IS_IPAD) {
        
        self.view.frame = CGRectMake(0.0, 0.0, viewWidth, 600.0);
        textView.frame = CGRectMake(10.0, 10.0, viewWidth-20.0f, 600.0);
        textView.scrollEnabled=YES;
        
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
        
        textView.frame = CGRectMake(10.0, 322.0, viewWidth-20.0f, 25.0);
        
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
            if ([statusInfo length]>26600) {
                [textView setText:[statusInfo substringToIndex:600]];
            } else {
                [textView setText:statusInfo];
                CGRect frame = textView.frame;
                frame.size.height += 1;
                textView.frame = frame;
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
        
        newY = -354.0f + [[SSThemeManager sharedTheme] statusViewTextY] + 30.0f;
        
        textView.scrollEnabled=NO;
        [textView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
        
        CGFloat viewWidth = [[SSThemeManager sharedTheme] statusViewWidth];
        
        self.shadowView.frame=CGRectMake(0, 324, viewWidth, 20);
        
        [UIView animateWithDuration:0.55 animations:^{
            self.view.frame = CGRectMake([[SSThemeManager sharedTheme] statusViewStartX], newY, viewWidth, 354);
        }];
        
        isShown=YES;
        
        [self  performSelector:@selector(hideInitialSizeView) withObject:nil afterDelay:4];
        
    }
}

-(void)hideInitialSizeView
{
    CGFloat newY;
    
    newY = -354.0;
    
    CGFloat viewWidth = [[SSThemeManager sharedTheme] statusViewWidth];
    
    [UIView animateWithDuration:0.55 animations:^{
        self.view.frame = CGRectMake(0, newY, viewWidth, 354);
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
    CGFloat viewWidth = [[SSThemeManager sharedTheme] statusViewWidth];
    CGFloat viewStartX = [[SSThemeManager sharedTheme] statusViewStartX];
    CGFloat viewUpdateY = [[SSThemeManager sharedTheme] statusViewUpdateY];
    CGFloat viewTextY = [[SSThemeManager sharedTheme] statusViewTextY];
    
    if (IS_IPAD) {
        self.view.frame = CGRectMake(0.0, 44.0, viewWidth, 1004.0-44.0);
        if (isNewMapAvailable) {
            updateTextView.hidden=NO;
            yellowView.hidden=NO;
            updateTextView.frame = CGRectMake(10.0, 44.0, viewWidth-20.0f, 60.0);
            textView.frame = CGRectMake(10.0, 68+40, viewWidth-20.0f, 600.0-10.0-68.0-44);
            yellowView.frame = CGRectMake(0, 40, viewWidth, 63);
        } else {
            textView.frame = CGRectMake(10.0, 44, viewWidth-20.0f, 600.0-10.0-44);
            updateTextView.hidden=YES;
            yellowView.hidden=YES;
        }
    } else {
        if (isShown) {
            self.view.frame = CGRectMake(viewStartX, 0, viewWidth, 354);
            self.shadowView.frame=CGRectMake(0, 44, viewWidth, 20);
            if (isNewMapAvailable) {
                updateTextView.hidden=NO;
                yellowView.hidden=NO;
                updateTextView.frame = CGRectMake(10.0, viewUpdateY, viewWidth, 60.0);
                textView.frame = CGRectMake(10.0, viewUpdateY+60.0f+8.0f, viewWidth-20.0f, 354.0-viewUpdateY-60.0f-8.0f);
            } else {
                textView.frame = CGRectMake(10.0, viewTextY, viewWidth-20.0f, 354.0-viewTextY-10.0);
                updateTextView.hidden=YES;
                yellowView.hidden=YES;
            }
        } else {
            self.view.frame = CGRectMake(viewStartX, -354, viewWidth, 354);
            textView.frame = CGRectMake(10.0, 322.0, viewWidth-20.0f, 25.0);
            
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

-(void)connectionFailed:(StatusDownloader*)server
{
    [servers removeObject:server];
    NSLog(@"%@",servers);
}

-(void)fixTextView:(UIInterfaceOrientation)orientation
{
    CGFloat viewWidth = [[SSThemeManager sharedTheme] statusViewWidth];
    
    if (IS_IPAD) {
        if (isNewMapAvailable) {
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                textView.frame = CGRectMake(10.0, 68+40, viewWidth-20.0f, 748-68-40);
            } else {
                textView.frame = CGRectMake(10.0, 68+40, viewWidth-20.0f, 1004-68-44);
            }
        } else {
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                textView.frame = CGRectMake(10.0, 44, viewWidth-20.0f, 748-44);
            } else {
                textView.frame = CGRectMake(10.0, 44, viewWidth-20.0, 1004-44);
            }
        }
        [textView setNeedsDisplay];
    }
}

-(void)rotateTextViewFromOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat viewWidth = [[SSThemeManager sharedTheme] statusViewWidth];
    
    if (IS_IPAD) {
        if (isNewMapAvailable) {
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                textView.frame = CGRectMake(10.0, 68+40, viewWidth-20.0f, 748-68-40);
            } else {
                textView.frame = CGRectMake(10.0, 68+40, viewWidth-20.0f, 1004-68-44);
            }
        } else {
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                textView.frame = CGRectMake(10.0, 44, viewWidth-20.0f, 748-44);
            } else {
                textView.frame = CGRectMake(10.0, 44, viewWidth-20.0f, 1004-44);
            }
        }
        [textView setNeedsDisplay];
    }
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
