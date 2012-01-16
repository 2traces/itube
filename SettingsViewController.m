//
//  SettingsViewController.m
//  tube
//
//  Created by sergey on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "InAppProductsViewController.h"

@implementation SettingsViewController

@synthesize cityButton;
@synthesize buyButton;
@synthesize mytableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    self.navigationItem.title = @"Test";
    
//    self.navigationItem.leftBarButtonItem=UIBarButtonSystemItemCancel;

    // Do any additional setup after loading the view from its nib.
    [self.mytableView.layer setCornerRadius:10.0];
    
	mytableView.backgroundColor = [UIColor clearColor];
 //   mytableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"CustomCell";
    
  UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) { 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }
 
    if (indexPath.row==0) {
        cell.textLabel.text = @"City";
        cell.detailTextLabel.text = @"Paris";
    } else {
        cell.textLabel.text = @"Language";
        cell.detailTextLabel.text = @"English";
    }
    
    cell.backgroundColor = [UIColor whiteColor];

//    cell.backgroundView = [[[UIImageView alloc] init] autorelease];
//    cell.selectedBackgroundView = [[[UIImageView alloc] init] autorelease];
    
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Не могу послать письмо" message:@"Это устройство должно быть не сконфигурированно чтобы отсылать почту" delegate:self cancelButtonTitle:@"Ок, я попробую позже" otherButtonTitles:nil];
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
            resultTitle = @"Email прерван";
            resultMsg = @"Вы прервали отсылку письма"; break;
        case MFMailComposeResultSaved:
            resultTitle = @"Email сохранен";
            resultMsg = @"Ваше письмо сохранено в черновиках"; break;
        case MFMailComposeResultSent: resultTitle = @"Email отослан";
            resultMsg = @"Ваше письмо успешно отослано";
            break;
        case MFMailComposeResultFailed:
            resultTitle = @"Email не отправлен";
            resultMsg = @"Ваше письмо не было отправлено"; break;
        default:
            resultTitle = @"Email не отправлен";
            resultMsg = @"Ваше письмо не было отправлено"; break;
    }
    // Notifies user of any Mail Composer errors received with an Alert View dialog.
    UIAlertView *mailAlertView = [[UIAlertView alloc] initWithTitle:resultTitle message:resultMsg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [mailAlertView show];
    [mailAlertView release];
    [resultTitle release];
    [resultMsg release];
    [self dismissModalViewControllerAnimated:YES];
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
