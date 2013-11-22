//
//  MainMenuLayer.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-2.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "Constants.h"
#import "MainMenuLayer.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "LoadingScene.h"
#import "MainMenuScene.h"
#import "LevelScrollScene.h"
#import "StoreScene.h"
#import "HelpScene.h"
CCSprite *bg;

@implementation MainMenuLayer


- (id) init {
    self = [super init];
    if (self) {
        
//        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [self preLoadSoundFiles];
        
        bg = [CCSprite spriteWithFile:@"background-menu.png"];
        bg.anchorPoint = ccp(0, 0);
        [self addChild: bg z:-10];
        
        
        CCMenuItemSprite *playButton = [CCMenuItemImage itemWithNormalImage:@"PLAY.png" selectedImage:@"PLAY.png" target:self selector:@selector(buttonPlayAction:)];
        
        CCMenuItemSprite *helpButton = [CCMenuItemImage itemWithNormalImage:@"HELP.png" selectedImage:@"HELP.png" target:self selector:@selector(buttonHelpAction:)];
        
        CCMenuItemSprite *storeButton = [CCMenuItemImage itemWithNormalImage:@"STORE.png" selectedImage:@"STORE.png" target:self selector:@selector(buttonStoreAction)];
        
        
        CCMenu *Menu = [CCMenu menuWithItems:storeButton,helpButton,playButton, nil];
        Menu.anchorPoint =ccp(0.0f, 0.0f);
        Menu.position=ccp(768/5*2,1024/5*2);
        [Menu alignItemsHorizontallyWithPadding:15];
        
        [self addChild:Menu z:1];
        
        /*
        //fake
        storeBackground = [CCMenuItemImage itemWithNormalImage:@"storeBackground.png" selectedImage:@"storeBackground.png" target:self selector:@selector(storeMenuAction)];
        storeBackground.visible = false;
        storeBackground.anchorPoint = ccp(0, 0);
        CCMenu *Menu3 = [CCMenu menuWithItems:storeBackground, nil];
        Menu3.anchorPoint = ccp(0, 0);
        Menu3.position=ccp(0, 0);

        [self addChild:Menu3 z:20];
         */
        
    }
    
    return self;
}

- (void)preLoadSoundFiles
{
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Menu_Music.mp3"];
}

-(void) buttonPlayAction:(id)sender {
//    [[CCDirector sharedDirector] replaceScene:[LoadingScene sceneWithTargetScene:GAME_STATE_ONE]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[LevelScrollScene scene]]];

}

-(void) buttonHelpAction:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelpScene scene]]];
}

-(void) buttonStoreAction
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[StoreScene scene]]];
}


@end
