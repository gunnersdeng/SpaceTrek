//
//  GameLayer.m
//  SpaceTrek
//
//  Created by huang yongke on 13-10-2.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "GameLayer.h"
#import "Constants.h"
#import "GameScene.h"
#import "HUDLayer.h"
#import "GameOverScene.h"

@implementation GameLayer
@synthesize distance;
@synthesize score;
@synthesize scale;
@synthesize allBatchNode;

bool isReach;
bool isPlayerMoveBack;
bool isPlayerCollect;
bool isStationMoveBack;
bool isPlayerBacktoStation;
bool isCollect;
bool isbullet;
bool isCollectCircle;
bool isSetPlayerVelocity;
bool beforeExplode;
bool during_shield;
CCParticleSystemQuad *particle;
CCParticleSystemQuad *particleMagnet;

-(id) init{
    self = [super init];
    if(self){
        
        getLevel = 1;
        during_invincible = false;
        during_magnet = false;
        during_shield = false;
        hitStop = false;
        distanceLevel = 1;
        milestoneStatus = 0;
        
        spaceshipState = 0;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        collectedTreasure.clear();
        
        treasureSpeedMultiplier = 1;
        gamePart1 = true;
        gamePart2 = false;
        isPlayerMoveBack = false;
        isPlayerCollect = false;
        isStationMoveBack = false;
        isPlayerBacktoStation = false;
        isCollect = false;
        isbullet = false;
        isCollectCircle = false;
        isSetPlayerVelocity = false;
        beforeExplode = true;
        
        self.tag = GAME_LAYER_TAG;
        
        
        self.distance = 0;
        self.power = 0;
        self.score = 0;
        collision = false;
        
        
        [self preLoadSoundFiles];
        [self setupPhysicsWorld];
        [self initBatchNode];
        
        
        
        
        [self addBeginStone: winSize.width/3*2 yy:winSize.height/2];
        [self addBeginStone: winSize.width/5*4 yy:winSize.height/4];
        
        _treasures = [[NSMutableArray alloc] init];
        
        player = [Player spriteWithSpriteFrameName:@"spaceship_1_1.png"];
        [player setType:(gameObjectPlayer)];
        [player initAnimation:allBatchNode];

        
        player.position = ccp(0, winSize.height/2);
        player.tag = PLAYER_TAG;
        
        [player createBox2dObject:world];
        
        [self addSpaceStation];
        
        isReach=false;
        
        [self schedule:@selector(treasureMovementLogic:)];
        
        hudLayer = nil;
        [self schedule:@selector(update:)];
        
//        [self addObstacle];
        
        star1Opa = 0;
        star1 = [CCSprite spriteWithFile: [NSString stringWithFormat:@"tinystar.png"]];
        star1.anchorPoint = ccp(0.5f, 0.5f);
        [star1 setPosition:ccp(winSize.width/3, winSize.height/2)];
        star1.scale = 2;
        [self addChild:star1 z:-1];
        
    }
    return self;
}

-(int)Level
{
    return getLevel;
}


- (void)preLoadSoundFiles
{
    //[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"PlayMode_Music_New.mp3"];
    //[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"PlayMode_Music_back.mp3"];
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"PlayMode_Music_New.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"PlayMode_Music_back.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"level1Background.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"CrashSong.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"LaunchSong.mp3"];

    [[SimpleAudioEngine sharedEngine] preloadEffect:@"trigger.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"treasureCrash.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"collectobstacle.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"collecttreasure.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"magnet.mp3"];
    
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"level1Background.mp3"];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"level1Background.mp3"];
    
    //firstBackgroundMusic = [[SimpleAudioEngine sharedEngine]playEffect:@"level1Background.mp3"];
    [[SimpleAudioEngine sharedEngine]playEffect:@"LaunchSong.mp3"];

}

- (void)ChangeGoBackSound
{
    //[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"PlayMode_Music_back.mp3"];
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"PlayMode_Music_back.mp3"];
    //[[SimpleAudioEngine sharedEngine] stopEffect:firstBackgroundMusic];
    //secondBackgroundMusic = [[SimpleAudioEngine sharedEngine] playEffect:@"PlayMode_Music_back.mp3"];
    //backgroundAmbience.backgroundMusicVolume = 1.0f;
}

-(void) setupPhysicsWorld {
    
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    bool doSleep = true;
    world = new b2World(gravity);
    world->SetAllowSleeping(doSleep);
    world->SetContinuousPhysics(TRUE);
    
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
    
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0);
    _groundBody = world->CreateBody(&groundBodyDef);
  
    b2EdgeShape groundBox;
    b2FixtureDef groundBoxDef;
    groundBoxDef.shape =&groundBox;
    
    groundBox.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
    _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);

    
    groundBox.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
    _topFixture = _groundBody->CreateFixture(&groundBoxDef);
    

}

