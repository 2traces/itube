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
#import "SpotInfoViewController.h"
#import "NavBarViewController.h"

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

- (void)updateData {
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    GlViewController *gl = appDelegate.glViewController;
    self.items = [gl getObjectsNearUserWithRadius:2000];
//    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:5];
//    for (int i = 0; i < 100; i++) {
//        Object *obj = [Object new];
//        obj.comments = @[@"comment 1 comment 1 comment 1 comment 1 comment 1 comment 1 comment 1 comment 1 comment 1 comment 1 comment 1 comment 1 comment 1 comment 1 ", @"comment 2", @"comment 3", @"comment asdfasdf asdfas dfasdf asdf sfafd asfd asdfasdf asdf asdfasdf asdfasdasd asdf as asdf asdf asdfadsf asdf asdfsadfa sdfa", @"dsfa", @"safas asdfas r asdf sad fd asd dsfas asdf sd a df ads dsafadsf dsf sdfs sdf sdf sf", @"d df asdfadf sdfasd sd sdf dfas sd sdf asdf asdf df asdf adsf asdf asdf sdfasdf asdfasdf asdfddf d"];
//        obj.title = [NSString stringWithFormat:@"Object #%i", i+1];
//        obj.ID = @"";
//        [temp addObject:obj];
//    }
//    self.items = [NSArray arrayWithArray:temp];
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self updateData];
    
    CGFloat yOffset = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (IS_IPAD) {
            if (self.navBarVC.bar) {
                [self.navBarVC.bar setBackgroundImage:[[UIImage imageNamed:@"navbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)] forBarMetrics:UIBarMetricsDefault];
            }
            else {
                [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)] forBarMetrics:UIBarMetricsDefault];
            }
        }
        else {
            if (self.navBarVC.bar) {
                [self.navBarVC.bar setBackgroundImage:[[UIImage imageNamed:@"navbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)] forBarMetrics:UIBarMetricsDefault];
            }
            else {
                [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar_bg_ios7"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)] forBarMetrics:UIBarMetricsDefault];
            }
        }

        yOffset = 64;
    }
    else {
        if (self.navBarVC.bar) {
            [self.navBarVC.bar setBackgroundImage:[[UIImage imageNamed:@"navbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)] forBarMetrics:UIBarMetricsDefault];
        }
        else {
            [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)] forBarMetrics:UIBarMetricsDefault];
        }
    }

    
    if (self.navBarVC.bar) {
        [self.navBarVC.bar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIColor colorWithRed:124.0/255.0f green:124.0/255.0f blue:124.0/255.0f alpha:1.0f], UITextAttributeTextColor,
                                                 [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                 [NSValue valueWithUIOffset:UIOffsetMake(-0.5, 0.5)], UITextAttributeTextShadowOffset, nil]];
    }
    else {
        self.navigationItem.title = NSLocalizedString(@"Wifi Nearby", @"");
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                         [UIColor colorWithRed:124.0/255.0f green:124.0/255.0f blue:124.0/255.0f alpha:1.0f], UITextAttributeTextColor,
                                                                         [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                                         [NSValue valueWithUIOffset:UIOffsetMake(-0.5, 0.5)], UITextAttributeTextShadowOffset, nil]];
    }
    
    self.navigationItem.title = NSLocalizedString(@"Wifi Nearby", @"");
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor colorWithRed:124.0/255.0f green:124.0/255.0f blue:124.0/255.0f alpha:1.0f], UITextAttributeTextColor,
                                                                     [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                                     [NSValue valueWithUIOffset:UIOffsetMake(-0.5, 0.5)], UITextAttributeTextShadowOffset, nil]];
    if(IS_IPAD){
    
    }
    else {
        UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset - 1, 320, 34)];
        shadow.image = [[UIImage imageNamed:@"navbar_shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
        [self.view addSubview:shadow];
        UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(231, yOffset, 59, 39)];
        [bt addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [bt setBackgroundImage:[UIImage imageNamed:@"list_bt"] forState:UIControlStateNormal];
        [self.view addSubview:bt];
    }

    if (self.navBarVC.bar) {
        self.navBarVC.bar.items = @[self.navigationItem];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name: @"distanceUpdated" object:nil];

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
    CGFloat distance = [gl calcGeoDistanceFrom:item.geoP to:appDelegate.userGeoPosition];
    
    NSLog(@"Type: %@", item.kind);
    
    cell.titleLabel.text = item.title;
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%.3f км", distance];
    cell.accessoryImage.image = [UIImage imageNamed:@"arrow"];
    cell.typeImage.image = [UIImage imageNamed:@"type_0"];
    
#ifdef SPOTS_FREE
    if (distance > 150) {
        cell.accessoryImage.image = [UIImage imageNamed:@"lock"];
    }
    else {
        cell.accessoryImage.image = [UIImage imageNamed:@"arrow"];
    }
#endif
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Object *item = [self.items objectAtIndex:indexPath.row];

    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    GlViewController *gl = appDelegate.glViewController;
#ifdef SPOTS_FREE
    Pin *pin = [gl getPin:item.pinID];
    CGFloat distance = pin.distanceToUser;
    if (distance > 150) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Free version heading", @"") message:NSLocalizedString(@"Free version message 1", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Free version appstore button", @""), nil];
        [alertView show];
        [alertView release];
        return;
    }
#endif
    
    SpotInfoViewController *svc = [[SpotInfoViewController alloc] initWithNibName:@"SpotInfoViewController" bundle:[NSBundle mainBundle]];

    svc.spotInfo = item;
    if (self.navBarVC) {
        [self.navBarVC pushVC:svc];
    }
    else {
        [self.navigationController pushViewController:svc animated:YES];
    }
    [svc autorelease];
    
    if(item.pinID >= 0) {
        [gl setPin:item.pinID active:YES];
    }

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL_FULL]];
            break;
        default:
            break;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}



@end
