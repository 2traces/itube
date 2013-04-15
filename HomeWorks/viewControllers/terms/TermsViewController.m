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

- (void)viewDidLoad
{
	[super viewDidLoad];

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

	RXMLElement *term = [[self.catalogRxml children:@"term"] objectAtIndex:indexPath.row];
	cell.numLabel.text = [term attribute:@"num"];
	[cell.iconImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%d", [[term attribute:@"icon"] intValue]]]];

	return cell;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"showTerm"])
	{
		SubjectsViewController *targetViewController = segue.destinationViewController;
		if ([segue.destinationViewController isKindOfClass:[UINavigationController class]])
		{
			targetViewController = [segue.destinationViewController topViewController];

		}
		targetViewController.term = [[self.catalogRxml children:@"term"] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
	}
}

@end