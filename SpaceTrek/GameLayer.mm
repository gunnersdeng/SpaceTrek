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
        _treasures = [[NSMutableArray alloc] init];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        //player = [[GameObject alloc] init];
        player = [Player spriteWithSpriteFrameName:@"spaceship1.png"];
        [player setType:(gameObjectPlayer)];
        [player initAnimation:allBatchNode];

        /*
        player = [GameObject spriteWithFile:@"spaceship-level-2.png"];
        [player setType:gameObjectPlayer];
        [self schedule:@selector(updateShip_1:) interval:0.2];
        [self schedule:@selector(updateShip_2:) interval:0.4];
        */
        player.position = ccp(player.contentSize.width/2, winSize.height/2);
        player.tag = PLAYER_TAG;
        [player createBox2dObject:world];
        [self addSpaceStation];
        /*
        int actualDuration = winSize.width/5.0/TRAVEL_SPEED;
        // Create the actions
        id actionMove = [CCMoveTo actionWithDuration:actualDuration
                                            position:ccp(winSize.width/5, winSize.height/2)];
        
        id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                                 selector:@selector(playerMoveFinished:)];
        
        [player runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
        */
       
        
        /*b2BodyDef playerBodyDef;
        playerBodyDef.type = b2_dynamicBody;
        playerBodyDef.position.Set(player.contentSize.width/2, winSize.height/2);
        playerBodyDef.userData = player;
        playerBody = world->CreateBody(&playerBodyDef);
        
        
        
        b2Vec2 force = b2Vec2(100, 0);
        playerBody->ApplyLinearImpulse(force, playerBodyDef.position);
        
        b2CircleShape circle;
        circle.m_radius = player.contentSize.height/2;
        
        b2FixtureDef playerShapeDef;
        playerShapeDef.shape = &circle;
        playerShapeDef.density = 1.0f;
        playerShapeDef.friction = 0.f;
        playerShapeDef.restitution = 1.0f;
        playerShapeDef.filter.categoryBits =  0x1;
        playerShapeDef.filter.maskBits =  0xFFFF;
        
        playerBody->CreateFixture(&playerShapeDef);
        */
        
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
/*
- (void)updateShip_1:(ccTime)dt{
    if(!collision)[player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"spaceship-level-2.png"]];
    else[player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"LittleCat.png"]];
}

- (void)updateShip_2:(ccTime)dt{
    if(!collision)[player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"spaceship-level-2-2.png"]];
    else [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"LittleCat.png"]];
    
}
*/
-(void) playerMoveFinished: (id)sender{
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED, 0);
    spaceStationBody->SetLinearVelocity(force);
    [self schedule:@selector(gameLogic:) interval:1.0];
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
            if(treasureData!=NULL && treasureData.tag==SPACESTATION_TAG && fabs(treasureData.position.x-winSize.width/2)<=10 && isStationMoveBack)
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
    world->SetGravity(b2Vec2(-3.0f, 0.0f));
   //[self unschedule:@selector(treasureMovementLogic:)];

    //[self unscheduleAllSelectors];
   //[self schedule:@selector(JumpToGameOverScene:) interval:3.0f];
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
//    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
//        if (b->GetUserData() != NULL) {
//            CCSprite *treasureData = (CCSprite *)b->GetUserData();
//            
//            /*if(treasureData.tag==TREASURE_TAG)
//            {
//                b2Vec2 force = b2Vec2(-b->GetLinearVelocity().x, -b->GetLinearVelocity().y);
//                b->SetLinearVelocity(force);
//            }*/
//            if(treasureData.tag==PLAYER_TAG)
//            {
//                
//                b2Vec2 force = b2Vec2(TRAVEL_SPEED, 0);
//                b->SetLinearVelocity(force);
    
//                
//                b2Vec2 force = b2Vec2(10000000,0);
//                b->ApplyForce(force, b->GetWorldCenter());
                
                
                
                isPlayerMoveBack = true;
                isStationMoveBack = true;
//            }
//
//        }
//    }
    
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
        }
    }
    
}



