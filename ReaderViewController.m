//
//  ReaderViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 16/11/12.
//
//

#import "ReaderViewController.h"
#import "ReaderItemViewController.h"

@interface ReaderViewController ()

@end

@implementation ReaderViewController

@synthesize btBack;
@synthesize btStar;
@synthesize lbHeader;
@synthesize scrollView;
@synthesize pageControl;
@synthesize items;
@synthesize itemViews;

- (IBAction)back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)star:(id)sender {

}

- (id) initWithReaderItems:(NSArray*)_items {
    self = [super initWithNibName:@"ReaderViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        self.items = _items;
    }
    return self;
}


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
    self.itemViews = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    CGFloat offset = 0;
    for (NSDictionary *item in self.items) {
        ReaderItemViewController *itemVC = [[ReaderItemViewController alloc] initWithNibName:@"ReaderItemViewController" bundle:[NSBundle mainBundle]];
        CGRect frame = itemVC.view.frame;
        frame.origin = CGPointMake(offset, 0);
        offset += 320;
        itemVC.view.frame = frame;
        [self.scrollView addSubview:itemVC.view];
        
        itemVC.textView.text = [item objectForKey:@"text"];
        
        [self.itemViews addObject:[itemVC autorelease]];
    }
    self.scrollView.contentSize = CGSizeMake(offset, 440);
    [self.pageControl setNumberOfPages:[self.itemViews count]];
    self.lbHeader.text = [[self.items objectAtIndex:currentPage] objectForKey:@"title"];
    [self.pageControl setCurrentPage:currentPage];
//    self.pageControl.pageIndicatorTintColor = [UIColor blackColor];
//    self.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    self.lbHeader.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:18.0f];
    self.btBack.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0f];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
    NSInteger page = floor((_scrollView.contentOffset.x + 160) / 320);
    if (page != currentPage && page >=0 && page < [self.items count]) {
        currentPage = page;
        self.lbHeader.text = [[self.items objectAtIndex:currentPage] objectForKey:@"title"];
        [self.pageControl setCurrentPage:currentPage];
    }

}


@end
