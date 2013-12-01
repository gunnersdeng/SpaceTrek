//
//  GameOver.m
//  SpaceTrek
//
//  Created by huang yongke on 13-10-20.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "MainMenuScene.h"
#import "Constants.h"
#import "Global.h"

int stageLevel;
int scoreNum;
int distanceNum;


int currentScoreNum;
int currentDistanceNum;

int timeSlap;
BOOL scoreFinish;
BOOL distanceFinish;


BOOL replaySelected;
BOOL mainSelected;

@implementation GameOverScene

+(CCScene *) sceneWithLevel:(int)level Score:(int)score Distance:(int)distance{
    stageLevel = level;
    scoreNum = score;
    
    gold += score;
    
    distanceNum = distance;
    
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    GameOverScene *layer = [GameOverScene node];
    [scene addChild:layer z:3];
    
	return scene;
}


-(id) init {
    if ((self = [ super init])) {
        
        replaySelected = false;
        mainSelected = false;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        //bg
        CCSprite *bg = [CCSprite spriteWithFile:@"background-v1.png"];
        bg.anchorPoint = ccp(0, 0);

        bg.opacity = 80;
        [self addChild:bg z:-1];
        
        // Create a label for display purposes
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Congratulations!" fontName:@"arial" fontSize:60];
        label.rotation = 90;
        label.color = ccWHITE;
		label.position = CGPointMake(winSize.width/5*4,winSize.height/2);
		[self addChild:label z:0];
        
        
        NSString *scoreStr = [NSString stringWithFormat:@"Score:%2d", scoreNum];
        
        labelScore = [CCLabelTTF labelWithString:scoreStr fontName:@"arial" fontSize:40];
        labelScore.color = ccWHITE;
		labelScore.position = CGPointMake(winSize.width/5*4 - 200,winSize.height/2);
        labelScore.rotation = 90;
		[self addChild:labelScore z:0];
        
        NSString *disStr = [NSString stringWithFormat:@"Distance:%2d", distanceNum];
        
        labelDistance = [CCLabelTTF labelWithString:disStr fontName:@"arial" fontSize:40];
        labelDistance.color = ccWHITE;
		labelDistance.position = CGPointMake(winSize.width/5*4 - 300,winSize.height/2);
        labelDistance.rotation = 90;
		[self addChild:labelDistance z:0];
        
        // Create Replay Button
        buttonRestart = [CCMenuItemImage itemWithNormalImage:@"Restart.png" selectedImage:@"Restart.png" target:self selector:@selector(buttonRestartAction:)];
        
        
        // Create Mainmenu Button
        buttonMenu = [CCMenuItemImage itemWithNormalImage:@"MENU.png" selectedImage:@"MENU.png" target:self selector:@selector(buttonMenuAction:)];
        
        
        CCMenu *Menu = [CCMenu menuWithItems:buttonMenu, buttonRestart, nil];
        Menu.position=ccp(winSize.width/4, winSize.height/2);
        
        [Menu alignItemsHorizontallyWithPadding:5.0f];
        [self addChild:Menu];
        [self schedule:@selector(update:) interval:0.01f];
        
    }
    return self;
}


- (void)update:(ccTime) dt
{
    timeSlap++;
    if(timeSlap >= 10) {
        if(scoreNum<0)
        {
            if(currentScoreNum > scoreNum) {
                currentScoreNum--;
                NSString *scoreStr = [NSString stringWithFormat:@"Score:%2d", currentScoreNum];
                [labelScore setString:scoreStr];
            }
            else
                scoreFinish = true;
        }
        else
        {
            if(currentScoreNum < scoreNum) {
                currentScoreNum++;
                NSString *scoreStr = [NSString stringWithFormat:@"Score:%2d", currentScoreNum];
                [labelScore setString:scoreStr];
            }
            else
                scoreFinish = true;
        }
        
        
        
        if(currentDistanceNum < distanceNum) {
            currentDistanceNum++;
            NSString *disStr = [NSString stringWithFormat:@"Distance:%2d", currentDistanceNum];
            [labelDistance setString:disStr];
        }
        else
            distanceFinish = true;
        
        if (scoreFinish) {
            if(labelScore.scale <= 1.5)
                labelScore.scale += 0.01;
        }
        
        if (distanceFinish) {
            if(labelDistance.scale <= 1.5)
                labelDistance.scale += 0.01;
        }
    }
    if(replaySelected) {
        if(buttonRestart.scale <= 1.2) {
            buttonRestart.scale += 0.01;
        }
    }
    
    if(mainSelected) {
        if(buttonMenu.scale <= 1.2) {
            buttonMenu.scale += 0.01;
        }
    }
}



- (void)buttonRestartAction:(id)sender {
    replaySelected = true;
    switch (stageLevel) {
        case 1:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene sceneWithState:GAME_STATE_ONE]]];
            break;
        case 2:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene sceneWithState:GAME_STATE_TWO]]];
            break;
        case 3:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene sceneWithState:GAME_STATE_THREE]]];
            break;
        default:
            break;
    }
}

- (void)buttonMenuAction:(id)sender {
    mainSelected = true;
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene]]];
    
}


@end
