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

#define plist_ 1
#define zip_  2

@implementation SettingsViewController

@synthesize langTableView;
@synthesize cityTableView;
@synthesize feedbackTableView;
@synthesize maps;
@synthesize textLabel1,textLabel2,textLabel3,textLabel4;
@synthesize scrollView;
@synthesize selectedPath;
@synthesize hud = _hud;
@synthesize delegate;
@synthesize servers;
@synthesize timer;
@synthesize progressArrows;
@synthesize languages;
@synthesize feedback;
@synthesize updateButton;
@synthesize updateImageView;
@synthesize purchaseIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
        [self loadImages];
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
    
    [langTableView reloadData];
    [self adjustViewHeight];
}

- (void) loadImages{
    tubeAppDelegate *appdelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *configPath = [NSString stringWithFormat:@"%@/settings_images.json", appdelegate.mapDirectoryPath];
    NSData *jsonData = [NSData dataWithContentsOfFile:configPath];
    if (jsonData) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"Error reading JSON: %@, %@", [error localizedFailureReason], [error localizedDescription]);
        }
        NSArray *imagePaths = [json objectForKey:@"images"];
        if(imagePaths){
            for (NSString *imagePath in imagePaths) {
                NSLog(@"IMAGE_PATH: %@", [LCUtil getLocalizedPhotoPathWithMapDirectory:appdelegate.mapDirectoryPath withPath:imagePath iphone5:appdelegate.isIPHONE5]);
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SSThemeManager *theme = [SSThemeManager sharedTheme];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapChanged:) name:kMapChanged object:nil];
    
	langTableView.backgroundColor = [UIColor clearColor];
    langTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    textLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    textLabel2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    textLabel3.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    textLabel4.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    
	cityTableView.backgroundColor = [UIColor clearColor];
    cityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	feedbackTableView.backgroundColor = [UIColor clearColor];
    feedbackTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGRect frame = CGRectMake(0, 3, 180, 44);
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:20.0];
    //	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor darkGrayColor];
    label.text = NSLocalizedString(@"Settings",@"Settings");
	
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
    CGFloat langTableHeight;
    CGFloat addX = 0.0;
    
    if (IS_IPAD) {
        if (isFirstTime) {
            addX=110.0;
            isFirstTime=NO;
        }
    }
    
    textLabel1.frame = CGRectMake(textLabel1.frame.origin.x+addX, textLabel1.frame.origin.y, textLabel1.frame.size.width, textLabel1.frame.size.height);
    updateButton.frame = CGRectMake(updateButton.frame.origin.x+addX, updateButton.frame.origin.y, updateButton.frame.size.width, updateButton.frame.size.height);
    updateImageView.frame = CGRectMake(updateImageView.frame.origin.x+addX, updateImageView.frame.origin.y, updateImageView.frame.size.width, updateImageView.frame.size.height);
    textLabel2.frame = CGRectMake(textLabel2.frame.origin.x+addX, textLabel2.frame.origin.y, textLabel2.frame.size.width, textLabel2.frame.size.height);
    langTableView.frame=CGRectMake(langTableView.frame.origin.x+addX, langTableView.frame.origin.y, langTableView.frame.size.width, langTableHeight);
    textLabel3.frame=CGRectMake(textLabel3.frame.origin.x+addX, langTableView.frame.origin.y, textLabel3.frame.size.width, textLabel3.frame.size.height);

    
    if ([languages count]<2) {
        textLabel2.hidden=YES;
        langTableView.hidden=YES;
        textLabel3.frame=CGRectMake(textLabel2.frame.origin.x, textLabel2.frame.origin.y, textLabel2.frame.size.width, textLabel2.frame.size.height);
    } else {
        textLabel2.hidden=NO;
        langTableView.hidden=NO;
        langTableHeight = [languages count]*45.0f+2.0;
        langTableView.frame=CGRectMake(langTableView.frame.origin.x, langTableView.frame.origin.y, langTableView.frame.size.width, langTableHeight);
        textLabel3.frame=CGRectMake(textLabel3.frame.origin.x, langTableView.frame.origin.y+langTableHeight+17, textLabel3.frame.size.width, textLabel3.frame.size.height);
    }
    
    CGFloat cityTableHeight = [maps count]*199.0f+2.0;
    CGFloat feedbackTableHeight = [feedback count]*45.0f+2.0; 
    
    cityTableView.frame=CGRectMake(cityTableView.frame.origin.x+addX, textLabel2.frame.origin.y, cityTableView.frame.size.width,  cityTableHeight);
    textLabel4.frame=CGRectMake(textLabel4.frame.origin.x+addX, cityTableView.frame.origin.y+cityTableHeight+17, textLabel4.frame.size.width, textLabel4.frame.size.height);
    feedbackTableView.frame=CGRectMake(feedbackTableView.frame.origin.x+addX, textLabel4.frame.origin.y+textLabel4.frame.size.height+10, feedbackTableView.frame.size.width, feedbackTableHeight);

    if (IS_IPAD) {
        scrollView.contentSize = CGSizeMake(540, feedbackTableView.frame.origin.y+feedbackTableView.frame.size.height+15.0);
        scrollView.frame = CGRectMake(0.0, 0.0, 540.0, 620.0-44.0);
    } else {
        tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if ([appDelegate isIPHONE5]) {
            scrollView.contentSize = CGSizeMake(320, feedbackTableView.frame.origin.y+feedbackTableView.frame.size.height+15.0);
            scrollView.frame = CGRectMake(0.0, 0.0, 320.0, 568.0-44.0);
        } else {
            scrollView.contentSize = CGSizeMake(320, feedbackTableView.frame.origin.y+feedbackTableView.frame.size.height+15.0);
            scrollView.frame = CGRectMake(0.0, 0.0, 320.0, 460.0-44.0);
        }
    }

    
    [scrollView flashScrollIndicators];
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

