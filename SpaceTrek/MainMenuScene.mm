//
//  MainMenuScene.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-2.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "MainMenuScene.h"
#import "MainMenuLayer.h"

@implementation MainMenuScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    MainMenuScene *layer = [MainMenuScene node];
    [scene addChild:layer z:1];
    
	// 'layer' is an autorelease object.
	MainMenuLayer *menuLayer = [MainMenuLayer node];
	// add layer as a child to scene
	[scene addChild: menuLayer z:1];
    
	return scene;
}


@end
