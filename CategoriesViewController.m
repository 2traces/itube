//
//  CategoriesViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
//
//

#import "CategoriesViewController.h"
#import "CategoryCell.h"
#import "ManagedObjects.h"
#import "tubeAppDelegate.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

@synthesize tableView;
@synthesize scrollView;
@synthesize buttonSettings;
@synthesize navigationDelegate;
@synthesize categories;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initializeCategories {
    self.categories = [[MHelper sharedHelper] getCategoriesList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeCategories];
    // Do any additional setup after loading the view from its nib.

    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    MCategory *category = self.categories[1];
    [self.navigationDelegate selectCategoryWithIndex:[category.index integerValue]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MCategory *category = self.categories[indexPath.row];
    [self.navigationDelegate selectCategoryWithIndex:[category.index integerValue]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categories count];
}


- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCategory *category = self.categories[indexPath.row];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString *imagePath = [NSString stringWithFormat:@"%@/categories/%@", appDelegate.mapDirectoryPath, category.image_normal];
    UIImage *imageNormal = [UIImage imageWithContentsOfFile:imagePath];
    
    imagePath = [NSString stringWithFormat:@"%@/categories/%@", appDelegate.mapDirectoryPath, category.image_highlighted];
    UIImage *imageHighlighted = [UIImage imageWithContentsOfFile:imagePath];
    CategoryCell *cell = [[CategoryCell alloc] initwithTitle:category.name image:imageNormal highlightedImage:imageHighlighted];
    return [cell autorelease];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


@end
