//
//  HCBookmarkItemView.m
//  tube
//
//  Created by Alexey Starovoitov on 14/11/12.
//
//

#import "HCBookmarkItemView.h"

@implementation HCBookmarkItemView

@synthesize imageView;
@synthesize textView;
@synthesize labelPlaceDistance;
@synthesize labelPlaceName;
@synthesize buttonRemoveFromBookmarks;
@synthesize infoContainer;
@synthesize imageInfoBg;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UIImage* infoBg = [[UIImage imageNamed:@"bookmark_item_info_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 0, 30, 0)];
    self.imageInfoBg.image = infoBg;
    self.textView.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12.0f];
    self.labelPlaceName.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:15.0f];
    self.labelPlaceDistance.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12.0f];
}

- (void) setImage:(UIImage*)image text:(NSString*)text placeName:(NSString*)name placeDistance:(NSString*)distance {
    self.imageView.image = image;
    self.labelPlaceName.text = name;
    self.labelPlaceDistance.text = distance;
    self.textView.text = text;
    CGFloat delta = self.textView.contentSize.height - self.textView.frame.size.height;
    if (delta > 0) {
        CGRect selfFrame = self.frame;
        CGRect textFrame = self.textView.frame;
        textFrame.size.height += delta;
        selfFrame.size.height += delta;
        self.textView.frame = textFrame;
        self.frame = selfFrame;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
