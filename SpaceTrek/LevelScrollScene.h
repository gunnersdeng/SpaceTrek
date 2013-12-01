//
//  LevelScrollScene.h
//  SpaceTrek
//
//  Created by huang yongke on 13-11-5.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LevelScrollScene : CCLayer {
    CCMenu *Menu1, *Menu2, *Menu3;
    CCMenuItem *button1, *button2, *button3;
    bool button1Selected, button2Selected, button3Selected;
}

+(CCScene *) scene;

@end