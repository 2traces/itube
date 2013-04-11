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

	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:121.0 / 255.0 green:166.0 / 255.0 blue:191.0 / 255.0 alpha:1.0]];
	[self.navigationController.navigationBar setTitleTextAttributes:
			@{
					UITextAttributeTextShadowColor : [UIColor blackColor],
					UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)]
			}];

	UIImage *navigationBarBackgroundImage = [[UIImage imageNamed:@"bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 5.0, 1.0, 5.0)];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage
												  forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage
												  forBarMetrics:UIBarMetricsLandscapePhone];
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
		SubjectsViewController *subjectsViewController = segue.destinationViewController;
		subjectsViewController.term = [[self.catalogRxml children:@"term"] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
	}
}

@end