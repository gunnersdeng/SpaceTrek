//
//  GameLayer.m
//  SpaceTrek
//
//  Created by huang yongke on 13-10-2.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "GameLayer.h"
#import "Constants.h"
#import "PauseLayer.h"
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
bool isStationMoveBack;
bool isPlayerBacktoStation;
bool isCollect;

-(id) init{
    self = [super init];
    if(self){
        /*
        CCSprite *bg = [CCSprite spriteWithFile:@"version_1_level_1_background(map).png"];
        bg.anchorPoint = ccp(0, 0);
        [self addChild: bg z:-10];
        */
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        collectedTreasure.clear();
        
        isPlayerMoveBack = false;
        isStationMoveBack = false;
        isPlayerBacktoStation = false;
        isCollect = false;
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

        
        player.position = ccp(player.contentSize.width/2, winSize.height/2);
        player.tag = PLAYER_TAG;
        [player createBox2dObject:world];
        [self addSpaceStation];
        
        isReach=false;
        
        [self schedule:@selector(treasureMovementLogic:)];

        
        pauseButton = [CCMenuItemImage itemWithNormalImage:@"Button-Pause-icon-modified.png" selectedImage:@"Button-Pause-icon-modified.png" target:self selector:@selector(pauseButtonSelected)];
        pauseButton.scale = 0.8;
        pauseButton.rotation = 90;
        
        pauseMenu = [CCMenu menuWithItems:pauseButton, nil];
        pauseMenu.position=ccp(980, 700);
        
        [pauseMenu alignItemsVerticallyWithPadding:10.0f];
        [self addChild:pauseMenu z:1];
        
        //CCScene* scene = [[CCDirector sharedDirector] runningScene];
        //hudLayer = (HUDLayer*)[scene getChildByTag:HUD_LAYER_TAG];
        //[hudLayer updateDistanceCounter:self.distance];
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
    
    groundBox.Set(b2Vec2(0,0), b2Vec2(winSize.width, 0));
    _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
    _groundBody->CreateFixture(&groundBoxDef);
    
    groundBox.Set(b2Vec2(0, winSize.height), b2Vec2(winSize.width, winSize.height));
    _groundBody->CreateFixture(&groundBoxDef);
    

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
    world->Step(dt, 10, 10);
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (CCSprite *)b->GetUserData();
            
            
            if(treasureData.tag == TREASURE_DESTROY_TAG)
            {
                //[self removeChild:treasureData cleanup:YES];
                //world->DestroyBody(b);
                if ( treasureData.visible ){
                    treasureData.visible = false;
                    collectedTreasure.push_back(b);
                    [[SimpleAudioEngine sharedEngine]playEffect:@"CollectTreasure.wav"];
                    continue;
                }
            }
            
            if(treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-winSize.width/5)<=0.5 && !isReach)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                isReach = true;
                [self schedule:@selector(playerMoveFinished:)];
                self.isAccelerometerEnabled=YES;
                
                self.isTouchEnabled = YES;
            }
            /*
            if(treasureData!=NULL && treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-winSize.width/5*4)<=10 && isPlayerMoveBack)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                isPlayerMoveBack = false;
            }
            */
            if(treasureData!=NULL && treasureData.tag==SPACESTATION_TAG && fabs(treasureData.position.x-winSize.width/2)<=100 && isStationMoveBack)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                isStationMoveBack = false;
                
                isPlayerBacktoStation = true;
                b2Vec2 forcePlayer = b2Vec2(-TRAVEL_SPEED, 0);
                player->playerBody->SetLinearVelocity(forcePlayer);
                
            }
            if(treasureData!=NULL && treasureData.tag==PLAYER_TAG && fabs(treasureData.position.x-treasureData.contentSize.width)<=10 && isPlayerBacktoStation)
            {
                b2Vec2 force = b2Vec2(0, 0);
                b->SetLinearVelocity(force);
                isPlayerBacktoStation = false;
                
                [self collectTreasure];
                
            }
            treasureData.position = ccp(b->GetPosition().x,
                                            b->GetPosition().y);
            treasureData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
       
            
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(isCollect)
    {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        b2Vec2 position = b2Vec2(location.x, location.y);
        for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
            if (b->GetUserData() != NULL) {
                b2Fixture *f = b->GetFixtureList();
                CCSprite *treasureData = (CCSprite *)b->GetUserData();
                if(treasureData.tag!=SPACESTATION_TAG && f->TestPoint(position))
                {
                    CCLOG(@"here 0");
                    self.score += 10;
                    treasureData.tag = TREASURE_COLLECT_TAG;
                }
            
            }
        }
    }
}