-(void) playerMoveFinished: (id)sender{
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED, 0);
    spaceStationBody->SetLinearVelocity(force);
    [self schedule:@selector(gameLogic:) interval:1.0];
    [self schedule:@selector(gameStoneLogic:) interval:3.0];
}
-(void) treasureMovementLogic:(ccTime)dt
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(dt, velocityIterations, positionIterations);
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (CCSprite *)b->GetUserData();
            if(treasureData.tag == BULLET_TAG)
            {
                if(treasureData.position.x>winSize.width)
                {
                    treasureData.tag = BULLET_DESTROY_TAG;
                }
                
            }
            if(treasureData.tag == TREASURE_PROPERTY_TYPE_1_TAG)
            {
                [self removeChild:treasureData cleanup:YES];
                world->DestroyBody(b);
                continue;
            }
            if(treasureData.tag == TREASURE_BULLET_TAG)
            {
                [self removeChild:treasureData cleanup:YES];
                world->DestroyBody(b);
                continue;
            }
            if(treasureData.tag == TREASURE_DESTROY_BYBULLET_TAG)
            {
                [self removeChild:treasureData cleanup:YES];
                world->DestroyBody(b);
                continue;
            }
            if(treasureData.tag == BULLET_DESTROY_TAG)
            {
                [self removeChild:treasureData cleanup:YES];
                world->DestroyBody(b);
                continue;
            }
            if(treasureData.tag == TREASURE_DESTROY_TAG)
            {
                //[self removeChild:treasureData cleanup:YES];
                //world->DestroyBody(b);
                if ( treasureData.visible ){
                    treasureData.visible = false;
                    if ( !gamePart1 ){
                        collectedTreasure.push_back(b);
                        [[SimpleAudioEngine sharedEngine]playEffect:@"CollectTreasure.wav"];
                    }
                    if( gamePart1 && isSetPlayerVelocity)
                    {
                        [self setPlayerVelocity];
                    }
                    
                    if ( gamePart2 || gamePart1 ){
                        player->playerBody->SetLinearVelocity(b2Vec2(0.0f,0.0f));
                    }
                    continue;
                }
            }
            if(treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-winSize.width/5)<=10 && !isReach)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                isReach = true;
                [self schedule:@selector(playerMoveFinished:)];
                self.isAccelerometerEnabled=YES;
                self.isTouchEnabled = YES;
                
            }
            if(treasureData!=NULL && treasureData.tag==SPACESTATION_TAG && fabs(treasureData.position.x-winSize.width/2)<=100 && isStationMoveBack)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                isStationMoveBack = false;
                
                isPlayerBacktoStation = true;
                b2Vec2 forcePlayer = b2Vec2(-TRAVEL_SPEED, 0);
                player->playerBody->SetLinearVelocity(forcePlayer);
                gamePart2 = false;
                
            }
            if(treasureData!=NULL && treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-winSize.width/5*4)<=50&&isPlayerCollect)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                [self treasureBack];
                isPlayerCollect=false;
                isSetPlayerVelocity = false;
                
                gamePart2 = true;

            }
            if(treasureData!=NULL && treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-treasureData.contentSize.width)<=10 && isPlayerBacktoStation)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                isPlayerBacktoStation = false;
                [self collectTreasure];
            }

            
            treasureData.position = ccp(b->GetPosition().x*PTM_RATIO,
                                        b->GetPosition().y*PTM_RATIO);
            treasureData.rotation = 0 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
        }
    }
}

-(void) setVolecity : (int)judge
{
    if(judge==0)
    {
        hitStop = true;
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                GameObject* treasure = (GameObject*) b->GetUserData();
                [treasure setV_X:b->GetLinearVelocity().x];
                [treasure setV_Y:b->GetLinearVelocity().y];
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
            }
        }
    }
    else{
        hitStop = false;
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                GameObject* treasure = (GameObject*) b->GetUserData();
                b2Vec2 force = b2Vec2(treasure.v_X, treasure.v_Y);
                b->SetLinearVelocity(force);
            }
        }
        
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    
    if(isbullet)
    {
        if ( gamePart1 ){
            [[SimpleAudioEngine sharedEngine]playEffect:@"trigger.mp3"];
            [self addBullet];
        }
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    b2Vec2 position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
   
    
    if(isCollectCircle)
    {
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                CCSprite *treasureData = (CCSprite *)b->GetUserData();
                if(treasureData.tag!=SPACESTATION_TAG && (sqrt(sqr(b->GetPosition().x-position.x)+sqr(b->GetPosition().y-position.y))<3)&&isCollect)
                {
                    CCLOG(@"here 0");
                    
                    
                    CCParticleSystem *ps = [CCParticleExplosion node];
                    [self addChild:ps z:12];
                    ps.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars.png"];
                    
                    CGPoint position = ccp(b->GetPosition().x*PTM_RATIO, b->GetPosition().y*PTM_RATIO);
                    
                    ps.position = position;
                    ps.blendAdditive = YES;
                    ps.life = 0.25f;
                    ps.lifeVar = 0.25f;
                    ps.totalParticles = 120.0f;
                    ps.autoRemoveOnFinish = YES;
                    
                    /* Draw a circle by plist, one second disappear
                    CCSprite* circle= [CCSprite spriteWithFile:@"StatusBar.png"];
                    circle.position = ccp(location.x, location.y);
                    [self addChild:circle z:2 tag:CIRCLE_TAG];
                    */
                    /*
                    CCSprite* circle= [CCSprite spriteWithSpriteFrameName:@"TreasureBoom_11.png"];
                    circle.position = ccp(location.x, location.y);
                    [self addChild:circle z:2 tag:CIRCLE_TAG];
                    
                    
                    CCFadeOut *fade = [CCFadeOut actionWithDuration:1];  //this will make it fade
                    CCCallFuncN *remove = [CCCallFuncN actionWithTarget:self selector:@selector(removeSprite:)];
                    CCSequence *seq = [CCSequence actions: fade, remove, nil];
                    [circle runAction:seq];
                    */
                    
//                                        NSMutableArray *collectAnimFrames = [NSMutableArray array];
//                                        for(int i = 1; i <= 3; ++i){
//                                                [collectAnimFrames addObject:
//                                                                           [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
//                                                                                                       [NSString stringWithFormat:@"TreasureBoom_1%d.png", i]]];
//                                            }
//                                        CCAnimation *collectAnimation = [CCAnimation animationWithSpriteFrames:collectAnimFrames delay:0.25f];
//                                        CCFiniteTimeAction *collectAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: collectAnimation] times:1];
//                                        id actHide = [CCHide action];
//                                        id seq = [CCSequence actions:collectAction, actHide,nil];
//                    
//                                        [circle runAction:seq];
                    
                    
                    
                    GameObject* treasureObj = (__bridge GameObject *)treasureData;
                    
                    if ( treasureObj.score<0 ){
                        [[SimpleAudioEngine sharedEngine]playEffect:@"collectobstacle.mp3"];
                    }else{
                        [[SimpleAudioEngine sharedEngine]playEffect:@"collecttreasure.mp3"];
                    }
                    
                    self.score += treasureObj.score*10;
                    [hudLayer updateDistanceCounter:score/10];
                    
                    treasureData.tag = TREASURE_COLLECT_TAG;
                    
                    treasureNumber--;
                    if ( treasureNumber==0 ){
                        [self unscheduleAllSelectors];
                        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:  [GameOverScene sceneWithLevel:GAME_STATE_ONE Score:self.score Distance:distance]]];
                    }
                }
            }
        }
    }
    else
    {
        
        
        CCParticleSystem *ps = [CCParticleExplosion node];
        [self addChild:ps z:12];
        ps.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars.png"];
        ps.position = location;
        ps.blendAdditive = YES;
        ps.life = 0.25f;
        ps.lifeVar = 0.25f;
        ps.totalParticles = 120.0f;
        ps.autoRemoveOnFinish = YES;
        
        
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                b2Fixture *f = b->GetFixtureList();
                CCSprite *treasureData = (CCSprite *)b->GetUserData();
                if(treasureData.tag!=SPACESTATION_TAG && f->TestPoint(position)&&isCollect)
                {
                    CCLOG(@"here 0");
                    GameObject* treasureObj = (__bridge GameObject *)treasureData;
                    
                    if ( treasureObj.score<0 ){
                        [[SimpleAudioEngine sharedEngine]playEffect:@"collectobstacle.mp3"];
                    }else{
                        [[SimpleAudioEngine sharedEngine]playEffect:@"collecttreasure.mp3"];
                    }
                    
                    self.score += treasureObj.score*10;
                    [hudLayer updateDistanceCounter:score/10];
                    
                    treasureData.tag = TREASURE_COLLECT_TAG;
                
                    treasureNumber--;
                    if ( treasureNumber==0 ){
                        [self unscheduleAllSelectors];
                        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:  [GameOverScene sceneWithLevel:GAME_STATE_ONE Score:self.score Distance:distance]]];
                    }
                }
            }
        }
    }
}

