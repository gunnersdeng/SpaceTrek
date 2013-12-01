//
//  BackgroundLayer.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-6.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "BackgroundLayer.h"
#import "Constants.h"

@implementation BackgroundLayer

CCSprite *bgTop;
CCSprite *bgBottom;
CCSprite *bgBottom1;
CCSprite *bgBottom2;
NSMutableArray * bgTops;
CGSize winSize;

int backgroundLevel = 1;
float backSpeed = 1.0f;


- (id) initWithLevel:(int)level {
    self = [super init];
    if (self) {
                
        backgroundLevel = level;
        
        [self initBackground];
        

        if(backgroundLevel == 2 || backgroundLevel==3)
            [self schedule: @selector(tick:)];
    }
    return self;
}

-(void)initBackground
{
    winSize = [[CCDirector sharedDirector] winSize];
    switch (backgroundLevel) {
        case GAME_STATE_ONE:
//            bgTop = [CCSprite spriteWithFile:@"space-background-upperlayer.png"];
            bgBottom = [CCSprite spriteWithFile:@"background-v1.png"];
            bgBottom.anchorPoint = ccp(0, 0);
            bgBottom.position = ccp(0, 0);
            
            bgBottom.flipX = true;
            [self addChild:bgBottom z:-1];
            break;
        case GAME_STATE_TWO:
//            bgTop = [CCSprite spriteWithFile:@"space-background-upperlayer.png"];
            bgBottom1 = [CCSprite spriteWithFile:@"level2-background.png"];
            bgBottom2 = [CCSprite spriteWithFile:@"level2-background.png"];
            
            bgBottom1.anchorPoint = ccp(0,0);
            bgBottom1.position = ccp(0,0);
            [self addChild:bgBottom1 z:-3];
            
            bgBottom2.anchorPoint = ccp(0,0);
            bgBottom2.position = ccp(winSize.width, 0);
            bgBottom2.flipX = true;
            [self addChild:bgBottom2 z:-3];

            break;
        case GAME_STATE_THREE:
//            bgTop = [CCSprite spriteWithFile:@"space-background-upperlayer.png"];
            bgBottom1 = [CCSprite spriteWithFile:@"level3-background.png"];
            bgBottom2 = [CCSprite spriteWithFile:@"level3-background.png"];
            
            bgBottom1.anchorPoint = ccp(0,0);
            bgBottom1.position = ccp(0,0);
            [self addChild:bgBottom1 z:-3];
            
            bgBottom2.anchorPoint = ccp(0,0);
            bgBottom2.position = ccp(winSize.width, 0);
            bgBottom2.flipX = true;
            [self addChild:bgBottom2 z:-3];

            break;
            
        default:
            break;
    }
    
/*
    bgTop.position = ccp(0, 0);
    bgTop.anchorPoint = ccp(0, 0);
    [self addChild:bgTop z: 1];

    CGPoint realDest = ccp(-3500, 0);
    CCAction *_bgTopMoveAction = [CCRepeatForever actionWithAction: [CCMoveTo actionWithDuration:BGTOPDURATION position:realDest]];
    _bgTopMoveAction.tag = 1;
    [bgTop runAction:_bgTopMoveAction];
    
    [self schedule:@selector(updateMap:)];
    [self unschedule:@selector(updateMap:)];
    [self schedule:@selector(updateMap:) interval:15.0];
*/
//    [self stopActionByTag:1];
//    [self reverseMap];
    
    
    
    
    
    /*
    bgBottom.anchorPoint = ccp(0, 0);
    bgBottom.position = ccp(0, 0);
    
    bgBottom.flipX = true;
    [self addChild:bgBottom z:-1];
     */
}

- (void)updateMap:(ccTime)dt {
    [self addMap];
}

- (void) addMap {
    bgTop = [CCSprite spriteWithFile:@"space-background-upperlayer.png"];
    [bgTops addObject:bgTop];
    
    //    Create the monster slightly off-screen along the right edge,
    bgTop.position = ccp(2048, 0);
    bgTop.anchorPoint = ccp(0,0);
    [self addChild:bgTop z:-1];
    
    // Create the actions
    CGPoint realDest = ccp(-3500, 0);
    CCMoveTo * actionMove = [CCMoveTo actionWithDuration: BGTOPDURATION position:realDest];
    actionMove.tag = 0;
    [bgTop runAction:actionMove];
    
}

-(void) reverseMap
{
    [self unschedule:@selector(addMap)];
    [self unschedule:@selector(updateMap:)];
    [self stopAllActions];
    
}




-(void)scrollBackground:(ccTime)dt
{
    CGPoint pos1, pos2;
    
    pos1 = bgBottom1.position;
    pos2 = bgBottom2.position;
    pos1.x -= backSpeed;
    pos2.x -= backSpeed;
    if(pos1.x <=-(winSize.width) )
    {
        pos1.x = pos2.x + winSize.width;
    }
    if(pos2.x <=-(winSize.width) )
    {
        pos2.x = pos1.x + winSize.width;
    }
    bgBottom1.position = pos1;
    bgBottom2.position = pos2;
    
}

-(void)tick:(ccTime)dt
{
    [self scrollBackground:dt];
}

-(void)scrollBackBackground:(ccTime)dt
{
    CGPoint pos1, pos2;
    
    pos1 = bgBottom1.position;
    pos2 = bgBottom2.position;
    pos1.x += backSpeed;
    pos2.x += backSpeed;
    if(pos1.x >= winSize.width)
    {
        pos1.x = pos2.x - winSize.width;
    }
    if(pos2.x >= winSize.width)
    {
        pos2.x = pos1.x - winSize.width;
    }
    bgBottom1.position = pos1;
    bgBottom2.position = pos2;
    
}

-(void)tickBack:(ccTime)dt
{
    [self scrollBackBackground:dt];
}

-(void)changeBack
{
    [self unschedule:@selector(tick:)];
    [self schedule: @selector(tickBack:)];
}

@end
