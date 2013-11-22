//
//  HelpScene.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-11-12.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "HelpScene.h"
#import "HelpLayer.h"

@implementation HelpScene


+(CCScene *) scene
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    HelpScene *layer = [HelpScene node];
    [scene addChild:layer z:1];
    
   	// 'layer' is an autorelease object.
    
	HelpLayer *helpLayer = [HelpLayer node];
    
	// add layer as a child to scene
	[scene addChild: helpLayer z:1];
    
    return scene;
}


-(id) init
{
	if( (self=[super init])) {
    }
    return self;
}


@end
