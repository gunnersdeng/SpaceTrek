//
//  HelpLayer.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-22.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "HelpLayer.h"
#import "Constants.h"
#import "MainMenuScene.h"

@implementation HelpLayer


- (id) init{
    
	if ((self = [super initWithColor:ccc4(139, 137, 137, 200)]))
    {
        
        
        self.isTouchEnabled = YES;
        self.tag=Help_LAYER_TAG;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        
        HelpBackground= [CCSprite spriteWithFile:@"help_Background.png"];
        HelpBackground.position = ccp(winSize.width/2 , winSize.height/2);
        
        [self addChild:HelpBackground z:1];
        
    }
    return self;
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
