//
//  SettingsViewController.m
//  tube
//
//  Created by sergey on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "CityCell.h"
#import "MyNavigationBar.h"
#import "CityMap.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "Reachability.h"
#import "TubeAppIAPHelper.h"
#import "DemoMapViewController.h"
#import "SSZipArchive.h"
#import "SSTheme.h"
#import "CustomPhotoViewerViewController.h"
#import "LCUtil.h"
#import "RectObject.h"

#define plist_ 1
#define zip_  2

@implementation SettingsViewController

@synthesize maps;
@synthesize imagesScrollView;
@synthesize selectedPath;
@synthesize delegate;
@synthesize servers;
@synthesize timer;
@synthesize progressArrows;
@synthesize languages;
@synthesize feedback;
@synthesize purchaseIndex;
@synthesize buyAllButton;
@synthesize buyButton;
@synthesize reloadButton;
@synthesize paging;
@synthesize quitButton;
@synthesize subviewPositions;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.subviewPositions = [NSMutableDictionary dictionary];
        self.maps = [self getMapsList];
        self.servers = [[[NSMutableArray alloc] init] autorelease];
        tubeAppDelegate *appdelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.languages=appdelegate.cityMap.languages;
        
        int currentLanguageIndex = [[MHelper sharedHelper] languageIndex];
        if (currentLanguageIndex == 2 && [self.languages count] == 2) {
            selectedLanguages = [[NSMutableArray alloc] initWithObjects:[languages objectAtIndex:0],[languages objectAtIndex:1], nil];
        } else {
            selectedLanguages = [[NSMutableArray alloc] initWithObjects:[languages objectAtIndex:currentLanguageIndex], nil];
        }

        self.feedback = [NSArray arrayWithObjects:NSLocalizedString(@"FeedbackRate",@"FeedbackRate"),NSLocalizedString(@"FeedbackMail",@"FeedbackMail"),NSLocalizedString(@"FeedbackTell",@"FeedbackTell"), nil];
        
        isFirstTime=YES;
    }
    return self;
}

-(void)downloadDone:(NSMutableData *)data prodID:(NSString*)prodID server:(DownloadServer *)myid
{
    if (requested_file_type==plist_) {
        [self processPlistFromServer:data];
    } else if (requested_file_type==zip_) {
        NSIndexPath *mapIndexPath = [self getIndexPathProdID:prodID];
        
        if (mapIndexPath) {
            for (NSDictionary *map in self.maps) {
                if ([[map objectForKey:@"prodID"] isEqual:prodID]) {
                    [map setValue:@"ZIP" forKey:@"status"];
                }
            }
            [self performSelectorOnMainThread:@selector(updateFreakingButton:) withObject:mapIndexPath waitUntilDone:NO];
            //[self updateFreakingButton:mapIndexPath];
            
        }
        mapID = [prodID retain];
        //        zipData = [data retain];
        [self performSelector:@selector(processZipFromServer:) withObject:data afterDelay:1];
        //        [self processZipFromServer:data prodID:(NSString*)prodID];
    }
    
    [servers removeObject:myid];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(NSArray*)getMapsList
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSArray *mapIDs = [dict allKeys];
    NSMutableArray *mapsInfoArray = [[[NSMutableArray alloc] initWithCapacity:[mapIDs count]] autorelease];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

    NSMutableDictionary *productContent = nil;
    NSString *contentID = nil;
    
    for (NSString* mapID in mapIDs) {
        NSMutableDictionary *product = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:mapID]];
        [product setObject:@"3" forKey:@"sortingPosition"];
        [product setObject:mapID forKey:@"prodID"];
        
        if ([mapID isEqual:bundleIdentifier]) {
            [product setObject:@"1" forKey:@"sortingPosition"];

            [product setObject:@"D" forKey:@"status"];
            productContent = [NSMutableDictionary dictionaryWithDictionary:product];
            [productContent setObject:@"2" forKey:@"sortingPosition"];

            contentID = [NSString stringWithFormat:@"%@.content", mapID];
            [productContent setObject:contentID forKey:@"prodID"];
            if ([self isProductInstalled:contentID]) {
                [productContent setObject:@"I" forKey:@"status"];
            }
            if ([self isProductPurchased:bundleIdentifier]) {
                [product setObject:@"P" forKey:@"status"];
            }
        } else if ([self isProductPurchased:mapID]) {
            if ([self isProductInstalled:[product valueForKey:@"filename"]]) {
                [product setObject:@"I" forKey:@"status"];
            } else {
                [product setObject:@"P" forKey:@"status"];
            }
        } else {
            [product setObject:@"Z" forKey:@"status"];
        };
        
        [mapsInfoArray addObject:product];
        [product release];
    }
    
    if (productContent) {
        [mapsInfoArray addObject:productContent];
    }
    
    
    [dict release];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    [mapsInfoArray sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil]];
    
    [sortDescriptor2 release];
    [sortDescriptor1 release];
    
    return mapsInfoArray;
}

