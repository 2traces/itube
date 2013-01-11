//
//  LineListViewController.m
//  tube
//
//  Created by Sergey Mingalev on 06.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LineListViewController.h"
#import "ManagedObjects.h"
#import "StationListCell.h"
#import "SectionInfo.h"
#import "SectionHeaderView.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "UIColor-enhanced.h"
#import "SSTheme.h"

#define DEFAULT_ROW_HEIGHT 38
#define HEADER_HEIGHT 40

@implementation LineListViewController

@synthesize lineList;
@synthesize dataSource;
@synthesize colorDictionary;
@synthesize stationsList;
@synthesize mytableView;
@synthesize imageView;

@synthesize sectionInfoArray=sectionInfoArray_, uniformRowHeight=rowHeight_, openSectionIndex=openSectionIndex_;

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
    
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        self.view.backgroundColor=[UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
        self.mytableView.layer.cornerRadius=5.0f;
    }
    
    MHelper *helper = [MHelper sharedHelper];
    self.dataSource = helper;
    
    self.lineList = [dataSource getLineList];
    
    self.colorDictionary = [[[NSMutableDictionary alloc] initWithCapacity:[self.lineList count]] autorelease];
    
//    [self.mytableView setBackgroundColor:[UIColor clearColor]];
//    self.imageView.image = [UIImage imageNamed:@"lines_shadow.png"];

    [SSThemeManager customizeSettingsTableView:self.mytableView imageView:self.imageView searchBar:(UISearchBar*)nil];

    // Set up default values.
    self.mytableView.sectionHeaderHeight = HEADER_HEIGHT;
	/*
     The section info array is thrown away in viewWillUnload, so it's OK to set the default values here. If you keep the section information etc. then set the default values in the designated initializer.
     */
    rowHeight_ = DEFAULT_ROW_HEIGHT;
    openSectionIndex_ = NSNotFound;
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

-(void) dealloc
{
    [lineList release];
    [stationsList release];
    [colorDictionary release];
    [sectionInfoArray_ release];
    [mytableView release];
    [imageView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ((self.sectionInfoArray == nil) || ([self.sectionInfoArray count] != [self numberOfSectionsInTableView:self.mytableView])) {
		
        // For each play, set up a corresponding SectionInfo object to contain the default height for each row.
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
		
		for (MLine* line in self.lineList) {
			
			SectionInfo *sectionInfo = [[SectionInfo alloc] init];			
			sectionInfo.line = line;
			sectionInfo.open = NO;
			
            NSNumber *defaultRowHeight = [NSNumber numberWithInteger:DEFAULT_ROW_HEIGHT];
			NSInteger countOfQuotations = [[line stations] count];
            
			for (NSInteger i = 0; i < countOfQuotations; i++) {
				[sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
			}
			
			[infoArray addObject:sectionInfo];
            [sectionInfo release];
		}
		
		self.sectionInfoArray = infoArray;
        [infoArray release];
	}
    
    [self.mytableView reloadData];

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
    return [self.lineList  count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
	NSInteger numStoriesInSection = [[sectionInfo.line stations] count];
	
    return sectionInfo.open ? numStoriesInSection : 0;
    
//    return [[(Line*)[self.lineList objectAtIndex:section] stations] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSDate *date = [NSDate date];
    static NSString *CellIdentifier = @"StationCell";
    
    StationListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"StationListCell" owner:self options:nil] lastObject];
        [[cell mybutton] addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
 
    if ([[[self.stationsList objectAtIndex:indexPath.row] isFavorite] intValue]==1) {
        [[cell mybutton] setImage:[UIImage imageNamed:@"starbutton_on.png"] forState:UIControlStateNormal];
    } else {
        [[cell mybutton] setImage:[UIImage imageNamed:@"starbutton_off.png"] forState:UIControlStateNormal];
    }
    
    NSString *cellValue;
    if ([[MHelper sharedHelper] languageIndex]%2) {
        cellValue = [[self.stationsList objectAtIndex:indexPath.row] altname];
    } else {
        cellValue = [[self.stationsList objectAtIndex:indexPath.row] name];
    }
    cell.mylabel.text = cellValue;
    cell.mylabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0f];
    cell.mylabel.textColor = [[SSThemeManager sharedTheme] mainColor];
    
    UIImageView *myImageView = (UIImageView*) [cell viewWithTag:102];
    
    myImageView.image = [self imageWithColor:[(MStation*)[self.stationsList objectAtIndex:indexPath.row] lines]];
    
//    NSDate *date2 = [NSDate date];
//    NSLog(@"%f",[date2 timeIntervalSinceDate:date]);
    
    return cell;
}

-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
	
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionOpened];
	
	sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo.line.stations count];
    self.stationsList = [dataSource getStationsForLine:sectionInfo.line];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
        
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
		
		SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection.line.stations count];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    
    // Style the animation so that there's a smooth flow in either direction.
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }

    // Apply the updates.
    [self.mytableView beginUpdates];
    [self.mytableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [self.mytableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [self.mytableView endUpdates];
    self.openSectionIndex = sectionOpened;
        
    if ([indexPathsToInsert count]>0){
         [self performSelector:@selector(scrollToDesiredArea:) withObject:[indexPathsToInsert objectAtIndex:0] afterDelay:0.5f];
    }
    
    [indexPathsToDelete release];
    [indexPathsToInsert release];

}

-(void)scrollToDesiredArea:(NSIndexPath *)indexPath {
        [self.mytableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionClosed];
	
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.mytableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.mytableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
        [indexPathsToDelete release];
    }
    self.openSectionIndex = NSNotFound;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLine *line = [self.lineList objectAtIndex:[indexPath section]];
    
    NSArray *stations = [dataSource getStationsForLine:line];
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.mainViewController returnFromSelection:[NSArray arrayWithObject:[stations objectAtIndex:indexPath.row]]];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
    return [[sectionInfo objectInRowHeightsAtIndex:indexPath.row] floatValue];
//    return 38.0;
}

- (void)buttonPressed:(id)sender
{
    
    UITableViewCell *cell = (UITableViewCell*)[[sender superview] superview];
    
    NSIndexPath *path = [self.mytableView indexPathForCell:cell];
    
    MLine *line = [self.lineList objectAtIndex:[path section]];
    
    NSArray *stations = [dataSource getStationsForLine:line];
    
    MStation *station = [stations objectAtIndex:path.row];
    
    //    NSLog(@"%@",cellValue);
    
    
    if ([[station isFavorite] intValue]==1) {
        [station setIsFavorite:[NSNumber numberWithInt:0]];
    } else {
        [station setIsFavorite:[NSNumber numberWithInt:1]];
    }
    
    [self.mytableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    /*
     Create the section header views lazily.
     */
    
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if (!sectionInfo.headerView) {
		NSString *lineName = sectionInfo.line.name;
        sectionInfo.headerView = [[[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mytableView.bounds.size.width, HEADER_HEIGHT    ) title:lineName color:[(UIColor*)sectionInfo.line.color saturatedColor] section:section delegate:self] autorelease];
    }

    return sectionInfo.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{    
    return HEADER_HEIGHT; 
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


@end
