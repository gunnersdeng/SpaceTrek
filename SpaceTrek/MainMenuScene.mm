//
//  MainMenuScene.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-2.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "MainMenuScene.h"
#import "MainMenuLayer.h"
#import "StoreLayer.h"
#import "Constants.h"

@implementation MainMenuScene

static MainMenuScene* instanceOfMainMenuScene;

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

-(id) init
{
	if( (self=[super init])) {
        instanceOfMainMenuScene = self;
        [self setShowingStore:NO];
    }
    return self;
}


- (void)showStore {
    StoreLayer *store = [[StoreLayer alloc] initWithLevel: GAME_STATE_ONE];
    
    [self addChild:store z:10 tag:STORE_LAYER_TAG];
}


+ (MainMenuScene *) sharedMainMenuScene
{
	return instanceOfMainMenuScene;
}


@end