-(void)resortMapArray
{
    //NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"sortingPosition" ascending:YES];
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.maps];
    
    [temp sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor2, nil]];
    
    self.maps = [NSArray arrayWithArray:temp];
    
    [sortDescriptor2 release];
//    [sortDescriptor1 release];
    
    [self setCurrentMapSelectedPath];
}

#pragma mark - View lifecycle

- (void)mapChanged:(NSNotification*)note
{
    tubeAppDelegate *appdelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.languages=appdelegate.cityMap.languages;
    
    int currentLanguageIndex = [[MHelper sharedHelper] languageIndex];
    if (currentLanguageIndex == 2 && [self.languages count] == 2) {
        selectedLanguages = [[NSMutableArray alloc] initWithObjects:[languages objectAtIndex:0],[languages objectAtIndex:1], nil];
    } else {
        selectedLanguages = [[NSMutableArray alloc] initWithObjects:[languages objectAtIndex:currentLanguageIndex], nil];
    }
}

- (void) loadImages{
    tubeAppDelegate *appdelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *configPath = [NSString stringWithFormat:@"%@/settings_images.json", appdelegate.mapDirectoryPath];
    NSData *jsonData = [NSData dataWithContentsOfFile:configPath];
    self.imagesScrollView.delegate = self;
    self.imagesScrollView.showsHorizontalScrollIndicator = NO;
    if (jsonData) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"Error reading JSON: %@, %@", [error localizedFailureReason], [error localizedDescription]);
        }
        NSArray *imagePaths = [json objectForKey:@"images"];
        CGFloat parentWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat imageHeight;
        CGFloat yOffset = 0;
        if (IS_IPAD) {
            imageHeight = 1496 * parentWidth / 1536;
        }else{
            if(appdelegate.isIPHONE5){
                imageHeight = 393;
            }else{
                imageHeight = 393;
                yOffset = -70;
            }
        }
        self.imagesScrollView.pagingEnabled = YES;
        self.imagesScrollView.frame = CGRectMake(0, yOffset, parentWidth, imageHeight);
        self.imagesScrollView.contentSize = CGSizeMake(parentWidth * imagePaths.count, imageHeight);
        self.paging.numberOfPages = imagePaths.count;
        if(imagePaths){
            for (int i = 0; i < imagePaths.count; i++) {
                NSString *imagePath = [imagePaths objectAtIndex:i];
                NSString *localizedPath = [LCUtil getLocalizedPhotoPathWithMapDirectory:appdelegate.mapDirectoryPath withPath:imagePath iphone5:appdelegate.isIPHONE5];
                CGFloat xOffset = i * parentWidth;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, 0, parentWidth, imageHeight)];
                UIImage *image = [UIImage imageWithContentsOfFile:localizedPath];
                imageView.image = image;
                [self.imagesScrollView addSubview:imageView];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"mask %i", self.view.autoresizingMask);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapChanged:) name:kMapChanged object:nil];
    [TubeAppIAPHelper sharedHelper];
    [self loadImages];
    [self rememberPositions];
    
}

-(void)rememberPositions{
    int tag = 0;
    for (UIView *subview in self.view.subviews){
        tag += 1;
        subview.tag = tag;
        RectObject *rect = [RectObject rectWithCGRect:subview.frame];
        [self.subviewPositions setObject:rect forKey:[NSNumber numberWithInt: tag]];
    }
    NSLog(@"self.subviewPositions %@", self.subviewPositions.description);
}

- (void) resetPositions{
    for (UIView *subview in self.view.subviews){
        RectObject *rect = [self.subviewPositions objectForKey:[NSNumber numberWithInt: subview.tag]];
        if (rect != nil) {
            subview.frame = rect.rect;
        }
    }
}

