//
// Created by bsideup on 4/9/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FRLayeredNavigationController/UIViewController+FRLayeredNavigationController.h"
#import "HomeworksTableViewController.h"


@implementation HomeworksTableViewController
{

	UIImage *tableButtomTopImage;
	UIImage *tableButtomTopPressedImage;
	UIImage *tableButtonMidImage;
	UIImage *tableButtonMidPressedImage;
	UIImage *tableButtonDownImage;
	UIImage *tableButtonDownPressedImage;
	UIImage *tableButtonSingleImage;
	UIImage *tableButtonSinglePressedImage;
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
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		self.tableView.backgroundView  = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableBackgroundIpad"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 768.0, 0.0, 0.0)]];
	}
	else
	{
		self.tableView.backgroundView  = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)]];

	}
	self.tableView.backgroundColor = [UIColor clearColor];

	tableButtomTopImage = [[UIImage imageNamed:@"table_button_top"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	tableButtomTopPressedImage = [[UIImage imageNamed:@"table_button_top_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	tableButtonMidImage = [[UIImage imageNamed:@"table_button_mid"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	tableButtonMidPressedImage = [[UIImage imageNamed:@"table_button_mid_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	tableButtonDownImage = [[UIImage imageNamed:@"table_button_down"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	tableButtonDownPressedImage = [[UIImage imageNamed:@"table_button_down_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	tableButtonSingleImage = [[UIImage imageNamed:@"table_button_single"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	tableButtonSinglePressedImage = [[UIImage imageNamed:@"table_button_single_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger  numberOfRowsInSection = [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section];
	
	if(numberOfRowsInSection == 1)
	{
		cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtonSingleImage];
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:tableButtonSinglePressedImage];
	}
	else if(indexPath.row  > 0 && indexPath.row < (numberOfRowsInSection - 1))
	{
		cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtonMidImage];
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:tableButtonMidPressedImage];
	}
	else if(indexPath.row == 0)
	{
		cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtomTopImage];
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:tableButtomTopPressedImage];
	}
	else if(indexPath.row == numberOfRowsInSection - 1)
	{
		cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtonDownImage];
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:tableButtonDownPressedImage];
	}
}
@end