-(void)gameLogic:(ccTime)dt {
    [self addTreasure];
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
    if ( arc4random()%2==0 ){
        treasure = [GameObject spriteWithFile:@"treasure_type_2_blk.png"];
        treasure.scale = 1.5;
    }else{
        treasure = [GameObject spriteWithFile:@"treasure_type_1_y.png"];
        treasure.scale = 2;
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
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED*20, (treasureDestinationY-treasureStartY)/(winSize.width/TRAVEL_SPEED)*10);
//    treasureBody->ApplyLinearImpulse(force, treasureBodyDef.position);
    treasureBody->SetLinearVelocity(force);
    
    b2CircleShape circle;
    circle.m_radius = treasure.contentSize.width/2;
    
    b2FixtureDef treasureShapeDef;
    treasureShapeDef.shape = &circle;
    treasureShapeDef.density = 1.0f;
    treasureShapeDef.friction = 0.2f;
    treasureShapeDef.restitution = 1.0f;
    treasureShapeDef.filter.categoryBits = 0x2;
    treasureShapeDef.filter.maskBits = 0xFFFF-0x2;
   
    treasureBody->CreateFixture(&treasureShapeDef);
    

}
-(void)addBackgroundTreasure
{
    GameObject *treasure;
    treasure = [[GameObject alloc] init];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    if ( arc4random()%2==0 ){
        treasure = [GameObject spriteWithFile:@""];
        treasure.scale = 1.5;
    }else{
        treasure = [GameObject spriteWithFile:@""];
        treasure.scale = 2;
    }
    treasure.tag = BACKGROUND_TREASURE_TAG;
    [treasure setType:gameObjectBackgroundTreasure];
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
    
    b2Vec2 force = b2Vec2(-TRAVEL_SPEED/10, (treasureDestinationY-treasureStartY)/(winSize.width/TRAVEL_SPEED));
    treasureBody->ApplyLinearImpulse(force, treasureBodyDef.position);
    
    b2CircleShape circle;
    circle.m_radius = treasure.contentSize.width/2;
    
    b2FixtureDef treasureShapeDef;
    treasureShapeDef.shape = &circle;
    treasureShapeDef.density = 1.0f;
    treasureShapeDef.friction = 0.f;
    treasureShapeDef.restitution = 1.0f;
    treasureShapeDef.filter.categoryBits = 0x2;
    treasureShapeDef.filter.maskBits = 0xFFFF-0x2-0x1-0x3;
    
    treasureBody->CreateFixture(&treasureShapeDef);
    
    
}

/*
-(void)addTreasure {
    
    CCSprite *treasure;
    if ( arc4random()%2==0 ){
        treasure = [CCSprite spriteWithFile:@"treasure_type_2_blk.png"];
        treasure.scale = 1.5;
    }else{
        treasure = [CCSprite spriteWithFile:@"treasure_type_1_y.png"];
        treasure.scale = 2;
    }
    
    
    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    [self addChild:treasure];
    
    int treasureStartY = GetRandom( treasure.contentSize.height/2, winSize.height - treasure.contentSize.height/2 );
    int treasureDestinationY = GetRandomGaussian( treasureStartY-winSize.height, treasureStartY+winSize.height );
    
    treasure.position = ccp(winSize.width - treasure.contentSize.width/2, treasureStartY);
    
    int x = winSize.width - treasure.contentSize.width/2+LEFTBOUNDARYSAVETREASURE;
    int y = treasureStartY;
    int destY = treasureDestinationY;
    
    CCSequence *seq = nil;
    
    while ( x>0 ){
        int dx=0, dy=0;
        if ( 0<=destY && destY<=winSize.height ){
            dx = 0; dy = destY;
        }
        else if ( destY<0 ){
            destY = -destY;
            dx = (int)( (double)x/(y+destY)*destY );
            dy = 0;
        }
        else if ( destY>winSize.height ){
            dx = (int)( (double)x/((winSize.height-y)+(destY-winSize.height))*(destY-winSize.height) );
            dy = winSize.height;
            destY = winSize.height*2-destY;
        }
        
        // Create the actions
        int actualDuration = (x-dx) / TRAVEL_SPEED;
        id actionMove = [CCMoveTo actionWithDuration:actualDuration
                                            position:ccp(dx-LEFTBOUNDARYSAVETREASURE, dy)];
        
        if (!seq)
        {
            seq = (CCSequence *)actionMove;
        }
        else
        {
            seq = [CCSequence actionOne:seq two:actionMove];
        }
        x = dx; y = dy;
    }
    
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(treasureMoveFinished:)];
    
    
    
    CCRotateBy *rotateAction = [CCRotateBy actionWithDuration:10 angle:360];
    
    [treasure runAction:[CCSequence actions:seq, actionMoveDone, nil]];
    [treasure runAction:rotateAction];
    
    treasure.tag =1;
    [_treasures addObject:treasure];
}

*/
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