-(void)setCurrentMapSelectedPath
{
    int mapsC = [self.maps count];
    
    NSString *currentMap = [[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName];
    
    for (int i=0;i<mapsC;i++) {
        if ([[[self.maps objectAtIndex:i] objectForKey:@"filename"] isEqual:currentMap]) {
            self.selectedPath=[NSIndexPath indexPathForRow:i inSection:0];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self processPurchases];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }    
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMapChanged object:nil];
    
    [servers release];
    [timer release];
    [progressArrows release];
    self.imagesScrollView.delegate = nil;
    [imagesScrollView release];
    
    [selectedLanguages release];
    [maps release];
    [selectedPath release];
    delegate = nil;
    [super dealloc];
}

-(void)downloadedBytes:(long)part outOfBytes:(long)whole prodID:(NSString*)prodID
{
    if (requested_file_type==zip_) {
        NSIndexPath *mapIndexPath = [self getIndexPathProdID:prodID];
        
        if (mapIndexPath) {
            for (NSDictionary *map in self.maps) {
                if ([[map objectForKey:@"prodID"] isEqual:prodID]) {
                    [map setValue:@"N" forKey:@"status"];
                    [map setValue:[NSNumber numberWithLong:part] forKey:@"progressPart"];
                    [map setValue:[NSNumber numberWithLong:whole] forKey:@"progressWhole"];
                }
            }
            
            [self performSelectorOnMainThread:@selector(refreshButton:) withObject:mapIndexPath waitUntilDone:NO];
        }
    }
}

-(void)downloadedBytes:(float)part prodID:(NSString*)prodID
{
    if (requested_file_type==zip_) {
        NSIndexPath *mapIndexPath = [self getIndexPathProdID:prodID];
        
        if (mapIndexPath) {
            for (NSDictionary *map in self.maps) {
                if ([[map objectForKey:@"prodID"] isEqual:prodID]) {
                    [map setValue:@"N" forKey:@"status"];
                    [map setValue:[NSNumber numberWithFloat:part] forKey:@"progress"];
                }
            }

            [self performSelectorOnMainThread:@selector(refreshButton:) withObject:mapIndexPath waitUntilDone:NO];
        }
    }
}

-(void)startDownloading:(NSString*)prodID
{    
    if (requested_file_type==zip_) {
        NSIndexPath *mapIndexPath = [self getIndexPathProdID:prodID];
        
        if (mapIndexPath) {
            for (NSDictionary *map in self.maps) {
                if ([[map objectForKey:@"prodID"] isEqual:prodID]) {
                    [map setValue:@"N" forKey:@"status"];
                }
            }
        }
    }
}

-(void)downloadFailed:(DownloadServer*)myid
{
    if (requested_file_type==plist_) {
        [self stopTimer];
    }
    
    [servers removeObject:myid];
    
    //    [self.updatButton enabled];
}

#pragma mark - some helpers

-(BOOL)isProductInstalled:(NSString*)mapName
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *contentIdentifier = [NSString stringWithFormat:@"%@.content", bundleIdentifier];
    
    if ([mapName isEqualToString:contentIdentifier]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[defaults objectForKey:@"additionalContentAccessLevel"] integerValue] > 0) {
            return  YES;
        }
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mapDirPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[mapName lowercaseString]]];
    
    BOOL mapFile = NO;
    BOOL trpFile = NO;
    BOOL trpNewFile = NO;
    
    if ([[manager contentsOfDirectoryAtPath:mapDirPath error:nil] count]>0) {
        NSDirectoryEnumerator *dirEnum = [manager enumeratorAtPath:mapDirPath];
        NSString *file;
        
        while (file = [dirEnum nextObject]) {
            if ([[file pathExtension] isEqualToString: @"map"]) {
                mapFile=YES;
            } else if ([[file pathExtension] isEqualToString: @"trp"]) {
                trpFile=YES;
            } else if ([[file pathExtension] isEqualToString: @"trpnew"]) {
                trpNewFile=YES;
            }
        }
    } 
    if (mapFile && (trpFile || trpNewFile)) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isProductPurchased:(NSString*)prodID
{
    //   NSMutableSet *purchasedProducts = [[TubeAppIAPHelper sharedHelper] purchasedProducts];
    //   return [purchasedProducts intersectsSet:[NSMutableSet setWithArray:[NSArray arrayWithObject:prodID]]];
    return [[NSUserDefaults standardUserDefaults] boolForKey:prodID];
}

-(BOOL)isProductAvailable:(NSString*)prodID
{
    return YES;
}

-(BOOL)isProductStatusDownloading:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:@"N"]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusUnpacking:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:@"ZIP"]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusInstalled:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:@"I"]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusPurchased:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:@"P"]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusAvailable:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:@"V"]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusDefault:(NSString*)prodID
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

    if ([prodID isEqual:bundleIdentifier]) {
        return YES;
    } 
    
    return NO;     
}


