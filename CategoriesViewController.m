//
//  CategoriesViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
//
//

#import "CategoriesViewController.h"
#import "CategoryCell.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

@synthesize tableView;
@synthesize scrollView;
@synthesize buttonSettings;
@synthesize navigationDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    itemsNames = [[NSArray arrayWithObjects:@"What to see",
                                           @"Off the beaten track",
                                           @"Wifi spots",
                                           @"Recommended cafes", nil] retain];
    
    itemsImages = [[NSArray arrayWithObjects:[UIImage imageNamed:@"what_to_see_normal"],
                                            [UIImage imageNamed:@"off_beaten_track_normal"],
                                            [UIImage imageNamed:@"wifi_spots_normal"],
                                            [UIImage imageNamed:@"recommended_cafes_normal"], nil] retain];
    
    itemsImagesHighlighted = [[NSArray arrayWithObjects:[UIImage imageNamed:@"what_to_see_pressed"],
                                            [UIImage imageNamed:@"off_beaten_track_pressed"],
                                            [UIImage imageNamed:@"wifi_spots_pressed"],
                                            [UIImage imageNamed:@"recommended_cafes_pressed"], nil] retain];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.buttonSettings = nil;
    self.scrollView = nil;
    self.tableView = nil;
    [super viewDidUnload];
}

- (void) dealloc {
    self.buttonSettings = nil;
    self.scrollView = nil;
    self.tableView = nil;
    [super dealloc];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [itemsNames count];
}


- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCell *cell = [[CategoryCell alloc] initwithTitle:itemsNames[indexPath.row] image:itemsImages[indexPath.row] highlightedImage:itemsImagesHighlighted[indexPath.row]];
    return [cell autorelease];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


@end
