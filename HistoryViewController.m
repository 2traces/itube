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
#import "MainViewController.h"
#import "tubeAppDelegate.h"

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
    
    self.colorDictionary = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    
    [self.mytableView setBackgroundColor:[UIColor clearColor]];
    self.imageView.image = [UIImage imageNamed:@"lines_shadow.png"];

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
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    MHistory *history = [self.historyList objectAtIndex:indexPath.row];

    [appDelegate.mainViewController returnFromSelection:[NSArray arrayWithObjects:history.fromStation,history.toStation,nil]];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 60.0;
}


-(UIImage*)drawCircleView:(UIColor*)myColor
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(20,20),NO,0.0);
    
    CGRect circleRect = CGRectMake(5.0, 6.0, 10.0, 10.0);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const CGFloat* components = CGColorGetComponents(myColor.CGColor);
    
    CGContextSetRGBStrokeColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor)); 
    CGContextSetRGBFillColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));  
	CGContextSetLineWidth(context, 0.0);
	CGContextFillEllipseInRect(context, circleRect);
	CGContextStrokeEllipseInRect(context, circleRect);
    
    
    UIImage *bevelImg = [UIImage imageNamed:@"bevel.png"];
    [bevelImg drawInRect:circleRect]; 
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    return image;
}

@end
