//
//  SettingsViewController.m
//  tube
//
//  Created by sergey on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "LanguageCell.h"
#import "CityCell.h"
#import "MyNavigationBar.h"
#import "CityMap.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "Reachability.h"
#import "TubeAppIAPHelper.h"
#import "DemoMapViewController.h"
#import "SSZipArchive.h"
#import "LanguageViewController.h"

#define plist_ 1
#define zip_  2

@implementation SettingsViewController

@synthesize cityButton;
@synthesize buyButton;
@synthesize langTableView;
@synthesize cityTableView;
@synthesize maps;
@synthesize textLabel1,textLabel2,textLabel3;
@synthesize scrollView;
@synthesize selectedPath;
@synthesize buyAllButton,sendMailButton;
@synthesize hud = _hud;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.maps = [self getMapsList];
    }
    return self;
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
    
    for (NSString* mapID in mapIDs) {
        NSMutableDictionary *product = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:mapID]];
        [product setObject:mapID forKey:@"prodID"];
        
        if ([mapID isEqual:@"default"]) {
            [product setObject:[NSString stringWithString:@"D"] forKey:@"status"];
        } else if ([self isProductPurchased:mapID]) {
            if ([self isProductInstalled:[product valueForKey:@"filename"]]) {
                [product setObject:[NSString stringWithString:@"I"] forKey:@"status"];
            } else {
                [product setObject:[NSString stringWithString:@"P"] forKey:@"status"];
            }
        } else {
            [product setObject:[NSString stringWithString:@"Z"] forKey:@"status"];
        };
        
        [mapsInfoArray addObject:product];
        [product release];
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
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.maps];
    
    [temp sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil]];
    
    self.maps = [NSArray arrayWithArray:temp];
    
    [sortDescriptor2 release];
    [sortDescriptor1 release];
    
    [self setCurrentMapSelectedPath];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    
	langTableView.backgroundColor = [UIColor clearColor];
    langTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    textLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    textLabel2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    textLabel3.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    
	cityTableView.backgroundColor = [UIColor clearColor];
    cityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *iv = [[UIView alloc] initWithFrame:CGRectMake(0,0,160,44)];
    CGRect frame = CGRectMake(0, 3, 160, 44);
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0];
    //	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor darkGrayColor];
    label.text = @"Settings";
    [iv addSubview:label];
    self.navigationItem.titleView=iv;
    [iv release];
	
    UIImage *back_image=[UIImage imageNamed:@"settings_back_button.png"];
	UIButton *back_button = [UIButton buttonWithType:UIButtonTypeCustom];
	back_button.bounds = CGRectMake( 0, 0, back_image.size.width, back_image.size.height );    
	[back_button setBackgroundImage:back_image forState:UIControlStateNormal];
	[back_button addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];    
	UIBarButtonItem *barButtonItem_back = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    self.navigationItem.leftBarButtonItem = barButtonItem_back;
    self.navigationItem.hidesBackButton=YES;
	[barButtonItem_back release];
    
    [TubeAppIAPHelper sharedHelper];
    
    [self adjustViewHeight];
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

