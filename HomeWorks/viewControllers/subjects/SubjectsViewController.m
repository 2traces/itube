//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "RaptureXML/RXMLElement.h"
#import "SubjectsViewController.h"
#import "BooksViewController.h"
#import "SubjectTableVIewCell.h"


@implementation SubjectsViewController
{

}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = [NSString stringWithFormat:@"%d класс", [_term attributeAsInt:@"num"]];

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
	[self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"infoViewController"] animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [_term children:@"subject"].count;
            break;
        case 1:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}


//Returning same text to be sure header will have correct height.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            break;
        case 1: {
            return @"Школьные учебники \n(ссылка на отдельный сайт)";
            break;
        }
        default:
            break;
    }
    return nil;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            break;
        case 1: {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:20];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 2;
            label.text = @"Школьные учебники \n(ссылка на отдельный сайт)";
            return label;
            break;
        }
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubjectTableVIewCell *cell = nil;
	static NSString *cellIdentifier = @"subjectCell";
    
    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            RXMLElement *subject = [[_term children:@"subject"] objectAtIndex:indexPath.row];
            cell.nameLabel.text = [subject attribute:@"name"];
            [cell.iconImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%d", [[subject attribute:@"icon"] intValue]]]];
            break;
        }
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.nameLabel.text = [NSString stringWithFormat:@"по %i-му классу", [_term attributeAsInt:@"num"]];
            cell.nameLabel.textColor = [UIColor colorWithRed:48/255.0f green:102/255.0f blue:112/255.0f alpha:1.0f];
            [cell.iconImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_6"]]];
            break;
        }
        default:
            NSLog(@"Section %d, row %d", indexPath.section, indexPath.row);
            break;
    }
    
	return cell;
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	if ([identifier isEqualToString:@"showSubject"] && self.tableView.indexPathForSelectedRow.section == 1)
	{
        NSString *urlString = [NSString stringWithFormat:@"http://spishi.ws/view/page/%d/", [_term attributeAsInt:@"num"]];
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        return NO;
	}
    return YES;
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