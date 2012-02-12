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

@implementation SettingsViewController

@synthesize cityButton;
@synthesize buyButton;
@synthesize langTableView;
@synthesize cityTableView;
@synthesize maps;
@synthesize textLabel1,textLabel2;
@synthesize navBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
          self.maps = [NSArray arrayWithObjects:@"London",@"Paris",@"Madrid",@"Berlin",@"Dublin",@"Oslo", nil];
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
    
 //  self.navigationItem.title = @"Settqqqings";
    
//    self.navigationItem.leftBarButtonItem=UIBarButtonSystemItemCancel;

    // Do any additional setup after loading the view from its nib.
    [self.cityTableView.layer setCornerRadius:10.0];
    
	langTableView.backgroundColor = [UIColor clearColor];
    langTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    textLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    textLabel2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];

	cityTableView.backgroundColor = [UIColor clearColor];
    cityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGRect frame = CGRectMake(0, 0, 320, 44);
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor darkGrayColor];
	self.navigationItem.titleView = label;
	label.text = @"Settings";
	
	self.navigationItem.hidesBackButton=YES;
    
//    self.navBar.
    
	// добавляем кастомные кнопочки слева и справа
	
//	[self putBackButton];	

  
}

-(void) putBackButton
{
	UIImage *back_image=[UIImage imageNamed:@"settings_back_button.png"];
	UIButton *back_button = [UIButton buttonWithType:UIButtonTypeCustom];
	back_button.bounds = CGRectMake( 0, 0, back_image.size.width, back_image.size.height );    
	[back_button setBackgroundImage:back_image forState:UIControlStateNormal];
	[back_button addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];    
	UIBarButtonItem *barButtonItem_back = [[UIBarButtonItem alloc] initWithCustomView:back_button];
	self.navigationItem.leftBarButtonItem = barButtonItem_back;
    self.navigationItem.hidesBackButton=YES;
	[barButtonItem_back release];
}

- (void)viewDidUnload
{
    [self setCityButton:nil];
    [self setBuyButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
        }    
        
        [[(CityCell*)cell cityName] setText:[maps objectAtIndex:[indexPath row]]];
        [[(CityCell*)cell cityName] setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:18.0]];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"city_table_cell.png"]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"city_table_cell.png"]] autorelease];
        

        
        return cell;

    } else {
        static NSString *cellIdentifier = @"LanguageCell";
        
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
 
        if (cell == nil) { 
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LanguageCell" owner:self options:nil] lastObject];
        }

        [[(LanguageCell*)cell languageWordLabel] setText:@"Language"];
        [[(LanguageCell*)cell languageWordLabel] setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:18.0]];
        
        [[(LanguageCell*)cell languageLabel] setText:@"English"];
        [[(LanguageCell*)cell languageLabel] setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:18.0]];
        [[(LanguageCell*)cell languageLabel] setTextColor:[UIColor darkGrayColor]];
        
        
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"language_table_cell.png"]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"language_table_cell.png"]] autorelease];
        
        return cell;
    }
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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

-(IBAction)donePressed:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [cityButton release];
    [buyButton release];
    [super dealloc];
}
@end
