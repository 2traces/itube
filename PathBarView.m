//
//  PathBarView.m
//  tube
//
//  Created by Sergey Mingalev on 31.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PathBarView.h"
#import "PathDrawView.h"
#import "CityMap.h"
#import "tubeAppDelegate.h"
#import "SSTheme.h"

@implementation PathBarView

- (id)initWithFrame:(CGRect)frame path:(NSMutableArray*)thisPath number:(int)number overall:(int)overall
{
    self = [super initWithFrame:frame];

    if (self) {
 
        int page = frame.origin.x/frame.size.width;

        CGFloat start=10.0f;

        if ([[SSThemeManager sharedTheme] isNewTheme]) {
        
                    
        } else {
            NSString *fileName = [NSString stringWithFormat:@"n%d.png",number+1];
            UIImageView *pathNumberView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
            pathNumberView.frame = CGRectMake(8,4,24,32);
            [self addSubview:pathNumberView];
            [pathNumberView release];

            UILabel *over = [[UILabel alloc] init];
            over.text=[NSString stringWithFormat:@"%d",overall];
            over.backgroundColor = [UIColor clearColor];
            over.font = [UIFont fontWithName:@"MyriadPro-Regular" size:9.0];
            over.textColor = [UIColor whiteColor];
            over.frame=CGRectMake(23, 9, 10, 10);
            [self addSubview:over];
            [over release];
            
            start = 37.0f;
        }
        

        UIImage *clockImage = [[SSThemeManager sharedTheme] pathBarViewClockIcon];
        UIImageView *clockView = [[UIImageView alloc] initWithImage:clockImage];
        clockView.frame = CGRectMake(start, 4,clockImage.size.width,clockImage.size.height);
        clockView.tag=6400+page;
        [self addSubview:clockView];
        [clockView release];
        
        UIImage *destinationIcon = [[SSThemeManager sharedTheme] pathBarViewDestinationIcon];
        UIImageView *flagView = [[UIImageView alloc] initWithImage:destinationIcon];
        flagView.frame = CGRectMake(244,5,destinationIcon.size.width,destinationIcon.size.height);
        flagView.tag=6500+page;
        [self addSubview:flagView];
        [flagView release];
        
        NSInteger travelTime = [self dsGetTravelTime:thisPath];
        UILabel *travelTimeLabel = [[UILabel alloc] init];
        travelTimeLabel.text=[NSString stringWithFormat:@"%d %@",travelTime,NSLocalizedString(@"minutes", @"minutes")];        
        travelTimeLabel.backgroundColor = [UIColor clearColor];
        travelTimeLabel.font = [[SSThemeManager sharedTheme] pathBarViewFont];
        travelTimeLabel.textColor = [[SSThemeManager sharedTheme] pathBarViewFontColor1];
        travelTimeLabel.shadowColor = [[SSThemeManager sharedTheme] pathBarViewFontShadowColor];
        travelTimeLabel.shadowOffset = CGSizeMake(0, 1);
        travelTimeLabel.frame=CGRectMake(start+15.0f, 6, 65, 15);
        travelTimeLabel.tag=6000+page;
        [self addSubview:travelTimeLabel];
        [travelTimeLabel release];
        
        UILabel *arrivalTimeLabel = [[UILabel alloc] init];
        arrivalTimeLabel.backgroundColor = [UIColor clearColor];
        arrivalTimeLabel.font = [[SSThemeManager sharedTheme] pathBarViewFont];
        arrivalTimeLabel.frame=CGRectMake(256.0, 7, 54, 15); 
        arrivalTimeLabel.shadowOffset = CGSizeMake(0, 1);
        arrivalTimeLabel.textColor= [[SSThemeManager sharedTheme] pathBarViewFontColor2];
        arrivalTimeLabel.shadowColor = [[SSThemeManager sharedTheme] pathBarViewFontShadowColor];
        arrivalTimeLabel.tag=7000+page;
        arrivalTimeLabel.textAlignment=UITextAlignmentRight;
        [self addSubview:arrivalTimeLabel];
        [arrivalTimeLabel release];
        
        PathDrawView *drawView = [[PathDrawView alloc] initWithFrame:CGRectMake(start, 0, self.frame.size.width, frame.size.height) path:(NSMutableArray*)thisPath];
        drawView.tag =10000+page;
        [self addSubview:drawView];
        [drawView release];

        NSString *arrivalTime = [self getArrivalTimeFromNow:travelTime];
        CGSize atSize = [arrivalTime sizeWithFont: [[SSThemeManager sharedTheme] pathBarViewFont]];
        CGRect labelRect = [(UILabel*)[self viewWithTag:7000+page] frame];
        CGFloat labelStart = frame.size.width-atSize.width;//-10.0f-atSize.width-2.0;
        [(UILabel*)[self viewWithTag:7000+page] setFrame:CGRectMake(labelStart, labelRect.origin.y, atSize.width+2.0, labelRect.size.height)];
        [(UILabel*)[self viewWithTag:7000+page] setText:[NSString stringWithFormat:@"%@",arrivalTime]];
        
        CGRect flagRect = [(UILabel*)[self viewWithTag:6500+page] frame];
        [(UIImageView*)[self viewWithTag:6500+page] setFrame:CGRectMake(labelStart-flagRect.size.width-2.0, flagRect.origin.y, flagRect.size.width, flagRect.size.height)];
        
        if (IS_IPAD) {
            
            CGSize dateSize = [arrivalTime sizeWithFont:[[SSThemeManager sharedTheme] pathBarViewFont]];
            
            [[self viewWithTag:10000+page] removeFromSuperview];
            [[self viewWithTag:6400+page] setFrame:CGRectMake(start, 10, 18, 18)];
            [[self viewWithTag:6500+page] setFrame:CGRectMake(self.frame.size.width-10.0-dateSize.width-5-26, 10, 18, 18)];
            [[self viewWithTag:6000+page] setFrame:CGRectMake(start+26.0f, 12, 90, 20)];
            [[self viewWithTag:7000+page] setFrame:CGRectMake(self.frame.size.width-10.0-dateSize.width-5 , 12 , dateSize.width+5 , 20)];
            [(UILabel*)[self viewWithTag:7000+page] setTextAlignment:UITextAlignmentLeft];
        }
    }

    return self;
}