-(void)adjustViewHeight
{
    CGFloat tableHeight = [maps count]*45.0f+2.0;
    
    cityTableView.frame = CGRectMake(8, 179, 304, tableHeight);
    
    CGRect buyAll = buyAllButton.frame;
    buyAllButton.frame = CGRectMake(buyAll.origin.x, 179+tableHeight+8, buyAll.size.width, buyAll.size.height);
    
    textLabel3.frame = CGRectMake(textLabel3.frame.origin.x, buyAllButton.frame.origin.y+buyAllButton.frame.size.height+17.0, textLabel3.frame.size.width, textLabel3.frame.size.height);
    
    sendMailButton.frame = CGRectMake(sendMailButton.frame.origin.x, buyAllButton.frame.origin.y+buyAllButton.frame.size.height+8.0, sendMailButton.frame.size.width, sendMailButton.frame.size.height);
    
    scrollView.contentSize = CGSizeMake(320, sendMailButton.frame.origin.y+sendMailButton.frame.size.height+15.0);
    scrollView.frame = CGRectMake(0.0, 0.0, 320.0, 460.0-44.0);
    
    [scrollView flashScrollIndicators];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidUnload
{
    [self setCityButton:nil];
    [self setBuyButton:nil];
    [super viewDidUnload];
}


#pragma mark - TableView

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==cityTableView) {
        return [maps count];
    } else {
        return 1;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==cityTableView) {
        static NSString *cellIdentifier = @"CityCell";
        
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) { 
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CityCell" owner:self options:nil] lastObject];
            [[(CityCell*)cell cellButton] addTarget:self action:@selector(buyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }    
        
        NSMutableDictionary *map = [maps objectAtIndex:[indexPath row]];
        NSString *mapName = [map objectForKey:@"name"];
        
        [[(CityCell*)cell cityName] setText:mapName];
        [[(CityCell*)cell cityName] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:18.0]];
        [[(CityCell*)cell cityName] setHighlightedTextColor:[UIColor whiteColor]];
        
        cell.backgroundColor = [UIColor clearColor];
        
        if ([indexPath isEqual:self.selectedPath]) {
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
        
        //
        // setting button background
        //
        
        UIButton *cellButton = [(CityCell*)cell cellButton];
        cellButton.hidden=NO;
        
        UIProgressView *progress = [(CityCell*)cell progress];
        progress.hidden=YES;
        progress.tag=123;
        
        if ([self isProductStatusDefault:[map objectForKey:@"prodID"]] || [self isProductStatusInstalled:[map objectForKey:@"prodID"]]) {
            [cellButton setTitle:@"Installed" forState:UIControlStateNormal];
            [cellButton setTitle:@"Installed" forState:UIControlStateHighlighted];
            [cellButton setBackgroundImage:[UIImage imageNamed:@"blue_button.png"] forState:UIControlStateNormal];
            [cellButton setBackgroundImage:[UIImage imageNamed:@"blue_button.png"] forState:UIControlStateHighlighted];
            [cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [[cellButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:15.0]];
            
        } else if ([self isProductStatusPurchased:[map objectForKey:@"prodID"]])  {
            
            [cellButton setTitle:@"Install" forState:UIControlStateNormal];
            [cellButton setTitle:@"Install" forState:UIControlStateHighlighted];
            [cellButton setBackgroundImage:[UIImage imageNamed:@"green_button.png"] forState:UIControlStateNormal];
            [cellButton setBackgroundImage:[UIImage imageNamed:@"high_green_button.png"] forState:UIControlStateHighlighted];
            [cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [[cellButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:15.0]];
            
        } else if ([self isProductStatusAvailable:[map objectForKey:@"prodID"]])  {
            
            [cellButton setTitle:[map valueForKey:@"price"] forState:UIControlStateNormal];
            [cellButton setTitle:[map valueForKey:@"price"] forState:UIControlStateHighlighted];
            [cellButton setBackgroundImage:[UIImage imageNamed:@"buy_button.png"] forState:UIControlStateNormal];
            [cellButton setBackgroundImage:[UIImage imageNamed:@"high_buy_button.png"] forState:UIControlStateHighlighted];
            [cellButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [[cellButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:15.0]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } else if ([self isProductStatusDownloading:[map objectForKey:@"prodID"]]){
            
            cellButton.hidden=YES;
            progress.hidden=NO;

        } else {
            cellButton.hidden=YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        //
        // setting background
        //
        
        UIImage *rowBackground;
        UIImage *selectionBackground;
        NSInteger sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
        NSInteger crow = [indexPath row];
        
        if (crow == 0 && crow == sectionRows - 1)
        {
            // у нас таких быть не должно вообще но 
            rowBackground = [UIImage imageNamed:@"middle_cell_bg.png"];
            selectionBackground = [UIImage imageNamed:@"high_middle_cell_bg.png"];
        }
        else if (crow == 0)
        {
            rowBackground = [UIImage imageNamed:@"first_cell_bg.png"];
            selectionBackground = [UIImage imageNamed:@"high_first_cell_bg.png"];
        }
        else if (crow == sectionRows - 1)
        {
            rowBackground = [UIImage imageNamed:@"last_cell_bg.png"];
            selectionBackground = [UIImage imageNamed:@"high_last_cell_bg.png"];
        }
        else
        {
            rowBackground = [UIImage imageNamed:@"middle_cell_bg.png"];
            selectionBackground = [UIImage imageNamed:@"high_middle_cell_bg.png"];
        }
        
        cell.backgroundView  = [[[UIImageView alloc] initWithImage:rowBackground] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectionBackground] autorelease];
        
        return cell;
        
    } else {
        static NSString *cellIdentifier = @"LanguageCell";
        
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) { 
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LanguageCell" owner:self options:nil] lastObject];
        }
        
        [[(LanguageCell*)cell languageWordLabel] setText:@"Language"];
        [[(LanguageCell*)cell languageWordLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:18.0]];
        [[(LanguageCell*)cell languageWordLabel] setHighlightedTextColor:[UIColor whiteColor]];
        
        [[(LanguageCell*)cell languageLabel] setText:@"English"];
        [[(LanguageCell*)cell languageLabel] setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:18.0]];
        [[(LanguageCell*)cell languageLabel] setTextColor:[UIColor darkGrayColor]];
        [[(LanguageCell*)cell languageLabel] setHighlightedTextColor:[UIColor whiteColor]];
        
        
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"language_table_cell.png"]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"high_language_table_cell.png"]] autorelease];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.cityTableView) {
        NSMutableDictionary *map = [maps objectAtIndex:[indexPath row]];
        tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if ([[map objectForKey:@"prodID"] isEqual:@"default"]) {
            self.selectedPath=indexPath;
            [tableView reloadData];    
            
            NSString *mapName = [appDelegate getDefaultMapName];
            NSString *cityName = [appDelegate getDefaultCityName];
            
            [appDelegate.mainViewController changeMapTo:mapName andCity:cityName];
        } else if ([self isProductInstalled:[map objectForKey:@"filename"]] || [self isProductPurchased:[map objectForKey:@"filename"]]) {
            
            self.selectedPath=indexPath;
            [tableView reloadData];    
            
            NSString *mapName = [map objectForKey:@"filename"];
            NSString *cityName = [map objectForKey:@"name"];
            
            [appDelegate.mainViewController changeMapTo:mapName andCity:cityName];
            
        } else {
            // показать рекламное окно
            DemoMapViewController *controller = [[DemoMapViewController alloc] initWithNibName:@"DemoMapViewController" bundle:[NSBundle mainBundle]];
            NSMutableDictionary *map = [maps objectAtIndex:[indexPath row]];
            controller.filename = [map objectForKey:@"filename"];
            controller.cityName = [map objectForKey:@"name"];
            controller.prodID = [map objectForKey:@"prodID"];
            controller.delegate=self;
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }    
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        LanguageViewController *controller = [[LanguageViewController alloc] initWithNibName:@"LanguageViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 45.0;
}

#pragma mark - Download delegate methods

-(void)downloadDone:(NSMutableData *)data prodID:(NSString*)prodID
{
    if (requested_file_type==plist_) {
        [self processPlistFromServer:data];
    } else if (requested_file_type==zip_) {
        [self processZipFromServer:data prodID:(NSString*)prodID];
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

-(void)refreshButton:(NSIndexPath*)path
{
    CityCell *cell = (CityCell*)[self.cityTableView cellForRowAtIndexPath:path];
    UIProgressView *progress = (UIProgressView*)[cell viewWithTag:123];
    NSDictionary *map = [self.maps objectAtIndex:path.row];
//    NSString *percent = [NSString stringWithFormat:@"%f %%",[[map objectForKey:@"progress"] floatValue]*100.0];
//    [button setTitle:percent forState:UIControlStateNormal];
    progress.progress=[[map objectForKey:@"progress"] floatValue];
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
        
            [self.cityTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:mapIndexPath] withRowAnimation:NO];  
        //    [self.updatButton disabled];
        }
    }
}

