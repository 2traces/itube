//
//  LanguageCell.m
//  tube
//
//  Created by sergey on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LanguageCell.h"

@implementation LanguageCell

@synthesize languageLabel;
@synthesize languageWordLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
    [languageLabel release];
    [languageWordLabel release];
    [super dealloc];
}

@end
