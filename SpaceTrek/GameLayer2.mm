//
//  GameLayer2.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-11-12.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "GameLayer2.h"
#import "Constants.h"
#import "GameScene.h"
#import "HUDLayer.h"
#import "BackgroundLayer.h"
#import "GameOverScene.h"

@implementation GameLayer2
@synthesize distance;
@synthesize score;
@synthesize scale;
@synthesize allBatchNode;

bool isReach_2;
bool isPlayerMoveBack_2;
bool isPlayerCollect_2;
bool isStationMoveBack_2;
bool isPlayerBacktoStation_2;
bool isCollect_2;
bool isbullet_2;
bool isCollectCircle_2;
bool isSetPlayerVelocity_2;
bool during_shield_2;
bool beforeExplode_2;
CCParticleSystemQuad *particle_2;
CCParticleSystemQuad *particleMagnet_2;

-(id) init{
    self = [super init];
    if(self){
        /*
         CCSprite *bg = [CCSprite spriteWithFile:@"version_1_level_1_background(map).png"];
         bg.anchorPoint = ccp(0, 0);
         [self addChild: bg z:-10];
         */
        getLevel = 2;
        during_invincible = false;
        during_magnet = false;
        distanceLevel = 1;
        milestoneStatus = 0;
        
        spaceshipState = 0;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        collectedTreasure.clear();
        
        treasureSpeedMultiplier = 1;
        gamePart1 = true;
        gamePart2 = false;
        isPlayerMoveBack_2 = false;
        isPlayerCollect_2 = false;
        isStationMoveBack_2 = false;
        isPlayerBacktoStation_2 = false;
        isCollect_2 = false;
        isbullet_2 = false;
        isCollectCircle_2 = false;
        isSetPlayerVelocity_2 = false;
        during_shield_2 = false;
        beforeExplode_2 = true;
        self.tag = GAME_LAYER_TAG;
        
        
        self.distance = 0;
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
        
        isReach_2=false;
        
        [self schedule:@selector(treasureMovementLogic:)];
        
        hudLayer = nil;
        backgroundLayer = nil;
        [self schedule:@selector(update:)];
        
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
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"level2Background.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"CrashSong.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"LaunchSong.mp3"];

    [[SimpleAudioEngine sharedEngine] preloadEffect:@"trigger.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"treasureCrash.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"collectobstacle.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"collecttreasure.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"magnet.mp3"];

    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"level2Background.mp3"];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"level2Background.mp3"];

    //firstBackgroundMusic = [[SimpleAudioEngine sharedEngine]playEffect:@"level2Background.mp3"];
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
            CCSprite *treasureDataCCSprite = (__bridge GameObject*)b->GetUserData();
            
            if([treasureDataCCSprite isMemberOfClass:[GameObject class]] || [treasureDataCCSprite isMemberOfClass:[Player class]])
            {
                GameObject* treasureData;
                
                if([treasureDataCCSprite isMemberOfClass:[Player class]])
                    treasureData=(Player*)treasureDataCCSprite;
                else
                    treasureData=(GameObject*)treasureDataCCSprite;
            
            
            
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
                        if( gamePart1 && isSetPlayerVelocity_2)
                        {
                            [self setPlayerVelocity];
                        }
                    
                        if ( gamePart2 || gamePart1 ){
                            player->playerBody->SetLinearVelocity(b2Vec2(0.0f,0.0f));
                        }
                        continue;
                    }
                }
                if(treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-winSize.width/5)<=10 && !isReach_2)
                {
                    b2Vec2 force = b2Vec2(0, 0);
                    b->SetLinearVelocity(force);
                    isReach_2 = true;
                    [self schedule:@selector(playerMoveFinished:)];
                    self.isAccelerometerEnabled=YES;
                    self.isTouchEnabled = YES;
                
                }
                if(treasureData!=NULL && treasureData.tag==SPACESTATION_TAG && fabs(treasureData.position.x-winSize.width/2)<=100 &&            isStationMoveBack_2)
                {
                    b2Vec2 force = b2Vec2(0, 0);
                    b->SetLinearVelocity(force);
                    isStationMoveBack_2 = false;
                
                    isPlayerBacktoStation_2 = true;
                    b2Vec2 forcePlayer = b2Vec2(-TRAVEL_SPEED, 0);
                    player->playerBody->SetLinearVelocity(forcePlayer);
                    gamePart2 = false;
                
                }
                if(treasureData!=NULL && treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-winSize.width/5*4)<=50&&isPlayerCollect_2)
                {
                    b2Vec2 force = b2Vec2(0, 0);
                    b->SetLinearVelocity(force);
                    [self treasureBack];
                    isPlayerCollect_2=false;
                    isSetPlayerVelocity_2 = false;
                
                    gamePart2 = true;
                }
                if(treasureData!=NULL && treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-treasureData.contentSize.width)<=10 && isPlayerBacktoStation_2)
                {
                    b2Vec2 force = b2Vec2(0, 0);
                    b->SetLinearVelocity(force);
                    isPlayerBacktoStation_2 = false;
                
                
                    [self collectTreasure];
                
                
                }
                if(treasureData!=NULL && treasureData.tag==PLAYER_TAG && isSetPlayerVelocity_2)
                {
                    [self setPlayerVelocity];
                }
            
                treasureData.position = ccp(b->GetPosition().x*PTM_RATIO,
                                        b->GetPosition().y*PTM_RATIO);
                treasureData.rotation = 0 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            
            
            
            }
        }
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(isbullet_2)
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
    
    
    if(isCollectCircle_2)
    {
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                CCSprite *treasureData = (__bridge CCSprite *)b->GetUserData();
                if(treasureData.tag!=SPACESTATION_TAG && (sqrt(sqr(b->GetPosition().x-position.x)+sqr(b->GetPosition().y-position.y))<3)&&isCollect_2)
                {
                    CCLOG(@"here 0");
                    
                    /* Draw a circle by plist, one second disappear
                     CCSprite* circle= [CCSprite spriteWithFile:@"StatusBar.png"];
                     circle.position = ccp(location.x, location.y);
                     [self addChild:circle z:2 tag:CIRCLE_TAG];
                     */
                    
                    CCParticleSystemQuad *ps = [CCParticleSystemQuad particleWithFile:@"treasureCollection.plist"];
                    ps.positionType = kCCPositionTypeFree;
                    [self addChild:ps z:1];
                    
                    CGPoint position = ccp(b->GetPosition().x*PTM_RATIO, b->GetPosition().y*PTM_RATIO);
                    
                    ps.position = position;
                    ps.blendAdditive = YES;
                    ps.life = 0.25f;
                    ps.lifeVar = 0.25f;
                    ps.totalParticles = 120.0f;
                    ps.autoRemoveOnFinish = YES;
                    
                    
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
                        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:  [GameOverScene sceneWithLevel:GAME_STATE_TWO Score:self.score Distance:distance]]];

                    }
                }
            }
        }
    }
    else
    {
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                b2Fixture *f = b->GetFixtureList();
                CCSprite *treasureData = (__bridge CCSprite *)b->GetUserData();
                if(treasureData.tag!=SPACESTATION_TAG && f->TestPoint(position)&&isCollect_2)
                {
                    CCLOG(@"here 0");
                    
                    
                    CCParticleSystem *ps = [CCParticleExplosion node];
                    [self addChild:ps z:12];
                    ps.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars.png"];
                    ps.position = location;
                    ps.blendAdditive = YES;
                    ps.life = 0.25f;
                    ps.lifeVar = 0.25f;
                    ps.totalParticles = 120.0f;
                    ps.autoRemoveOnFinish = YES;
                    
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
                        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:  [GameOverScene sceneWithLevel:GAME_STATE_TWO Score:self.score Distance:distance]]];

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
            CCSprite *treasureData = (__bridge CCSprite *)b->GetUserData();
            
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
        CCSprite *treasureData = (__bridge CCSprite *)b->GetUserData();
        
        
        b->SetTransform(b2Vec2(playPosition.x, playPosition.y), 0.0);
        //        treasureData.position =  ccp(playPosition.x*PTM_RATIO,playPosition.y*PTM_RATIO);
        treasureData.visible = true;
        b->SetLinearVelocity(b2Vec2(rand()%15+5, rand()%10-5));
        
    }
    isCollect_2 = true;
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
            CCSprite *treasureData = (__bridge CCSprite *)b->GetUserData();
            
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
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:  [GameOverScene sceneWithLevel:GAME_STATE_TWO Score:self.score Distance:distance]]];

}

