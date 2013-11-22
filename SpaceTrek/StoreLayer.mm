//
//  StoreLayer.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-22.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "StoreLayer.h"
#import "Constants.h"
#import "MainMenuScene.h"


std::set<int> purcharsedProperty;
int gold;
bool firstTime;

@implementation StoreLayer


- (id) init{
    
	if ((self = [super initWithColor:ccc4(139, 137, 137, 200)]))
    {        
        if(!firstTime){
            firstTime = true;
            gold = 3000;
        }
        
        
        self.isTouchEnabled = YES;
        self.tag=STORE_LAYER_TAG;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
    
        
        storeBackground= [CCSprite spriteWithFile:@"storeBackground.png"];
        storeBackground.position = ccp(winSize.width/2 , winSize.height/2);

        
        [self addProperty];
        
        [self addChild:storeBackground z:1];
    
        goldLabel = [CCLabelTTF labelWithString:@"0" fontName:@"arial" fontSize:35];
        NSString *golds = [NSString stringWithFormat:@"%d", (int)gold];
        [goldLabel setString:golds];
        goldLabel.rotation = 90;
        [goldLabel setColor:ccORANGE];
        [goldLabel setAnchorPoint:ccp(0.5f,1)];
        [goldLabel setPosition:ccp(863, 400)];
        
        [storeBackground addChild:goldLabel z:30];
        
    }
    return self;
}

-(void)addProperty
{
    property1 = [CCMenuItemImage itemWithNormalImage:@"STORE_SHIELD_2TIMES.png" selectedImage:@"STORE_SHIELD_2TIMES.png" target:self selector:@selector(storePropertySelected1)];
    property1.tag = STORE_PROPERTY_TYPE_1_TAG;
    
    property2 = [CCMenuItemImage itemWithNormalImage:@"STORE_Invincible15s.png" selectedImage:@"STORE_Invincible15s.png" target:self selector:@selector(storePropertySelected2)];
    property2.tag = STORE_PROPERTY_TYPE_2_TAG;
    
    property3 = [CCMenuItemImage itemWithNormalImage:@"STORE_Magnet.png" selectedImage:@"STORE_Magnet.png" target:self selector:@selector(storePropertySelected3)];
    property3.tag = STORE_PROPERTY_TYPE_3_TAG;
   
    property4 = [CCMenuItemImage itemWithNormalImage:@"STORE_Bullet.png" selectedImage:@"STORE_Bullet.png" target:self selector:@selector(storePropertySelected4)];
    property4.tag = STORE_PROPERTY_TYPE_4_TAG;
    
    property5 = [CCMenuItemImage itemWithNormalImage:@"STORE_Toucharea.png" selectedImage:@"STORE_Toucharea.png" target:self selector:@selector(storePropertySelected5)];
    property5.tag = STORE_PROPERTY_TYPE_5_TAG;
    
    property6 = [CCMenuItemImage itemWithNormalImage:@"STORE_Toucharea.png" selectedImage:@"STORE_Toucharea.png" target:self selector:@selector(storePropertySelected6)];
    property6.tag = STORE_PROPERTY_TYPE_6_TAG;
    
    PropertyMenu = [CCMenu menuWithItems:property1, property2, property3,property4,property5, nil];
    [PropertyMenu setAnchorPoint: ccp(0.0f, 1.0f)];
    [PropertyMenu setPosition:ccp(714, 383)];
    
    [PropertyMenu alignItemsVerticallyWithPadding:35.0f];
    [self addChild:PropertyMenu z:3];
    
    PropertyMenu2 = [CCMenu menuWithItems:property6, nil];
    [PropertyMenu2 setAnchorPoint: ccp(0.0f, 0.0f)];
    [PropertyMenu2 setPosition:ccp(574, 653)];
    
    [PropertyMenu2 alignItemsVerticallyWithPadding:35.0f];
    [self addChild:PropertyMenu2 z:3];

}


-(void) storeMenuAction
{
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene]]];
}
-(void) storePropertySelected1
{
    if(gold<400)
        return;
    gold -= 400;
    NSString *golds = [NSString stringWithFormat:@"%d", (int)gold];
    [goldLabel setString:golds];
    property1.visible = false;
//    [self removeChild:property1];
    purcharsedProperty.insert(1);
    
}
-(void) storePropertySelected2
{
    if(gold<600)
        return;
    gold -= 600;
    NSString *golds = [NSString stringWithFormat:@"%d", (int)gold];
    [goldLabel setString:golds];
    property2.visible = false;
//    [self removeChild:property2];
    purcharsedProperty.insert(2);
    
}
-(void) storePropertySelected3
{
    if(gold<500)
        return;
    gold -= 500;
    NSString *golds = [NSString stringWithFormat:@"%d", (int)gold];
    [goldLabel setString:golds];
    property3.visible = false;
//    [self removeChild:property3];
    purcharsedProperty.insert(3);
    
}
-(void) storePropertySelected4
{
    if(gold<500)
        return;
    gold -= 500;
    NSString *golds = [NSString stringWithFormat:@"%d", (int)gold];
    [goldLabel setString:golds];

    property4.visible = false;
//    [self removeChild:property4];
    purcharsedProperty.insert(4);
}

-(void) storePropertySelected5
{
    if(gold<300)
        return;
    gold -= 300;
    NSString *golds = [NSString stringWithFormat:@"%d", (int)gold];
    [goldLabel setString:golds];

    property5.visible = false;
    //    [self removeChild:property4];
    purcharsedProperty.insert(5);
}

-(void) storePropertySelected6
{
    if(gold<300)
        return;
    gold -= 300;
    NSString *golds = [NSString stringWithFormat:@"%d", (int)gold];
    [goldLabel setString:golds];
    property6.visible = false;
    //    [self removeChild:property4];
    purcharsedProperty.insert(6);
    
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
//    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    CGRect mySurface = (CGRectMake(0, 0, 1320, 1480));//x坐标,y坐标,宽度width,高度height;
    
    if(CGRectContainsPoint(mySurface, location)) {
	    NSLog(@"Event Handled");
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene]]];
    }
}



@end
