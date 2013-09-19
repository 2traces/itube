//
// Created by bsideup on 4/9/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FRLayeredNavigationController/UIViewController+FRLayeredNavigationController.h"
#import "HomeworksTableViewController.h"


@implementation HomeworksTableViewController
{

	UIImage *tableButtonDownImageNoSeparator;
	UIImage *tableButtonMidImageNoSeparator;
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

//	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:121.0 / 255.0 green:166.0 / 255.0 blue:191.0 / 255.0 alpha:1.0]];
//	[self.navigationController.navigationBar setTitleTextAttributes:
//			@{
//					UITextAttributeTextShadowColor : [UIColor blackColor],
//					UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)]
//			}];

//	UIImage *navigationBarBackgroundImage = [[UIImage imageNamed:@"bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 5.0, 1.0, 5.0)];
//	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage
//												  forBarMetrics:UIBarMetricsDefault];
//	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage
//												  forBarMetrics:UIBarMetricsLandscapePhone];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.tableView.backgroundView  = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableBackgroundIpad"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile]];
            tableButtomTopPressedImage = [[UIImage imageNamed:@"table_button_mid_pressed_ios7_ipad"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            tableButtonMidPressedImage = [[UIImage imageNamed:@"table_button_mid_pressed_ios7_ipad"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            tableButtonDownPressedImage = [[UIImage imageNamed:@"table_button_mid_pressed_ios7_ipad"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        }
        else
        {
            self.tableView.backgroundView  = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableBackground"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile]];
            tableButtomTopPressedImage = [[UIImage imageNamed:@"table_button_mid_pressed_ios7"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            tableButtonMidPressedImage = [[UIImage imageNamed:@"table_button_mid_pressed_ios7"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            tableButtonDownPressedImage = [[UIImage imageNamed:@"table_button_mid_pressed_ios7"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            
        }
//
//        tableButtonDownImageNoSeparator = [[UIImage imageNamed:@"table_button_mid"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
//        tableButtonMidImageNoSeparator = [[UIImage imageNamed:@"table_button_mid"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
//        
//        tableButtomTopImage = [[UIImage imageNamed:@"table_button_mid"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
//        tableButtonMidImage = [[UIImage imageNamed:@"table_button_mid"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
//        tableButtonDownImage = [[UIImage imageNamed:@"table_button_mid"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
//        tableButtonSingleImage = [[UIImage imageNamed:@"table_button_mid"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        tableButtonSinglePressedImage = [[UIImage imageNamed:@"table_button_single_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    }
    else {
    	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.tableView.backgroundView  = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableBackgroundIpad"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile]];
            tableButtomTopPressedImage = [[UIImage imageNamed:@"table_button_top_pressed_ipad"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            tableButtonMidPressedImage = [[UIImage imageNamed:@"table_button_mid_pressed_ipad"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            tableButtonDownPressedImage = [[UIImage imageNamed:@"table_button_down_pressed_ipad"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        }
        else
        {
            self.tableView.backgroundView  = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableBackground"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile]];
            tableButtomTopPressedImage = [[UIImage imageNamed:@"table_button_top_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            tableButtonMidPressedImage = [[UIImage imageNamed:@"table_button_mid_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            tableButtonDownPressedImage = [[UIImage imageNamed:@"table_button_down_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            
        }
        self.tableView.backgroundColor = [UIColor clearColor];
        
        tableButtonDownImageNoSeparator = [[UIImage imageNamed:@"table_button_down_s"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        tableButtonMidImageNoSeparator = [[UIImage imageNamed:@"table_button_mid_s"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        
        tableButtomTopImage = [[UIImage imageNamed:@"table_button_top"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        tableButtonMidImage = [[UIImage imageNamed:@"table_button_mid"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        tableButtonDownImage = [[UIImage imageNamed:@"table_button_down"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        tableButtonSingleImage = [[UIImage imageNamed:@"table_button_single"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        tableButtonSinglePressedImage = [[UIImage imageNamed:@"table_button_single_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    }
    
}


- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    NSArray *paths = [tableView indexPathsForVisibleRows];
    for (NSIndexPath *path in paths) {
        if ([path isEqual:indexPath]) {
            [self highlightTableCellWithArgs:[NSDictionary dictionaryWithObjectsAndKeys:path, @"indexPath", [NSNumber numberWithBool:YES], @"shouldHighlight", nil]];
        }
        else {
            [self highlightTableCellWithArgs:[NSDictionary dictionaryWithObjectsAndKeys:path, @"indexPath", [NSNumber numberWithBool:NO], @"shouldHighlight", nil]];
        }
    }
//    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
//	NSInteger  numberOfRowsInSection = [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
//    if (cell) {
//        if(numberOfRowsInSection == 1)
//        {
//
//        }
//        else if(indexPath.row  >= 0 && indexPath.row < (numberOfRowsInSection - 1))
//        {
//            cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtonMidImageNoSeparator];
//        }
//        else if(indexPath.row == numberOfRowsInSection - 1)
//        {
//
//            cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtonDownImageNoSeparator];
//        }
//
//    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    
    }
    else {
        [self performSelector:@selector(highlightTableCellWithArgs:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:indexPath, @"indexPath", [NSNumber numberWithBool:NO], @"shouldHighlight", nil] afterDelay:1.0f];

    }
}

- (void)highlightTableCellWithArgs:(NSDictionary*)args {
    NSIndexPath *indexPath = [args objectForKey:@"indexPath"];
    BOOL shouldHighlight = [[args objectForKey:@"shouldHighlight"] boolValue];
    //UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    UITableViewCell *lowerCell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
    NSInteger  numberOfRowsInSection = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:indexPath.section];
    if (lowerCell) {
        if(numberOfRowsInSection == 1)
        {
            
        }
        else if(nextIndexPath.row  >= 0 && nextIndexPath.row < (numberOfRowsInSection - 1))
        {
            lowerCell.backgroundView = [[UIImageView alloc] initWithImage: shouldHighlight ? tableButtonMidImageNoSeparator : tableButtonMidImage];
        }
        else if(nextIndexPath.row == numberOfRowsInSection - 1)
        {
            lowerCell.backgroundView = [[UIImageView alloc] initWithImage: shouldHighlight ? tableButtonDownImageNoSeparator : tableButtonDownImage];
        }
        
    }


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger  numberOfRowsInSection = [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section];
	NSInteger selectedRow = INT_MAX;
    NSInteger selectedSection = INT_MAX;
    
    if (tableView.indexPathForSelectedRow) {
        selectedRow = tableView.indexPathForSelectedRow.row;
        selectedSection = tableView.indexPathForSelectedRow.section;
    }
    
	if(numberOfRowsInSection == 1)
	{
		cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtonSingleImage];
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:tableButtonSinglePressedImage];
	}
	else if(indexPath.row  > 0 && indexPath.row < (numberOfRowsInSection - 1))
	{
        if (indexPath.row - 1 == selectedRow && indexPath.section == selectedSection) {
            cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtonMidImageNoSeparator];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:tableButtonMidPressedImage];
        }
        else {
            cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtonMidImage];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:tableButtonMidPressedImage];
        }

	}
	else if(indexPath.row == 0)
	{
		cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtomTopImage];
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:tableButtomTopPressedImage];
	}
	else if(indexPath.row == numberOfRowsInSection - 1)
	{
        if (indexPath.row - 1 == selectedRow && indexPath.section == selectedSection) {
            cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtonDownImageNoSeparator];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:tableButtonDownPressedImage];
        }
        else {
            cell.backgroundView = [[UIImageView alloc] initWithImage:tableButtonDownImage];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:tableButtonDownPressedImage];
        }
	}
}

@end