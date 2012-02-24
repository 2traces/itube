//
//  SettingsViewController.m
//  tube
//
//  Created by sergey on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "InAppProductsViewController.h"
#import "LanguageCell.h"
#import "CityCell.h"
#import "MyNavigationBar.h"
#import "CityMap.h"
#import "tubeAppDelegate.h"

@implementation SettingsViewController

@synthesize cityButton;
@synthesize buyButton;
@synthesize langTableView;
@synthesize cityTableView;
@synthesize maps;
@synthesize textLabel1,textLabel2,textLabel3;
@synthesize navBar;
@synthesize navItem;
@synthesize scrollView;
@synthesize selectedPath;
@synthesize buyAllButton,sendMailButton;

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

-(IBAction)cityPress:(id)sender
{
    // soj
    
    Server *server = [[Server alloc] init];
    server.listener=self;
    
    NSArray *stationList = [NSArray arrayWithObjects:@"Croix de Chavaux", @"Robespierre", nil];
    
    [server sendRequestStationList:stationList];
}

-(IBAction)buyPress:(id)sender
{
    InAppProductsViewController *controller = [[InAppProductsViewController alloc] initWithNibName:@"InAppProductsViewController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	langTableView.backgroundColor = [UIColor clearColor];
    langTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    textLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    textLabel2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    textLabel3.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];

	cityTableView.backgroundColor = [UIColor clearColor];
    cityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGRect frame = CGRectMake(80, 0, 160, 44);
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0];
//	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor darkGrayColor];
    label.text = @"Settings";
	self.navItem.titleView = label;
	
    UIImage *back_image=[UIImage imageNamed:@"settings_back_button.png"];
	UIButton *back_button = [UIButton buttonWithType:UIButtonTypeCustom];
	back_button.bounds = CGRectMake( 0, 0, back_image.size.width, back_image.size.height );    
	[back_button setBackgroundImage:back_image forState:UIControlStateNormal];
	[back_button addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];    
	UIBarButtonItem *barButtonItem_back = [[UIBarButtonItem alloc] initWithCustomView:back_button];
	self.navItem.leftBarButtonItem = barButtonItem_back;
	self.navItem.hidesBackButton=YES;
	[barButtonItem_back release];
    
    CGFloat tableHeight = [maps count]*45.0f+2.0;
    
    cityTableView.frame = CGRectMake(8, 179, 304, tableHeight);
    
    CGRect buyAll = buyAllButton.frame;
    buyAllButton.frame = CGRectMake(buyAll.origin.x, 179+tableHeight+8, buyAll.size.width, buyAll.size.height);
    
    textLabel3.frame = CGRectMake(textLabel3.frame.origin.x, buyAllButton.frame.origin.y+buyAllButton.frame.size.height+17.0, textLabel3.frame.size.width, textLabel3.frame.size.height);
    
    sendMailButton.frame = CGRectMake(sendMailButton.frame.origin.x, buyAllButton.frame.origin.y+buyAllButton.frame.size.height+8.0, sendMailButton.frame.size.width, sendMailButton.frame.size.height);

	scrollView.contentSize = CGSizeMake(320, sendMailButton.frame.origin.y+sendMailButton.frame.size.height+15.0);
    scrollView.frame = CGRectMake(0.0, 44.0, 320.0, 460.0-44.0);
    
	[scrollView flashScrollIndicators];
}

- (void)viewDidUnload
{
    [self setCityButton:nil];
    [self setBuyButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma - TableView
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
        [[(CityCell*)cell cellButton] setImage:[UIImage imageNamed:@"buy_button.png"] forState:UIControlStateNormal];
        [[(CityCell*)cell cellButton] setImage:[UIImage imageNamed:@"high_buy_button.png"] forState:UIControlStateHighlighted];
        [[(CityCell*)cell cellButton] setTitle:@"$0.99" forState:UIControlStateNormal];
        [[(CityCell*)cell cellButton] setTitle:@"$0.99" forState:UIControlStateHighlighted];
        
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
        
        cell.backgroundView  = [[UIImageView alloc] initWithImage:rowBackground];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:selectionBackground];
                
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
    self.selectedPath=indexPath;
    
    [tableView reloadData];    

    NSMutableDictionary *map = [maps objectAtIndex:[indexPath row]];
    NSString *mapName = [map objectForKey:@"filename"];

    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController changeMapTo:mapName];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 45.0;
}

-(void)serverDone:(NSMutableDictionary *)schedule
{
    NSString *stationName;
    NSString *stationTimes;
    
    NSArray *array = [schedule allKeys];
    
    if ([array count]>0) {
        stationName=[array objectAtIndex:1];
        stationTimes=[[schedule objectForKey:stationName] componentsJoinedByString:@", "];
    }
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:stationName message:stationTimes delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [myAlertView show];
    [myAlertView release];
    
}

-(IBAction)buyButtonPressed:(id)sender 
{
    NSLog(@"Button pressed");
}

-(IBAction)donePressed:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

-(NSArray*)getMapsList
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSArray *array = [dict allKeys];
    NSMutableArray *mapsInfoArray = [[[NSMutableArray alloc] initWithCapacity:[array count]] autorelease];
    
    for (NSString* key in array) {
        NSMutableDictionary *product = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:key]];
        [product setObject:key forKey:@"prodID"];
        [mapsInfoArray addObject:product];
        [product release];
    }

    [dict release];
    
    return mapsInfoArray;
}

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
    [cityButton release];
    [buyButton release];
    [super dealloc];
}
@end
