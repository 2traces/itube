//
//  ReaderItemViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 16/11/12.
//
//

#import "ReaderItemViewController.h"

@interface ReaderItemViewController ()

@end

@implementation ReaderItemViewController

@synthesize scrollView;
@synthesize textView;

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
    self.textView.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0f];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
