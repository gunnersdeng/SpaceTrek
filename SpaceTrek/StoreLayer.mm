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

@implementation StoreLayer


- (id) init{
    
	if ((self = [super initWithColor:ccc4(139, 137, 137, 200)]))
    {
    
        
        self.isTouchEnabled = YES;
        self.tag=STORE_LAYER_TAG;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
    
        
        storeBackground= [CCSprite spriteWithFile:@"storeBackground.png"];
        storeBackground.position = ccp(winSize.width/2 , winSize.height/2);

        
        [self addProperty];
        
        [self addChild:storeBackground z:1];
    
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
    
    PropertyMenu = [CCMenu menuWithItems:property1, property2, property3, nil];
    [PropertyMenu setAnchorPoint: ccp(0.0f, 1.0f)];
    [PropertyMenu setPosition:ccp(584, 653)];
    
    [PropertyMenu alignItemsHorizontallyWithPadding:45.0f];
    [self addChild:PropertyMenu z:3];
}


-(void) storeMenuAction
{
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene]]];
}
-(void) storePropertySelected1
{
    property1.visible = false;
    purcharsedProperty.insert(1);
}
-(void) storePropertySelected2
{
    property2.visible = false;
    purcharsedProperty.insert(2);
}
-(void) storePropertySelected3
{
    property3.visible = false;
    purcharsedProperty.insert(3);
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
