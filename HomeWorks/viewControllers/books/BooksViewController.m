//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "RaptureXML/RXMLElement.h"
#import <MessageUI/MessageUI.h>
#import <CoreGraphics/CoreGraphics.h>
#import "BooksViewController.h"
#import "BookTableViewCell.h"
#import "AnswersViewController.h"
#import "UIImageView+JMImageCache.h"
#import "NSObject+homeWorksServiceLocator.h"

static NSString *findCellidentifier = @"findCell";
static NSString *cellIdentifier = @"bookCell";

@interface BooksViewController () <MFMailComposeViewControllerDelegate>
@end

@implementation BooksViewController
{

}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = [_subject attribute:@"name"];

	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
	[button setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
	[button setImage:[UIImage imageNamed:@"settings_pressed"] forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];

	UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
	[buttonContainer addSubview:button];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonContainer];
}

- (void)showInfo
{
	[self presentModalViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"infoViewController"] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [MFMailComposeViewController canSendMail] ? 2 : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return section == 1 ? 1 : [_subject children:@"book"].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 1)
	{
		return [[tableView dequeueReusableCellWithIdentifier:findCellidentifier] frame].size.height;;
	}

	static NSNumber *height;
	if (!height)
	{
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		height = @(cell.bounds.size.height);
	}
	return [height floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 1) {
		return [tableView dequeueReusableCellWithIdentifier:findCellidentifier];
	}

	BookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	RXMLElement *book = [[_subject children:@"book"] objectAtIndex:indexPath.row];

	cell.nameLabel.text = [book attribute:@"name"];
	cell.authorsLabel.text = [book attribute:@"authors"];

	NSLog([NSString stringWithFormat:self.pageCoverStringFormat,
									 [_term attribute:@"id"],
									 [_subject attribute:@"id"],
									 [book attribute:@"id"]]);

	[cell.bookImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:self.pageCoverStringFormat,
																					[_term attribute:@"id"],
																					[_subject attribute:@"id"],
																					[book attribute:@"id"]]]];

	return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 1)
	{
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
		mailViewController.mailComposeDelegate = self;
		[mailViewController setToRecipients:@[@"oxana.bakuma@hotmail.com"]];
		[mailViewController setSubject:@"Новый решебник"];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
			mailViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		}

		[self presentModalViewController:mailViewController animated:YES];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"showBook"])
	{
		AnswersViewController *targetViewController = segue.destinationViewController;
		if([segue.destinationViewController isKindOfClass:[UINavigationController class]])
		{
			targetViewController = [segue.destinationViewController topViewController];
		}
		targetViewController.term = _term;
		targetViewController.subject = _subject;
		targetViewController.book = [[_subject children:@"book"] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissModalViewControllerAnimated:YES];
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];

}
@end