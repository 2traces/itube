//
//  StationListViewController.m
//  tube
//
//  Created by sergey on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StationListViewController.h"
#import "ManagedObjects.h"
#import "StationListCell.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "UIColor-enhanced.h"

@implementation StationListViewController

@synthesize stationList;
@synthesize stationIndex;
@synthesize dataSource;
@synthesize filteredStation;
@synthesize colorDictionary;
@synthesize mytableView;
@synthesize imageView;

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
    
    [self createStationIndex];
    
    [self.mytableView setBackgroundColor:[UIColor clearColor]];
    self.imageView.image = [UIImage imageNamed:@"tablebackground.png"];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    searchBar.barStyle=UIBarStyleDefault;
    searchBar.showsCancelButton=NO;
    searchBar.autocorrectionType=UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType=UITextAutocapitalizationTypeNone;
    searchBar.tintColor=[UIColor lightGrayColor];
    self.mytableView.tableHeaderView=searchBar;
    
    // create a filtered list that will contain products for the search results table.
	self.filteredStation = [[[NSMutableArray alloc] initWithCapacity:[self.stationList count]] autorelease];
    
    UISearchDisplayController *searchDC = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    // The above assigns self.searchDisplayController, but without retaining.
    // Force the read-only property to be set and retained. 
    [self performSelector:@selector(setSearchDisplayController:) withObject:searchDC];
    
    searchDC.delegate = self;
    searchDC.searchResultsDataSource = self;
    searchDC.searchResultsDelegate = self;
    
    [searchBar release];
    [searchDC release];
    
    self.colorDictionary = [[[NSMutableDictionary alloc] initWithCapacity:[self.stationList count]] autorelease];
    
}

-(void)createStationIndex
{
    //---create the index---
    self.stationIndex = [[[NSMutableArray alloc] init] autorelease];
    
    [self.stationIndex addObject:UITableViewIndexSearch];
    
    for (int i=0; i<[self.stationList count]-1; i++){
        //---get the first char of each state---
        char alphabet = [[[self.stationList objectAtIndex:i] name] characterAtIndex:0];
        NSString *uniChar = [NSString stringWithFormat:@"%C", alphabet];
        
        //---add each letter to the index array---
        if (![stationIndex containsObject:uniChar])
        {            
            [stationIndex addObject:uniChar];
        }        
    }
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
    [self.mytableView setContentOffset:CGPointMake(0.0f, 45.0f) animated:NO];
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return [stationIndex count];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return nil;
    } else {
        return [stationIndex objectAtIndex:section];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if  (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [filteredStation count];
    }
	else
	{	
        NSString *alphabet = [stationIndex objectAtIndex:section];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", alphabet];
        NSArray *stations = [self.stationList filteredArrayUsingPredicate:predicate];
        
        return [stations count]; 
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [NSDate date];
    
    static NSString *CellIdentifier = @"StationCell";
    
    StationListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"StationListCell" owner:self options:nil] lastObject];
        [[cell mybutton] addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        NSString *cellValue = [[self.filteredStation objectAtIndex:indexPath.row] name];
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
    }
    else
    {
        // название и прочее
        NSString *alphabet = [stationIndex objectAtIndex:[indexPath section]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", alphabet];
        NSArray *stations = [self.stationList filteredArrayUsingPredicate:predicate];
        
        if ([stations count]>0) {
            NSString *cellValue = [[stations objectAtIndex:indexPath.row] name];
            cell.mylabel.text = cellValue;
            cell.mylabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0f];
            cell.mylabel.textColor = [UIColor blackColor];
            
            NSUInteger indexForTag = [self.stationList indexOfObject:[stations objectAtIndex:indexPath.row]]; 
            
            // звездочка
            [[cell mybutton] setTag:indexForTag];
            
            if ([[[self.stationList objectAtIndex:indexForTag] isFavorite] intValue]==1) {
                [[cell mybutton] setImage:[UIImage imageNamed:@"starbutton_on.png"] forState:UIControlStateNormal];
            } else {
                [[cell mybutton] setImage:[UIImage imageNamed:@"starbutton_off.png"] forState:UIControlStateNormal];
            }
            
            // RoundView *procentView = [[[RoundView alloc] initWithDefaultSize] autorelease];
            //[procentView setColor:(UIColor*)[[(Station*)[stations objectAtIndex:indexPath.row] lines] color]];
            //[cell.contentView addSubview:procentView];
            //cell.circleView=procentView;
            //cell.circleView = 
            //        [cell.contentView addSubview:[self drawCircleView:(UIColor*)[[(Station*)[stations objectAtIndex:indexPath.row] lines] color]]];
            UIImageView *myImageView = (UIImageView*) [cell viewWithTag:102];
            myImageView.image = [self imageWithColor:[(MStation*)[stations objectAtIndex:indexPath.row] lines]];
        }
    }
    NSDate *date2 = [NSDate date];
    NSLog(@"%f",[date2 timeIntervalSinceDate:date]);

    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return stationIndex;
    }
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index == 0) {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    return index;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if  (tableView == self.searchDisplayController.searchResultsTableView)
	{
        NSLog(@"%@",[[self.filteredStation objectAtIndex:indexPath.row] name]); 
        
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate.mainViewController returnFromSelection:[NSArray arrayWithObject:[self.filteredStation objectAtIndex:indexPath.row]]];
    }
	else
	{	
        NSString *alphabet = [stationIndex objectAtIndex:indexPath.section];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", alphabet];
        NSArray *stations = [self.stationList filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@",[[stations objectAtIndex:indexPath.row] name]); 
        
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate.mainViewController returnFromSelection:[NSArray arrayWithObject:[stations objectAtIndex:indexPath.row]]];

    }
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
        
    if (self.searchDisplayController.active) {

        NSIndexPath *path = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];

        [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        
        NSIndexPath *path = [self.mytableView indexPathForCell:cell];

        [self.mytableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        // Return the header section view
        return sectionView;

    } else {
        
        // Create a stretchable image that emulates the default gradient
        UIImage *buttonImageNormal = [UIImage imageNamed:@"sectionheaderbackround.png"];
        UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        
        // Create the view for the header
        CGRect sectionFrame = CGRectMake(0.0, 0.0, 320.0, 22.0);
        UIView *sectionView = [[[UIView alloc] initWithFrame:sectionFrame] autorelease];
//        sectionView.alpha = 0.;
        
        UIView *bgView = [[[UIView alloc] initWithFrame:sectionFrame] autorelease];
        bgView.backgroundColor = [UIColor colorWithPatternImage:stretchableButtonImageNormal];
        bgView.alpha=0.5;
        [sectionView addSubview:bgView];
        
        // Create the label
        CGRect labelFrame = CGRectMake(10.0, 3.0, 310.0, 22.0);
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:labelFrame];
        sectionLabel.text = [stationIndex objectAtIndex:section];
        sectionLabel.font =[UIFont fontWithName:@"MyriadPro-Regular" size:18.0f];
        sectionLabel.textColor = [UIColor darkGrayColor];
        sectionLabel.shadowColor = [UIColor grayColor];
        sectionLabel.shadowOffset = CGSizeMake(0, 1);
        sectionLabel.backgroundColor = [UIColor clearColor];
        [sectionView addSubview:sectionLabel];
        [sectionLabel release];
        
        // Return the header section view
        return sectionView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    } else {
        return 22.0;
    }
}

