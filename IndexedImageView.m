//
//  IndexedImageView.m
//  tube
//
//  Created by alex on 09.04.13.
//
//

#import "IndexedImageView.h"

@implementation IndexedImageView

@synthesize index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) dealloc{
    self.image = nil;
    [super dealloc];
}

@end