-(void) ccTouchesMoved:(UITouch *)touches withEvent:(UIEvent *)event
{
    //    CGPoint touchLocation = [touch locationInView: [touch view]];
    //    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    //    touchLocation = [self convertToNodeSpace:touchLocation];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    b2Vec2 position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    CCParticleSystem *ps = [CCParticleExplosion node];
    [self addChild:ps z:12];
    ps.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars.png"];
    ps.position = location;
    ps.blendAdditive = YES;
    ps.life = 0.25f;
    ps.lifeVar = 0.25f;
    ps.totalParticles = 120.0f;
    ps.autoRemoveOnFinish = YES;
}

-(void) ccTouchesEnded:(UITouch *)touches withEvent:(UIEvent *)event {
    //    CGPoint touchLocation = [touch locationInView: [touch view]];
    //    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    //    touchLocation = [self convertToNodeSpace:touchLocation];
    
    //endLocation = touchLocation;
}

-(void) removeSprite:(id)sender
{
    [self removeChild:sender cleanup:YES];
}

-(void) collectTreasure
{
    
    [self unscheduleAllSelectors];

    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (CCSprite *)b->GetUserData();
            
            if(treasureData.tag == STONE_TAG)
            {
                [self removeChild:treasureData cleanup:YES];
                world->DestroyBody(b);
                continue;
            }
        }
    }
    
    
    b2Vec2 playPosition = player->playerBody->GetPosition();
    treasureNumber = collectedTreasure.size();
    
    for (int i=0; i<collectedTreasure.size(); i++)
    {
        b2Body *b = collectedTreasure[i];
        CCSprite *treasureData = (CCSprite *)b->GetUserData();
        
        
        b->SetTransform(b2Vec2(playPosition.x, playPosition.y), 0.0);
//        treasureData.position =  ccp(playPosition.x*PTM_RATIO,playPosition.y*PTM_RATIO);
        treasureData.visible = true;
        b->SetLinearVelocity(b2Vec2(rand()%15+5, rand()%10-5));
        
    }
    isCollect = true;
    world->DestroyBody(player->playerBody);
    [self schedule:@selector(treasureCollectMovementLogic:)];
    world->SetGravity(b2Vec2(-6.0f, 0.0f));
    
   [self schedule:@selector(JumpToGameOverScene:) interval:6.0f];
}

-(void) treasureCollectMovementLogic:(ccTime)dt
{

    int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(dt, velocityIterations, positionIterations);
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (CCSprite *)b->GetUserData();
            
            if(treasureData.tag == TREASURE_COLLECT_TAG || treasureData.tag == TREASURE_TAG)
            {
                [self removeChild:treasureData cleanup:YES];
                world->DestroyBody(b);
                continue;
            }
            if(treasureData.tag != SPACESTATION_TAG)
            {
                treasureData.position = ccp(b->GetPosition().x*PTM_RATIO,
                                        b->GetPosition().y*PTM_RATIO);
                treasureData.rotation = 0 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            
        }
    }
}



-(void)JumpToGameOverScene:(ccTime)delta
{
    [self unscheduleAllSelectors];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:  [GameOverScene sceneWithLevel:GAME_STATE_ONE Score:self.score Distance:distance]]];
}

-(void) playerBack
{
    [self removeChild:redLine];
    isPlayerMoveBack = true;
    isStationMoveBack = true;
    gamePart1 = false;
    beforeExplode = false;
}
-(void) treasureBack
{
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (CCSprite *)b->GetUserData();
            
            if(treasureData.tag==TREASURE_TAG)
             {
             b2Vec2 force = b2Vec2(-b->GetLinearVelocity().x, -b->GetLinearVelocity().y);
             b->SetLinearVelocity(force);
             }
             
            if(treasureData.tag==SPACESTATION_TAG)
            {
                b2Vec2 force = b2Vec2(TRAVEL_SPEED, 0);
                spaceStationBody->SetLinearVelocity(force);
            }
            if(treasureData.tag==STONE_TAG)
            {
                b2Vec2 force = b2Vec2(-b->GetLinearVelocity().x, -b->GetLinearVelocity().y);
                b->SetLinearVelocity(force);
            }
            if(treasureData.tag==OBSTACLE_TAG)
            {
                b2Vec2 force = b2Vec2(-b->GetLinearVelocity().x, -b->GetLinearVelocity().y);
                b->SetLinearVelocity(force);
            }
        }
    }
    
}



-(void)gameLogic:(ccTime)dt {
    for (int i=arc4random()%2; i>=0; i--)
        [self addTreasure];
}
-(void) gameStoneLogic:(ccTime)dt
{
    [self addStone];
}

int GetRandom(int lowerbound, int upperbound){
    return lowerbound + arc4random() % ( upperbound - lowerbound + 1 );
}

int GetRandomGaussian( int lowerbound, int upperbound ){
    double u1 = (double)arc4random() / UINT32_MAX;
    double u2 = (double)arc4random() / UINT32_MAX;
    double f1 = sqrt(-2 * log(u1));
    double f2 = 2 * M_PI * u2;
    double g1 = f1 * cos(f2);
    g1 = (g1+1)/2;
    return lowerbound + g1 * ( upperbound - lowerbound + 1 );
}

