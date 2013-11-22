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
NSMutableArray * bgTops;
CGSize winSize;

int backgroundLevel = 1;


- (id) initWithLevel:(int)level {
    self = [super init];
    if (self) {
        
//        self.tag=BG_LAYER_TAG;
        
        backgroundLevel = level;
        
        [self initBackground];
        
//        if(level == 2)
//            [self initMoon];
        
//        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void)initBackground
{
    
    switch (backgroundLevel) {
        case GAME_STATE_ONE:
//            bgTop = [CCSprite spriteWithFile:@"space-background-upperlayer.png"];
            bgBottom = [CCSprite spriteWithFile:@"background-v1.png"];
            break;
        case GAME_STATE_TWO:
//            bgTop = [CCSprite spriteWithFile:@"space-background-upperlayer.png"];
            bgBottom = [CCSprite spriteWithFile:@"level2-background.png"];
            break;
        case GAME_STATE_THREE:
//            bgTop = [CCSprite spriteWithFile:@"space-background-upperlayer.png"];
            bgBottom = [CCSprite spriteWithFile:@"level3-background.png"];
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
    
    
    
    bgBottom.anchorPoint = ccp(0, 0);
    bgBottom.position = ccp(0, 0);
    
    bgBottom.flipX = true;
    [self addChild:bgBottom z:-1];
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

@end