-(void) collectTreasure
{
    
    [self unscheduleAllSelectors];

    b2Vec2 playPosition = player->playerBody->GetPosition();
    
    
    for (int i=0; i<collectedTreasure.size(); i++)
    {
        b2Body *b = collectedTreasure[i];
        CCSprite *treasureData = (CCSprite *)b->GetUserData();
        b->SetTransform(playPosition, 0.0);
        treasureData.position =  ccp(b->GetPosition().x,
            b->GetPosition().y);
        b->SetLinearVelocity(b2Vec2(rand()%30000, -10000+rand()%20000));
        treasureData.visible = true;
    }
    isCollect = true;
    world->DestroyBody(player->playerBody);
    [self schedule:@selector(treasureCollectMovementLogic:)];
    world->SetGravity(b2Vec2(-10.0f, 0.0f));
   //[self unschedule:@selector(treasureMovementLogic:)];

    //[self unscheduleAllSelectors];
   [self schedule:@selector(JumpToGameOverScene:) interval:10.0f];
}

-(void) treasureCollectMovementLogic:(ccTime)dt
{

    world->Step(dt, 10, 10);
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (CCSprite *)b->GetUserData();
            
            if(treasureData.tag == TREASURE_COLLECT_TAG || treasureData.tag == TREASURE_TAG)
            {
                [self removeChild:treasureData cleanup:YES];
                world->DestroyBody(b);
                continue;
            }
            treasureData.position = ccp(b->GetPosition().x,
                                        b->GetPosition().y);
            treasureData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            
        }
    }
}



-(void)JumpToGameOverScene:(ccTime)delta
{
    [self unscheduleAllSelectors];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionProgressRadialCCW transitionWithDuration:1.0 scene:[GameOverScene sceneWithLevel:GAME_STATE_ONE Score:self.score Distance:distance]]];
}