-(void)addTreasure
{
    GameObject *treasure;
    treasure = [[GameObject alloc] init];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    
    if(distance>=0 && distance<=400)
    {
        int treasureIndex = arc4random()%2;
        if(treasureIndex==0)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_1.png"]];
            treasure.scale = 1.5;
            [treasure setScore:1];
        }
        else
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_4.png"]];
            treasure.scale = 1.5;
            [treasure setScore:1];
        }
    }
    else if(distance>=400 && distance<=1200)
    {
        int treasureIndex = arc4random()%5;
        if(treasureIndex == 0)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_1.png"]];
            treasure.scale = 1.5;
            [treasure setScore:1];
        }
        if(treasureIndex == 1)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_4.png"]];
            treasure.scale = 1.5;
            [treasure setScore:1];
        }
        if(treasureIndex == 2)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_3.png"]];
            treasure.scale = 1.5;
            [treasure setScore:5];
        }
        if(treasureIndex == 3)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_7.png"]];
            treasure.scale = 1.5;
            [treasure setScore:5];
        }
        if(treasureIndex == 4)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_8.png"]];
            treasure.scale = 0.5;
            [treasure setScore:-5];
        }
    }
    else if(distance>=1200 && distance<=2400)
    {
        int treasureIndex = arc4random()%5;
        if(treasureIndex == 0)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_3.png"]];
            treasure.scale = 1.5;
            [treasure setScore:5];
        }
        if(treasureIndex == 1)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_7.png"]];
            treasure.scale = 1.5;
            [treasure setScore:5];
        }
        if(treasureIndex == 2)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_5.png"]];
            treasure.scale = 1.5;
            [treasure setScore:10];
        }
        if(treasureIndex == 3)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_6.png"]];
            treasure.scale = 1.5;
            [treasure setScore:10];
        }
        if(treasureIndex == 4)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_8.png"]];
            treasure.scale = 0.5;
            [treasure setScore:-5];
        }
    }
    else if(distance>=2400)
    {
        int treasureIndex = arc4random()%6;
        if(treasureIndex == 0)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_3.png"]];
            treasure.scale = 1.5;
            [treasure setScore:5];
        }
        if(treasureIndex == 1)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_7.png"]];
            treasure.scale = 1.5;
            [treasure setScore:5];
        }
        if(treasureIndex == 2)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_5.png"]];
            treasure.scale = 1.5;
            [treasure setScore:10];
        }
        if(treasureIndex == 3)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_6.png"]];
            treasure.scale = 1.5;
            [treasure setScore:10];
        }
        if(treasureIndex == 4)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_8.png"]];
            treasure.scale = 0.5;
            [treasure setScore:-5];
        }
        if(treasureIndex == 5)
        {
            treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_2.png"]];
            treasure.scale = 1.5;
            [treasure setScore:15];
        }
    }
    
    /*
    treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_%d.png", treasureIndex] ];
    if ( treasureIndex == 1 ){
        treasure.scale = 2;
        [treasure setScore:10];
    }else
    if ( treasureIndex == 8 ){
        treasure.scale = 0.5;
        [treasure setScore:-10];
    }else{
        treasure.scale = 1.5;
        [treasure setScore:10];
    }
    */
    
    
    if ( !hitStop ){
    
    treasure.tag = TREASURE_TAG;
    [treasure setType:gameObjectTreasure1];
    int treasureStartY = GetRandom( treasure.contentSize.height/2, winSize.height - treasure.contentSize.height/2 );
    int treasureDestinationY = GetRandomGaussian( treasureStartY-winSize.height, treasureStartY+winSize.height );
    
    treasure.position = ccp(winSize.width - treasure.contentSize.width/2, treasureStartY);
    
        [self addChild:treasure];
    
    
    b2BodyDef treasureBodyDef;
    treasureBodyDef.type = b2_dynamicBody;
    treasureBodyDef.position.Set(treasure.position.x/PTM_RATIO, treasure.position.y/PTM_RATIO);
    treasureBodyDef.userData = treasure;
    
    
    
    
    treasureBodyDef.userData = (__bridge_retained void*) treasure;
    
    b2Body* treasureBody = world->CreateBody(&treasureBodyDef);
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED*treasureSpeedMultiplier, (treasureDestinationY-treasureStartY)/(winSize.width/TRAVEL_SPEED)*treasureSpeedMultiplier);
    treasureBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = treasure.contentSize.width/2/PTM_RATIO;
    
    b2FixtureDef treasureShapeDef;
    treasureShapeDef.shape = &circle;
    treasureShapeDef.density = 3.0f;
    treasureShapeDef.friction = 0.0f;
    treasureShapeDef.restitution = 1.0f;
    treasureShapeDef.filter.categoryBits = 0x2;
    treasureShapeDef.filter.maskBits = 0xFFFF-0x2;
   
    treasureBody->CreateFixture(&treasureShapeDef);
    
    }
}

-(void)addRowTreasure:(int)num index:(int)treasureIndex location:(int)loc
{
    
    if ( hitStop ) return;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    
    for(int i=0; i<num; i++)
    {
        GameObject *treasure;
        treasure = [[GameObject alloc] init];
        treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_%d.png", treasureIndex] ];
        if ( treasureIndex == 1 ){
            treasure.scale = 2;
            [treasure setScore:10];
        }else
            if ( treasureIndex == 8 ){
                treasure.scale = 0.5;
                [treasure setScore:-10];
            }else{
                treasure.scale = 1.5;
                [treasure setScore:10];
            }
        treasure.tag = TREASURE_TAG;
        [treasure setType:gameObjectTreasure1];
        
        if(loc>0)
            treasure.position = ccp(winSize.width - treasure.contentSize.width/2, loc-treasure.contentSize.height*(i+1));
        else
            treasure.position = ccp(winSize.width - treasure.contentSize.width/2, loc+treasure.contentSize.height*(i+1));
        
        [self addChild:treasure];
        
        b2BodyDef treasureBodyDef;
        treasureBodyDef.type = b2_dynamicBody;
        treasureBodyDef.position.Set(treasure.position.x/PTM_RATIO, treasure.position.y/PTM_RATIO);
        treasureBodyDef.userData = treasure;
        
        
        
        
        treasureBodyDef.userData = (__bridge_retained void*) treasure;
        
        b2Body* treasureBody = world->CreateBody(&treasureBodyDef);
        
        b2Vec2 force = b2Vec2(-TRAVEL_SPEED*treasureSpeedMultiplier, 0);
        treasureBody->SetLinearVelocity(force);
        
        b2CircleShape circle;
        circle.m_radius = treasure.contentSize.width/2/PTM_RATIO;
        
        b2FixtureDef treasureShapeDef;
        treasureShapeDef.shape = &circle;
        treasureShapeDef.density = 3.0f;
        treasureShapeDef.friction = 0.0f;
        treasureShapeDef.restitution = 1.0f;
        treasureShapeDef.filter.categoryBits = 0x2;
        treasureShapeDef.filter.maskBits = 0xFFFF-0x2;
        
        treasureBody->CreateFixture(&treasureShapeDef);

    }
    
    
    
}

