//
//  Constants.h
//  SpaceTrek
//
//  Created by Deng Ziheng on 10/6/13.
//  Copyright (c) 2013 Deng Ziheng. All rights reserved.
//

#ifndef SpaceTrek_Constants_h
#define SpaceTrek_Constants_h

#define TRAVEL_SPEED 150
#define MINTREASURE_DES_X 250
#define LEFTBOUNDARYSAVETREASURE 1024
#define BGTOPDURATION 100

#define GAME_STATE_ONE 1
#define GAME_STATE_TWO 2
#define GAME_STATE_THREE 3

#define BACKGROUND_LAYER_TAG 0
#define HUD_LAYER_TAG 1
#define GAME_LAYER_TAG 2
#define PAUSE_LAYER_TAG 3

#define PLAYER_TAG 0
#define COLLECTOR_TAG 1
#define TREASURE_TAG 2
#define TREASURE_DESTROY_TAG 3
#define SPACESTATION_TAG 4



typedef enum {
    gameObjectGeneral=0,
    gameObjectPlayer=1,
    gameObjectCollector=2,
    gameObjectTreasure1=3,
    gameObjectSpaceStation=4
} GameObjectType;


#endif
