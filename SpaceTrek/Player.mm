//
//  MyCocos2DClass.m
//  SpaceTrek
//
//  Created by Zhen Li on 10/19/13.
//  Copyright 2013 Zhen Li. All rights reserved.
//

#import "Player.h"
#import "GameLayer.h"

@implementation Player

+(Player*) getPlayer{
    return self;
}


-(b2Body*) getBody{
    return playerBody;
}

-(id) init{
    if((self = [super init])){
        type = gameObjectPlayer;
    }
    return self;
}

-(void) initAnimation:(CCSpriteBatchNode *)batchNode{
    NSMutableArray *runAnimFrames = [NSMutableArray array];
    
    for(int i = 1; i <= 2; ++i){
        [runAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceship%d.png", i]]];
    }
    
    playerRunAnimation = [CCAnimation animationWithSpriteFrames:runAnimFrames delay:0.09f];
    playerRunAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: playerRunAnimation] times:2000];
    
    
    [self runAction:playerRunAction];
    [batchNode addChild:(Player*)self];
}

-(void) createBox2dObject:(b2World *)world{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    b2BodyDef playerBodyDef;
    playerBodyDef.type = b2_dynamicBody;
    playerBodyDef.position.Set(self.contentSize.width/2, winSize.height/2);
    playerBodyDef.userData = (__bridge void*) self;
    playerBody = world->CreateBody(&playerBodyDef);
    
    
    
    
    b2Vec2 force = b2Vec2(100, 0);
    playerBody->ApplyLinearImpulse(force, playerBodyDef.position);
    
    b2CircleShape circle;
    circle.m_radius = self.contentSize.height/2;
    
    b2FixtureDef playerShapeDef;
    playerShapeDef.shape = &circle;
    playerShapeDef.density = 1000.0f;
    playerShapeDef.friction = 0.f;
    playerShapeDef.restitution = 1.0f;
    playerShapeDef.filter.categoryBits =  0x1;
    playerShapeDef.filter.maskBits =  0xFFFF;
    
    playerBody->CreateFixture(&playerShapeDef);
}

-(void) crashTransformAction
{
    [self stopAllActions];
    NSMutableArray *crashAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i){
        [crashAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"boom%d.png", i]]];
    }
    crashAnimation = [CCAnimation animationWithSpriteFrames:crashAnimFrames delay:0.09f];
    crashAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: crashAnimation] times:1];
    
    
    NSMutableArray *spacemanAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 1; ++i){
        [spacemanAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceman%d.png", i]]];
    }
    spacemanAnimation = [CCAnimation animationWithSpriteFrames:spacemanAnimFrames delay:0.09f];
    spacemanAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: spacemanAnimation] times:2];
    
    
    NSMutableArray *exlosionAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 2; ++i){
        [exlosionAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"exlosion_bg%d.png", i]]];
    }
    exlosionAnimation = [CCAnimation animationWithSpriteFrames:exlosionAnimFrames delay:0.09f];
    exlosionAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: exlosionAnimation] times:1];
    
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(crashTransformActionFinished:)];
    CCSequence *seq = nil;
    seq = [CCSequence actions:crashAction,spacemanAction,nil];

    [self runAction:[CCSequence actions:seq, actionMoveDone, nil]];
}

-(void) crashTransformActionFinished:(id)sender
{
    CCScene* scene = [[CCDirector sharedDirector] runningScene];
    GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
    [layer resumeSchedulerAndActions];
}
@end
