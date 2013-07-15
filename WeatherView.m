//
//  WeatherView.m
//  tube
//
//  Created by Сергей on 12.07.13.
//
//

#import "WeatherView.h"
#import <QuartzCore/QuartzCore.h>
#import "WeatherHelper.h"

@implementation WeatherView

@synthesize dayOneLabel;
@synthesize dayThreeLabel;
@synthesize dayTwoLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 190, 50)];
        view2.backgroundColor = [UIColor whiteColor];
        view2.layer.cornerRadius = 5.0f;
        
        [self addSubview:view2];
        
        dayOneLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 80, 30)] autorelease];
        dayTwoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100.0, 7.0, 80, 25)] autorelease];
        dayThreeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100.0, 30.0, 80, 25)] autorelease];
        
        dayOneLabel.font = [UIFont systemFontOfSize:24];
        dayTwoLabel.font = [UIFont systemFontOfSize:17];
        dayThreeLabel.font = [UIFont systemFontOfSize:17];
        
        [self addSubview:dayOneLabel];
        [self addSubview:dayTwoLabel];
        [self addSubview:dayThreeLabel];
        
    }
    return self;
}

-(void)layoutSubviews
{
    dayOneLabel.text = @"--";
    dayTwoLabel.text = @"--";
    dayThreeLabel.text = @"--";
    
    
    //test

    
    
//        NSArray *array = [self.weatherInfo allKeys];
//
//        label.text = [self.weatherInfo objectForKey:[array objectAtIndex:0]];
//    
//           [view2 addSubview:label];
//
  
    NSDictionary *dict = [[WeatherHelper sharedHelper] getWeatherInformation];
    
    if ([dict count]>0) {
        
        NSArray *array = [dict allKeys];
        NSArray *sortedKeys = [array sortedArrayUsingSelector: @selector(compare:)];

        dayOneLabel.text = [[dict objectForKey:[sortedKeys objectAtIndex:0]] objectForKey:@"temperature"];
        dayTwoLabel.text = [[dict objectForKey:[sortedKeys objectAtIndex:1]] objectForKey:@"temperature"];
        dayThreeLabel.text = [[dict objectForKey:[sortedKeys objectAtIndex:2]] objectForKey:@"temperature"];

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
