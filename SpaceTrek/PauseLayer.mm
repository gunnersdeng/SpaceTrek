//
//  PauseLayer.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-6.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "PauseLayer.h"
#import "Constants.h"
#import "GameLayer.h"
#import "GameScene.h"
#import "MainMenuScene.h"
#import "SimpleAudioEngine.h"

int buttonSelected;


@implementation PauseLayer

int pauseLevel;


- (id) initWithLevel:(int)level {
    if ((self = [super initWithColor:ccc4(139, 137, 137, 200)]))
	{
        pauseLevel = level;
        
        self.tag=PAUSE_LAYER_TAG;
        buttonSelected = 0;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        
        // Resume Button
        resume = [CCMenuItemImage itemWithNormalImage:@"RESUME.png" selectedImage:@"RESUME.png" target:self selector:@selector(resumeButtonSelected)];
        
        
        // Restart Button
        
        restart = [CCMenuItemImage itemWithNormalImage:@"Restart.png" selectedImage:@"Restart.png" target:self selector:@selector(restartButtonSelected)];
        
        
        main = [CCMenuItemImage itemWithNormalImage:@"MENU.png" selectedImage:@"MENU.png" target:self selector:@selector(mainButtonSelected)];

        
        CCMenu *menu = [CCMenu menuWithItems:main, restart, resume, nil];
        menu.position =  ccp( screenSize.width/2 , screenSize.height/2);
        [menu alignItemsHorizontallyWithPadding:5.0f];
        [self addChild:menu];
        //        [self schedule:@selector(update:) interval:0.01f];
        
    }
	return self;
}

-(void) resumeButtonSelected
{
    [[GameScene sharedGameScene] setShowingPausedMenu:NO];
    [[CCDirector sharedDirector]resume];
    [[GameScene sharedGameScene] removeChildByTag:PAUSE_LAYER_TAG cleanup:YES];
}

-(void) restartButtonSelected
{
    [[GameScene sharedGameScene] setShowingPausedMenu:NO];
    [[CCDirector sharedDirector] resume];

    switch (pauseLevel) {
        case 1:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene sceneWithState:1]]];
            break;
        case 2:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene sceneWithState:2]]];
            break;
        case 3:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene sceneWithState:3]]];
            break;
        default:
            break;
    }
    
    [[GameScene sharedGameScene] removeChildByTag:PAUSE_LAYER_TAG cleanup:YES];
}
-(void) mainButtonSelected
{
    [[GameScene sharedGameScene] setShowingPausedMenu:NO];
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene]]];

    [[GameScene sharedGameScene] removeChildByTag:PAUSE_LAYER_TAG cleanup:YES];
}


@end