-(void) playerBack
{
    isPlayerMoveBack = true;
    isStationMoveBack = true;
}
-(void) treasureBack
{
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *treasureData = (CCSprite *)b->GetUserData();
            
            if(treasureData.tag==TREASURE_TAG)
             {
             b2Vec2 force = b2Vec2(-b->GetLinearVelocity().x*2, -b->GetLinearVelocity().y*2);
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
    int treasureIndex = arc4random()%7+1;
    treasure = [GameObject spriteWithFile: [NSString stringWithFormat:@"treasure_type_%d.png", treasureIndex] ];
    if ( treasureIndex == 1 ){
        treasure.scale = 2;
    }else{
        treasure.scale = 1.5;
    }
    
    treasure.tag = TREASURE_TAG;
    [treasure setType:gameObjectTreasure1];
    int treasureStartY = GetRandom( treasure.contentSize.height/2, winSize.height - treasure.contentSize.height/2 );
    int treasureDestinationY = GetRandomGaussian( treasureStartY-winSize.height, treasureStartY+winSize.height );
    
    treasure.position = ccp(winSize.width - treasure.contentSize.width/2, treasureStartY);
    
    [self addChild:treasure];
    
    b2BodyDef treasureBodyDef;
    treasureBodyDef.type = b2_dynamicBody;
    treasureBodyDef.position.Set(winSize.width - treasure.contentSize.width/2, treasureStartY);
    treasureBodyDef.userData = treasure;
    
    
    
    
    treasureBodyDef.userData = (__bridge_retained void*) treasure;
    
    b2Body* treasureBody = world->CreateBody(&treasureBodyDef);
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED*10, (treasureDestinationY-treasureStartY)/(winSize.width/TRAVEL_SPEED)*10);
//    treasureBody->ApplyLinearImpulse(force, treasureBodyDef.position);
    treasureBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = treasure.contentSize.width/2;
    
    b2FixtureDef treasureShapeDef;
    treasureShapeDef.shape = &circle;
    treasureShapeDef.density = 3.0f;
    treasureShapeDef.friction = 0.0f;
    treasureShapeDef.restitution = 1.0f;
    treasureShapeDef.filter.categoryBits = 0x2;
    treasureShapeDef.filter.maskBits = 0xFFFF-0x2;
   
    treasureBody->CreateFixture(&treasureShapeDef);
    

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
    stoneBodyDef.position.Set(winSize.width+stone.contentSize.width, stoneStartY);
    stoneBodyDef.userData = stone;
    
    
    
    
    stoneBodyDef.userData = (__bridge_retained void*) stone;
    
    b2Body* stoneBody = world->CreateBody(&stoneBodyDef);
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED/10, 0);
    //    treasureBody->ApplyLinearImpulse(force, treasureBodyDef.position);
    stoneBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = stone.contentSize.width/2;
    
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
    stoneBodyDef.position.Set(x, y);
    stoneBodyDef.userData = stone;
    
    
    
    
    stoneBodyDef.userData = (__bridge_retained void*) stone;
    
    b2Body* stoneBody = world->CreateBody(&stoneBodyDef);
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED/10, 0);
    //    treasureBody->ApplyLinearImpulse(force, treasureBodyDef.position);
    stoneBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = stone.contentSize.width/2;
    
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
    spaceStationBodyDef.position.Set(50, winSize.height/2);
    spaceStationBodyDef.userData = spaceStation;
    
    
    
    
    spaceStationBodyDef.userData = (__bridge_retained void*) spaceStation;
    
    spaceStationBody = world->CreateBody(&spaceStationBodyDef);
    
    
    b2CircleShape circle;
    circle.m_radius = spaceStation.contentSize.width/2;
    
    b2FixtureDef spaceStationShapeDef;
    spaceStationShapeDef.shape = &circle;
    spaceStationShapeDef.density = 100.0f;
    spaceStationShapeDef.friction = 0.f;
    spaceStationShapeDef.restitution = 1.0f;
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
    
    if(isPlayerMoveBack)
    {
        [self pauseSchedulerAndActions];
        [player crashTransformAction];
        
        b2Vec2 position1(winSize.width/5*4, player.position.y);
        player->playerBody->SetTransform(position1, 0.0);
        
        [self unschedule:@selector(playerMoveFinished:)];
        [self unschedule:@selector(gameLogic:)];
        [self unschedule:@selector(gameStoneLogic:)];
        [self unschedule:@selector(addTreasure:)];
        [self treasureBack];
        isPlayerMoveBack=false;
    }
    else
    {
        b2Vec2 position1(player.position.x, newY);
        player->playerBody->SetTransform(position1, 0.0);
    }
    
    
}


- (void)pauseButtonSelected {
    //    [self zoomPause];
    
        if (![[GameScene sharedGameScene] isShowingPausedMenu]) {
            [[GameScene sharedGameScene] setShowingPausedMenu:YES];
            [[GameScene sharedGameScene] showPausedMenu];
            [[CCDirector sharedDirector] pause];
    
        }
    
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
    distance += dt*100;
    [hudLayer updateDistanceCounter:distance];
    [self updateShip];
}

- (void) dealloc
{
    [[SimpleAudioEngine sharedEngine] stopEffect:firstBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] stopEffect:secondBackgroundMusic];
	[super dealloc];
}

@end