-(BOOL)isProductContentPurchase:(NSString*)prodID
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *purchaseId = [NSString stringWithFormat:@"%@.content", bundleIdentifier];
    
    if ([prodID isEqual:purchaseId]) {
        return YES;
    }
    
    return NO;
}

-(NSIndexPath*)getIndexPathProdID:(NSString*)prodID
{
    int mapsC = [self.maps count];
    
    for (int i=0;i<mapsC;i++) {
        if ([[[self.maps objectAtIndex:i] objectForKey:@"prodID"] isEqual:prodID]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

-(void)processPlistFromServer:(NSMutableData*)data
{
    NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
    
    NSArray *array = [dict allKeys];
    
    NSMutableArray *productToDonwload = [NSMutableArray array];
    
    if ([array count]>0) {
        NSString *tempDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"maps.plist"]];
        [data writeToFile:path atomically:YES];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

        
        for (NSDictionary *mmap in self.maps) {
            if ([self isProductPurchased:[mmap objectForKey:@"prodID"]] || [[mmap objectForKey:@"prodID"] isEqual:bundleIdentifier]) {
                for (NSString *prodId in array) {
                    if ([prodId isEqual:[mmap objectForKey:@"prodID"]]) {
                        if ([[mmap objectForKey:@"ver"] integerValue]<[[[dict objectForKey:prodId] objectForKey:@"ver"] integerValue]) {
                            //[productToDonwload addObject:[mmap objectForKey:@"prodID"]];
                        }
                    }
                }
            }
        }    
        
        self.maps = [self getMapsList];
        
        [self enableProducts];
        [self resortMapArray];
        
        NSSet *newProductIdentifiers = [[[NSSet alloc] initWithArray:array] autorelease];    
        
        [[TubeAppIAPHelper sharedHelper] setProductIdentifiers:newProductIdentifiers];
        
        [[TubeAppIAPHelper sharedHelper] requestProducts];
    }
    
    BOOL onceRestored = [[NSUserDefaults standardUserDefaults] boolForKey:@"restored"];
    
    if (!onceRestored) {
        // запрашиваем старые покупки
        [[TubeAppIAPHelper sharedHelper] restoreCompletedTransactions];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

        // если вышла новая версия дефолтной карты то ее сразу закачиваем
        for (NSString *prodId in productToDonwload) {
            if ([prodId isEqual:bundleIdentifier]) {
                [self downloadProduct:prodId];
            }
        }
    } else {
        for (NSString *prodId in productToDonwload ) {
            [self downloadProduct:prodId];
        }
    } 
    
    [self stopTimer];
}

-(void)processZipFromServer:(NSMutableData*)data {
    [self processZipFromServer:data prodID:mapID];
}

-(void)processZipFromServer:(NSMutableData*)data prodID:(NSString*)prodID
{
    NSIndexPath *mapIndexPath = [self getIndexPathProdID:prodID];
    
    if (mapIndexPath) {
        for (NSDictionary *map in self.maps) {
            if ([[map objectForKey:@"prodID"] isEqual:prodID]) {
                [map setValue:@"ZIP" forKey:@"status"];
            }
        }
    
    }
    
    // save data to file in tmp 
    NSString *tempDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"1.zip"]];
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    [data writeToFile:path atomically:YES];
    
    //SHOULD BE ASYNC!
    __block BOOL success = NO;
    
        success = [SSZipArchive unzipFileAtPath:path toDestination:cacheDir];
        
        
        // delete file from temp
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:path error:nil];
        
        if (success) {
            [self markProductAsInstalled:prodID];
        }
        
        [self resortMapArray];
        
        // если мы скачали новую версию нашей текущей карты - то обновить ее
        
        tubeAppDelegate *appdelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        NSString *mapName = [self getMapNameForProduct:prodID];
        
        if ([[[appdelegate cityMap] thisMapName] isEqual:mapName])
        {
            // перегрузить карту
            //  NSLog(@"перегружаю активную карту");
            
            NSString *cityName;
            
            for (NSDictionary *dict in self.maps) {
                if ([[dict objectForKey:@"filename"] isEqual:mapName]) {
                    cityName = [dict objectForKey:@"name"];
                }
            }
            
        }
        [self performSelectorOnMainThread:@selector(updateFreakingButton:) withObject:mapIndexPath waitUntilDone:NO];


}

