//
//  ReaderViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 16/11/12.
//
//

#import "ReaderViewController.h"
#import "ReaderItemViewController.h"
#import "ManagedObjects.h"

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


- (IBAction)addToFavorites:(id)sender {
    MPlace *place = self.items[currentPage];
    place.isFavorite = [place.isFavorite boolValue] ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [self updateInfoForCurrentPage];
}


- (id) initWithReaderItems:(NSArray*)_items currentItemIndex:(NSInteger)currentItemIndex {
    self = [super initWithNibName:@"ReaderViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        self.items = _items;
        currentPage = currentItemIndex;
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


- (void)updateInfoForCurrentPage {
    MPlace *place = self.items[currentPage];
    self.lbHeader.text = place.name;
    UIImage *btImage = [place.isFavorite boolValue] ?
    [UIImage imageNamed:@"bt_star_solid"] :
    [UIImage imageNamed:@"bt_star"];
    [self.btStar setImage:btImage forState:UIControlStateNormal];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.itemViews = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    CGFloat offset = 0;
    for (MPlace *place in self.items) {
        ReaderItemViewController *itemVC = [[ReaderItemViewController alloc] initWithPlaceObject:place];
        CGRect frame = itemVC.view.frame;
        frame.origin = CGPointMake(offset, 0);
        offset += 320;
        itemVC.view.frame = frame;
        [self.scrollView addSubview:itemVC.view];
        [self.itemViews addObject:[itemVC autorelease]];
    }
    self.scrollView.contentSize = CGSizeMake(offset, 440);
    self.scrollView.contentOffset = CGPointMake(320 * currentPage, 0);
    [self.pageControl setNumberOfPages:[self.itemViews count]];
    [self.pageControl setCurrentPage:currentPage];
    self.lbHeader.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:18.0f];
    self.btBack.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0f];
    [self updateInfoForCurrentPage];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = (self.scrollView.contentOffset.x + self.scrollView.frame.size.width/2 - 1) / self.scrollView.frame.size.width;
    if (page != currentPage && page >=0 && page < [self.items count]) {
        currentPage = page;
        [self updateInfoForCurrentPage];
        [self.pageControl setCurrentPage:currentPage];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