-(void)addStone
{
    GameObject *stone;
    stone = [[GameObject alloc] init];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int stoneIndex = arc4random()%6+1;
    stone = [GameObject spriteWithFile: [NSString stringWithFormat:@"Stone_type_%d.png", stoneIndex] ];
    
    stone.tag = STONE_TAG;
    [stone setType:gameObjectStone];
    int stoneStartY = GetRandom(-30, winSize.height - stone.contentSize.height/2 );
    
    stone.position = ccp(winSize.width+stone.contentSize.width, stoneStartY);
    
    [self addChild:stone z:-1];
    
    b2BodyDef stoneBodyDef;
    stoneBodyDef.type = b2_dynamicBody;
    stoneBodyDef.position.Set(stone.position.x/PTM_RATIO, stone.position.y/PTM_RATIO);
    stoneBodyDef.userData = stone;
    
    stoneBodyDef.userData = (__bridge_retained void*) stone;
    
    b2Body* stoneBody = world->CreateBody(&stoneBodyDef);
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED/5, 0);
    //    treasureBody->ApplyLinearImpulse(force, treasureBodyDef.position);
    stoneBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = stone.contentSize.width/2/PTM_RATIO;
    
    b2FixtureDef stoneShapeDef;
    stoneShapeDef.shape = &circle;
    stoneShapeDef.density = 3.0f;
    stoneShapeDef.friction = 0.2f;
    stoneShapeDef.restitution = 1.0f;
    stoneShapeDef.filter.categoryBits = 0x5;
    stoneShapeDef.filter.maskBits = 0x0;
    
    stoneBody->CreateFixture(&stoneShapeDef);
}

-(void) addBeginStone:(int) x yy:(int) y
{
    GameObject *stone;
    stone = [[GameObject alloc] init];
    
    stone = [GameObject spriteWithFile: [NSString stringWithFormat:@"Stone_type_2.png"]];
    
    
    stone.tag = STONE_TAG;
    [stone setType:gameObjectStone];
    
    stone.position = ccp(x, y);
    
    [self addChild:stone z:-1];
    
    b2BodyDef stoneBodyDef;
    stoneBodyDef.type = b2_dynamicBody;
    stoneBodyDef.position.Set(stone.position.x/PTM_RATIO, stone.position.y/PTM_RATIO);
    stoneBodyDef.userData = stone;
    
    
    
    
    stoneBodyDef.userData = (__bridge_retained void*) stone;
    
    b2Body* stoneBody = world->CreateBody(&stoneBodyDef);
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED/5, 0);
    stoneBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = stone.contentSize.width/2/PTM_RATIO;
    
    b2FixtureDef stoneShapeDef;
    stoneShapeDef.shape = &circle;
    stoneShapeDef.density = 3.0f;
    stoneShapeDef.friction = 0.2f;
    stoneShapeDef.restitution = 1.0f;
    stoneShapeDef.filter.categoryBits = 0x5;
    stoneShapeDef.filter.maskBits = 0x0;
    
    stoneBody->CreateFixture(&stoneShapeDef);
}

-(void)treasureMoveFinished:(id)sender {
    
    CCSprite *sprite = (CCSprite *)sender;
    if (sprite.tag ==1)
    {
        [_treasures removeObject:sprite];
    }
    
    [self removeChild:sprite cleanup:YES];
}

-(void)addSpaceStation
{
    spaceStation = [[GameObject alloc] init];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    spaceStation = [GameObject spriteWithFile:@"runway.png"];
    spaceStation.scale = 1.5;
    
    spaceStation.tag = SPACESTATION_TAG;
    [spaceStation setType:gameObjectSpaceStation];
    
    
    spaceStation.position = ccp(50, winSize.height/2);
    
    [self addChild:spaceStation];
    
    b2BodyDef spaceStationBodyDef;
    spaceStationBodyDef.type = b2_dynamicBody;
    spaceStationBodyDef.position.Set(spaceStation.position.x/PTM_RATIO, spaceStation.position.y/PTM_RATIO);
    spaceStationBodyDef.userData = spaceStation;
    
    spaceStationBodyDef.userData = (__bridge_retained void*) spaceStation;
    
    spaceStationBody = world->CreateBody(&spaceStationBodyDef);
    
    
    b2CircleShape circle;
    circle.m_radius = spaceStation.contentSize.width/2/PTM_RATIO;
    
    b2FixtureDef spaceStationShapeDef;
    spaceStationShapeDef.shape = &circle;
    spaceStationShapeDef.density = 100.0f;
    spaceStationShapeDef.friction = 0.f;
    spaceStationShapeDef.restitution = 0.0f;
    spaceStationShapeDef.filter.categoryBits = 0x3;
    spaceStationShapeDef.filter.maskBits = 0;
    
    spaceStationBody->CreateFixture(&spaceStationShapeDef);
    
    
}

