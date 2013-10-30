//
//  SpotsListViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 25/10/13.
//
//

#import "SpotsListViewController.h"
#import "SpotItemCell.h"
#import "GlViewController.h"
#import "tubeAppDelegate.h"

@interface SpotsListViewController ()

@end

@implementation SpotsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadItems:(NSArray *)items {
    self.items = items;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    GlViewController *gl = appDelegate.glViewController;

    self.items = [gl getObjectsNearUserWithRadius:2000000];
    [self.tableView reloadData];
    
    CGFloat yOffset = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self.navigationController.navigationBar setBackgroundColor:[UIColor darkGrayColor]];
        yOffset = 64;
    }
    else {
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)] forBarMetrics:UIBarMetricsDefault];
    }
    
    UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, 320, 34)];
    shadow.image = [[UIImage imageNamed:@"navbar_shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    [self.view addSubview:shadow];
    
    self.navigationItem.title = @"Wifi рядом";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor colorWithRed:124.0/255.0f green:124.0/255.0f blue:124.0/255.0f alpha:1.0f], UITextAttributeTextColor,
                                                                     [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                                     [NSValue valueWithUIOffset:UIOffsetMake(-0.5, 0.5)], UITextAttributeTextShadowOffset, nil]];
    
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(231, yOffset, 59, 39)];
    [bt addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [bt setBackgroundImage:[UIImage imageNamed:@"list_bt"] forState:UIControlStateNormal];
    [self.view addSubview:bt];
}

- (void)hide {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SpotItemCell";
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    SpotItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SpotItemCell" owner:self options:nil] lastObject];
    }
    
    Object *item = [self.items objectAtIndex:indexPath.row];
    GlViewController *gl = appDelegate.glViewController;
    Pin *pin = [gl getPin:item.pinID];
    CGFloat distance = pin.distanceToUser;
    
    NSLog(@"Type: %@", item.kind);
    
    cell.titleLabel.text = item.title;
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%.0f м", distance];
    
    return cell;
}



@end
