//
//  GameOver.h
//  SpaceTrek
//
//  Created by huang yongke on 13-10-20.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"

@interface GameOverScene : CCLayer {
    CCLabelTTF *labelScore;
    CCLabelTTF *labelDistance;
    
    CCMenuItemImage *buttonRestart;
    
    CCMenuItemImage *buttonMenu;
}
+(CCScene *) sceneWithLevel:(int)level Score:(int)score Distance:(int)distance;
@end
