//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TermsViewController.h"
#import "TermTableViewCell.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "SubjectsViewController.h"


@implementation TermsViewController
{

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.catalogRxml children:@"term"].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"termCell";
	TermTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	cell.numLabel.text = [[[self.catalogRxml children:@"term"] objectAtIndex:indexPath.row] attribute:@"num"];

	return cell;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"showTerm"])
	{
		SubjectsViewController *subjectsViewController = segue.destinationViewController;
		subjectsViewController.term = [[self.catalogRxml children:@"term"] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
	}
}

@end