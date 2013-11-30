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
        [self initBatchNode];
        
        // bg = [CCSprite spriteWithSpriteFrameName:@"menu-bg-btm.png"];
        bg = [CCSprite spriteWithFile:@"background-menu.png"];
        bg.anchorPoint = ccp(0, 0);
        [self addChild: bg z:-10];
        
        [self addBackgroundElmt];
        
        
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

-(void) addBackgroundElmt{
    
    CCSprite *star1 = [CCSprite spriteWithSpriteFrameName:@"menu-bg-star1.png"];
    //    CCSprite *star1 = [CCSprite spriteWithFile:@"menu-bg-star1.png"];
    star1.position = ccp(623,634);
    [self addChild:star1 z:-1];
    
    CCSprite *star2 = [CCSprite spriteWithSpriteFrameName:@"menu-bg-star2-1.png"];
    //    CCSprite *star1 = [CCSprite spriteWithFile:@"menu-bg-star2.png"];
    star2.position = ccp(815,365);
    [self addChild:star2 z:-1];
    
    CCSprite *star3 = [CCSprite spriteWithSpriteFrameName:@"menu-bg-star3-1.png"];
    //    CCSprite *star1 = [CCSprite spriteWithFile:@"menu-bg-star3.png"];
    star3.position = ccp(138,472);
    [self addChild:star3 z:-1];
    
    CCSprite *planet1 = [CCSprite spriteWithSpriteFrameName:@"menu-bg-planet-1.png"];
    planet1.position = ccp(230,660);
    [self addChild:planet1 z:-1];
    
    CCSprite *planet2 = [CCSprite spriteWithSpriteFrameName:@"menu-bg-planet2-1.png"];
    planet2.position = ccp(820,760);
    [self addChild:planet2 z:-1];
    
    CCSprite *title = [CCSprite spriteWithSpriteFrameName:@"menu-bg-title.png"];
    title.position = ccp(820,768/2);
    [self addChild:title z:1];
    
    CCSprite *alien = [CCSprite spriteWithSpriteFrameName:@"menu-bg-body-1.png"];
    alien.position = ccp(768/2,1024/2);
    [self addChild:alien z:1];
    
    CCSprite *buttonpanel = [CCSprite spriteWithSpriteFrameName:@"menu-bg-buttonpanel.png"];
    buttonpanel.position = ccp(768/5*2,1024/5*2);
    [self addChild:buttonpanel z:-1];
    
    CCSprite *bread = [CCSprite spriteWithSpriteFrameName:@"menu-bg-bread-3.png"];
    bread.position = ccp(100, 100);
    [self addChild:bread z:1];
    
    
    
    [self starPulse:star1];
    [self starPulse:star2];
    [self starPulse:star3];
    
    
    
    NSMutableArray *breadAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 3; ++i){
        [breadAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"menu-bg-bread-%d.png", (4-i)]]];
    }
    
    
    CCAnimation *breadAnimation = [CCAnimation animationWithSpriteFrames:breadAnimFrames delay:0.3f];
    CCFiniteTimeAction *breadAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: breadAnimation] times:2000];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:[CCSequence actions:breadAction,nil]];
    [bread runAction:repeat];
    
}

- (void) starPulse: (CCSprite *) star{
    
    [star setOpacity:1.0];
    CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:127];
    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:255];
    
    CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
    [star runAction:repeat];
    
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

- (void) initBatchNode {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu_bg_elmt.plist"];
    CCSpriteBatchNode *allBatchNode=[CCSpriteBatchNode batchNodeWithFile:@"menu_bg_elmt.png"];
    [self addChild:allBatchNode z:10];
}


@end
