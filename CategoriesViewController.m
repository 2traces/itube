//
//  CategoriesViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
//
//

#import "CategoriesViewController.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

@synthesize tableView;
@synthesize scrollView;
@synthesize buttonSettings;

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

@end
