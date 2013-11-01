//
//  SpotInfoViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 30/10/13.
//
//

#import "SpotInfoViewController.h"
#import "SpotCommentCell.h"
#import "tubeAppDelegate.h"
#import "NavBarViewController.h"

@interface SpotInfoViewController ()

@end

@implementation SpotInfoViewController

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
    CGFloat yOffset = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        yOffset = 64;
    }
    else {

    }
    
    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];
    
    self.navigationItem.title = self.spotInfo.title;
    

    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.frame = CGRectMake(0, 0, 320, 44);
    [bt setTitle:self.spotInfo.title forState:UIControlStateNormal];
    [bt setTitleColor:[UIColor colorWithRed:124.0/255.0f green:124.0/255.0f blue:124.0/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [bt setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bt.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    bt.titleLabel.shadowColor = [UIColor whiteColor];
    bt.titleLabel.shadowOffset = CGSizeMake(-0.5, 0.5);
    
    [bt addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = bt;
    
    if (self.navBarVC.bar) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack)] autorelease];
        [self.navBarVC.bar setItems:@[self.navigationItem] animated:YES];
    }
    else {
        UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, 320, 34)];
        shadow.image = [[UIImage imageNamed:@"navbar_shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
        [self.view addSubview:shadow];
    }
    
//    UITapGestureRecognizer *rec2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    [self.navigationItem.titleView addGestureRecognizer:rec2];
}

- (void)goBack {
    [self.navBarVC popVC];
}

-(void)handleTap:(id)sender
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    GlViewController *gl = appDelegate.glViewController;
    Pin *pin = [gl getPin:self.spotInfo.pinID];
    [gl scrollToGeoPosition:pin.geoPosition withZoom:-1];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.spotInfo.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SpotCommentCell";
    
    SpotCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SpotCommentCell" owner:self options:nil] lastObject];
    }
    
    cell.subtitleLabel.text = [self.spotInfo.comments objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 81;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.shareView;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

@end
