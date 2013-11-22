//
//  GameLayer3.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-11-12.
//  Copyright 2013年 huang yongke. All rights reserved.
//


#import "GameLayer3.h"
#import "Constants.h"
#import "GameScene.h"
#import "HUDLayer.h"
#import "GameOverScene.h"

@implementation GameLayer3
@synthesize distance;
@synthesize score;
@synthesize scale;
@synthesize allBatchNode;

bool isReach_3;
bool isPlayerMoveBack_3;
bool isPlayerCollect_3;
bool isStationMoveBack_3;
bool isPlayerBacktoStation_3;
bool isCollect_3;
bool isbullet_3;
bool isCollectCircle_3;
bool isSetPlayerVelocity_3;

-(id) init{
    self = [super init];
    if(self){
        getLevel = 3;
        during_invincible = false;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        collectedTreasure.clear();
        blackholeVector.clear();
        
        treasureSpeedMultiplier = 1;
        gamePart1 = true;
        gamePart2 = false;
        isPlayerMoveBack_3 = false;
        isPlayerCollect_3 = false;
        isStationMoveBack_3 = false;
        isPlayerBacktoStation_3 = false;
        isCollect_3 = false;
        isbullet_3 = false;
        isCollectCircle_3 = false;
        isSetPlayerVelocity_3 = false;
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
        
        player = [Player spriteWithSpriteFrameName:@"spaceship1.png"];
        [player setType:(gameObjectPlayer)];
        [player initAnimation:allBatchNode];
        
        
        
        player.position = ccp(0, winSize.height/2);
        player.tag = PLAYER_TAG;
        
        [player createBox2dObject:world];
        
        
        
        [self addSpaceStation];
        
        isReach_3=false;
        
        [self schedule:@selector(treasureMovementLogic:)];
        
        [self schedule:@selector(blackholeLogic:)];
        
        hudLayer = nil;
        [self schedule:@selector(update:)];
        
    }
    return self;
}

- (void)preLoadSoundFiles
{
    //[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"PlayMode_Music_New.mp3"];
    //[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"PlayMode_Music_back.mp3"];
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"PlayMode_Music_New.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"PlayMode_Music_back.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"PlayMode_Music_New.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"CrashSong.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"LaunchSong.mp3"];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    firstBackgroundMusic = [[SimpleAudioEngine sharedEngine]playEffect:@"PlayMode_Music_New.mp3"];
    [[SimpleAudioEngine sharedEngine]playEffect:@"LaunchSong.mp3"];
}

