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
        numOfAffordCollsion = 1;
        numOfCollsion = 0;
    }
    return self;
}

-(void) initAnimation:(CCSpriteBatchNode *)batchNode{
    NSMutableArray *runAnimFrames = [NSMutableArray array];
    
    for(int i = 1; i <= 4; ++i){
        [runAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceship_1_%d.png", i]]];
    }
    
    playerRunAnimation = [CCAnimation animationWithSpriteFrames:runAnimFrames delay:0.09f];
    playerRunAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: playerRunAnimation] times:2000];
    
    
    [self runAction:playerRunAction];
    [batchNode addChild:(Player*)self];
}

-(void) createBox2dObject:(b2World *)world{
    
    b2BodyDef playerBodyDef;
    playerBodyDef.type = b2_dynamicBody;
    playerBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    playerBodyDef.userData = self;
    playerBodyDef.userData = (__bridge void*) self;
    playerBody = world->CreateBody(&playerBodyDef);
    playerBody->SetUserData(self);
    
    
    b2Vec2 force = b2Vec2(10, 0.0f);
    playerBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = self.contentSize.height/2/PTM_RATIO;
    
    
    
//    b2PolygonShape polygon;
//    polygon.SetAsBox(self.contentSize.height/4/PTM_RATIO, self.contentSize.width/4/PTM_RATIO);
    
    b2FixtureDef playerShapeDef;
    playerShapeDef.shape = &circle;
//    playerShapeDef.shape = &polygon;
    playerShapeDef.density = 1000.0f;
    playerShapeDef.friction = 0.5f;
    playerShapeDef.restitution = 0.0f;
    playerShapeDef.filter.categoryBits =  0x1;
    playerShapeDef.filter.maskBits =  0x2+0x10;
    
    playerBody->CreateFixture(&playerShapeDef);
    
    
    
}

-(void) crashTransformAction
{
    [self stopAllActions];
    
    
    
    CCScene* scene = [[CCDirector sharedDirector] runningScene];
    GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
    [layer crash];
    /* NSMutableArray *crashAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i){
        [crashAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"boom%d.png", i]]];
    }
    crashAnimation = [CCAnimation animationWithSpriteFrames:crashAnimFrames delay:0.09f];
    crashAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: crashAnimation] times:1];
    */
    
    
    NSMutableArray *spacemanAnimFrames = [NSMutableArray array];
    for(int i = 0; i <= 7; ++i){
        [spacemanAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceman-%d.png", i]]];
    }
    spacemanAnimation = [CCAnimation animationWithSpriteFrames:spacemanAnimFrames delay:0.09f];
    spacemanAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: spacemanAnimation] times:200];
    
    
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(crashTransformActionFinished:)];
    CCSequence *seq = nil;
    seq = [CCSequence actions:crashAction,spacemanAction,nil];
    [self runAction:[CCSequence actions:actionMoveDone, spacemanAction, nil]];
    //[self runAction:[CCSequence actions:seq, actionMoveDone, nil]];
//    [self runAction:[CCSequence actions:actionMoveDone, seq, nil]];
}

-(void) magnetAction
{
    [self stopAllActions];
    /*NSMutableArray *magnet1AnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 1; ++i){
        [magnet1AnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceman_magnet_%d.png", i]]];
    }
    magnet1Animation = [CCAnimation animationWithSpriteFrames:magnet1AnimFrames delay:0.09f];
    magnet1Action = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: magnet1Animation] times:100];
    */
    
    NSMutableArray *magnet2AnimFrames = [NSMutableArray array];
    for(int i = 0; i <= 4; ++i){
        [magnet2AnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceman_magnet_%d.png", i]]];
    }
    magnet2Animation = [CCAnimation animationWithSpriteFrames:magnet2AnimFrames delay:0.1f];
    magnet2Action = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: magnet2Animation] times:30];
    
    
    NSMutableArray *spacemanAnimFrames = [NSMutableArray array];
    for(int i = 0; i <= 7; ++i){
        [spacemanAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceman-%d.png", i]]];
    }
    spacemanAnimation = [CCAnimation animationWithSpriteFrames:spacemanAnimFrames delay:0.09f];
    spacemanAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: spacemanAnimation] times:2000];
    
    
    //id seq = [CCSequence actions:magnet1Action,magnet2Action,nil];
    [self runAction:[CCSequence actions:magnet2Action, spacemanAction, nil]];
    
    //[self runAction:[CCSequence actions:magnet2Action, spacemanAction, nil]];
}