- (void)viewDidUnload
{
    [updateButton release];
    updateButton = nil;
    [updateImageView release];
    updateImageView = nil;
    [super viewDidUnload];
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMapChanged object:nil];
    
    [_hud release];
    _hud = nil;
    
    [langTableView release];
    [cityTableView release];
    [feedbackTableView release];
    
    [textLabel1 release];
    [textLabel2 release];
    [textLabel3 release];
    [textLabel4 release];
    
    [servers release];
    [timer release];
    [progressArrows release];
    
    [scrollView release];
    
    [selectedLanguages release];
    [maps release];
    [selectedPath release];
    delegate = nil;
    [updateButton release];
    [updateImageView release];
    [super dealloc];    
}

- (void)viewDidAppear:(BOOL)animated
{

    if (purchaseCell != nil)
    {
        [self buyButtonPressed:purchaseCell];
        purchaseCell = nil;
    }
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
    } else if (tableView==langTableView) {
        if ([languages count]<2) {
            return 0;
        } else {
            return [languages count];
        }
    } else {
        return [feedback count];
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

        }    
        
        NSMutableDictionary *map = [maps objectAtIndex:[indexPath row]];
        NSString *mapName = [map objectForKey:@"name"];
        
        [[(CityCell*)cell cityName] setText:[NSString stringWithFormat:@"%@ application", mapName]];
        [[(CityCell*)cell cityName] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:18.0]];
        [[(CityCell*)cell cityName] setTextColor:[UIColor darkGrayColor]];
        
        [[(CityCell*)cell cityNameAlt] setText:mapName];
        [[(CityCell*)cell cityNameAlt] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:16.0]];
        [[(CityCell*)cell cityNameAlt] setTextColor:[UIColor darkGrayColor]];
        
        
        [[(CityCell*)cell priceTag] setText:[map valueForKey:@"price"]];
        [[(CityCell*)cell priceTag] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:18.0]];
        [[(CityCell*)cell priceTag] setHighlightedTextColor:[UIColor whiteColor]];
        
        cell.backgroundColor = [UIColor clearColor];
        
        [[(CityCell*)cell imageView] setImage:[UIImage imageNamed:[map objectForKey:@"picture"]]];
        [[(CityCell*)cell iconView] setImage:[UIImage imageNamed:[map objectForKey:@"icon"]]];

        if ([self isProductStatusDefault:[map objectForKey:@"prodID"]]) {
            CityCell *cityCell = (CityCell*)cell;
            cityCell.cityNameAlt.hidden = NO;
            cityCell.cityName.hidden = YES;
            cityCell.cityNameAlt.text = [NSString stringWithFormat:NSLocalizedString(@"DownloadMapsLabel", @"DownloadMapsLabel"), mapName];
            [cityCell.cellButton addTarget:self action:@selector(buyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cityCell.imageButton addTarget:self action:@selector(previewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

            
            if (self.purchaseIndex == 1)
            {
                purchaseCell = cityCell.cellButton;
                purchaseIndex = 0;
            }
           // if ([map objectForKey:@"picture_maps"] != nil)
             //   [[(CityCell*)cell imageView] setImage:[UIImage imageNamed:[map objectForKey:@"picture_maps"]]];
        }
        else if ([self isProductContentPurchase:[map objectForKey:@"prodID"]]) {
            //This is a content purchase cell
            CityCell *cityCell = (CityCell*)cell;
            cityCell.cityNameAlt.hidden = NO;
            cityCell.cityName.hidden = YES;
            cityCell.cityNameAlt.text = [NSString stringWithFormat:NSLocalizedString(@"PurchaseContentLabel", @"PurchaseContentLabel"), mapName];
            [cityCell.cellButton addTarget:self action:@selector(buyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [cityCell.imageButton addTarget:self action:@selector(previewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

            if ([map objectForKey:@"picture_content"] != nil)
                [[(CityCell*)cell imageView] setImage:[UIImage imageNamed:[map objectForKey:@"picture_content"]]];
            
            if (self.purchaseIndex == 2)
            {
                purchaseCell = cityCell.cellButton;
                purchaseIndex = 0;
            }
        }
        else {
            CityCell *cityCell = (CityCell*)cell;
            cityCell.priceContainer.hidden = YES;
            [cityCell.cellButton addTarget:self action:@selector(openAppStoreLinkPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //
        // setting button background
        //
        
        UIButton *cellButton = [(CityCell*)cell cellButton];
        cellButton.hidden=NO;
        
        UIProgressView *progress = [(CityCell*)cell progress];
        progress.hidden=YES;
        progress.tag=123;
        
//        if ([self isProductStatusDefault:[map objectForKey:@"prodID"]] || [self isProductStatusInstalled:[map objectForKey:@"prodID"]]) {
////            [cellButton setTitle:@"Installed" forState:UIControlStateNormal];
////            [cellButton setTitle:@"Installed" forState:UIControlStateHighlighted];
////            [cellButton setBackgroundImage:[UIImage imageNamed:@"blue_button.png"] forState:UIControlStateNormal];
////            [cellButton setBackgroundImage:[UIImage imageNamed:@"blue_button.png"] forState:UIControlStateHighlighted];
////            [cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////            [[cellButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:15.0]];
//            
//        } else
        if ([self isProductStatusPurchased:[map objectForKey:@"prodID"]])  {
            [[(CityCell*)cell priceTag] setText:NSLocalizedString(@"DownloadButton", @"DownloadButton")];
        }
        if ([self isProductStatusInstalled:[map objectForKey:@"prodID"]]) {
            [[(CityCell*)cell priceTag] setText:NSLocalizedString(@"InstalledButton", @"InstalledButton")];

        }
//
////            [cellButton setTitle:@"Install" forState:UIControlStateNormal];
////            [cellButton setTitle:@"Install" forState:UIControlStateHighlighted];
////            [cellButton setBackgroundImage:[UIImage imageNamed:@"green_button.png"] forState:UIControlStateNormal];
////            [cellButton setBackgroundImage:[UIImage imageNamed:@"high_green_button.png"] forState:UIControlStateHighlighted];
////            [cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////            [[cellButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:15.0]];
//            
//        } else if ([self isProductStatusAvailable:[map objectForKey:@"prodID"]])  {
//            
////            [cellButton setTitle:[map valueForKey:@"price"] forState:UIControlStateNormal];
////            [cellButton setTitle:[map valueForKey:@"price"] forState:UIControlStateHighlighted];
////            [cellButton setBackgroundImage:[UIImage imageNamed:@"buy_button.png"] forState:UIControlStateNormal];
////            [cellButton setBackgroundImage:[UIImage imageNamed:@"high_buy_button.png"] forState:UIControlStateHighlighted];
////            [cellButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
////            [[cellButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:15.0]];
////            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            
//        } else
        if ([self isProductStatusDownloading:[map objectForKey:@"prodID"]]){
            [[(CityCell*)cell priceTag] setText:NSLocalizedString(@"DownloadingButton", @"DownloadingButton")];

            //cellButton.hidden=YES;
            progress.hidden=NO;
            CityCell *cityCell = (CityCell*)cell;
            cityCell.cityNameAlt.hidden = YES;
            cityCell.cityName.hidden = YES;

        }
        else if ([self isProductStatusUnpacking:[map objectForKey:@"prodID"]]) {
            [[(CityCell*)cell priceTag] setText:NSLocalizedString(@"UnpackingButton", @"UnpackingButton")];
            
            //cellButton.hidden=YES;
            progress.hidden=NO;
            CityCell *cityCell = (CityCell*)cell;
            cityCell.cityNameAlt.hidden = YES;
            cityCell.cityName.hidden = YES;
        } else {
            //cellButton.hidden=YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        //
        // setting background
        //
//        
//        UIImage *rowBackground;
//        UIImage *selectionBackground;
//        NSInteger sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
//        NSInteger crow = [indexPath row];
//        
//        if (crow == 0 && crow == sectionRows - 1)
//        {
//            rowBackground = [UIImage imageNamed:@"first_and_last_cell_bg.png"];
//            selectionBackground = [UIImage imageNamed:@"high_first_and_last_cell_bg.png"];
//        }
//        else if (crow == 0)
//        {
//            rowBackground = [UIImage imageNamed:@"first_cell_bg.png"];
//            selectionBackground = [UIImage imageNamed:@"high_first_cell_bg.png"];
//        }
//        else if (crow == sectionRows - 1)
//        {
//            rowBackground = [UIImage imageNamed:@"last_cell_bg.png"];
//            selectionBackground = [UIImage imageNamed:@"high_last_cell_bg.png"];
//        }
//        else
//        {
//            rowBackground = [UIImage imageNamed:@"middle_cell_bg.png"];
//            selectionBackground = [UIImage imageNamed:@"high_middle_cell_bg.png"];
//        }
//        
//        cell.backgroundView  = [[[UIImageView alloc] initWithImage:rowBackground] autorelease];
//        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectionBackground] autorelease];
//        
        return cell;

        // ---------------- language ----------------------
        
    } else if (tableView==langTableView) {
        static NSString *cellIdentifier = @"CityCellContact";
        
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) { 
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CityCellContact" owner:self options:nil] lastObject];
        }    
        
        [[(CityCell*)cell cellButton] setHidden:YES];
        [[(CityCell*)cell progress] setHidden:YES];
        
        [[(CityCell*)cell cityName] setText:[languages objectAtIndex:indexPath.row]];
        [[(CityCell*)cell cityName] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:18.0]];
        [[(CityCell*)cell cityName] setHighlightedTextColor:[UIColor whiteColor]];
        
        cell.backgroundColor = [UIColor clearColor];        
        
        if ([selectedLanguages containsObject:[self.languages objectAtIndex:indexPath.row]]) {
            cell.accessoryType=UITableViewCellAccessoryNone;
            [[(CityCell*)cell checkView] setImage:[UIImage imageNamed:@"checkmark.png"]];
        } else {
            cell.accessoryType=UITableViewCellAccessoryNone;
            [[(CityCell*)cell checkView] setImage:nil];
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
            rowBackground = [UIImage imageNamed:@"first_and_last_cell_bg.png"];
            selectionBackground = [UIImage imageNamed:@"high_first_and_last_cell_bg.png"];
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
        static NSString *cellIdentifier = @"CityCellContact";
        
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) { 
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CityCellContact" owner:self options:nil] lastObject];
        }    
        
        [[(CityCell*)cell cellButton] setHidden:YES];
        [[(CityCell*)cell progress] setHidden:YES];
        
        [[(CityCell*)cell cityName] setText:[feedback objectAtIndex:indexPath.row]];
        [[(CityCell*)cell cityName] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:18.0]];
        [[(CityCell*)cell cityName] setHighlightedTextColor:[UIColor whiteColor]];
        [[(CityCell*)cell cityName] setFrame:CGRectMake(20, 16, 240, 21)];
        
        cell.backgroundColor = [UIColor clearColor];
        
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        [[(CityCell*)cell checkView] setImage:nil];
        
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
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (tableView==self.cityTableView) {
        NSMutableDictionary *map = [maps objectAtIndex:[indexPath row]];
        tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

        if ([[map objectForKey:@"prodID"] isEqual:bundleIdentifier]) {
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
    } else if (tableView==langTableView){
 
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([self.languages count]>1) {
            
            NSMutableArray *reloadA = [NSMutableArray array];
            
            if ([selectedLanguages containsObject:[self.languages objectAtIndex:indexPath.row]]) {
                [selectedLanguages removeObject:[self.languages objectAtIndex:indexPath.row]];
            } else {
                [selectedLanguages addObject:[self.languages objectAtIndex:indexPath.row]];
            }
            
            [reloadA addObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            
            if ([selectedLanguages count] == 0) {
                if (indexPath.row == 0) {
                    [selectedLanguages addObject:[self.languages objectAtIndex:1]];
                    [reloadA addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
                } else {
                    [selectedLanguages addObject:[self.languages objectAtIndex:0]];
                    [reloadA addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
                }
            }
            
            [tableView reloadRowsAtIndexPaths:reloadA withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row==0) {
            NSString *address = [appDelegate getRateUrl];
            if (address) {
                NSURL *url = [NSURL URLWithString:address];
                [[UIApplication sharedApplication] openURL:url];
            }
        } else if (indexPath.row==1) {
            tubeAppDelegate *appDelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
            [self showMailComposer:[NSArray arrayWithObject:[NSString stringWithFormat:@"oxana.bakuma@hotmail.com"]] subject:[NSString stringWithFormat:@"%@ map",[appDelegate getDefaultCityName]] body:nil];
        } else {
            [self showMailComposer:nil subject:NSLocalizedString(@"FeedbackTellSubject", @"FeedbackTellSubject") body:NSLocalizedString(@"FeedbackTellBody", @"FeedbackTellBody")];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == cityTableView) {
        return 199.0;
    }
    return 44.0;
}

#pragma mark - Download delegate methods

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

-(void)refreshButton:(NSIndexPath*)path
{
    CityCell *cell = (CityCell*)[self.cityTableView cellForRowAtIndexPath:path];
    UIProgressView *progress = (UIProgressView*)[cell viewWithTag:123];
    NSDictionary *map = [self.maps objectAtIndex:path.row];
    CGFloat prog = [[map objectForKey:@"progressPart"] floatValue] / [[map objectForKey:@"progressWhole"] floatValue];
    CGFloat part = (float)[[map objectForKey:@"progressPart"] longValue] / (1024.0f*1024.0f);
    CGFloat whole = (float)[[map objectForKey:@"progressWhole"] longValue] / (1024.0f*1024.0f);
    cell.priceTag.text = [NSString stringWithFormat:@"%.1f/%.1f Mb", part, whole];
    progress.progress=prog;
}

-(void)updateFreakingButton:(NSIndexPath*)path
{
    CityCell *cell = (CityCell*)[self.cityTableView cellForRowAtIndexPath:path];
    NSDictionary *map = [self.maps objectAtIndex:path.row];
    if ([[map valueForKey:@"status"] isEqual:@"I"]) {
        [[(CityCell*)cell priceTag] setText:NSLocalizedString(@"InstalledButton", @"InstalledButton")];

    }
    if ([[map valueForKey:@"status"] isEqual:@"ZIP"]) {
        NSString *title = NSLocalizedString(@"UnpackingButton", @"UnpackingButton");
        [[(CityCell*)cell priceTag] setText:title];
        [self.view setNeedsLayout];
    }
}


-(void)installedButton:(NSIndexPath*)path
{
    CityCell *cell = (CityCell*)[self.cityTableView cellForRowAtIndexPath:path];
    UIProgressView *progress = (UIProgressView*)[cell viewWithTag:123];
    NSDictionary *map = [self.maps objectAtIndex:path.row];
    CGFloat prog = [[map objectForKey:@"progressPart"] floatValue] / [[map objectForKey:@"progressWhole"] floatValue];
    CGFloat part = (float)[[map objectForKey:@"progressPart"] longValue] / (1024.0f*1024.0f);
    CGFloat whole = (float)[[map objectForKey:@"progressWhole"] longValue] / (1024.0f*1024.0f);
    cell.priceTag.text = [NSString stringWithFormat:@"%.1f/%.1f Mb", part, whole];
    progress.progress=prog;
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
        //[self performSelectorOnMainThread:@selector(updateFreakingButton:) withObject:mapIndexPath waitUntilDone:NO];
        [self updateFreakingButton:mapIndexPath];

    }
    [cityTableView reloadData];

    
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

-(IBAction)previewButtonPressed:(id)sender
{
    CityCell *cell = (CityCell*)[[sender superview] superview];
    NSMutableDictionary *map = [maps objectAtIndex:[cityTableView indexPathForCell:cell].row];
    //NSString *prodID = [map valueForKey:@"prodID"];
    
    NetworkStatus status = [self connectionStatus];

    if (status == ReachableViaWiFi)
    {
        NSString * key;
        if ([self isProductContentPurchase:[map objectForKey:@"prodID"]])
            key = @"video_content";
        else
            key = @"video";

        NSString *video = [map valueForKey:key];

        if (video != nil)
        {
         //   CustomPhotoViewerViewController *viewer = [[CustomPhotoViewerViewController alloc] initWithVideo:video];
           // viewer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
           // [self presentModalViewController:[viewer autorelease] animated:YES];
           // return;
            NSURL *url = [NSURL URLWithString:video];
            UIApplication *app = [UIApplication sharedApplication];
            if ([app openURL:url])
                return;
        }

    }
    {
        NSString * key;
        if ([self isProductContentPurchase:[map objectForKey:@"prodID"]])
            key = @"preview_content";
        else
            key = @"preview";
        
        NSArray *photos = (NSArray*)[map valueForKey:key];
        
        if (photos != nil)
        {
            CustomPhotoViewerViewController *viewer = [[CustomPhotoViewerViewController alloc] initWithNames:photos];
            viewer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
            [self presentModalViewController:[viewer autorelease] animated:YES];
        }
    }
    
    /*
    if ([self isProductStatusAvailable:prodID]) {
        [self purchaseProduct:prodID];
    } else if ([self isProductStatusPurchased:prodID]) {
        [self downloadProduct:prodID];
    }*/
}

-(IBAction)openAppStoreLinkPressed:(id)sender
{
    CityCell *cell = (CityCell*)[[sender superview] superview];
    NSMutableDictionary *map = [maps objectAtIndex:[cityTableView indexPathForCell:cell].row];
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
    //NSLog(@"Purchased: %@", productIdentifier);
    //[self downloadProduct:productIdentifier];

    [self markProductAsPurchased:productIdentifier];
    
    
    
    
    [self resortMapArray];
    
    [cityTableView reloadData];    
    
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
    [self dismissModalViewControllerAnimated:YES];
}

@end
