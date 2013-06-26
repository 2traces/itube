//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <RaptureXML/RXMLElement.h>
#import <MessageUI/MessageUI.h>
#import "BooksViewController.h"
#import "BookTableViewCell.h"
#import "AnswersViewController.h"
#import "UIImageView+JMImageCache.h"
#import "NSObject+homeWorksServiceLocator.h"

static NSString *findCellidentifier = @"findCell";
static NSString *cellIdentifier = @"bookCell";

static NSUInteger kFeedbackSection = 2;

@interface BooksViewController () <MFMailComposeViewControllerDelegate>
@end

@implementation BooksViewController
{
	NSMutableArray *freeBooks;
	NSMutableArray *paidBooks;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = [_subject attribute:@"name"];

	freeBooks = [NSMutableArray array];
	paidBooks = [NSMutableArray array];
	for(RXMLElement *book in [_subject children:@"book"])
	{
		if([book attributeAsInt:@"free"] == YES)
		{
			[freeBooks addObject:book];
		}
		else
		{
			[paidBooks addObject:book];
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [MFMailComposeViewController canSendMail] ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch(section)
	{
		case 0:
			return paidBooks.count;
		case 1:
			return freeBooks.count;
		default:
			return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == kFeedbackSection)
	{
		return [[tableView dequeueReusableCellWithIdentifier:findCellidentifier] frame].size.height;
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
	if(indexPath.section == kFeedbackSection)
	{
		return [tableView dequeueReusableCellWithIdentifier:findCellidentifier];
	}

	BookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	NSArray *sectionBooks = indexPath.section == 0 ? paidBooks : freeBooks;
	RXMLElement *book = [sectionBooks objectAtIndex:indexPath.row];

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
	if(indexPath.section == kFeedbackSection)
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

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissModalViewControllerAnimated:YES];
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];

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
@end