- (void)ChangeGoBackSound
{
    //[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"PlayMode_Music_back.mp3"];
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"PlayMode_Music_back.mp3"];
    [[SimpleAudioEngine sharedEngine] stopEffect:firstBackgroundMusic];
    secondBackgroundMusic = [[SimpleAudioEngine sharedEngine] playEffect:@"PlayMode_Music_back.mp3"];
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
            
            if(treasureData.tag == PLAYER_TAG)
            {
                b2Vec2 force = b2Vec2(player->playerBody->GetLinearVelocity().x, 10);
                player->playerBody->SetLinearVelocity(force);
            }
             
            
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
                    collectedTreasure.push_back(b);
                    [[SimpleAudioEngine sharedEngine]playEffect:@"CollectTreasure.wav"];
                    if( gamePart1 && isSetPlayerVelocity_3)
                    {
                        [self setPlayerVelocity];
                    }
                    
                    if ( gamePart2 || gamePart1 ){
                        player->playerBody->SetLinearVelocity(b2Vec2(0.0f,0.0f));
                    }
                    continue;
                }
            }
            if(treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-winSize.width/5)<=10 && !isReach_3)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                isReach_3 = true;
                [self schedule:@selector(playerMoveFinished:)];
                self.isAccelerometerEnabled=YES;
                self.isTouchEnabled = YES;
                [self addBlackhole];
                
            }
            if(treasureData!=NULL && treasureData.tag==SPACESTATION_TAG && fabs(treasureData.position.x-winSize.width/2)<=100 && isStationMoveBack_3)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                isStationMoveBack_3 = false;
                
                isPlayerBacktoStation_3 = true;
                b2Vec2 forcePlayer = b2Vec2(-TRAVEL_SPEED, 0);
                player->playerBody->SetLinearVelocity(forcePlayer);
                gamePart2 = false;
                
            }
            if(treasureData!=NULL && treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-winSize.width/5*4)<=50&&isPlayerCollect_3)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                [self treasureBack];
                isPlayerCollect_3=false;
                isSetPlayerVelocity_3 = false;
                
                gamePart2 = true;
            }
            if(treasureData!=NULL && treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-treasureData.contentSize.width)<=10 && isPlayerBacktoStation_3)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                isPlayerBacktoStation_3 = false;
                
                
                [self collectTreasure];
                
                
            }
            if(treasureData!=NULL && treasureData.tag==PLAYER_TAG && isSetPlayerVelocity_3)
            {
                [self setPlayerVelocity];
            }
            
            treasureData.position = ccp(b->GetPosition().x*PTM_RATIO,
                                        b->GetPosition().y*PTM_RATIO);
            treasureData.rotation = 0 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            
            
            
        }
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(isbullet_3)
    {
        if ( gamePart1 ){
            [self addBullet];
        }
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    b2Vec2 position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    if(isCollectCircle_3)
    {
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                CCSprite *treasureData = (CCSprite *)b->GetUserData();
                if(treasureData.tag!=SPACESTATION_TAG && (sqrt(sqr(b->GetPosition().x-position.x)+sqr(b->GetPosition().y-position.y))<4)&&isCollect_3)
                {
                    CCLOG(@"here 0");
                    
                    /* Draw a circle by plist, one second disappear
                     CCSprite* circle= [CCSprite spriteWithFile:@"StatusBar.png"];
                     circle.position = ccp(location.x, location.y);
                     [self addChild:circle z:2 tag:CIRCLE_TAG];
                     */
                    
                    GameObject* treasureObj = (__bridge GameObject *)treasureData;
                    self.score += treasureObj.score;
                    treasureData.tag = TREASURE_COLLECT_TAG;
                    
                    treasureNumber--;
                    if ( treasureNumber==0 ){
                        [self unscheduleAllSelectors];
                        [[CCDirector sharedDirector] replaceScene:[CCTransitionProgressRadialCCW transitionWithDuration:1.0 scene:  [GameOverScene sceneWithLevel:GAME_STATE_THREE Score:self.score Distance:distance]]];
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
                CCSprite *treasureData = (CCSprite *)b->GetUserData();
                if(treasureData.tag!=SPACESTATION_TAG && f->TestPoint(position)&&isCollect_3)
                {
                    CCLOG(@"here 0");
                    
                    GameObject* treasureObj = (__bridge GameObject *)treasureData;
                    self.score += treasureObj.score;
                    treasureData.tag = TREASURE_COLLECT_TAG;
                    
                    treasureNumber--;
                    if ( treasureNumber==0 ){
                        [self unscheduleAllSelectors];
                        [[CCDirector sharedDirector] replaceScene:[CCTransitionProgressRadialCCW transitionWithDuration:1.0 scene:  [GameOverScene sceneWithLevel:GAME_STATE_THREE Score:self.score Distance:distance]]];
                    }
                }
            }
        }
    }
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
    isCollect_3 = true;
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
    [[CCDirector sharedDirector] replaceScene:[CCTransitionProgressRadialCCW transitionWithDuration:1.0 scene:[GameOverScene sceneWithLevel:GAME_STATE_THREE Score:self.score Distance:distance]]];
}

-(void) playerBack
{
    isPlayerMoveBack_3 = true;
    isStationMoveBack_3 = true;
    gamePart1 = false;
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
    [self addTreasure];
}
-(void) gameStoneLogic:(ccTime)dt
{
    [self addStone];
}

int GetRandom_3(int lowerbound, int upperbound){
    return lowerbound + arc4random() % ( upperbound - lowerbound + 1 );
}

int GetRandomGaussian_3( int lowerbound, int upperbound ){
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
    int treasureStartY = GetRandom_3( treasure.contentSize.height/2, winSize.height - treasure.contentSize.height/2 );
    int treasureDestinationY = GetRandomGaussian_3( treasureStartY-winSize.height, treasureStartY+winSize.height );
    
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

-(void)addBlackhole
{
    GameObject *blackhole;
    blackhole = [[GameObject alloc] init];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
//    int treasureIndex = arc4random()%8+1;
//    blackhole = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_%d.png", treasureIndex] ];
    
    blackhole = [GameObject spriteWithFile: [NSString stringWithFormat:@"blackhole.png"]];
    
//    backhole.tag = TREASURE_TAG;
//    [treasure setType:gameObjectTreasure1];
    
    int blackholeStartY = GetRandom_3( blackhole.contentSize.height/2, winSize.height - blackhole.contentSize.height/2 );
    
    blackhole.position = ccp(winSize.width - blackhole.contentSize.width/2, blackholeStartY);
    
    [self addChild:blackhole z:-1];
    
    b2BodyDef blackholeBodyDef;
    blackholeBodyDef.type = b2_dynamicBody;
    blackholeBodyDef.position.Set(blackhole.position.x/PTM_RATIO, blackhole.position.y/PTM_RATIO);
    blackholeBodyDef.userData = blackhole;
    
    
    
    
    blackholeBodyDef.userData = (__bridge_retained void*) blackhole;
    
    b2Body* blackholeBody = world->CreateBody(&blackholeBodyDef);
    
    blackholeVector.push_back(blackholeBody);
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED*0.2, 0);
    blackholeBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = blackhole.contentSize.width/2/PTM_RATIO;
    
    b2FixtureDef blackholeShapeDef;
    blackholeShapeDef.shape = &circle;
    blackholeShapeDef.density = 3.0f;
    blackholeShapeDef.friction = 0.0f;
    blackholeShapeDef.restitution = 1.0f;
    blackholeShapeDef.filter.categoryBits = 0x2;
    blackholeShapeDef.filter.maskBits = 0;
    
    blackholeBody->CreateFixture(&blackholeShapeDef);
    
    
}


