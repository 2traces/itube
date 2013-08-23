//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "RaptureXML/RXMLElement.h"
#import "SubjectsViewController.h"
#import "BooksViewController.h"
#import "SubjectTableVIewCell.h"
#import "NSObject+homeWorksServiceLocator.h"


@implementation SubjectsViewController
{

}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = [NSString stringWithFormat:@"%d класс", [_term attributeAsInt:@"num"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_term children:@"subject"].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"subjectCell";
	SubjectTableVIewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	RXMLElement *subject = [[_term children:@"subject"] objectAtIndex:indexPath.row];
	cell.nameLabel.text = [subject attribute:@"name"];
	[cell.iconImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%d", [[subject attribute:@"icon"] intValue]]]];

	return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"showSubject"])
	{
		BooksViewController *targetViewController = segue.destinationViewController;
		if([segue.destinationViewController isKindOfClass:[UINavigationController class]])
		{
			targetViewController = (BooksViewController*)[segue.destinationViewController topViewController];

		}
		targetViewController.term = _term;
		targetViewController.subject = [[_term children:@"subject"] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
	}
}

@end