-(void) playerBack
{
    if ( hudLayer==nil ){
        CCScene* scene = [[CCDirector sharedDirector] runningScene];
        hudLayer = (HUDLayer*)[scene getChildByTag:HUD_LAYER_TAG];
    }
    if ( backgroundLayer==nil ){
        CCScene* scene = [[CCDirector sharedDirector] runningScene];
        backgroundLayer = (BackgroundLayer*)[scene getChildByTag:BACKGROUND_LAYER_TAG];
    }
    [backgroundLayer changeBack];
    [hudLayer setShadow:2];
    isPlayerMoveBack_2 = true;
    isStationMoveBack_2 = true;
    gamePart1 = false;
    beforeExplode_2 = false;
}
-(void) treasureBack
{
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (__bridge CCSprite *)b->GetUserData();
            
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
    [self addTreasure];
}
-(void) gameStoneLogic:(ccTime)dt
{
    [self addStone];
}

int GetRandom_2(int lowerbound, int upperbound){
    return lowerbound + arc4random() % ( upperbound - lowerbound + 1 );
}

int GetRandomGaussian_2( int lowerbound, int upperbound ){
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
    int treasureIndex = arc4random()%8+1;
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
    int treasureStartY = GetRandom_2( treasure.contentSize.height/2, winSize.height - treasure.contentSize.height/2 );
    int treasureDestinationY = GetRandomGaussian_2( treasureStartY-winSize.height, treasureStartY+winSize.height );
    
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
    treasureShapeDef.filter.maskBits = 0x1+0x20;
    
    treasureBody->CreateFixture(&treasureShapeDef);
    
    
}

