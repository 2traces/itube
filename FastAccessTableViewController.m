//
//  FastAccessTableViewController.m
//  tube
//
//  Created by sergey on 21.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FastAccessTableViewController.h"
#import "ManagedObjects.h"
#import "StationListCell.h"
#import "tubeAppDelegate.h"

@implementation FastAccessTableViewController

@synthesize stationList;
@synthesize stationIndex;
@synthesize dataSource;
@synthesize filteredStation;
@synthesize colorDictionary;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MHelper *helper = [MHelper sharedHelper];
    self.dataSource = helper;
    
    self.stationList = [dataSource getStationList];
    
    // create a filtered list that will contain products for the search results table.
	self.filteredStation = [[[NSMutableArray alloc] initWithCapacity:[self.stationList count]] autorelease];
    self.colorDictionary = [[[NSMutableDictionary alloc] initWithCapacity:[self.stationList count]] autorelease];
}

-(void)textDidChange:(NSNotification *)note
{
    UITextField *tf = [note object];
    [self filterContentForSearchText:tf.text scope:nil];
    
    if (self.tableView.hidden) {
        self.tableView.hidden=NO;
    }
    
    [self.tableView reloadData];
}

-(UIImage*)imageWithColor:(MLine*)line
{
    if ([self.colorDictionary objectForKey:[line name]]) {
        return [self.colorDictionary objectForKey:[line name]];
    } 
    
    UIImage *image = [self drawCircleView:[line color]];
    [self.colorDictionary setObject:image forKey:[line name]];
    
    return image;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredStation count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StationCell";
    BOOL lang = [[MHelper sharedHelper] languageIndex]%2;
    
    StationListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"StationListCell" owner:self options:nil] lastObject];
        [[cell mybutton] addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    MStation *station = [self.filteredStation objectAtIndex:indexPath.row];
    
    NSString *cellValue;
    if (lang) {
        cellValue = station.altname;
    } else {
        cellValue = station.name;
    }

    BOOL duplicate = NO;
    NSString *stN = lang ? DisplayStationName(station.altname) : DisplayStationName(station.name);
    for (MStation *st in self.filteredStation) {
        if(st != station) {
            if(lang) {
                if([DisplayStationName(st.altname) isEqualToString:stN]) {
                    duplicate = YES;
                    break;
                }
            } else {
                if([DisplayStationName(st.name) isEqualToString:stN]) {
                    duplicate = YES;
                    break;
                }
            }
        }
    }
    cellValue = DisplayStationName(cellValue);
    if(duplicate) {
        cellValue = [NSString stringWithFormat:@"%@ (%@)", cellValue, station.lines.name];
    }
    cell.mylabel.text = cellValue;
    cell.mylabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0f];
    cell.mylabel.textColor = [UIColor blackColor];
    
    NSUInteger indexForTag = [self.stationList indexOfObject:[self.filteredStation objectAtIndex:indexPath.row]];  
    
    // звездочка
    [[cell mybutton] setTag:indexForTag];
    
    
    if ([[[self.stationList objectAtIndex:indexForTag] isFavorite] intValue]==1) {
        [[cell mybutton] setImage:[UIImage imageNamed:@"starbutton_on.png"] forState:UIControlStateNormal];
    } else {
        [[cell mybutton] setImage:[UIImage imageNamed:@"starbutton_off.png"] forState:UIControlStateNormal];
    }
    
    UIImageView *myImageView = (UIImageView*) [cell viewWithTag:102];
    myImageView.image = [self imageWithColor:[(MStation*)[self.filteredStation objectAtIndex:indexPath.row] lines]];    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 38.0;
}

- (void)buttonPressed:(id)sender
{
    int rowOfButton = [sender tag];
    
    if ([[[self.stationList objectAtIndex:rowOfButton] isFavorite] intValue]==1) {
        [[self.stationList objectAtIndex:rowOfButton] setIsFavorite:[NSNumber numberWithInt:0]];
    } else {
        [[self.stationList objectAtIndex:rowOfButton] setIsFavorite:[NSNumber numberWithInt:1]];
    }
    
    UITableViewCell *cell = (UITableViewCell*)[[sender superview] superview];
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

-(UIImage*)drawCircleView:(UIColor*)myColor
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(27, 27), NO, 0.0);
    
    UIImage *radialImg = [UIImage imageNamed:@"radial.png"];
    
    CGRect circleRect = CGRectMake(1.0, 1.0, 25.0, 25.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const CGFloat* components = CGColorGetComponents(myColor.CGColor);
    
    CGContextSetRGBStrokeColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));
    CGContextSetRGBFillColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));
    CGContextSetLineWidth(context, 0.0);
    CGContextFillEllipseInRect(context, circleRect);
    CGContextStrokeEllipseInRect(context, circleRect);
    
    [radialImg drawInRect:circleRect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRelease(context);
    
    return image;
}

#pragma mark -
#pragma mark UISearchBarDelegate

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[filteredStation removeAllObjects]; 
	
	for (MStation* station in self.stationList)
	{
		NSRange isFound = [DisplayStationName(station.name) rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
        
		if (isFound.location!=NSNotFound)
		{
			[filteredStation addObject:station];
		}
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}
     
-(void)dealloc
{
    self.dataSource=nil;
    
    [stationList release];
    [stationIndex release];
    [filteredStation release];
    [colorDictionary release];
    [super dealloc];
}

@end