-(UIImage*)drawCircleView:(UIColor*)myColor
{

    /*
//    myColor = [UIColor whiteColor];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(26, 26), NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGGradientRef myGradient;
    
    CGColorSpaceRef myColorspace;
    
    size_t num_locations=2;
    
    CGFloat locations[2] = { 0.0 , 1.0 };
    
    const CGFloat* components = CGColorGetComponents(myColor.CGColor);
    const CGFloat* componentsD = CGColorGetComponents([[myColor darkenedColor] CGColor]);
    
    CGFloat componentsG[8] = { components[0], components[1], components[2], 1.0, componentsD[0], componentsD[1], componentsD[2], 1.0 };

    myColorspace = CGColorSpaceCreateDeviceRGB();
    
    myGradient = CGGradientCreateWithColorComponents (myColorspace, componentsG, locations, num_locations);
    
    CGPoint myStartPoint, myEndPoint;
    CGFloat myStartRadius, myEndRadius;
    
    myStartPoint.x = 13;
    myStartPoint.y = 13;
    
    myEndPoint.x = 13;
    myEndPoint.y = 13;
    
    myStartRadius =9;
    myEndRadius = 12;
    
    CGRect circleRect = CGRectMake(1.0, 1.0, 24.0, 24.0);
   
    CGContextSetRGBStrokeColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor)); 
    CGContextSetRGBFillColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));  
	CGContextSetLineWidth(context, 1.0);
	CGContextFillEllipseInRect(context, circleRect);
	CGContextStrokeEllipseInRect(context, circleRect);
    
    CGContextDrawRadialGradient(context, myGradient, myStartPoint, myStartRadius, myEndPoint, myEndRadius, 0);
    
     UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
     
     return image;*/
    
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
		NSRange isFound = [[station name] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
        
		if (isFound.location!=NSNotFound)
		{
			[filteredStation addObject:station];
		}
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterContentForSearchText:searchString scope:nil];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
	[self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:nil];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    [self.mytableView reloadData];
}

-(void)dealloc
{
    self.dataSource=nil;
    self.searchDisplayController.delegate = nil;
    self.searchDisplayController.searchResultsDelegate = nil;
    self.searchDisplayController.searchResultsDataSource = nil;

    [stationList release];
    [stationIndex release];
    [filteredStation release];
    [colorDictionary release];
    [super dealloc];
}

@end


@implementation RoundView

- (id)initWithDefaultSize {
    return [super initWithFrame:CGRectMake(255.0, 6.0, 25.0f, 25.0f)];
}

-(void)setColor:(UIColor*)circleColor
{
    myColor = circleColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect allRect = self.bounds;
    CGRect circleRect = CGRectMake(allRect.origin.x + 2, allRect.origin.y + 2, allRect.size.width - 4,
                                   allRect.size.height - 4);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const CGFloat* components = CGColorGetComponents(myColor.CGColor);
    
    CGContextSetRGBStrokeColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor)); 
    CGContextSetRGBFillColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));  
	CGContextSetLineWidth(context, 2.0);
	CGContextFillEllipseInRect(context, circleRect);
	CGContextStrokeEllipseInRect(context, circleRect);
}

@end
