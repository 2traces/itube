//
//  SectionHeaderView.m
//  tube
//
//  Created by Sergey Mingalev on 11.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SectionHeaderView


@synthesize titleLabel=_titleLabel, disclosureButton=_disclosureButton, delegate=_delegate, section=_section;


-(id)initWithFrame:(CGRect)frame title:(NSString*)title color:(UIColor*)color section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate {
    
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        
        // Set up the tap gesture recognizer.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];

        _delegate = delegate;        
        self.userInteractionEnabled = YES;
        
        // Create and configure the title label.
        _section = sectionNumber;
        CGRect titleLabelFrame = self.bounds;
        titleLabelFrame.origin.x += 21.0;
        titleLabelFrame.size.width -= 35.0;
        titleLabelFrame.origin.y += 4.0;
        CGRectInset(titleLabelFrame, 0.0, 5.0);
        UILabel *label = [[UILabel alloc] initWithFrame:titleLabelFrame];
        label.text = title;
        label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:21.0f];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        _titleLabel = label;
        
       
        // Create and configure the disclosure button.
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.0, 3.0, 35.0, 35.0);
        [button addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        _disclosureButton = button;
        
       self.backgroundColor = color;
        
        UIImage *img = [UIImage imageNamed:@"lines_edge.png"];
        UIImageView *lineEdge= [[UIImageView alloc] initWithImage:img];
        CGFloat imgH = img.size.height;
        lineEdge.frame=CGRectMake(0,frame.size.height-imgH,320.0,imgH);
        [self addSubview:lineEdge];
        [lineEdge release];

    }
    
    return self;
}


-(IBAction)toggleOpen:(id)sender {
    
    [self toggleOpenWithUserAction:YES];
}


-(void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // Toggle the disclosure button state.
    self.disclosureButton.selected = !self.disclosureButton.selected;
    
    // If this was a user action, send the delegate the appropriate message.
    if (userAction) {
        if (self.disclosureButton.selected) {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                [self.delegate sectionHeaderView:self sectionOpened:self.section];
                
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [self.delegate sectionHeaderView:self sectionClosed:self.section];
            }
        }
    }
}

-(void)dealloc
{
    [_titleLabel release];
    [super dealloc];
}


@end