-(void) blackholeLogic:(ccTime)dt
{
    for (int i=0; i<blackholeVector.size(); i++)
    {
        b2Body *b = blackholeVector[i];
        b2Vec2 blackholePos = b->GetPosition();
        b2Vec2 playerPos = player->playerBody->GetPosition();
                    
        if (  (gamePart1 || gamePart2) && sqrt( sqr(playerPos.x-blackholePos.x)+sqr(playerPos.y-blackholePos.y) ) < 20 )
        {
                
            float delY = playerPos.y-blackholePos.y;
            delY = -7*delY;
            b2Vec2 force = b2Vec2(0, delY);
            player->playerBody->SetLinearVelocity(force);
            break;
        }
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
    int stoneStartY = GetRandom_3(-30, winSize.height - stone.contentSize.height/2 );
    
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
    spaceStationShapeDef.filter.maskBits = 0xFFFF-0x2-0x1;
    
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
    
    if(isPlayerMoveBack_3)
    {
        [self pauseSchedulerAndActions];
        [player crashTransformAction];
         b2Vec2 force = b2Vec2(TRAVEL_SPEED, 0);
        player->playerBody->SetLinearVelocity(force);
        
        isSetPlayerVelocity_3 = true;
        
        [self unschedule:@selector(playerMoveFinished:)];
        [self unschedule:@selector(gameLogic:)];
        [self unschedule:@selector(gameStoneLogic:)];
        [self unschedule:@selector(addTreasure:)];
        
        isPlayerMoveBack_3 = false;
        isPlayerCollect_3 = true;
    }
    else
    {
        b2Vec2 position1(player.position.x/PTM_RATIO, newY/PTM_RATIO);
        player->playerBody->SetTransform(position1, 0.0);
        [hudLayer setShadowPosition:player.position.x yy:newY];
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
}

- (void)update:(ccTime)dt {
    if ( hudLayer==nil ){
        CCScene* scene = [[CCDirector sharedDirector] runningScene];
        hudLayer = (HUDLayer*)[scene getChildByTag:HUD_LAYER_TAG];
    }
    
    if(gamePart1){
        distance += dt*100*treasureSpeedMultiplier;
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
    }

    [hudLayer updateDistanceCounter:distance];
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
        [player shield2];
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
        [player invincible];
        [_scheduler resumeTarget:self];
        [self schedule:@selector(gameLogic:) interval:(1.0f/treasureSpeedMultiplier/2.0f)];
        [self schedule:@selector(endInvincible:) interval:15];
    }
    else if (propertyTag == TREASURE_PROPERTY_TYPE_3_TAG)
    {
        if ( !gamePart2 ){
            return false;
        }
        [self schedule:@selector(SetUpMagnet:)];
        [self schedule:@selector(endMagnet:) interval:15];
        [player magnetAction];
    }
    else if(propertyTag == TREASURE_PROPERTY_TYPE_4_TAG)
    {
        if ( !gamePart1 ){
            return false;
        }
        isbullet_3 = true;
        [self schedule:@selector(endBullet:) interval:15];
    }
    else if(propertyTag == TREASURE_PROPERTY_TYPE_5_TAG)
    {
        if(gamePart1||gamePart2)
            return false;
        isCollectCircle_3 = true;
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
                
                if (  sqrt( sqr(treasurePos.x-playerPos.x)+sqr(treasurePos.y-playerPos.y) ) < 20 )
                {
                    
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
    isbullet_3 = false;
}
-(void) endCollectCirle:(ccTime)dt
{
    isCollectCircle_3 = false;
}
- (void) dealloc
{
    [[SimpleAudioEngine sharedEngine] stopEffect:firstBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] stopEffect:secondBackgroundMusic];
	[super dealloc];
}

@end