-(void)addRowTreasure:(int)num index:(int)treasureIndex location:(int)loc
{
    
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
        treasureShapeDef.filter.maskBits = 0x1+0x20;
        
        treasureBody->CreateFixture(&treasureShapeDef);
        
    }
    
    
    
}

-(void)addStone
{
    GameObject *stone;
    stone = [[GameObject alloc] init];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int stoneIndex = arc4random()%2+1;
    stone = [GameObject spriteWithFile: [NSString stringWithFormat:@"fireball_%d.png", stoneIndex] ];
    
    stone.tag = STONE_TAG;
    [stone setType:gameObjectStone];
    int stoneStartY = GetRandom_2(-30, winSize.height - stone.contentSize.height/2 );
    
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
    stoneShapeDef.filter.categoryBits = 0x4;
    stoneShapeDef.filter.maskBits = 0x0;
    
    stoneBody->CreateFixture(&stoneShapeDef);
}

-(void) addBeginStone:(int) x yy:(int) y
{
    GameObject *stone;
    stone = [[GameObject alloc] init];
    
    stone = [GameObject spriteWithFile: [NSString stringWithFormat:@"fireball_2.png"]];
    
    
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
    stoneShapeDef.filter.categoryBits = 0x4;
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
    spaceStationShapeDef.filter.categoryBits = 0x8;
    spaceStationShapeDef.filter.maskBits = 0x0;
    
    spaceStationBody->CreateFixture(&spaceStationShapeDef);
    
    
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
    
    if(isPlayerMoveBack_2)
    {
        [self pauseSchedulerAndActions];
        [player crashTransformAction];
        
        
        b2Vec2 force = b2Vec2(TRAVEL_SPEED, 0);
        player->playerBody->SetLinearVelocity(force);
        
        isSetPlayerVelocity_2 = true;
        
        [self unschedule:@selector(playerMoveFinished:)];
        [self unschedule:@selector(gameLogic:)];
        [self unschedule:@selector(gameStoneLogic:)];
        [self unschedule:@selector(addTreasure:)];
        
        isPlayerMoveBack_2 = false;
        isPlayerCollect_2 = true;
    }
    else
    {
        b2Vec2 position1(player.position.x/PTM_RATIO, newY/PTM_RATIO);
        
        if(beforeExplode_2)
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
        if(gamePart2)
        {
            if(newY>player.position.y+5)
            {
                player.rotation = -30;
            }
            else if(newY<player.position.y-5)
            {
                player.rotation = 30;
            }
        }

        
        
        player->playerBody->SetTransform(position1, 0.0);
        [hudLayer setShadowPosition:player.position.x yy:newY];
        
        if(during_invincible){
            //CGPoint location = ccp(player.position.x+player.contentSize.height/2, player.position.y);
            particle_2.positionType = kCCPositionTypeFree;
            particle_2.position = player.position;
        }
        if(during_magnet)
        {
            particleMagnet_2.positionType = kCCPositionTypeFree;
            particleMagnet_2.position = player.position;
        }
        if(during_shield_2)
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

- (void) initBatchNode {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Character.plist"];
    allBatchNode=[CCSpriteBatchNode batchNodeWithFile:@"Character.png"];
    [self addChild:allBatchNode z:10];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Treasure.plist"];
    treasureBatchNode=[CCSpriteBatchNode batchNodeWithFile:@"Treasure.png"];
    [self addChild:treasureBatchNode z:10];
}

- (void)update:(ccTime)dt {
    if ( hudLayer==nil ){
        CCScene* scene = [[CCDirector sharedDirector] runningScene];
        hudLayer = (HUDLayer*)[scene getChildByTag:HUD_LAYER_TAG];
    }
    
    if ( backgroundLayer==nil ){
        CCScene* scene = [[CCDirector sharedDirector] runningScene];
        backgroundLayer = (BackgroundLayer*)[scene getChildByTag:BACKGROUND_LAYER_TAG];
    }
    
    if(gamePart1){
        distance += dt*100*treasureSpeedMultiplier;
        score += dt*100*treasureSpeedMultiplier;
        
        if ( distance/1000>=distanceLevel ){
            distanceLevel++;
            [self popMilestone:distanceLevel];
        }
        
        [hudLayer updatePointer: distance];
        if ( distance >= MAX_DISTANCE ){
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
        CGSize winSize = [[CCDirector sharedDirector] winSize];
    
        switch (distance) {
            case 800:
                [self addRowTreasure:3 index:2 location:winSize.height];
                [self addRowTreasure:5 index:2 location:0];
                break;
            case 1200:
                [self addRowTreasure:5 index:2 location:winSize.height];
                [self addRowTreasure:6 index:2 location:0];
                break;
            case 2000:
                [self addRowTreasure:2 index:2 location:winSize.height];
                [self addRowTreasure:2 index:2 location:0];
                break;
            case 2100:
                [self addRowTreasure:4 index:2 location:winSize.height];
                [self addRowTreasure:4 index:2 location:0];
                break;
            case 2200:
                [self addRowTreasure:6 index:2 location:winSize.height];
                [self addRowTreasure:6 index:2 location:0];
                break;
            case 2300:
                [self addRowTreasure:8 index:2 location:winSize.height];
                [self addRowTreasure:8 index:2 location:0];
                break;
            case 3000:
                [self addRowTreasure:15 index:2 location:winSize.height];
                [self addRowTreasure:15 index:2 location:0];
                break;
            case 1500:
                [self addRowTreasure:5 index:1 location:winSize.height];
                [self addRowTreasure:0 index:1 location:0];
                break;
            case 2600:
                [self addRowTreasure:0 index:1 location:winSize.height];
                [self addRowTreasure:8 index:1 location:0];
                break;
            case 1800:
                [self addRowTreasure:3 index:1 location:winSize.height];
                [self addRowTreasure:5 index:1 location:0];
                break;
            case 2900:
                [self addRowTreasure:7 index:3 location:winSize.height];
                [self addRowTreasure:0 index:3 location:0];
                break;
            case 3300:
                [self addRowTreasure:2 index:3 location:winSize.height];
                [self addRowTreasure:5 index:3 location:0];
                break;
            case 2800:
                [self addRowTreasure:4 index:3 location:winSize.height];
                [self addRowTreasure:4 index:3 location:0];
                break;
            case 3900:
                [self addRowTreasure:3 index:5 location:winSize.height];
                [self addRowTreasure:0 index:5 location:0];
                break;
            case 4900:
                [self addRowTreasure:2 index:5 location:winSize.height];
                [self addRowTreasure:6 index:5 location:0];
                break;
            case 5300:
                [self addRowTreasure:7 index:5 location:winSize.height];
                [self addRowTreasure:3 index:5 location:0];
                break;
                
            default:
                break;
        }

    }
    
    /*
    if(distance == 1000)
        [hudLayer setShadow:1];
    if(distance == 2000)
        [hudLayer setShadow:2];
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
        during_shield_2 = true;
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
                CCSprite *treasureData = (__bridge CCSprite *)b->GetUserData();
                
                if(treasureData.tag==TREASURE_TAG)
                {
                    b2Vec2 force = b2Vec2(b->GetLinearVelocity().x * treasureSpeedMultiplier, b->GetLinearVelocity().y * treasureSpeedMultiplier);
                    b->SetLinearVelocity(force);
                }
            }
        }
        during_invincible = true;
//        [player invincible];
        
        particle_2 = [CCParticleSystemQuad particleWithFile:@"protection.plist"];
        particle_2.positionType = kCCPositionTypeFree;
        particle_2.position = player.position;
        [self addChild:particle_2 z:1];
        
        [_scheduler resumeTarget:self];
        [self schedule:@selector(gameLogic:) interval:(1.0f/treasureSpeedMultiplier/2.0f)];
        [backgroundLayer speedupBackground];
        [self schedule:@selector(endInvincible:) interval:10];
    }
    else if (propertyTag == TREASURE_PROPERTY_TYPE_3_TAG)
    {
        if ( !gamePart2 ){
            return false;
        }
        during_magnet = true;
        particleMagnet_2 = [CCParticleSystemQuad particleWithFile:@"magnet.plist"];
        particleMagnet_2.positionType = kCCPositionTypeFree;
        particleMagnet_2.position = player.position;
        [self addChild:particleMagnet_2 z:1];

        [self schedule:@selector(SetUpMagnet:)];
        [self schedule:@selector(endMagnet:) interval:15];
        [player magnetAction];
    }
    else if(propertyTag == TREASURE_PROPERTY_TYPE_4_TAG)
    {
        if ( !gamePart1 ){
            return false;
        }
        isbullet_2 = true;
        [self schedule:@selector(endBullet:) interval:15];
    }
    else if(propertyTag == TREASURE_PROPERTY_TYPE_5_TAG)
    {
        if(gamePart1||gamePart2)
            return false;
        isCollectCircle_2 = true;
        [self schedule:@selector(endCollectCirle:) interval:15];
    }
    else if(propertyTag == TREASURE_PROPERTY_TYPE_6_TAG)
    {
        if(!gamePart1)
            return false;
        [hudLayer setShadow:5];
        [self schedule:@selector(endLight:) interval:15];
    }
    return true;
}

-(void) SetUpMagnet:(ccTime)dt
{
    
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (__bridge CCSprite *)b->GetUserData();
            
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
            CCSprite *treasureData = (__bridge CCSprite *)b->GetUserData();
            
            if(treasureData.tag==TREASURE_TAG)
            {
                b2Vec2 force = b2Vec2(b->GetLinearVelocity().x / treasureSpeedMultiplier, b->GetLinearVelocity().y / treasureSpeedMultiplier);
                b->SetLinearVelocity(force);
            }
        }
    }
    treasureSpeedMultiplier = 1;
    [_scheduler resumeTarget:self];
    [backgroundLayer backSpeedBackground];
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
    bulletShapeDef.filter.categoryBits = 0x20;
    bulletShapeDef.filter.maskBits = 0x2;
    
    
    bulletBody->CreateFixture(&bulletShapeDef);
}
-(void) endBullet:(ccTime)dt
{
    isbullet_2 = false;
}
-(void) endCollectCirle:(ccTime)dt
{
    isCollectCircle_2 = false;
}
-(void) endLight:(ccTime)dt
{
    [hudLayer setShadow:2];
}
- (void) dealloc
{
    //[[SimpleAudioEngine sharedEngine] stopEffect:firstBackgroundMusic];
    //[[SimpleAudioEngine sharedEngine] stopEffect:secondBackgroundMusic];
	[super dealloc];
}

-(void) popMilestone:(int)distanceLevel
{
    [hudLayer addMilestone:distanceLevel];
    [self schedule:@selector(endMilestone:) interval:5];
}

-(void) endMilestone:(ccTime)dt
{
    milestoneStatus = 0;
    [self unschedule:@selector(endMilestone:)];
    [hudLayer endMilestone];
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
        during_shield_2 = false;
        [shield_1 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"spaceship-shield-1.png"]];
        during_shield_2 = true;
    }
    if(status == 1)
    {
        during_shield_2 = false;
        [self removeChild:shield_1 cleanup:YES];
    }
}
@end
