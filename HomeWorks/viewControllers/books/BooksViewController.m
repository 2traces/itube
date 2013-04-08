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


	cell.nameLabel.text = [[[_subject children:@"book"] objectAtIndex:indexPath.row] attribute:@"name"];
	cell.authorsLabel.text = [[[_subject children:@"book"] objectAtIndex:indexPath.row] attribute:@"authors"];

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