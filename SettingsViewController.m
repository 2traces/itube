//
//  SettingsViewController.m
//  tube
//
//  Created by Sergey Mingalev on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "CityCell.h"
#import "CityMap.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "Reachability.h"
#import "TubeAppIAPHelper.h"
#import "DemoMapViewController.h"
#import "SSZipArchive.h"
#import "SSTheme.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>

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

        self.feedback = [NSMutableArray arrayWithObjects:NSLocalizedString(@"FeedbackRate",@"FeedbackRate"),NSLocalizedString(@"FeedbackMail",@"FeedbackMail"),NSLocalizedString(@"FeedbackTell",@"FeedbackTell"), nil];
        
        if ([self isTwitterAvailable]) {
            [self.feedback addObject:NSLocalizedString(@"FeedbackTwitter",@"FeedbackTwitter")];
        }
             
        if ([self isFacebookAvailable]) {
            [self.feedback addObject:NSLocalizedString(@"FeedbackFacebook",@"FeedbackFacebook")];
        }
        
        isFirstTime=YES;
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
            [product setObject:@"D" forKey:@"status"];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id <SSTheme> theme = [SSThemeManager sharedTheme];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapChanged:) name:kMapChanged object:nil];
    
	langTableView.backgroundColor = [UIColor clearColor];
    langTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    langTableView.frame = CGRectMake((320.0-[theme widthSettingsCellTableView])/2, cityTableView.frame.origin.y, [theme widthSettingsCellTableView],cityTableView.frame.size.height);
    
    textLabel1.font = [theme settingsTableViewFont];
    textLabel2.font = [theme settingsTableViewFont];
    textLabel3.font = [theme settingsTableViewFont];
    textLabel4.font = [theme settingsTableViewFont];
    
    textLabel1.textColor = [theme mainColor];
    textLabel2.textColor = [theme mainColor];
    textLabel3.textColor = [theme mainColor];
    textLabel4.textColor = [theme mainColor];
    
    scrollView.backgroundColor = [theme demoMapViewBackgroundColor];
    
	cityTableView.backgroundColor = [UIColor clearColor];
    cityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cityTableView.frame = CGRectMake((320.0-[theme widthSettingsCellTableView])/2, cityTableView.frame.origin.y, [theme widthSettingsCellTableView],cityTableView.frame.size.height);

	feedbackTableView.backgroundColor = [UIColor clearColor];
    feedbackTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    feedbackTableView.frame = CGRectMake((320.0-[theme widthSettingsCellTableView])/2, cityTableView.frame.origin.y, [theme widthSettingsCellTableView],cityTableView.frame.size.height);
    
	self.navigationItem.title=NSLocalizedString(@"Settings",@"Settings");
    
    UIBarButtonItem *barButtonItem_back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(donePressed:)];
    
    [barButtonItem_back setBackgroundImage:[theme backBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItem_back setBackgroundImage:[theme backBackgroundForState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [barButtonItem_back  setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[theme backButtonTitleColor], UITextAttributeTextColor, [theme backbuttonTitleFont], UITextAttributeFont, [theme titleShadowColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil] forState:UIControlStateNormal];
    [barButtonItem_back  setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[theme backButtonPressedTitleColor], UITextAttributeTextColor, [theme backbuttonTitleFont], UITextAttributeFont, [theme titleShadowColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil] forState:UIControlStateDisabled];
    [barButtonItem_back  setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[theme backButtonPressedTitleColor], UITextAttributeTextColor, [theme backbuttonTitleFont], UITextAttributeFont, [theme backButtonTitleColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil] forState:UIControlStateHighlighted];

#if defined(NEW_THEME)
    [updateButton setFrame:CGRectMake(0, updateButton.frame.origin.y, 320, updateButton.frame.size.height)];
    [updateButton setImage:nil forState:UIControlStateNormal];
    [updateButton setImage:nil forState:UIControlStateHighlighted];
    [updateButton setTitle:@"Update" forState:UIControlStateNormal];
    [updateButton setTitle:@"Update" forState:UIControlStateHighlighted];
    [[updateButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:18.0]];
    [updateButton setTitleColor:[theme mainColor] forState:UIControlStateNormal];
    [updateButton setBackgroundImage:[theme middleCellSettingsTableImageNormal] forState:UIControlStateNormal];
    [updateButton setBackgroundImage:[theme middleCellSettingsTableImageHighlighted] forState:UIControlStateHighlighted];
    [updateButton setTitleEdgeInsets:UIEdgeInsetsMake(7, 15, 0, 0)];
    
    [barButtonItem_back setBackgroundVerticalPositionAdjustment:-2.0f forBarMetrics:UIBarMetricsDefault];
    [barButtonItem_back setTitlePositionAdjustment:UIOffsetMake(5.0, 3.0f) forBarMetrics:UIBarMetricsDefault];
    
    updateImageView.image = [UIImage imageNamed:@"newdes_pregressArrows.png"];
#else
    [barButtonItem_back setTitlePositionAdjustment:UIOffsetMake(2.0, 3.0f) forBarMetrics:UIBarMetricsDefault];
#endif

    self.navigationItem.leftBarButtonItem=barButtonItem_back;
    
    [TubeAppIAPHelper sharedHelper];
        
    [self adjustViewHeight];

//    for testing multi-charts
//    [self markProductAsPurchased:@"com.zuev.itube.paris.shanghai"];
//    [self markProductAsPurchased:@"com.zuev.itube.paris.london"];
//    [self markProductAsPurchased:@"com.zuev.itube.paris.hamburg"];
//    [self resortMapArray];
//    [cityTableView reloadData];
    
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
    
    CGFloat cityTableHeight = [maps count]*45.0f+2.0;
    CGFloat feedbackTableHeight = [feedback count]*45.0f+2.0; 
    
    cityTableView.frame=CGRectMake(cityTableView.frame.origin.x+addX, textLabel3.frame.origin.y+textLabel3.frame.size.height+10, cityTableView.frame.size.width,  cityTableHeight);
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
    id <SSTheme> theme = [SSThemeManager sharedTheme];
    
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
        [[(CityCell*)cell cityName] setTextColor:[theme mainColor]];
        [[(CityCell*)cell cityName] setHighlightedTextColor:[UIColor whiteColor]];
        
        cell.backgroundColor = [UIColor clearColor];
        
        if ([indexPath isEqual:self.selectedPath]) {
            cell.accessoryType=UITableViewCellAccessoryNone;
            [[(CityCell*)cell checkView] setImage:[UIImage imageNamed:@"checkmark.png"]];
        } else {
            cell.accessoryType=UITableViewCellAccessoryNone;
            [[(CityCell*)cell checkView] setImage:nil];
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
            [cellButton setBackgroundImage:[theme bluebuttonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
            [cellButton setBackgroundImage:[theme bluebuttonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            [cellButton setTitleColor:[theme buyButtonFontColorInstalled] forState:UIControlStateNormal];
            [[cellButton titleLabel] setFont:[theme buyButtonFont]];
            
            
        } else if ([self isProductStatusPurchased:[map objectForKey:@"prodID"]])  {
            
            [cellButton setTitle:@"Install" forState:UIControlStateNormal];
            [cellButton setTitle:@"Install" forState:UIControlStateHighlighted];
            [cellButton setBackgroundImage:[theme greenbuttonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
            [cellButton setBackgroundImage:[theme greenbuttonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            [cellButton setTitleColor:[theme buyButtonFontColorInstalled] forState:UIControlStateNormal];
            [[cellButton titleLabel] setFont:[theme buyButtonFont]];
            
        } else if ([self isProductStatusAvailable:[map objectForKey:@"prodID"]])  {
            
            [cellButton setTitle:[map valueForKey:@"price"] forState:UIControlStateNormal];
            [cellButton setTitle:[map valueForKey:@"price"] forState:UIControlStateHighlighted];
            [cellButton setBackgroundImage:[theme buybuttonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
            [cellButton setBackgroundImage:[theme buybuttonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            [cellButton setTitleColor:[theme buyButtonFontColorAvailable] forState:UIControlStateNormal];
            [[cellButton titleLabel] setFont:[theme buyButtonFont]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            [[cellButton titleLabel] setShadowColor:[UIColor whiteColor]];
            [[cellButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
            [cellButton setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];


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

        if (crow == 0 && crow == sectionRows - 1)
        {
            rowBackground = [theme firstAndLastCellSettingsTableImageNormal];
            selectionBackground = [theme firstAndLastCellSettingsTableImageHighlighted];
        }
        else if (crow == 0)
        {
            rowBackground = [theme firstCellSettingsTableImageNormal];
            selectionBackground = [theme firstCellSettingsTableImageHighlighted];
        }
        else if (crow == sectionRows - 1)
        {
            rowBackground = [theme lastCellSettingsTableImageNormal];
            selectionBackground = [theme lastCellSettingsTableImageHighlighted];
        }
        else
        {
            rowBackground = [theme middleCellSettingsTableImageNormal];
            selectionBackground = [theme middleCellSettingsTableImageHighlighted];
        }

        
        cell.backgroundView  = [[[UIImageView alloc] initWithImage:rowBackground] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectionBackground] autorelease];
        
        return cell;

        // ---------------- language ----------------------
        
    } else if (tableView==langTableView) {
        static NSString *cellIdentifier = @"CityCell";
        
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) { 
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CityCell" owner:self options:nil] lastObject];
        }    
        
        [[(CityCell*)cell cellButton] setHidden:YES];
        [[(CityCell*)cell progress] setHidden:YES];
        
        [[(CityCell*)cell cityName] setText:[languages objectAtIndex:indexPath.row]];
        [[(CityCell*)cell cityName] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:18.0]];
        [[(CityCell*)cell cityName] setTextColor:[theme mainColor]];
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

        if (crow == 0 && crow == sectionRows - 1)
        {
            rowBackground = [theme firstAndLastCellSettingsTableImageNormal];
            selectionBackground = [theme firstAndLastCellSettingsTableImageHighlighted];
        }
        else if (crow == 0)
        {
            rowBackground = [theme firstCellSettingsTableImageNormal];
            selectionBackground = [theme firstCellSettingsTableImageHighlighted];
        }
        else if (crow == sectionRows - 1)
        {
            rowBackground = [theme lastCellSettingsTableImageNormal];
            selectionBackground = [theme lastCellSettingsTableImageHighlighted];
        }
        else
        {
            rowBackground = [theme middleCellSettingsTableImageNormal];
            selectionBackground = [theme middleCellSettingsTableImageHighlighted];
        }

        cell.backgroundView  = [[[UIImageView alloc] initWithImage:rowBackground] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectionBackground] autorelease];
        
        return cell;
    } else {
        static NSString *cellIdentifier = @"CityCell";
        
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) { 
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CityCell" owner:self options:nil] lastObject];
        }    
        
        [[(CityCell*)cell cellButton] setHidden:YES];
        [[(CityCell*)cell progress] setHidden:YES];
        
        [[(CityCell*)cell cityName] setText:[feedback objectAtIndex:indexPath.row]];
        [[(CityCell*)cell cityName] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:18.0]];
        [[(CityCell*)cell cityName] setTextColor:[theme mainColor]];
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
        
//        if (crow == 0 && crow == sectionRows - 1)
//        {
//            // у нас таких быть не должно вообще но 
//            rowBackground = [UIImage imageNamed:@"middle_cell_bg.png"];
//            selectionBackground = [UIImage imageNamed:@"high_middle_cell_bg.png"];
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

        if (crow == 0 && crow == sectionRows - 1)
        {
            rowBackground = [theme middleCellSettingsTableImageNormal];
            selectionBackground = [theme middleCellSettingsTableImageHighlighted];
        }
        else if (crow == 0)
        {
            rowBackground = [theme firstCellSettingsTableImageNormal];
            selectionBackground = [theme firstCellSettingsTableImageHighlighted];
        }
        else if (crow == sectionRows - 1)
        {
            rowBackground = [theme lastCellSettingsTableImageNormal];
            selectionBackground = [theme lastCellSettingsTableImageHighlighted];
        }
        else
        {
            rowBackground = [theme middleCellSettingsTableImageNormal];
            selectionBackground = [theme middleCellSettingsTableImageHighlighted];
        }

        cell.backgroundView  = [[[UIImageView alloc] initWithImage:rowBackground] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectionBackground] autorelease];
        
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
            NSString *address = [[NSUserDefaults standardUserDefaults] objectForKey:@"RateMeURL"];
            if (address) {
                NSURL *url = [NSURL URLWithString:address];
                [[UIApplication sharedApplication] openURL:url];
            }
        } else if (indexPath.row==1) {
            tubeAppDelegate *appDelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
            [self showMailComposer:[NSArray arrayWithObject:[NSString stringWithFormat:@"fusio@yandex.ru"]] subject:[NSString stringWithFormat:@"%@ map",[appDelegate getDefaultCityName]] body:nil];
        } else if (indexPath.row==2){
            [self showMailComposer:nil subject:NSLocalizedString(@"FeedbackTellSubject", @"FeedbackTellSubject") body:NSLocalizedString(@"FeedbackTellBody", @"FeedbackTellBody")];
        } else {
            CityCell *cell = (CityCell*)[tableView cellForRowAtIndexPath:indexPath];
            if ([cell.cityName.text isEqual:NSLocalizedString(@"FeedbackTwitter",@"FeedbackTwitter")]) {
                [self sendTweet];
            } else if ([cell.cityName.text isEqual:NSLocalizedString(@"FeedbackFacebook",@"FeedbackFacebook")]) {
                [self postFacebook];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 45.0;
}

#pragma mark - Download delegate methods

-(void)downloadDone:(NSMutableData *)data prodID:(NSString*)prodID server:(DownloadServer *)myid
{
    if (requested_file_type==plist_) {
        [self processPlistFromServer:data];
    } else if (requested_file_type==zip_) {
        [self processZipFromServer:data prodID:(NSString*)prodID];
    }
    
    [servers removeObject:myid];
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
    
    [self stopTimer];
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
    
    [self markProductAsPurchased:productIdentifier];
    
    [self resortMapArray];
    
    [cityTableView reloadData];    
    
}

-(void)markProductAsPurchased:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && ([[map valueForKey:@"status"] isEqual:@"V"] || [[map valueForKey:@"status"] isEqual:@"Z"]) ) {
            [map setObject:@"P" forKey:@"status"];
        }
    }
}

-(void)markProductAsInstalled:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID]) {
            [map setObject:@"I" forKey:@"status"];
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

#pragma mark  - Social

-(BOOL)isTwitterAvailable
{
    Class class = NSClassFromString(@"SLComposeViewController");
    if (!class) {
        Class class2 = NSClassFromString(@"TWTweetComposeViewController");
        if(!class2) {
            return NO;
        } else {
            return [TWTweetComposeViewController canSendTweet];
        }
    } else {
        return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    }
}

-(BOOL)isFacebookAvailable
{
    Class class = NSClassFromString(@"SLComposeViewController");
    if (!class) {
        return NO;
    } else {
        return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
    }
}

-(void)sendTweet
{
    Class class = NSClassFromString(@"SLComposeViewController");
    if (class) {
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:@"Check this great Metro.Paris app"];
        NSString *string = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0];
        [composeController addImage:[UIImage imageNamed:string]];
        [composeController addURL: [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppStoreURL"]]];
        
        [self presentViewController:composeController animated:YES completion:nil];
    } else {
        TWTweetComposeViewController *tweetSheet =
        [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:@"Check this great Metro.Paris app"];
        [tweetSheet addImage:[UIImage imageNamed: [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]]];
        [tweetSheet addURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppStoreURL"]]];
        [self presentModalViewController:tweetSheet animated:YES];
    }
}

-(void)postFacebook
{
    SLComposeViewController *composeController = [SLComposeViewController
                                                  composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [composeController setInitialText:@"Check this great Metro.Paris app"];
    [composeController addImage:[UIImage imageNamed: [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]]];
    [composeController addURL: [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppStoreURL"]]];
    
    [self presentViewController:composeController animated:YES completion:nil];
}

@end
