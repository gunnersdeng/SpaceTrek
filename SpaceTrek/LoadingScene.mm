//
//  LoadingScene.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-20.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "Constants.h"
#import "GameScene.h"
#import "LoadingScene.h"


@implementation LoadingScene

+( id ) sceneWithTargetScene:(int)gameStage;
{
    return [[ self alloc] initWithTargetScene:gameStage];
}

-( id ) initWithTargetScene:(int)gameStage
{
    if (( self = [ super init]))
    {
        GameStage = gameStage;
        
        CCSprite *bg = [CCSprite spriteWithFile:@"loading.png"];
        //CCSprite *bg = [CCSprite spriteWithFile:@"loadingBackground.png"];
        //bg.rotation = 90;
        bg.anchorPoint = ccp(0, 0);
        [self addChild:bg];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        /*
         loadingLabel = [CCLabelTTF labelWithString:@"Loading" fontName:@"arial" fontSize:80];
         loadingLabel.rotation = 90;
         [loadingLabel setColor:ccORANGE];
         [loadingLabel setAnchorPoint:ccp(0.5f,1.0f)];
         [loadingLabel setPosition:ccp(100, winSize.height/2)];
         [self addChild:loadingLabel z:30];
         [self schedule:@selector(updateLoading:) interval:0.5f repeat:1000 delay:0];
         */
        
        angle = 0;
        circle = [CCSprite spriteWithFile: [NSString stringWithFormat:@"LoadingCircle.png"]];
        circle.anchorPoint = ccp(0.5f, 0.5f);
        [circle setPosition:ccp(winSize.width/3*2, winSize.height/2)];
        [self addChild:circle];
        [self schedule:@selector(updateLoading1:) interval:0.01f repeat:1000 delay:0];
        
        [self schedule:@selector(update:) interval:3.0f];
    }
    return self ;
}

-( void ) updateLoading1:(ccTime)delta
{
    angle += 5;
    angle = angle%360;
    circle.rotation = angle;
}

-( void ) updateLoading:(ccTime)delta
{
    count++;
    if(count==7)
    {
        count=1;
    }
    switch(count)
    {
        case 1:[loadingLabel setString:@"Loading .     "];break;
        case 2:[loadingLabel setString:@"Loading ..    "];break;
        case 3:[loadingLabel setString:@"Loading ...   "];break;
        case 4:[loadingLabel setString:@"Loading ....  "];break;
        case 5:[loadingLabel setString:@"Loading ..... "];break;
        case 6:[loadingLabel setString:@"Loading ......"];break;
    }
}

-(void) updateLable1
{
    [loadingLabel setString:@"Loading ."];
}

-(void) updateLable2
{
    [loadingLabel setString:@"Loading .."];
}


-( void ) update:(ccTime)delta
{
    //[ self unscheduleAllSelectors];
    switch (GameStage)
    {
        case GAME_STATE_ONE:
            [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithState:GAME_STATE_ONE]];
            break ;
        case GAME_STATE_TWO:
            [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithState:GAME_STATE_TWO]];
            break ;
        case GAME_STATE_THREE:
            [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithState:GAME_STATE_THREE]];
            break ;
        default :
            break ;
    }
}


@end