-(IBAction)updatePressed:(id)sender
{
    DownloadServer *server = [[[DownloadServer alloc] init] autorelease];
    server.listener=self;
    
    [servers addObject:server];
    
    NSString *bundleName = [NSString stringWithFormat:@"%@.plist",[[NSBundle mainBundle] bundleIdentifier]];
    requested_file_type=plist_;
    [server loadFileAtURL:bundleName];
    [self spinLayer:progressArrows.layer duration:2.0 direction:1];
    [self startTimer];
}

-(void)buyMap:(NSDictionary*)map
{
    NSString *prodID = [map valueForKey:@"prodID"];
    
    if ([self isProductStatusAvailable:prodID]) {
        [self purchaseProduct:prodID];
    } else if ([self isProductStatusPurchased:prodID]) {
        [self downloadProduct:prodID];
    }
}

- (NetworkStatus) connectionStatus
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
               
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // if target host is not reachable
        return NotReachable;
    }
    
    NetworkStatus retVal = NotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        retVal = ReachableViaWiFi;
    }
    
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            retVal = ReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        retVal = ReachableViaWWAN;
    }
    return retVal;
}

-(IBAction)openAppStoreLink:(NSDictionary*)map
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[map objectForKey:@"appstore_link"]]];
}

-(NSString*)getMapNameForProduct:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID]) {
            return [map valueForKey:@"filename"];
        }
    }
    
    return nil;
}

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    [timer invalidate];
}

-(void)timerFired:(NSTimer *)timer
{
    [self spinLayer:progressArrows.layer duration:2.0 direction:1];
}

- (void)spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration
        direction:(int)direction
{
    CABasicAnimation* rotationAnimation;
    
    // Rotate about the z axis
    rotationAnimation = 
    [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // Rotate 360 degress, in direction specified
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * direction];
    
    // Perform the rotation over this many seconds
    rotationAnimation.duration = inDuration;
    
    // Set the pacing of the animation
    rotationAnimation.timingFunction = 
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Add animation to the layer and make it so
    [inLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)downloadProduct:(NSString*)prodID
{
    DownloadServer *server = [[[DownloadServer alloc] init] autorelease];
    server.listener=self;
    server.prodID = prodID;
    
    [servers addObject:server];
    
    NSString *mapName = [self getMapNameForProduct:prodID];   
    
    NSString *mapFilePath = [NSString stringWithFormat:@"%@/%@.zip",mapName,mapName];
    requested_file_type=zip_;
    [server loadFileAtURL:mapFilePath];
}

-(void)returnWithPurchase:(NSString *)prodID
{
    [self.navigationController popViewControllerAnimated:YES];
    [self purchaseProduct:prodID];
}

#pragma mark - in-app purchase 

-(void) processPurchases
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];	
    NetworkStatus netStatus = [reach currentReachabilityStatus];  
    
    if (netStatus == NotReachable) {        
        NSLog(@"No internet connection!");        
    } else {
        if ([TubeAppIAPHelper sharedHelper].products == nil) {
            [[TubeAppIAPHelper sharedHelper] requestProducts];
        } else { 
            [self enableProducts];
            [self resortMapArray];
        }
    }
}

- (void)productsLoaded:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self enableProducts];
    [self resortMapArray];
}

-(void)enableProducts
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"status"] isEqual:@"D"]) {
            for (SKProduct *product in [TubeAppIAPHelper sharedHelper].products) {
                if ([product.productIdentifier isEqual:[map valueForKey:@"prodID"]]) {
                    [map setObject:@"V" forKey:@"status"];
                    
                    [numberFormatter setLocale:product.priceLocale];
                    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
                    
                    [map setObject:formattedString forKey:@"price"];
                }
            }
        }
    }
    
    [numberFormatter release];
}

-(void)purchaseProduct:(NSString*)prodID
{
    NSArray *products = [TubeAppIAPHelper sharedHelper].products;
    
    for (SKProduct *product in products) {
        if ([product.productIdentifier isEqual:prodID]) {
            
            //NSLog(@"Buying %@...", product.productIdentifier);
            [[TubeAppIAPHelper sharedHelper] buyProductIdentifier:product.productIdentifier];
            
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:130.0];
            
        }
    }    
}

- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];    
    
    NSString *productIdentifier = (NSString *) notification.object;
    //NSLog(@"Purchased: %@", productIdentifier);
    //[self downloadProduct:productIdentifier];

    [self markProductAsPurchased:productIdentifier];
    [self resortMapArray];
}