-(void)downloadFailed
{
    //    [self.updatButton enabled];
}

#pragma mark - some helpers

-(BOOL)isProductInstalled:(NSString*)mapName
{
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/Metro.map",[mapName lowercaseString]]];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:path]) {
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
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:[NSString stringWithString:@"N"]]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusInstalled:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:[NSString stringWithString:@"I"]]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusPurchased:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:[NSString stringWithString:@"P"]]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusAvailable:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:[NSString stringWithString:@"V"]]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusDefault:(NSString*)prodID
{
    if ([prodID isEqual:@"default"]) {
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
        
        
        for (NSDictionary *mmap in self.maps) {
            if ([self isProductPurchased:[mmap objectForKey:@"prodID"]] || [[mmap objectForKey:@"prodID"] isEqual:@"default"]) {
                for (NSString *prodId in array) {
                    if ([prodId isEqual:[mmap objectForKey:@"prodID"]]) {
                        if ([[mmap objectForKey:@"ver"] integerValue]<[[[dict objectForKey:prodId] objectForKey:@"ver"] integerValue]) {
                            [productToDonwload addObject:[mmap objectForKey:@"prodID"]];
                        }
                    }
                }
            }
        }    
        
        self.maps = [self getMapsList];
        [self adjustViewHeight];
        
        [self enableProducts];
        [self resortMapArray];
        [cityTableView reloadData];
        
        NSSet *newProductIdentifiers = [[[NSSet alloc] initWithArray:array] autorelease];    
        
        [[TubeAppIAPHelper sharedHelper] setProductIdentifiers:newProductIdentifiers];
        
        [[TubeAppIAPHelper sharedHelper] requestProducts];
    }
    
    BOOL onceRestored = [[NSUserDefaults standardUserDefaults] boolForKey:@"restored"];
    
    if (!onceRestored) {
        // запрашиваем старые покупки
        [[TubeAppIAPHelper sharedHelper] restoreCompletedTransactions];
        
        // если вышла новая версия дефолтной карты то ее сразу закачиваем
        for (NSString *prodId in productToDonwload) {
            if ([prodId isEqual:@"default"]) {
                [self downloadProduct:prodId];
            }
        }
    } else {
        for (NSString *prodId in productToDonwload ) {
            [self downloadProduct:prodId];
        }
    } 
}

