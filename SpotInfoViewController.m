//
//  SpotInfoViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 30/10/13.
//
//

#import "SpotInfoViewController.h"
#import "SpotCommentCell.h"
#import "tubeAppDelegate.h"
#import "NavBarViewController.h"

#define APPSTORE_URL @"https://itunes.apple.com/en/app/angry-birds/id343200656#"
#define SHARE_FORMAT @"I've just found free Wi-Fi with WiFi Spots app! Check it out: %@"

@interface SpotInfoViewController ()

@end

@implementation SpotInfoViewController

- (IBAction)shareFacebook:(id)sender {
//    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
//    {
        self.mySLComposerSheet = [[[SLComposeViewController alloc] init] autorelease]; //initiate the Social Controller
        self.mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
        [self.mySLComposerSheet setInitialText:[NSString stringWithFormat:SHARE_FORMAT, APPSTORE_URL]]; //the message you want to post
        [self presentViewController:self.mySLComposerSheet animated:YES completion:nil];
        [self.mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = @"Action Cancelled";
                    break;
                case SLComposeViewControllerResultDone:
                    output = @"Post Successfull";
                    break;
                default:
                    break;
            } //check if everythink worked properly. Give out a message on the state.
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
//            [alert autorelease];
        }];
//    }
//    else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Facebook account" message:@"Please, connect your account in \"Settings\" -> \"Facebook\" to be able to share on Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        [alert autorelease];
//    }
    
}

- (IBAction)shareTwitter:(id)sender {
//    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) //check if Facebook Account is linked
//    {
        self.mySLComposerSheet = [[[SLComposeViewController alloc] init] autorelease]; //initiate the Social Controller
        self.mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter]; //Tell him with what social plattform to use it, e.g. facebook or twitter
        [self.mySLComposerSheet setInitialText:[NSString stringWithFormat:SHARE_FORMAT, APPSTORE_URL]]; //the message you want to post
        [self presentViewController:self.mySLComposerSheet animated:YES completion:nil];
        [self.mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = @"Action Cancelled";
                    break;
                case SLComposeViewControllerResultDone:
                    output = @"Post Successfull";
                    break;
                default:
                    break;
            } //check if everythink worked properly. Give out a message on the state.
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
//            [alert autorelease];
        }];
//    }
//    else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter account" message:@"Please, connect your account in \"Settings\" -> \"Twitter\" to be able to share on Twitter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        [alert autorelease];
//    }
}

- (IBAction)shareMail:(id)sender {
    if ([MFMailComposeViewController canSendMail])
        // The device can send email.
    {
        [self displayMailComposerSheet];
    }
    else
        // The device can not send email.
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Sorry, this device is not configured for sending mail." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert autorelease];
    }
}

- (IBAction)shareSMS:(id)sender {
    if ([MFMessageComposeViewController canSendText])
        // The device can send email.
    {
        [self displaySMSComposerSheet];
    }
    else
        // The device can not send email.
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Sorry, this device is not configured for sending messages." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert autorelease];
    }
}


#pragma mark - Compose Mail/SMS

// -------------------------------------------------------------------------------
//	displayMailComposerSheet
//  Displays an email composition interface inside the application.
//  Populates all the Mail fields.
// -------------------------------------------------------------------------------
- (void)displayMailComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Check out this awesome app!"];
	
	// Fill out the email body text
	NSString *emailBody = [NSString stringWithFormat:SHARE_FORMAT, APPSTORE_URL];
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentViewController:picker animated:YES completion:NULL];
}

// -------------------------------------------------------------------------------
//	displayMailComposerSheet
//  Displays an SMS composition interface inside the application.
// -------------------------------------------------------------------------------
- (void)displaySMSComposerSheet
{
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate = self;
	
    // You can specify one or more preconfigured recipients.  The user has
    // the option to remove or add recipients from the message composer view
    // controller.
    /* picker.recipients = @[@"Phone number here"]; */
    
    // You can specify the initial message text that will appear in the message
    // composer view controller.
    picker.body = [NSString stringWithFormat:SHARE_FORMAT, APPSTORE_URL];
    
	[self presentViewController:picker animated:YES completion:NULL];
}


#pragma mark - Delegate Methods

// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)res error:(NSError*)error
{
	NSString *result = nil;
	// Notifies users about errors associated with the interface
	switch (res)
	{
		case MFMailComposeResultCancelled:
			result = @"Result: Mail sending canceled";
			break;
		case MFMailComposeResultSaved:
			result = @"Result: Mail saved";
			break;
		case MFMailComposeResultSent:
			result = @"Result: Mail sent";
			break;
		case MFMailComposeResultFailed:
			result = @"Result: Mail sending failed";
			break;
		default:
			result = @"Result: Mail not sent";
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:NULL];
}

// -------------------------------------------------------------------------------
//	messageComposeViewController:didFinishWithResult:
//  Dismisses the message composition interface when users tap Cancel or Send.
//  Proceeds to update the feedback message field with the result of the
//  operation.
// -------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)res
{
	NSString *result = nil;
	// Notifies users about errors associated with the interface
	switch (res)
	{
		case MessageComposeResultCancelled:
			result = @"Result: SMS sending canceled";
			break;
		case MessageComposeResultSent:
			result = @"Result: SMS sent";
			break;
		case MessageComposeResultFailed:
			result = @"Result: SMS sending failed";
			break;
		default:
			result = @"Result: SMS not sent";
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:NULL];
}


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
    // Do any additional setup after loading the view from its nib.
    CGFloat yOffset = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        yOffset = 64;
    }
    else {

    }
    
    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];
    
    self.navigationItem.title = self.spotInfo.title;
    

    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.frame = CGRectMake(0, 0, 320, 44);
    [bt setTitle:self.spotInfo.title forState:UIControlStateNormal];
    [bt setTitleColor:[UIColor colorWithRed:124.0/255.0f green:124.0/255.0f blue:124.0/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [bt setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bt.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    bt.titleLabel.shadowColor = [UIColor whiteColor];
    bt.titleLabel.shadowOffset = CGSizeMake(-0.5, 0.5);
    
    [bt addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = bt;
    
    if (self.navBarVC.bar) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack)] autorelease];
        [self.navBarVC.bar setItems:@[self.navigationItem] animated:YES];
    }
    else {
        UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, 320, 34)];
        shadow.image = [[UIImage imageNamed:@"navbar_shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
        [self.view addSubview:shadow];
    }
    
//    UITapGestureRecognizer *rec2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    [self.navigationItem.titleView addGestureRecognizer:rec2];
}

- (void)goBack {
    [self.navBarVC popVC];
}

-(void)handleTap:(id)sender
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    GlViewController *gl = appDelegate.glViewController;
    Pin *pin = [gl getPin:self.spotInfo.pinID];
    [gl scrollToGeoPosition:pin.geoPosition withZoom:-1];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.spotInfo.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SpotCommentCell";
    
    SpotCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SpotCommentCell" owner:self options:nil] lastObject];
    }
    
    cell.subtitleLabel.text = [self.spotInfo.comments objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 81;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.shareView;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        SpotCommentCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:cell.subtitleLabel.text];
    }
}

@end
