//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <RaptureXML/RXMLElement.h>
#import "BooksViewController.h"
#import "AnswerViewController.h"
#import "BookTableViewCell.h"
#import "AnswersViewController.h"
#import "UIImageView+JMImageCache.h"
#import "NSObject+homeWorksServiceLocator.h"

static NSString *cellIdentifier = @"bookCell";

@implementation BooksViewController
{

}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = [_subject attribute:@"name"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_subject children:@"book"].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"showBook"])
	{
		AnswersViewController *answersViewController = segue.destinationViewController;
		answersViewController.term = _term;
		answersViewController.subject = _subject;
		answersViewController.book = [[_subject children:@"book"] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
	}
}
@end