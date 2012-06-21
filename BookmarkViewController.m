//
//  BookmarkViewController.m
//  tube
//
//  Created by sergey on 09.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BookmarkViewController.h"
#import "ManagedObjects.h"
#import "StationListCell.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"

@implementation BookmarkViewController

@synthesize stationList;
@synthesize dataSource;
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
    
    [self.mytableView setBackgroundColor:[UIColor clearColor]];
    self.imageView.image = [UIImage imageNamed:@"lines_shadow.png"];
    
//    self.stationList = [NSMutableArray arrayWithArray:[dataSource getFavoriteItemList]];
    
    self.colorDictionary = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    
}


-(UIImage*)imageWithColor:(MCategory*)line
{
    if ([self.colorDictionary objectForKey:[line name]]) {
        return [self.colorDictionary objectForKey:[line name]];
    } 
    
    UIImage *image = [self drawCircleView:[line color]];
    [self.colorDictionary setObject:image forKey:[line name]];
    
    return image;
}

-(void)dealloc
{
    [stationList release];
    [colorDictionary release];
    [imageView release];
    [mytableView release];
    [super dealloc];
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
    self.stationList = [NSMutableArray arrayWithArray:[dataSource getFavoriteItemList]];
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stationList count]; 
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
    
    // название и прочее
    MItem *station = [self.stationList objectAtIndex:indexPath.row];
    NSString *cellValue = [station name];
    cell.mylabel.text = cellValue;
    cell.mylabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0f];
    cell.mylabel.textColor = [UIColor blackColor];
    
    NSUInteger indexForTag = [indexPath row]; 
    
    // звездочка
    [[cell mybutton] setTag:indexForTag];
    
    if ([[station isFavorite] intValue]==1) {
        [[cell mybutton] setImage:[UIImage imageNamed:@"starbutton_on.png"] forState:UIControlStateNormal];
    } else {
        [[cell mybutton] setImage:[UIImage imageNamed:@"starbutton_off.png"] forState:UIControlStateNormal];
    }
    
    UIImageView *myImageView = (UIImageView*) [cell viewWithTag:102];
    myImageView.image = [self imageWithColor:[station lines]];
    
    NSDate *date2 = [NSDate date];
    NSLog(@"%f",[date2 timeIntervalSinceDate:date]);
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MItem  *station = [self.stationList objectAtIndex:indexPath.row];
    
    NSLog(@"%@",[station name]); 
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.mainViewController returnFromSelection:[NSArray arrayWithObject:station]];
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
    
    [self.stationList removeObjectAtIndex:rowOfButton];
    [self.mytableView reloadData];
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


