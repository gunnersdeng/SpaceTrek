//
//  HUDLayer.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-19.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "HUDLayer.h"
#import "GameScene.h"
#import <vector>
#import "Global.h"
#import "PauseLayer.h"

@implementation HUDLayer

int hudLevel;

+(HUDLayer*) getHUDLayer {
    return self;
}

-(id) initWithLevel:(int)state
{
	if ((self = [super init]))
	{
        shadow0= [CCSprite spriteWithFile:@"background-shadow-0.png"];
        shadow1= [CCSprite spriteWithFile:@"background-shadow-1.png"];
        shadow2= [CCSprite spriteWithFile:@"background-shadow-2.png"];
        shadow4= [CCSprite spriteWithFile:@"background-shadow-4.png"];
        
        hudLevel = state;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.tag=HUD_LAYER_TAG;
        statusBar= [CCSprite spriteWithFile:@"StatusBar.png"];
        statusBar.position = ccp(90, winSize.height/2);
        
        pointer = [CCSprite spriteWithFile:@"pointer.png"];
        [pointer setAnchorPoint:ccp(3.0/8.0, 0.5)];
        pointer.position = ccp(100, winSize.height/5*4+40);
        pointer.rotation = 90;
        [statusBar addChild:pointer z:5];
        
        isShowingPausedMenu = false;
        
        distanceLabel = [CCLabelTTF labelWithString:@"0" fontName:@"arial" fontSize:35];
        distanceLabel.rotation = 90;
        [distanceLabel setColor:ccORANGE];
        [distanceLabel setAnchorPoint:ccp(0.5f,1)];
        [distanceLabel setPosition:ccp(63, 100)];
        
        [self addProperty];
        
        [self addChild:statusBar z:2];
        [statusBar addChild:distanceLabel z:30];
     
        switch (state) {
            case GAME_STATE_ONE:
                shadow = NULL;
            break;
            case GAME_STATE_TWO:
                shadow= [CCSprite spriteWithFile:@"background-shadow-0.png"];
                [shadow setAnchorPoint: ccp(0,0.5)];
                [shadow setPosition: ccp(0, winSize.height/2)];
                [self addChild:shadow z:1 tag:SHADOW_TAG];
            break;
            case GAME_STATE_THREE:
                shadow = NULL;
            break;
            default:
            break;
        }
        
        
        
        pauseButton = [CCMenuItemImage itemWithNormalImage:@"Button-Pause-icon-modified.png" selectedImage:@"Button-Pause-icon-modified.png" target:self selector:@selector(pauseButtonSelectedCur)];
        pauseButton.scale = 0.8;
        pauseButton.rotation = 90;
        
        pauseMenu = [CCMenu menuWithItems:pauseButton, nil];
        pauseMenu.position=ccp(980, 700);
        
        [pauseMenu alignItemsVerticallyWithPadding:10.0f];
        [self addChild:pauseMenu z:2];

   }
    return self;
}
-(void) setShadowPosition: (int) x yy:(int) y
{
    if ( shadow!=NULL ){
        [shadow setPosition: ccp(0, y)];
    }
}
-(void) setShadow: (int) index
{
    [self removeChildByTag:SHADOW_TAG];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    shadow= [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-shadow-%d.png", index]];
    [shadow setAnchorPoint: ccp(0,0.5)];
    [shadow setPosition: ccp(0, winSize.height/2)];
    [self addChild:shadow z:1 tag:SHADOW_TAG];
}
-(void) updateDistanceCounter:(int)amount
{
    NSString *amounts = [NSString stringWithFormat:@"%d", (int)amount];
    [distanceLabel setString:amounts];
}

-(void)addProperty
{
    PropertyMenu = [CCMenu menuWithItems: nil];
    std::set<int>::iterator it;
    int num = 0;
    for (it=purcharsedProperty.begin(); it!=purcharsedProperty.end(); ++it)
    {
        if(num>=5)
            break;
        
        switch (*it) {
            case 1:
                property1 = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_SHIELD_2TIMES.png" selectedImage:@"TOOLBAR_SHIELD_2TIMES.png" target:self selector:@selector(propertySelected1)];
                property1.tag = TREASURE_PROPERTY_TYPE_1_TAG;
                [PropertyMenu addChild:property1];
                num++;
                break;
            case 2:
                property2 = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_Invincible15s.png" selectedImage:@"TOOLBAR_Invincible15s.png" target:self selector:@selector(propertySelected2)];
                property2.tag = TREASURE_PROPERTY_TYPE_2_TAG;
                [PropertyMenu addChild:property2];
                num++;
                break;
            case 3:
                property3 = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_Magnet.png" selectedImage:@"TOOLBAR_Magnet.png" target:self selector:@selector(propertySelected3)];
                property3.tag = TREASURE_PROPERTY_TYPE_3_TAG;
                [PropertyMenu addChild:property3];
                num++;
                break;
            case 4:
                property4 = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_Bullet.png" selectedImage:@"TOOLBAR_Bullet.png" target:self selector:@selector(propertySelected4)];
                property4.tag = TREASURE_PROPERTY_TYPE_4_TAG;
                [PropertyMenu addChild:property4];
                num++;
                break;
            case 5:
                property5 = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_Toucharea.png" selectedImage:@"TOOLBAR_Toucharea.png" target:self selector:@selector(propertySelected5)];
                property5.tag = TREASURE_PROPERTY_TYPE_5_TAG;
                [PropertyMenu addChild:property5];
                num++;
                break;
            case 6:
                if(hudLevel!=2)
                    break;
                property6 = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_Toucharea.png" selectedImage:@"TOOLBAR_Toucharea.png" target:self selector:@selector(propertySelected6)];
                property6.tag = TREASURE_PROPERTY_TYPE_6_TAG;
                [PropertyMenu addChild:property6];
                num++;
                break;
            default:
                break;
        }
        
    }
    
    for (int i=0; i<5-num; i++){
        propertyNull = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_empty.png" selectedImage:@"TOOLBAR_empty.png" target:self selector:@selector(propertySelectedNull)];
        propertyNull.tag = TREASURE_PROPERTY_TYPE_4_NULL;
        [PropertyMenu addChild:propertyNull];
    }
    
    //[PropertyMenu setAnchorPoint: ccp(0.0f, 1.0f)];
    //[PropertyMenu setPosition:ccp(46, 443)];
    
    //[PropertyMenu setAnchorPoint: ccp(-10.0f, 10.0f)];
    [PropertyMenu setPosition:ccp(37, 385)];
    
    [PropertyMenu alignItemsVerticallyWithPadding:8.5f];
    [self addChild:PropertyMenu z:3];
}

-(void) propertySelected1
{
    CCScene* scene = [[CCDirector sharedDirector] runningScene];
    GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
    bool used = [layer propertyListener:property1.tag];
    if ( used ){
        [PropertyMenu removeChild:property1];
        purcharsedProperty.erase(1);
    }
}

-(void) propertySelected2
{
    CCScene* scene = [[CCDirector sharedDirector] runningScene];
    GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
    bool used = [layer propertyListener:property2.tag];
    if ( used ){
        [PropertyMenu removeChild:property2];
        purcharsedProperty.erase(2);
    }
}

-(void) propertySelected3
{
    CCScene* scene = [[CCDirector sharedDirector] runningScene];
    GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
    bool used = [layer propertyListener:property3.tag];
    if ( used ){
        [PropertyMenu removeChild:property3];
        purcharsedProperty.erase(3);
    }
}

-(void) propertySelected4
{
    CCScene* scene = [[CCDirector sharedDirector] runningScene];
    GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
    bool used = [layer propertyListener:property4.tag];
    if ( used ){
        [PropertyMenu removeChild:property4];
        purcharsedProperty.erase(4);
    }
}
-(void) propertySelected5
{
    CCScene* scene = [[CCDirector sharedDirector] runningScene];
    GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
    bool used = [layer propertyListener:property5.tag];
    if ( used ){
        [PropertyMenu removeChild:property5];
        purcharsedProperty.erase(5);
    }
}
-(void) propertySelected6
{
    CCScene* scene = [[CCDirector sharedDirector] runningScene];
    GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
    bool used = [layer propertyListener:property6.tag];
    if ( used ){
        [PropertyMenu removeChild:property6];
        purcharsedProperty.erase(6);
    }
}
-(void) propertySelectedNull
{
}

-(void) pauseButtonSelectedCur
{
    if (!isShowingPausedMenu) {
        CCScene* scene = [[CCDirector sharedDirector] runningScene];
        GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
        
        isShowingPausedMenu = true;
        PauseLayer *pauzy = [[PauseLayer alloc] initWithLevel: (int)(layer->getLevel)];
        [self addChild:pauzy z:10 tag:PAUSE_LAYER_TAG];
        [[CCDirector sharedDirector] pause];
        
    }
}

-(void) disablePauseMenu
{
    isShowingPausedMenu = false;
    [self removeChildByTag:PAUSE_LAYER_TAG cleanup:YES];
}

-(void) updatePointer:(int)amount
{
    pointer.rotation = (amount/MAX_DISTANCE)*180-90;
}

@end