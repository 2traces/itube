//
//  HistoryViewController.m
//  tube
//
//  Created by sergey on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"
#import "ManagedObjects.h"
#import "HistoryListCell.h"

@implementation HistoryViewController

@synthesize historyList;
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
    
    //    self.stationList = [NSMutableArray arrayWithArray:[dataSource getFavoriteStationList]];
    
    self.colorDictionary = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    
    [self.mytableView setBackgroundColor:[UIColor clearColor]];
    self.imageView.image = [UIImage imageNamed:@"tablebackground.png"];
    
    formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
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

-(void)dealloc
{
    [formatter release];
    [historyList release];
    [colorDictionary release];
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
    self.historyList = [NSMutableArray arrayWithArray:[dataSource getHistoryList]];
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
    return [self.historyList count]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [NSDate date];
    
    static NSString *CellIdentifier = @"HistoryCell";
    
    HistoryListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HistoryListCell" owner:self options:nil] lastObject];
    }
 
    MHistory *history = [self.historyList objectAtIndex:indexPath.row];
    
    cell.fromStation.text = [history.fromStation name];
    
    cell.toStation.text = [history.toStation name];
    
    cell.dateLabel.text = [formatter stringFromDate:history.adate]; 
    
    cell.fromLineCircle.image = [self imageWithColor:[history.fromStation lines]];
    cell.toLineCircle.image = [self imageWithColor:[history.toStation lines]];
    
    /*
    // название и прочее
    Station *station = [self.stationList objectAtIndex:indexPath.row];
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
    */
    
    NSDate *date2 = [NSDate date];
    NSLog(@"%f",[date2 timeIntervalSinceDate:date]);
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Station  *station = [self.stationList objectAtIndex:indexPath.row];
    
//    NSLog(@"%@",[station name]); 
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 44.0;
}


-(UIImage*)drawCircleView:(UIColor*)myColor
{
    UIGraphicsBeginImageContext(CGSizeMake(29,29));
    
    CGRect circleRect = CGRectMake(9.0, 9.0, 15.0, 15.0);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const CGFloat* components = CGColorGetComponents(myColor.CGColor);
    
    CGContextSetRGBStrokeColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor)); 
    CGContextSetRGBFillColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));  
	CGContextSetLineWidth(context, 1.0);
	CGContextFillEllipseInRect(context, circleRect);
	CGContextStrokeEllipseInRect(context, circleRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    return image;
}

@end


