//
//  MediaTypeFactory.h
//  tube
//
//  Created by alex on 28.03.13.
//
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ManagedObjects.h"
#import "tubeAppDelegate.h"

@interface MediaTypeFactory : NSObject

+(UIView*)viewForMedia:(MMedia *)media withParent:(UIView*)parent withOrientation:(UIInterfaceOrientation)orientation withIndex:(int)index withMoviePlayers:(NSMutableArray*)moviePlayers;

@end
