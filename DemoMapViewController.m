//
//  DemoMapViewController.m
//  tube
//
//  Created by sergey on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DemoMapViewController.h"
#import "Reachability.h"
#import "tubeAppDelegate.h"
#import "ImageDownloader.h"

@interface DemoMapViewController ()

@end

@implementation DemoMapViewController

@synthesize scrollView;
@synthesize text1;
@synthesize text2;
@synthesize text3;
@synthesize image1;
@synthesize image2;
@synthesize image3;
@synthesize buyButton;
@synthesize cityName;
@synthesize delegate;
@synthesize filename,prodID;
@synthesize imageDownloadsInProgress;

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
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
        
    scrollView.frame = CGRectMake(0.0, 0.0, 320, 416);
    scrollView.contentSize = CGSizeMake(320, 939);
    
    text1.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0];
    text2.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0];
    text3.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0];
    
    [self loadImagesForScreen];
        
    [self.view addSubview:scrollView];
    
    [scrollView scrollsToTop];
    
    // Do any additional setup after loading the view from its nib.    
    
    UIView *iv = [[UIView alloc] initWithFrame:CGRectMake(0,0,160,44)];
    CGRect frame = CGRectMake(0, 3, 160, 44);
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0];
    //	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor darkGrayColor];
    label.text = cityName;
    [iv addSubview:label];
    self.navigationItem.titleView=iv;
    [iv release];
	
    UIImage *back_image=[UIImage imageNamed:@"demo_back.png"];
    UIImage *back_image_high=[UIImage imageNamed:@"demo_back_high.png"];
	UIButton *back_button = [UIButton buttonWithType:UIButtonTypeCustom];
	back_button.bounds = CGRectMake( 0, 0, back_image.size.width, back_image.size.height );    
	[back_button setBackgroundImage:back_image forState:UIControlStateNormal];
    [back_button setBackgroundImage:back_image_high forState:UIControlStateHighlighted];
	[back_button addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];    
	UIBarButtonItem *barButtonItem_back = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    self.navigationItem.leftBarButtonItem = barButtonItem_back;
    self.navigationItem.hidesBackButton=YES;
	[barButtonItem_back release];
    
    if ([delegate isProductStatusAvailable:prodID]) {
        buyButton.enabled = YES;
    } else {
        buyButton.enabled = NO;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)donePressed:(id)sender
{
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];

    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)buyPressed:(id)sender
{
    [delegate returnWithPurchase:prodID];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)fileExistsInCache:(NSString*)myfilename
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@",cacheDir,myfilename];

    return [manager fileExistsAtPath:fullPath];
}

-(UIImage*)fileFromCache:(NSString*)myfilename
{
    UIImage *img;
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@",cacheDir,myfilename];
    img = [UIImage imageWithContentsOfFile:fullPath];

    return img;
}

-(void)lazyDownloadImage:(NSString*)myfilename product:(NSString*)product 
{
    ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:myfilename];
    if (imageDownloader == nil) 
    {
        NSString *mainurl = @"http://findmystation.info/maps";
        NSString *path = [mainurl stringByAppendingPathComponent:[self getDemoMapFileName:product]];
        imageDownloader = [[ImageDownloader alloc] init];
        imageDownloader.delegate = self;
        imageDownloader.imageName=myfilename;
        imageDownloader.imageURLString=path;
        [imageDownloadsInProgress setObject:imageDownloader forKey:myfilename];
        [imageDownloader startDownload];
        [imageDownloader release];   
    }
}

-(void)loadImagesForScreen
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];	
    NetworkStatus netStatus = [reach currentReachabilityStatus];  
    
    NSString *retina=@"";
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
        retina=@"@2x";
    }
    
 /*   for (int i=1; i<4; i++) {
        NSString *imageViewName = [NSString stringWithFormat:@"image%d",i];

        NSString *fn = [NSString stringWithFormat:@"%@%d%@.png",filename,i,retina];
        UIImage *img = [UIImage imageNamed:fn];
        if (!img) {
            if ([self fileExistsInCache:fn]) {
                img =[self fileFromCache:fn];
            } else { 
                img = [UIImage imageNamed:@"placeholder1.png"];
                if (netStatus != NotReachable) { 
                    [self lazyDownloadImage:fn product:prodID];
                }
            }
        }
        
        [self setValue:img forKey:imageViewName];
        [image1 setNeedsDisplay];
        [image2 setNeedsDisplay];
        [image3 setNeedsDisplay];
    }
*/
    
    NSString *fn1 = [NSString stringWithFormat:@"%@1%@.png",filename,retina];
    UIImage *img1 = [UIImage imageNamed:fn1];
    if (!img1) {
        if ([self fileExistsInCache:fn1]) {
            img1 =[self fileFromCache:fn1];
        } else { 
            img1 = [UIImage imageNamed:@"placeholder.png"];
            if (netStatus != NotReachable) { 
                [self lazyDownloadImage:fn1 product:prodID];
            }
        }
    }
    [image1 setImage:img1];
    
    NSString *fn2 = [NSString stringWithFormat:@"%@2%@.png",filename,retina];
    UIImage *img2 = [UIImage imageNamed:fn2];
    if (!img2) {
        if ([self fileExistsInCache:fn2]) {
            img2 =[self fileFromCache:fn2];
        } else { 
            img2 = [UIImage imageNamed:@"placeholder.png"];
            if (netStatus != NotReachable) { 
                [self lazyDownloadImage:fn2 product:prodID];
            }
        }
    }
    [image2 setImage:img2];
    
    NSString *fn3 = [NSString stringWithFormat:@"%@3%@.png",filename,retina];
    UIImage *img3 = [UIImage imageNamed:fn3];
    if (!img3) {
        if ([self fileExistsInCache:fn3]) {
            img3 =[self fileFromCache:fn3];
        } else { 
            img3 = [UIImage imageNamed:@"placeholder.png"];
            if (netStatus != NotReachable) { 
                [self lazyDownloadImage:fn3 product:prodID];
            }
        }
    }
    [image3 setImage:img3];

}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad
{
    [self loadImagesForScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

-(NSString*)getDemoMapFileName:(NSString*)aproduct
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString *mapFileName =[NSString stringWithString:[[dict objectForKey:aproduct] objectForKey:@"filename"]];
    [dict release];
    
    return mapFileName;
}


-(void)dealloc
{
    delegate = nil;
    [scrollView release];
    [text1 release];
    [text2 release];
    [text3 release];
    [image1 release];
    [image2 release];
    [image3 release];
    [buyButton release];
    [filename release];
    [prodID release];
    [cityName release];
    [imageDownloadsInProgress release];
    [super dealloc];
}

@end
