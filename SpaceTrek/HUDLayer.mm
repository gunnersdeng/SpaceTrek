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

@implementation HUDLayer

int hudLevel;

+(HUDLayer*) getHUDLayer {
    return self;
}

-(id) init
{
	if ((self = [super init]))
	{
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.tag=HUD_LAYER_TAG;
        statusBar= [CCSprite spriteWithFile:@"StatusBar.png"];
        statusBar.position = ccp(45, winSize.height/2);
        
        distanceLabel = [CCLabelTTF labelWithString:@"0" fontName:@"arial" fontSize:35];
        distanceLabel.rotation = 90;
        [distanceLabel setColor:ccORANGE];
        [distanceLabel setAnchorPoint:ccp(0.5f,1)];
        [distanceLabel setPosition:ccp(63, 100)];
        
        [self addProperty];
        
        [self addChild:statusBar z:2];
        [statusBar addChild:distanceLabel z:30];
        
    }
    return self;
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
    for (it=purcharsedProperty.begin(); it!=purcharsedProperty.end(); ++it)
    {
        
        switch (*it) {
            case 1:
                property1 = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_SHIELD_2TIMES.png" selectedImage:@"TOOLBAR_SHIELD_2TIMES.png" target:self selector:@selector(propertySelected1)];
                property1.tag = TREASURE_PROPERTY_TYPE_1_TAG;
                [PropertyMenu addChild:property1];
                break;
            case 2:
                property2 = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_Invincible15s.png" selectedImage:@"TOOLBAR_Invincible15s.png" target:self selector:@selector(propertySelected2)];
                property2.tag = TREASURE_PROPERTY_TYPE_2_TAG;
                [PropertyMenu addChild:property2];
                break;
            case 3:
                property3 = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_Magnet.png" selectedImage:@"TOOLBAR_Magnet.png" target:self selector:@selector(propertySelected3)];
                property3.tag = TREASURE_PROPERTY_TYPE_3_TAG;
                [PropertyMenu addChild:property3];
                break;
            case 4:
                property4 = [CCMenuItemImage itemWithNormalImage:@"TOOLBAR_Magnet.png" selectedImage:@"TOOLBAR_Magnet.png" target:self selector:@selector(propertySelected4)];
                property4.tag = TREASURE_PROPERTY_TYPE_4_TAG;
                [PropertyMenu addChild:property3];
                break;
            default:
                break;
        }
        
    }
    
    
    
    [PropertyMenu setAnchorPoint: ccp(0.0f, 1.0f)];
    [PropertyMenu setPosition:ccp(46, 443)];
    
    [PropertyMenu alignItemsVerticallyWithPadding:9.0f];
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

@end