-(void)addFallingStone:(int)x loc:(int)y
{
    GameObject *fallingStone;
    fallingStone = [[GameObject alloc] init];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    fallingStone = [GameObject spriteWithSpriteFrameName:@"obstacle_1.png"];
    
    //    backhole.tag = TREASURE_TAG;
    [fallingStone setType:gameObjectFallingStone];
    
    
    fallingStone.position = ccp(x,y);
    fallingStone.scale = 1.5;
    
    [self addChild:fallingStone z:-1];
    
    NSMutableArray *collectAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 15; ++i){
        [collectAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"obstacle_%d.png", i]]];
    }
    CCAnimation *collectAnimation = [CCAnimation animationWithSpriteFrames:collectAnimFrames delay:0.1f];
    CCFiniteTimeAction *obstacleAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation: collectAnimation] times:1000];
    
    [fallingStone runAction:obstacleAction];
    
    b2BodyDef fallingStoneBodyDef;
    fallingStoneBodyDef.type = b2_dynamicBody;
    fallingStoneBodyDef.position.Set(fallingStone.position.x/PTM_RATIO, fallingStone.position.y/PTM_RATIO);
    fallingStoneBodyDef.userData = fallingStone;
    
    
    
    
    fallingStoneBodyDef.userData = (__bridge_retained void*) fallingStone;
    
    b2Body* fallingStoneBody = world->CreateBody(&fallingStoneBodyDef);
    
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED*5, 0);
    fallingStoneBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = fallingStone.contentSize.width/2/PTM_RATIO;
    
    b2FixtureDef fallingStoneShapeDef;
    fallingStoneShapeDef.shape = &circle;
    fallingStoneShapeDef.density = 3.0f;
    fallingStoneShapeDef.friction = 0.0f;
    fallingStoneShapeDef.restitution = 1.0f;
    fallingStoneShapeDef.filter.categoryBits = 0x5;
    fallingStoneShapeDef.filter.maskBits = 0xFFFF-0x2-0x3-0x4-0x5;
    
    fallingStoneBody->CreateFixture(&fallingStoneShapeDef);
    
    
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    shipSpeedY = -acceleration.x * 50;
    
}
-(void)updateShip{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float maxY = winSize.height - player.contentSize.height/2;
    float minY = player.contentSize.height/2;
    float newY = player.position.y + shipSpeedY;
    newY = MIN(MAX(newY, minY), maxY);
    
    if(isPlayerMoveBack)
    {
        [self pauseSchedulerAndActions];
        [player crashTransformAction];
        
        b2Vec2 force = b2Vec2(TRAVEL_SPEED, 0);
        player->playerBody->SetLinearVelocity(force);
        
        isSetPlayerVelocity = true;
        
        [self unschedule:@selector(playerMoveFinished:)];
        [self unschedule:@selector(gameLogic:)];
        [self unschedule:@selector(gameStoneLogic:)];
        [self unschedule:@selector(addTreasure:)];
        
        isPlayerMoveBack = false;
        isPlayerCollect = true;
    }
    else
    {
        b2Vec2 position1(player.position.x/PTM_RATIO, newY/PTM_RATIO);
    
        if(beforeExplode)
        {
            int current;
            if(newY>player.position.y+5)
            {
                current = 1;
            }
            else if(newY<player.position.y-5)
            {
                current = -1;
            }
            else
            {
                current = 0;
            }
            
            if ( current != spaceshipState ){
                [player fly:current];
                spaceshipState = current;
            }

        }
        
        player->playerBody->SetTransform(position1, 0.0);
        
        [hudLayer setShadowPosition:player.position.x yy:newY];
        
        if(during_invincible){
            //CGPoint location = ccp(player.position.x+player.contentSize.height/2, player.position.y);
            particle.positionType = kCCPositionTypeFree;
            particle.position = player.position;
        }
        if(during_magnet)
        {
            particleMagnet.positionType = kCCPositionTypeFree;
            particleMagnet.position = player.position;
        }
        if(during_shield)
        {
            [shield_1 setPosition:ccp(player.position.x, player.position.y)];
        }
    }
}


-(void)setPlayerVelocity
{
    b2Vec2 force = b2Vec2(TRAVEL_SPEED, 0);
    player->playerBody->SetLinearVelocity(force);
//    player->playerBody->ApplyLinearImpulse(force, player->playerBody->GetWorldCenter());
}
-(void)addObstacle
{
    GameObject *obstacle;
    obstacle = [[GameObject alloc] init];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    obstacle = [GameObject spriteWithFile: [NSString stringWithFormat:@"PLAY.png"]];
    
    obstacle.tag = OBSTACLE_TAG;
    [obstacle setType:gameObjectObstacle];
    
    obstacle.position = ccp(winSize.width - obstacle.contentSize.width/2, obstacle.contentSize.height/2);
    
    [self addChild:obstacle];
    
    b2BodyDef obstacleBodyDef;
    obstacleBodyDef.type = b2_dynamicBody;
    obstacleBodyDef.position.Set(obstacle.position.x/PTM_RATIO, obstacle.position.y/PTM_RATIO);
    obstacleBodyDef.userData = obstacle;
    
    obstacleBodyDef.userData = (__bridge_retained void*) obstacle;
    
    b2Body* obstacleBody = world->CreateBody(&obstacleBodyDef);
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED*treasureSpeedMultiplier, 0);
    obstacleBody->SetLinearVelocity(force);
    
//    b2CircleShape circle;
    b2PolygonShape polygon;
    polygon.SetAsBox(obstacle.contentSize.height/4/PTM_RATIO, obstacle.contentSize.width/4/PTM_RATIO);

    b2FixtureDef obstacleShapeDef;
//    obstacleShapeDef.shape = &circle;
    obstacleShapeDef.shape = &polygon;
    obstacleShapeDef.density = 3.0f;
    obstacleShapeDef.friction = 0.0f;
    obstacleShapeDef.restitution = 0.0f;
    obstacleShapeDef.filter.categoryBits = 0x7;
    obstacleShapeDef.filter.maskBits = 0x1;
    
    obstacleBody->CreateFixture(&obstacleShapeDef);
}


- (void) initBatchNode {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Character.plist"];
    allBatchNode=[CCSpriteBatchNode batchNodeWithFile:@"Character.png"];
    [self addChild:allBatchNode z:10];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"obstacle.plist"];
    treasureBatchNode=[CCSpriteBatchNode batchNodeWithFile:@"obstacle.png"];
    [self addChild:treasureBatchNode z:10];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"eject.plist"];
}

