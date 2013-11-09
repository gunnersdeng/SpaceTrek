//
//  StoreScene.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-11-5.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "StoreScene.h"
#import "StoreLayer.h"

@implementation StoreScene


+(CCScene *) scene
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    StoreScene *layer = [StoreScene node];
    [scene addChild:layer z:1];
    
   	// 'layer' is an autorelease object.
    
	StoreLayer *storeLayer = [StoreLayer node];
    
	// add layer as a child to scene
	[scene addChild: storeLayer z:1];
    
    return scene;
}


-(id) init
{
	if( (self=[super init])) {
    }
    return self;
}

@end
