//
//  WeatherHelper.m
//  tube
//
//  Created by Сергей on 11.07.13.
//
//

#import "WeatherHelper.h"
#import "tubeAppDelegate.h"
#import "CityMap.h"
#import "Reachability.h"
#import "StatusDownloader.h"
#import "WeatherXMLParser.h"

@implementation WeatherHelper

static WeatherHelper * _sharedHelper;

+ (WeatherHelper *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[WeatherHelper alloc] init];
    
    return _sharedHelper;
}

-(id) init
{
	if ((self=[super init]))
	{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapChanged:) name:@"kMapChanged" object:nil];
        _weatherURL = [self getCityWeatherURL];
        
        if (_weatherURL) {
            [self recieveWeatherInfo];
        }

	}
	
	return self;
}

-(NSString*)getCityWeatherURL
{
    NSString *url;
    
    url = nil;
    
    NSString *mainURL=nil;
    
    NSString *currentMap = [[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName];
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSArray *mapIDs = [dict allKeys];
    for (NSString* mapID in mapIDs) {
        NSDictionary *map = [dict objectForKey:mapID];
        if ([[map objectForKey:@"filename"] isEqual:currentMap]) {
            if ([map objectForKey:@"weatherURL"]) {
                mainURL = [NSString stringWithString:[map objectForKey:@"weatherURL"]];
            }
        }
    }
    
    [dict release];
    
    //temp
    mainURL = @"http://xml.weather.com/weather/local/FRXX0076?cc=*&dayf=3";
    
    return mainURL;
}

-(void)recieveWeatherInfo
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus != NotReachable) {
        StatusDownloader *statusDownloader = [[StatusDownloader alloc] init];
        statusDownloader.delegate = self;
        statusDownloader.imageURLString=_weatherURL;
        [statusDownloader startDownload];
        [statusDownloader release];
    }
}

-(void)statusInfoDidLoad:(NSString*)xmlString server:(StatusDownloader*)server
{
    if (xmlString) {
        WeatherXMLParser *parseOperation = [[WeatherXMLParser alloc] initWithString:xmlString];
        tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate.parseQueue addOperation:parseOperation];
        [parseOperation release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(parseComplete:)
                                                     name:kParseComplete
                                                   object:nil];
    }
}

-(void)connectionFailed:(StatusDownloader*)server
{
//    [servers removeObject:server];
//    NSLog(@"%@",servers);
}

-(void)parseComplete:(NSNotification*)note
{
//    NSLog(@"%@",[note object]);
    
    NSMutableDictionary *dict = [note object];
    
    _infoDictionary = dict;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kWeatherInfo" object:_infoDictionary];
}

-(NSDictionary*)getWeatherInformation
{
    if (_infoDictionary) {
        
        NSDate *date = [_infoDictionary objectForKey:@"timeStamp"];
        
        if ([date timeIntervalSinceNow]>3600) {
            [self getWeatherInformation];
        }
        
        return _infoDictionary;
        
    } 
    
    return nil;
}

@end