- (void)update:(ccTime)dt {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    if ( hudLayer==nil ){
        CCScene* scene = [[CCDirector sharedDirector] runningScene];
        hudLayer = (HUDLayer*)[scene getChildByTag:HUD_LAYER_TAG];
    }
    
       
    star1Opa++;
    star1.opacity = 120+(star1Opa/5)%(255-120);

    
    if(gamePart1){
        if ( !hitStop ){
            distance += dt*100*treasureSpeedMultiplier;
            score += dt*100*treasureSpeedMultiplier;
        }
        
        if ( distance/1000>=distanceLevel ){
            distanceLevel++;
            [self popMilestone:distanceLevel];
        }
        
        self.power += dt*100*treasureSpeedMultiplier;
        [hudLayer updatePointer: self.power];
        if ( self.power >= MAX_DISTANCE ){
            [self unschedule:@selector(gameLogic:)];
            [self unschedule:@selector(endInvincible:)];
            [self unschedule:@selector(SetUpMagnet:)];
            [self unschedule:@selector(endMagnet:)];
            [self unschedule:@selector(endBullet:)];
            [self unschedule:@selector(endCollectCirle:)];
            
            if (during_invincible){
                [self endInvincible:0];
            }
            
            distance = MAX_DISTANCE-1;
            [[SimpleAudioEngine sharedEngine]playEffect:@"CrashSong.mp3"];
            
            [self playerBack];
            [self ChangeGoBackSound];
            
            [player setType:gameObjectCollector];
        }
        
        if(distance == 500)
        {
            redLine = [CCSprite spriteWithFile: [NSString stringWithFormat:@"henggechumaPS2.png"]];
//            redLine.rotation = 90;
            [redLine setAnchorPoint:ccp(0,0.5)];
            [redLine setPosition:ccp(0, 200)];
            [self addChild:redLine z:10];
            
            
            
        }
        if(distance == 700)
        {
            [self removeChild:redLine];
            [self addFallingStone:winSize.width loc:200];
        }
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        switch (distance) {
            case 1300:
                [self addRowTreasure:2 index:2 location:winSize.height];
                [self addRowTreasure:3 index:2 location:0];
                break;
            case 1900:
                [self addRowTreasure:4 index:2 location:winSize.height];
                [self addRowTreasure:0 index:2 location:0];
                break;
            case 2500:
                [self addRowTreasure:0 index:2 location:winSize.height];
                [self addRowTreasure:5 index:2 location:0];
                break;
            case 3500:
                [self addRowTreasure:3 index:2 location:winSize.height];
                [self addRowTreasure:4 index:2 location:0];
                break;
            case 3800:
                [self addRowTreasure:4 index:2 location:winSize.height];
                [self addRowTreasure:3 index:2 location:0];
                break;
            case 4200:
                [self addRowTreasure:2 index:2 location:winSize.height];
                [self addRowTreasure:5 index:2 location:0];
                break;
            case 4900:
                [self addRowTreasure:5 index:2 location:winSize.height];
                [self addRowTreasure:4 index:2 location:0];
                break;
            case 1000:
                [self addRowTreasure:4 index:1 location:winSize.height];
                [self addRowTreasure:2 index:1 location:0];
                break;
            case 1500:
                [self addRowTreasure:2 index:1 location:winSize.height];
                [self addRowTreasure:0 index:1 location:0];
                break;
            case 3000:
                [self addRowTreasure:3 index:1 location:winSize.height];
                [self addRowTreasure:5 index:1 location:0];
                break;
            case 1800:
                [self addRowTreasure:4 index:3 location:winSize.height];
                [self addRowTreasure:2 index:3 location:0];
                break;
            case 2900:
                [self addRowTreasure:2 index:3 location:winSize.height];
                [self addRowTreasure:2 index:3 location:0];
                break;
            case 3300:
                [self addRowTreasure:4 index:3 location:winSize.height];
                [self addRowTreasure:0 index:3 location:0];
                break;
            case 3100:
                [self addRowTreasure:7 index:5 location:winSize.height];
                [self addRowTreasure:7 index:5 location:0];
                break;
            case 3700:
                [self addRowTreasure:0 index:5 location:winSize.height];
                [self addRowTreasure:6 index:5 location:0];
                break;
            case 4300:
                [self addRowTreasure:5 index:5 location:winSize.height];
                [self addRowTreasure:3 index:5 location:0];
                break;
            case 4500:
                [self addRowTreasure:2 index:5 location:winSize.height];
                [self addRowTreasure:4 index:5 location:0];
                break;
            case 2800:
                [self addRowTreasure:3 index:7 location:winSize.height];
                [self addRowTreasure:2 index:7 location:0];
                break;
            case 3900:
                [self addRowTreasure:2 index:7 location:winSize.height];
                [self addRowTreasure:0 index:7 location:0];
                break;
            case 5300:
                [self addRowTreasure:2 index:7 location:winSize.height];
                [self addRowTreasure:5 index:7 location:0];
                break;
            default:
                break;
        }
    }

    
    
    /*
    if(distance==1300 || distance==1900 || distance==2500 || distance==3500 || distance==3800 || distance==4200 || distance==4900)
    {
        [self addRowTreasure:6 index:2 location:winSize.height];
    }
    else if(distance==1000 || distance==1500 || distance==3000)
    {
        [self addRowTreasure:6 index:1 location:0];
    }
    else if(distance==1800 || distance==2900 || distance==3300)
    {
        [self addRowTreasure:6 index:3 location:0];
    }
    else if(distance==3100 || distance==3700 || distance==4300 || distance==4500)
    {
        [self addRowTreasure:6 index:5 location:0];
    }
    else if(distance==2800 || distance==3900 || distance==4900 || distance==5300)
    {
        [self addRowTreasure:6 index:7 location:0];
    }
     */
    [hudLayer updateDistanceCounter:score/10];
    [self updateShip];
}

-(bool) propertyListener: (int)propertyTag
{
    if(propertyTag == TREASURE_PROPERTY_TYPE_1_TAG)
    {
        if ( !gamePart1 ){
            return false;
        }
        player.numOfAffordCollsion += 2;
        numOfAffordCollsionTEMP += 2;
        
        shield_1 = [CCSprite spriteWithFile: [NSString stringWithFormat:@"spaceship-shield-2.png"]];
        [shield_1 setPosition:ccp(player.position.x, player.position.y)];
        [self addChild:shield_1 z:10];
        during_shield = true;
//        [player shield2];
    }
    else if (propertyTag == TREASURE_PROPERTY_TYPE_2_TAG)
    {
        if ( !gamePart1 ){
            return false;
        }
 
        
        [self unschedule:@selector(gameLogic:)];
        [_scheduler pauseTarget:self];
        numOfAffordCollsionTEMP = player.numOfAffordCollsion;
        player.numOfAffordCollsion = 1000000;
        treasureSpeedMultiplier = 2;
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                CCSprite *treasureData = (CCSprite *)b->GetUserData();
                
                if(treasureData.tag==TREASURE_TAG)
                {
                    b2Vec2 force = b2Vec2(b->GetLinearVelocity().x * treasureSpeedMultiplier, b->GetLinearVelocity().y * treasureSpeedMultiplier);
                    b->SetLinearVelocity(force);
                }
            }
        }
        
        during_invincible = true;