-(void)markProductAsPurchased:(NSString*)prodID
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *contentIdentifier = [NSString stringWithFormat:@"%@.content", bundleIdentifier];

    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && ([[map valueForKey:@"status"] isEqual:@"V"] || [[map valueForKey:@"status"] isEqual:@"Z"]) ) {
            [map setObject:@"P" forKey:@"status"];
            if ([prodID isEqualToString:bundleIdentifier]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:bundleIdentifier];
                [self markProductAsInstalled:contentIdentifier];
            }
        }
    }
    
    if ([prodID isEqualToString:contentIdentifier]) {
        [self markProductAsInstalled:prodID];
    }
    
}

-(void)markProductAsInstalled:(NSString*)prodID
{

    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID]) {
            [map setObject:@"I" forKey:@"status"];
        }
    }
    NSString *contentIdentifier = [NSString stringWithFormat:@"%@.content", bundleIdentifier];
    if ([prodID isEqualToString:contentIdentifier]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[NSNumber numberWithInt:1] forKey:@"additionalContentAccessLevel"];
        [defaults synchronize];
        tubeAppDelegate *appdelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate reloadContent];
    }

}


- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;    
    if (transaction.error.code != SKErrorPaymentCancelled) {    
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error!" 
                                                         message:transaction.error.localizedDescription 
                                                        delegate:nil 
                                               cancelButtonTitle:nil 
                                               otherButtonTitles:@"OK", nil] autorelease];
        
        [alert show];
    }
}

- (void)timeout:(id)arg {
    NSLog(@"timeout");
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = [[UIScreen mainScreen] bounds].size.width;
    int page = floor((self.imagesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.paging.currentPage = page;
    NSLog(@"closeButton %@", self.quitButton);
}

- (void)viewDidAppear:(BOOL)animated{
    [self resetPositions];
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.imagesScrollView.frame.size.width * self.paging.currentPage;
    frame.origin.y = 0;
    frame.size = self.imagesScrollView.frame.size;
    [self.imagesScrollView scrollRectToVisible:frame animated:YES];
}

-(IBAction)donePressed:(id)sender 
{
    for (DownloadServer *server in servers) {
        [server cancel];
    }
    
    [servers removeAllObjects];
    
    if ([languages count] > 1) {
        
        if ([selectedLanguages count]>1) {
            [[MHelper sharedHelper] saveLanguageIndex:2];
        } else {
            [[MHelper sharedHelper] saveLanguageIndex:[languages indexOfObject:[selectedLanguages lastObject]]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLangChanged object:nil];
    }
    
    [delegate donePressed];
}


#pragma mark - Mail methods

// Displays an email composition interface inside the app // and populates all the Mail fields.
-(void)showMailComposer:(NSArray*)recipient subject:(NSString*)subject body:(NSString*)body
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        // Test to ensure that device is configured for sending emails.
        if ([mailClass canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:subject];
            [picker setToRecipients:recipient];
            [picker setMessageBody:body isHTML:NO];
            [self presentModalViewController:picker animated:YES];
            [picker release];
        } else {
            // Device is not configured for sending emails, so notify user.
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can't send email" message:@"This device not configured to send emails" delegate:self cancelButtonTitle:@"Ok, I will try later" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
    } 
}

// Dismisses the Mail composer when the user taps Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    NSString *resultTitle = nil; NSString *resultMsg = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            resultTitle = @"Email cancelled";
            resultMsg = @"You cancelled you email"; break;
        case MFMailComposeResultSaved:
            resultTitle = @"Email saved";
            resultMsg = @"Your draft email was saved"; break;
        case MFMailComposeResultSent: resultTitle = @"Email sent";
            resultMsg = @"Your email was sent successfully";
            break;
        case MFMailComposeResultFailed:
            resultTitle = @"Email failed";
            resultMsg = @"Your email was failed"; break;
        default:
            resultTitle = @"Email was not sent";
            resultMsg = @"Your email was not sent"; break;
    }
    // Notifies user of any Mail Composer errors received with an Alert View dialog.
    UIAlertView *mailAlertView = [[UIAlertView alloc] initWithTitle:resultTitle message:resultMsg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [mailAlertView show];
    [mailAlertView release];
    [resultTitle release];
    [resultMsg release];
    [buyAllButton release];
    [buyButton release];
    [reloadButton release];
    [paging release];
    [quitButton release];
    [subviewPositions release];
    [self dismissModalViewControllerAnimated:YES];
}

@end
