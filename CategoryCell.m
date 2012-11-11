//
//  CategoryCell.m
//  tube
//
//  Created by Alexey Starovoitov on 12/11/12.
//
//

#import "CategoryCell.h"

@implementation CategoryCell

@synthesize imageCategory;
@synthesize labelCategory;
@synthesize imageNormal;
@synthesize imagePressed;

- (id)initwithTitle:(NSString*)title image:(UIImage*)image highlightedImage:(UIImage*)highlighted {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        // Initialization code
        self.imageNormal = image;
        self.imagePressed = highlighted;
        self.imageCategory = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 2, 40, 40)] autorelease];
        self.imageCategory.image = self.imageNormal;
        self.labelCategory = [[UILabel alloc] initWithFrame:CGRectMake(60, 4, self.frame.size.width - 60, self.frame.size.height - 4)];
        self.labelCategory.textColor = [UIColor darkGrayColor];
        self.labelCategory.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14.0f];
        self.labelCategory.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
        self.selectedBackgroundView.backgroundColor = [UIColor whiteColor];

        
        self.labelCategory.text = title;
        
        [self addSubview:self.imageCategory];
        [self addSubview:self.labelCategory];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imageCategory = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
        self.labelCategory = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.frame.size.width - 40, self.frame.size.height)];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.imageCategory.image = self.imagePressed;
        self.labelCategory.textColor = [UIColor colorWithRed:10.0f/255.0f green:109.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
    }
    else {
        self.imageCategory.image = self.imageNormal;
        self.labelCategory.textColor = [UIColor darkGrayColor];
    }

}

@end