//        [player invincible];
        
        particle = [CCParticleSystemQuad particleWithFile:@"protection.plist"];
        particle.positionType = kCCPositionTypeFree;
        particle.position = player.position;
        [self addChild:particle z:1];
        
        [_scheduler resumeTarget:self];
        [self schedule:@selector(gameLogic:) interval:(1.0f/treasureSpeedMultiplier/2.0f)];
        [self schedule:@selector(endInvincible:) interval:10];
    }
    else if (propertyTag == TREASURE_PROPERTY_TYPE_3_TAG)
    {
        if ( !gamePart2 ){
            return false;
        }
        during_magnet = true;
        [[SimpleAudioEngine sharedEngine]playEffect:@"magnet.mp3"];
        particleMagnet = [CCParticleSystemQuad particleWithFile:@"magnet.plist"];
        particleMagnet.positionType = kCCPositionTypeFree;
        particleMagnet.position = player.position;
        [self addChild:particleMagnet z:1];
        
        [self schedule:@selector(SetUpMagnet:)];
        [self schedule:@selector(endMagnet:) interval:15];
        [player magnetAction];
    }
    else if(propertyTag == TREASURE_PROPERTY_TYPE_4_TAG)
    {
        if ( !gamePart1 ){
            return false;
        }
        isbullet = true;
        [self schedule:@selector(endBullet:) interval:15];
    }
    else if(propertyTag == TREASURE_PROPERTY_TYPE_5_TAG)
    {
        if(gamePart1||gamePart2)
            return false;
        isCollectCircle = true;
        [self schedule:@selector(endCollectCirle:) interval:15];
    }
    return true;
}


-(void) SetUpMagnet:(ccTime)dt
{

    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (CCSprite *)b->GetUserData();
            
            if(treasureData.tag==TREASURE_TAG)
            {
                b2Vec2 playerPos = player->playerBody->GetPosition();
                b2Vec2 treasurePos = b->GetPosition();
                
                if (  sqrt( sqr(treasurePos.x-playerPos.x)+sqr(treasurePos.y-playerPos.y) ) < 20 ){
                   // b2Vec2 force1 = b2Vec2(0.0f,0.0f);
                    //b->SetLinearVelocity(force1);
                
                    float delX = treasurePos.x-playerPos.x;
                    float delY = treasurePos.y-playerPos.y;
                    delX = -7*delX;
                    delY = -7*delY;
                    b2Vec2 force = b2Vec2(delX, delY);
                    b->SetLinearVelocity(force);
                }
                
            }
        }
    }
}

-(void) endMagnet:(ccTime)dt
{
    during_magnet = false;
    [self unschedule:@selector(SetUpMagnet:)];
}

-(void) endInvincible:(ccTime)dt
{
    during_invincible = false;
    [self unschedule:@selector(endInvincible:)];
    [self unschedule:@selector(gameLogic:)];
    
    [_scheduler pauseTarget:self];
    player.numOfAffordCollsion = numOfAffordCollsionTEMP;
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (CCSprite *)b->GetUserData();
            
            if(treasureData.tag==TREASURE_TAG)
            {
                b2Vec2 force = b2Vec2(b->GetLinearVelocity().x / treasureSpeedMultiplier, b->GetLinearVelocity().y / treasureSpeedMultiplier);
                b->SetLinearVelocity(force);
            }
        }
    }
    treasureSpeedMultiplier = 1;
    [_scheduler resumeTarget:self];
    [self schedule:@selector(gameLogic:) interval:1.0];
}
-(void) addBullet
{
    GameObject *bullet;
    bullet = [[GameObject alloc] init];
    
    bullet = [GameObject spriteWithFile: [NSString stringWithFormat:@"Bullet.png"]];
    
    
    bullet.tag = BULLET_TAG;
    [bullet setType:gameObjectBullet];
    
    bullet.position = ccp(player.position.x, player.position.y);
    
    [self addChild:bullet z:-1];
    
    b2BodyDef bulletBodyDef;
    bulletBodyDef.type = b2_dynamicBody;
    bulletBodyDef.position.Set(bullet.position.x/PTM_RATIO, bullet.position.y/PTM_RATIO);
    bulletBodyDef.userData = bullet;
    
    
    
    
    bulletBodyDef.userData = (__bridge_retained void*) bullet;
    
    b2Body* bulletBody = world->CreateBody(&bulletBodyDef);
    
    b2Vec2 force = b2Vec2(TRAVEL_SPEED, 0);
    bulletBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = bullet.contentSize.width/2/PTM_RATIO;
    
    b2FixtureDef bulletShapeDef;
    bulletShapeDef.shape = &circle;
    bulletShapeDef.density = 3.0f;
    bulletShapeDef.friction = 0.2f;
    bulletShapeDef.restitution = 1.0f;
    bulletShapeDef.filter.categoryBits = 0x6;
    bulletShapeDef.filter.maskBits = 0xFFFF-0x1-0x5-0x3;
    
    
    bulletBody->CreateFixture(&bulletShapeDef);
}
-(void) endBullet:(ccTime)dt
{
    isbullet = false;
}

-(void) endCollectCirle:(ccTime)dt
{
    isCollectCircle = false;
}
- (void) dealloc
{
    //[[SimpleAudioEngine sharedEngine] stopEffect:firstBackgroundMusic];
    //[[SimpleAudioEngine sharedEngine] stopEffect:secondBackgroundMusic];
	[super dealloc];
}

-(void) popMilestone:(int)distanceLevel
{
    if ( milestoneStatus!=0 ){
        milestoneStatus = 0;
        [self unschedule:@selector(endMilestone:)];
        [self removeChildByTag:distanceLevel-1+100];
    }
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    milestoneLable = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d Miles", (distanceLevel-1)*1000] fontName:@"Chalkduster" fontSize:100];
    milestoneLable.rotation = 90;
    milestoneLable.opacity = 255;
    milestoneLable.tag = distanceLevel+100;
    [milestoneLable setColor:ccWHITE];
    [milestoneLable setAnchorPoint:ccp(0.5f,1)];
    [milestoneLable setPosition:ccp(winSize.width/4*3, winSize.height/2)];
    [self addChild:milestoneLable];
    
    [self schedule:@selector(endMilestone:) interval:5];
    milestoneStatus = 1;
}

-(void) endMilestone:(ccTime)dt
{
    milestoneStatus = 0;
    [self unschedule:@selector(endMilestone:)];
    [self removeChildByTag:distanceLevel+100];
}

-(void)crash
{
    CCParticleSystemQuad * crashParticle = [CCParticleSystemQuad particleWithFile:@"bloom.plist"];
    crashParticle.positionType = kCCPositionTypeFree;
    crashParticle.position = player.position;
    [self addChild:crashParticle z:10];
}

-(void)changeShield:(int)status
{
    if(status==0)
    {
        during_shield = false;
        [shield_1 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"spaceship-shield-1.png"]];
        during_shield = true;
    }
    if(status == 1)
    {
        during_shield = false;
        [self removeChild:shield_1 cleanup:YES];
    }
}

@end