-(void) invincible
{
    [self stopAllActions];
    NSMutableArray *invincibleAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 2; ++i){
        [invincibleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"invincible%d.png", i]]];
    }
    invincibleAnimation = [CCAnimation animationWithSpriteFrames:invincibleAnimFrames delay:0.1f];
    invincibleAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: invincibleAnimation] times:75];
    
    NSMutableArray *runAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 2; ++i){
        [runAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceship%d.png", i]]];
    }
    
    playerRunAnimation = [CCAnimation animationWithSpriteFrames:runAnimFrames delay:0.09f];
    playerRunAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: playerRunAnimation] times:2000];
    
    
    //id seq = [CCSequence actions:magnet1Action,magnet2Action,nil];
    
    [self runAction:[CCSequence actions:invincibleAction, playerRunAction, nil]];
}

-(void) fly:(int) flyType
{
    [self stopAllActions];
    NSMutableArray *runAnimFrames;
    
    if(flyType == -1){
        runAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 2; ++i){
            [runAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"spaceship_2_%d.png", i]]];
        }
    }
    else if(flyType == 0){
        runAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 4; ++i){
            [runAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"spaceship_1_%d.png", i]]];
        }
    }
    else{
        runAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 2; ++i){
            [runAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"spaceship_3_%d.png", i]]];
        }
    }
    playerRunAnimation = [CCAnimation animationWithSpriteFrames:runAnimFrames delay:0.09f];
    playerRunAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: playerRunAnimation] times:2000];
    
    [self runAction:playerRunAction];
}

-(void) noshield
{
    [self stopAllActions];
    
    NSMutableArray *runAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 2; ++i){
        [runAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceship%d.png", i]]];
    }
    
    playerRunAnimation = [CCAnimation animationWithSpriteFrames:runAnimFrames delay:0.09f];
    playerRunAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: playerRunAnimation] times:2000];
    
    [self runAction:playerRunAction];
}

-(void) shield1
{
    [self stopAllActions];
    NSMutableArray *shield1AnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 2; ++i){
        [shield1AnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceship-shield-1-%d.png", i]]];
    }
    shield1Animation = [CCAnimation animationWithSpriteFrames:shield1AnimFrames delay:0.1f];
    shield1Action = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: shield1Animation] times:2000];
    
    [self runAction:shield1Action];
}

-(void) shield2
{
    [self stopAllActions];
    NSMutableArray *shield2AnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 2; ++i){
        [shield2AnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"spaceship-shield-2-%d.png", i]]];
    }
    shield2Animation = [CCAnimation animationWithSpriteFrames:shield2AnimFrames delay:0.1f];
    shield2Action = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: shield2Animation] times:2000];
    
    [self runAction:shield2Action];
}

-(void) crashTransformActionFinished:(id)sender
{
    CCScene* scene = [[CCDirector sharedDirector] runningScene];
    GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
    [layer resumeSchedulerAndActions];
}

- (void) adjust {
    if(playerBody->GetLinearVelocity().x<8)
    {
        [self accelerate];
    }
    else if(playerBody->GetLinearVelocity().x>10)
    {
        [self decelerate];
    }
}

- (void) accelerate {
    b2Vec2 impulse = b2Vec2(8, playerBody->GetLinearVelocity().y);
    playerBody->SetLinearVelocity(impulse);
}

- (void) decelerate {
    b2Vec2 impulse = b2Vec2(10,  playerBody->GetLinearVelocity().y);
    playerBody->SetLinearVelocity(impulse);
}

-(void) changePlayer
{
    
}

@end
