//
//  LevelScrollScene.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-11-5.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "Constants.h"
#import "GameScene.h"
#import "LevelScrollLayer.h"
#import "LevelScrollScene.h"
#import "LoadingScene.h"


@implementation LevelScrollScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    LevelScrollScene *layer = [LevelScrollScene node];
    [scene addChild:layer];
    
	// return the scene
	return scene;
}

- (void)buttonAction1:(id)sender {
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[GameScene sceneWithState:GAME_STATE_ONE]]];
    button1Selected = true;

    CCScene * newScene = [LoadingScene sceneWithTargetScene : GAME_STATE_ONE ];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:newScene]];
}

- (void)buttonAction2:(id)sender {
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[GameScene sceneWithState:GAME_STATE_TWO]]];
    button2Selected = true;
    CCScene * newScene = [LoadingScene sceneWithTargetScene : GAME_STATE_TWO ];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:newScene]];
}

- (void)buttonAction3:(id)sender {
    //    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[GameScene sceneWithState:GAME_STATE_THREE]]];
    button3Selected = true;
    CCScene * newScene = [LoadingScene sceneWithTargetScene : GAME_STATE_THREE ];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:newScene]];
}

-(id) init
{
	if( (self=[super init])) {
        button1Selected = false;
        button2Selected = false;
        button3Selected = false;
        
        CCSprite *bg = [CCSprite spriteWithFile:@"background-chooseLevel.png"];
        bg.anchorPoint = ccp(0, 0);
        [self addChild:bg];
        // get screen size
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        /////////////////////////////////////////////////
        // PAGE 1
        ////////////////////////////////////////////////
        // create a blank layer for page 1
        CCLayer *pageOne = [[CCLayer alloc] init];
        // create an image button for page 1
        button1 = [CCMenuItemImage itemWithNormalImage:@"background-v1.png" selectedImage:@"background-v1.png" target:self selector:@selector(buttonAction1:)];
        button1.scale = 0.6;
        button1.rotation = 0;
        Menu1 = [CCMenu menuWithItems:button1, nil];
        Menu1.position=ccp(screenSize.width/2, screenSize.height/2);
        [Menu1 alignItemsHorizontally];
        [pageOne addChild:Menu1];
        // create a label for page 1
        CCLabelTTF *label1 = [CCLabelTTF labelWithString:@"Galaxy" fontName:@"arial" fontSize:44];
        label1.rotation = 90;
        label1.position =  ccp( screenSize.width /4 , screenSize.height/2 );
        // add label to page 1 layer
        [pageOne addChild:label1];
        
        /////////////////////////////////////////////////
        // PAGE 2
        ////////////////////////////////////////////////
        // create a blank layer for page 2
        CCLayer *pageTwo = [[CCLayer alloc] init];
        // create an image button for page 2
        button2 = [CCMenuItemImage itemWithNormalImage:@"level2-background.png" selectedImage:@"level2-background.png" target:self selector:@selector(buttonAction2:)];
        button2.scale = 0.6;
        button2.rotation = 0;
        Menu2 = [CCMenu menuWithItems:button2, nil];
        Menu2.position=ccp(screenSize.width/2, screenSize.height/2);
        [Menu2 alignItemsHorizontally];
        [pageTwo addChild:Menu2];
        // create a label for page 2
        CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Andromeda Galaxy" fontName:@"arial" fontSize:44];
        label2.rotation = 90;
        label2.position =  ccp( screenSize.width /4 , screenSize.height/2 );
        // add label to page 2 layer
        [pageTwo addChild:label2];
        /////////////////////////////////////////////////
        // PAGE 3
        ////////////////////////////////////////////////
        
        CCLayer *pageThree = [[CCLayer alloc] init];
        // create an image button for page 3
        button3 = [CCMenuItemImage itemWithNormalImage:@"level3-background.png" selectedImage:@"level3-background.png" target:self selector:@selector(buttonAction3:)];
        button3.scale = 0.6;
        button3.rotation = 0;
        Menu3 = [CCMenu menuWithItems:button3, nil];
        Menu3.position=ccp(screenSize.width/2, screenSize.height/2);
        [Menu3 alignItemsHorizontally];
        [pageThree addChild:Menu3];
        // create a label for page 3
        CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"Alien Galaxy" fontName:@"arial" fontSize:44];
        label3.rotation = 90;
        label3.position =  ccp( screenSize.width /4 , screenSize.height/2 );
        // add label to page 3 layer
        [pageThree addChild:label3];
        
        // now create the scroller and pass-in the pages (set widthOffset to 0 for fullscreen pages)
        LevelScrollLayer *scroller = [[LevelScrollLayer alloc] initWithLayers:[NSMutableArray arrayWithObjects: pageOne,pageTwo,pageThree,nil] widthOffset: 230];
        // finally add the scroller to your scene
        [self addChild:scroller];
        [self scheduleUpdate];
    }
    return self;
}

- (void)update:(ccTime) dt
{
    if(button1Selected) {
        if(button1.scale <= 1.2) {
            button1.scale += 0.01;
        }
    }
    
    if(button2Selected) {
        if(button2.scale <= 1.2) {
            button2.scale += 0.01;
        }
    }
    
    if(button3Selected) {
        if(button3.scale <= 1.2) {
            button3.scale += 0.01;
        }
    }
}

@end