-(NSString*)getArrivalTimeFromNow:(NSInteger)time
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([appDelegate.cityMap.pathTimesList count]>1) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        NSString *arrivalTime = [formatter stringFromDate:[appDelegate.cityMap.pathTimesList lastObject]];
        [formatter release];
        return arrivalTime;    
    }

    NSDate *newDate = [NSDate dateWithTimeIntervalSinceNow:time*60.0]; 
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    
    NSString *arrivalTime = [formatter stringFromDate:newDate];
    
    [formatter release];
    
    return arrivalTime;
}


-(NSInteger)dsGetTravelTime:(NSArray*)thisPath
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
 
    if ([appDelegate.cityMap.pathTimesList count]>1) {
        NSTimeInterval timeInterval = [[appDelegate.cityMap.pathTimesList lastObject] timeIntervalSinceNow];
        NSInteger transferTimeS = ceil((float)timeInterval/60.0);
        if(transferTimeS < 0) transferTimeS += 60*24;
        return transferTimeS;    
    }

    NSArray *path = thisPath;
    int objectNum = [path count];
    
    NSInteger transferTime=0;
    NSInteger lineTime=0;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            Segment *segment = (Segment*)[path objectAtIndex:i];
            lineTime+=[segment driving];
        } else if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]]) {
            transferTime+=[(Transfer*)[path objectAtIndex:i] time];
        }
    }
    
    return lineTime+transferTime;
}

@end
