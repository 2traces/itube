//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "RaptureXML/RXMLElement.h"
#import <MessageUI/MessageUI.h>
#import "BooksViewController.h"
#import "BookTableViewCell.h"
#import "AnswersViewController.h"
#import "UIImageView+JMImageCache.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "BooksService.h"

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
		NSMutableArray *targetArray = [book attributeAsInt:@"free"] ? freeBooks : paidBooks;

		if([[self booksService] isAvailableOfflineWithTermId:[_term attribute:@"id"] withSubjectId:[_subject attribute:@"id"] withBookId:[book attribute:@"id"]])
		{
			[targetArray insertObject:book atIndex:0];
		}
		else
		{
			[targetArray addObject:book];
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

	static CGFloat height;
	if (!height)
	{
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		height = cell.bounds.size.height;
	}
	return height;
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

	NSString *termId = [_term attribute:@"id"];
	NSString *subjectId = [_subject attribute:@"id"];
	NSString *bookId = [book attribute:@"id"];

	[cell.bookImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:self.pageCoverStringFormat,
																					termId,
																					subjectId,
																					bookId]]];

	if([self.booksService isAvailableOfflineWithTermId:termId withSubjectId:subjectId withBookId:bookId])
	{
		cell.nameLabel.text = [cell.nameLabel.text stringByAppendingString:@" [offline]"];
	}
	
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

		[self presentViewController:mailViewController animated:YES completion:nil];
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"showBook"])
	{
		AnswersViewController *targetViewController = segue.destinationViewController;
		if([segue.destinationViewController isKindOfClass:[UINavigationController class]])
		{
			targetViewController = (AnswersViewController*)[segue.destinationViewController topViewController];
		}
		targetViewController.term = _term;
		targetViewController.subject = _subject;
		targetViewController.book = [[_subject children:@"book"] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
	}
}
@end