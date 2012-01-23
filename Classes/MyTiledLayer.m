//
//  MyTiledLayer.m
//  tube
//
//  Created by Vasiliy Makarov on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyTiledLayer.h"

@implementation MyTiledLayer

// выключаем фейд рисуемых участков, чем экономим 1/4 секунды на участок
+(CFTimeInterval)fadeDuration
{
    return 0;
}

@end
