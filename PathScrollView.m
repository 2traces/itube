//
//  PathScrollView.m
//  tube
//
//  Created by sergey on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PathScrollView.h"
#import "Classes/MainView.h"
#import "Classes/tubeAppDelegate.h"
#import "PathBarView.h"

@implementation PathScrollView

@synthesize scrollView;
@synthesize delegate;
@synthesize numberOfPages;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfPages=1;
        
        tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableArray *pathes2 = [[NSMutableArray alloc] init];
        MainView *mainView = (MainView*)[appDelegate.mainViewController view];
        NSArray *keys = [[mainView.mapView.foundPaths allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        for (NSNumber *pathIndex in keys) {
            [pathes2 addObject:[mainView.mapView.foundPaths objectForKey:pathIndex]];
        }
        
        self.numberOfPages = [pathes2 count];
        
        CGFloat viewStartX = 0.0f;
        CGFloat viewStartY = 0.0f;
        CGFloat viewWidth = 320.0f;
        CGFloat viewHeight = 40.0f;
        
        if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad) {
            viewStartX = 0.0f;
            viewStartY = 26.0f;
            viewWidth = 320.0f;
            viewHeight = 40.0f;
        }
        
        UIScrollView *scView= [[UIScrollView alloc] initWithFrame:CGRectMake(viewStartX, viewStartY, viewWidth, viewHeight)];
        self.scrollView=scView;
        [self addSubview:scrollView];
        [scView release];
        
        self.scrollView.contentSize=CGSizeMake(numberOfPages * viewWidth, viewHeight);
        self.scrollView.pagingEnabled = YES;
        self.scrollView.bounces=NO;
        self.scrollView.showsVerticalScrollIndicator=NO;
        self.scrollView.showsHorizontalScrollIndicator=NO;
        self.scrollView.delegate = self;
        
        for (int i=0; i<numberOfPages; i++) {
            NSMutableArray *pathWithNumber = [appDelegate.cityMap describePath:[pathes2 objectAtIndex:i]];
            PathBarView *pathView = [[PathBarView alloc] initWithFrame:CGRectMake(i*viewWidth, 0.0, viewWidth, viewHeight) path:pathWithNumber number:i overall:numberOfPages];
            [self.scrollView addSubview:pathView];
            pathView.tag=20000+i;
            [pathView release];
        }
        
        [pathes2 release];
    }
    return self;
}

-(void)refreshContent
{
    NSArray *viewArray = [self.scrollView subviews];
    for (PathBarView *view in viewArray) {
        [view removeFromSuperview];
    }
    
    self.numberOfPages=1;
    
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *pathes2 = [[NSMutableArray alloc] init];
    MainView *mainView = (MainView*)[appDelegate.mainViewController view];
    NSArray *keys = [[mainView.mapView.foundPaths allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSNumber *pathIndex in keys) {
        [pathes2 addObject:[mainView.mapView.foundPaths objectForKey:pathIndex]];
    }
    
    self.numberOfPages = [pathes2 count];
    
    
    CGFloat viewStartX = 0.0f;
    CGFloat viewStartY = 26.0f;
    CGFloat viewWidth = 320.0f;
    CGFloat viewHeight = 40.0f;
    
    if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad) {
        viewStartX = 0.0f;
        viewStartY = 26.0f;
        viewWidth = 320.0f;
        viewHeight = 40.0f;
    }

    [self.scrollView scrollRectToVisible:CGRectMake(viewStartX, viewStartY, viewWidth, viewHeight) animated:NO];
    
    self.scrollView.contentSize=CGSizeMake(numberOfPages * viewWidth, viewHeight);
    
    for (int i=0; i<numberOfPages; i++) {
        NSMutableArray *pathWithNumber = [appDelegate.cityMap describePath:[pathes2 objectAtIndex:i]];
        PathBarView *pathView = [[PathBarView alloc] initWithFrame:CGRectMake(i*viewWidth, 0.0, viewWidth, viewHeight) path:pathWithNumber number:i overall:numberOfPages];
        [self.scrollView addSubview:pathView];
        pathView.tag=20000+i;
        [pathView release];
    }
    
    [pathes2 release];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)ascrollView{
    
    if (ascrollView==self.scrollView) {
        
        int pathNumb = floor(ascrollView.contentOffset.x/320.0);
        [delegate requestChangeActivePath:[NSNumber numberWithInt:pathNumb]];
    }
}

- (void)animateScrollView
{
    if (self.scrollView && self.scrollView.contentSize.width>320.0f && self.scrollView.contentOffset.x==0.0f) {
        
        [UIView animateWithDuration:1 delay:0 options:(UIViewAnimationCurveEaseInOut) animations:^{
            [self.scrollView setContentOffset:CGPointMake(38.0, 0.0)];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:1 delay:0 options:(UIViewAnimationCurveEaseInOut) animations:^{
                [self.scrollView setContentOffset:CGPointMake(0.0, 0.0)];
            } completion:nil];
        }];
    }
    
    [delegate animationDidEnd];
}

-(void)dealloc
{
    [scrollView release];
    [super dealloc];
}

@end
