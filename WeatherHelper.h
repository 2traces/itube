//
//  WeatherHelper.h
//  tube
//
//  Created by Сергей on 11.07.13.
//
//

#import <Foundation/Foundation.h>
#import "StatusDownloader.h"

@interface WeatherHelper : NSObject <StatusDownloaderDelegate>

@property (nonatomic,retain) NSString *weatherURL;
@property (nonatomic,retain) NSMutableDictionary *infoDictionary;

+(WeatherHelper*)sharedHelper;
-(NSMutableDictionary*)getWeatherInformation;

@end
