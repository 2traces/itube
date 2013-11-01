//
//  NavBarViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 1/11/13.
//
//

#import "NavBarViewController.h"
#import "SpotsListViewController.h"
#import "SpotInfoViewController.h"

@interface NavBarViewController ()

@end

@implementation NavBarViewController

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
    self.list = [[[SpotsListViewController alloc] initWithNibName:@"SpotsListViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.list.navBarVC = self;
    [self.container addSubview:self.list.view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushVC:(SpotInfoViewController*)vc {
    
}

- (void)popVC {

}

@end