-(void)processZipFromServer:(NSMutableData*)data prodID:(NSString*)prodID
{
    // save data to file in tmp 
    NSString *tempDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"1.zip"]];
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    [data writeToFile:path atomically:YES];
    
    BOOL success = [SSZipArchive unzipFileAtPath:path toDestination:cacheDir];
    
    // delete file from temp
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:path error:nil];
    
    if (success) {
        [self markProductAsInstalled:prodID];
    }
    
    [self resortMapArray];
    
    [self.cityTableView reloadData];
    
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
        
        [appdelegate.mainViewController changeMapTo:mapName andCity:cityName];
    }
    
    //    [self.updatButton enabled];
    
}

-(IBAction)updatePressed:(id)sender
{
    DownloadServer *server = [[[DownloadServer alloc] init] autorelease];
    server.listener=self;
    
    NSString *bundleName = [NSString stringWithFormat:@"%@.plist",[[NSBundle mainBundle] bundleIdentifier]];
    requested_file_type=plist_;
    [server loadFileAtURL:bundleName];
}

-(IBAction)buyButtonPressed:(id)sender 
{
    CityCell *cell = (CityCell*)[[sender superview] superview];  
    NSMutableDictionary *map = [maps objectAtIndex:[cityTableView indexPathForCell:cell].row];
    NSString *prodID = [map valueForKey:@"prodID"];
    
    if ([self isProductStatusAvailable:prodID]) {
        [self purchaseProduct:prodID];    
    } else if ([self isProductStatusPurchased:prodID]) {
        [self downloadProduct:prodID];
    }
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

-(void)downloadProduct:(NSString*)prodID
{
    DownloadServer *server = [[[DownloadServer alloc] init] autorelease];
    server.listener=self;
    server.prodID = prodID;
    
    NSString *mapName = [self getMapNameForProduct:prodID];   
    
    NSString *mapFilePath = [NSString stringWithFormat:@"maps/%@/%@.zip",mapName,mapName];
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
            [cityTableView reloadData];
        }
    }
}

- (void)productsLoaded:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self enableProducts];
    [self resortMapArray];
    [cityTableView reloadData];
}

-(void)enableProducts
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"status"] isEqual:@"Z"]) {
            for (SKProduct *product in [TubeAppIAPHelper sharedHelper].products) {
                if ([product.productIdentifier isEqual:[map valueForKey:@"prodID"]]) {
                    [map setObject:[NSString stringWithString:@"V"] forKey:@"status"];
                    
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
            
            NSLog(@"Buying %@...", product.productIdentifier);
            [[TubeAppIAPHelper sharedHelper] buyProductIdentifier:product.productIdentifier];
            
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _hud.labelText = @"Buying map ...";
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:130.0];
            
        }
    }    
}

- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];    
    
    NSString *productIdentifier = (NSString *) notification.object;
    NSLog(@"Purchased: %@", productIdentifier);
    
    [self markProductAsPurchased:productIdentifier];
    
    [self resortMapArray];
    
    [cityTableView reloadData];    
    
}

-(void)markProductAsPurchased:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && ([[map valueForKey:@"status"] isEqual:[NSString stringWithString:@"V"]] || [[map valueForKey:@"status"] isEqual:[NSString stringWithString:@"Z"]]) ) {
            [map setObject:[NSString stringWithString:@"P"] forKey:@"status"];
        }
    }
}

-(void)markProductAsInstalled:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID]) {
            [map setObject:[NSString stringWithString:@"I"] forKey:@"status"];
        }
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

- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.hud = nil;
    
}

- (void)timeout:(id)arg {
    
    _hud.labelText = @"Timeout!";
    _hud.detailsLabelText = @"Please try again later.";
    _hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	_hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}

-(IBAction)donePressed:(id)sender 
{
    [delegate donePressed];
}


#pragma mark - Mail methods

// Displays an email composition interface inside the app // and populates all the Mail fields.
-(IBAction)showMailComposer:(id)sender
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        // Test to ensure that device is configured for sending emails.
        if ([mailClass canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:@"Paris Metro"];
            [picker setToRecipients:[NSArray arrayWithObject:[NSString stringWithFormat:@"zuev.sergey@gmail.com"]]];
            [self presentModalViewController:picker animated:YES]; [picker release];
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
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [_hud release];
    _hud = nil;
    [cityButton release];
    [buyButton release];
    
    [langTableView release];
    [cityTableView release];

    [textLabel1 release];
    [textLabel2 release];
    [textLabel3 release];
    
    [scrollView release];
    
    [buyAllButton release];
    [sendMailButton release];
    [maps release];
    [selectedPath release];
    delegate = nil;
    [super dealloc];    
}

@end
