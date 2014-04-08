//
//  GameScene.m
//  Slash It!
//
//  Created by Savan on 3/23/14.
//  Copyright (c) 2014 Savan Rupani. All rights reserved.
//

#import "GameScene.h"
#import "Math.h"
#import "ViewController.h"
#import "LevelScreenViewController.h"
static const uint8_t boundry   =  0x1 << 1;
static const uint8_t catd      =  0x1 << 2;
static const uint8_t lined     =  0x1 << 3;
static const uint8_t selfContainer = 0x1 << 4;
static const double infinity = 9999999999;

@implementation GameScene{

    //Stores random moving objects
    NSMutableArray *myObjects;
    
    //Stores polygon points
    NSMutableArray *polygonPoints,*polygonLowerBoundPoints,*polygonUpperBoundPoints;
    
    //stores polygon path
    CGMutablePathRef polygonPath,polygonPath1,polygonPath2;
    
    //lineCut path
    CGMutablePathRef pathToDraw;
    
    SKShapeNode *polygonBoundry,*lineCut,*polygon1,*polygon2;
    CGPoint lineCutFirstPoint,lineCutSecondPoint;
    
    float objectOrientationSign;
    float ix1,ix2,iy1,iy2;
    float areaOfPolygonPercentage;
    float areaOfPolygonBefore;
    float areaOfPolygonCurrent;
    
    
    SKAction *backgroundmusic;
    SKAction *cutmusic;
    
}


-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.scaleMode = SKSceneScaleModeAspectFit;
        self.physicsWorld.gravity = CGVectorMake(0.0f,0.0f);
        self.physicsBody.categoryBitMask = selfContainer;
        self.physicsWorld.contactDelegate = self;
        self.physicsBody.node.name = @"body";
        
        /* Setup your scene here */
        NSLog(@"Screen Size: %f %f",self.frame.size.width,self.frame.size.height);
    
        myObjects = [[NSMutableArray alloc] init];
        polygonPoints = [[NSMutableArray alloc] init];
        polygonBoundry = [[SKShapeNode alloc]init];
        
        polygon1 = [[SKShapeNode alloc]init];
        polygon2 = [[SKShapeNode alloc]init];
        
        
        polygonLowerBoundPoints = [[NSMutableArray alloc] init];
        polygonUpperBoundPoints = [[NSMutableArray alloc] init];
        
        
        self.numberOfObjects = 0;
        self.environmentName = NULL;
        self.levelName = NULL;
        self.intersectionCount =0;
        self.drawLineCut = 1;
        
        cutmusic = [SKAction playSoundFileNamed:@"cut.mp3" waitForCompletion:NO];
    }
    return self;
}


-(void)draw{
    
    NSString *plistLevel = [[NSBundle mainBundle] pathForResource:@"Level-plist" ofType:@"plist"];
    
    NSDictionary *environmentDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistLevel];
    NSDictionary *levelDictionary = [[NSDictionary alloc] initWithDictionary:[environmentDictionary objectForKey:self.environmentName]];
    
    NSArray *tempLevel = [[NSArray alloc] init];
    tempLevel = [NSArray arrayWithArray:[levelDictionary objectForKey:self.levelName]];
    
    for (int i=0; i<tempLevel.count; i++) {
        NSArray *tempPoint = [[NSArray alloc] initWithArray:[tempLevel objectAtIndex:i]];
        CGFloat p1,p2;
        
        p1 =[[tempPoint objectAtIndex:0] floatValue];
        p2 =[[tempPoint objectAtIndex:1] floatValue];
        [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake(p1,p2)]];
    }
    
    NSArray *tempPoint = [[NSArray alloc] initWithArray:[tempLevel objectAtIndex:0]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:CGPointMake([[tempPoint objectAtIndex:0] floatValue],[[tempPoint objectAtIndex:1] floatValue])]];
    
    polygonBoundry = [self makePolygon:polygonPoints flag:0];
    
    [self addChild:polygonBoundry];
    [self spawnObjects:3];
    areaOfPolygonBefore = [self areaOfPolygon:polygonPoints];
    areaOfPolygonPercentage = 100;
    
    NSLog(@"Remaining Area :: %f",areaOfPolygonPercentage);
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSSet *allTouches = [event allTouches];
    if([allTouches count]==1){
        if(lineCut){
            [lineCut removeFromParent];
        }
        
        UITouch* touch = [touches anyObject];
        CGPoint tempPoint = [touch locationInNode:self];
        
        if(!CGPathContainsPoint(polygonPath, NULL,tempPoint,NULL)){
            self.drawLineCut=1;
            // Called when a touch begins
            UITouch* touch = [touches anyObject];
            lineCutFirstPoint = [touch locationInNode:self];
            pathToDraw = CGPathCreateMutable();
            CGPathMoveToPoint(pathToDraw, NULL, lineCutFirstPoint.x, lineCutFirstPoint.y);
            lineCut = [SKShapeNode node];
            lineCut.path = pathToDraw;
            lineCut.strokeColor = [SKColor redColor];
            [self addChild:lineCut];
        }else{
            self.drawLineCut = 0;
        }
    }else{
        if(lineCut)
            [lineCut removeFromParent];
        SKSpriteNode *tempNode;
        
        lineCutFirstPoint = [tempNode position];
        lineCutSecondPoint = [tempNode position];
        
    }
    
    
}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
    NSSet *allTouches = [event allTouches];
    
    if([allTouches count] == 1){
        if(self.drawLineCut ==1){
            UITouch* touch = [touches anyObject];
            lineCutSecondPoint = [touch locationInNode:self];
            
            pathToDraw = CGPathCreateMutable();
            
            CGPathMoveToPoint(pathToDraw, NULL, lineCutFirstPoint.x,lineCutFirstPoint.y);
            CGPathAddLineToPoint(pathToDraw, NULL, lineCutSecondPoint.x, lineCutSecondPoint.y);
            lineCut.path = pathToDraw;
            lineCut.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:lineCutFirstPoint toPoint:lineCutSecondPoint];
            lineCut.physicsBody.categoryBitMask = lined;
            lineCut.physicsBody.contactTestBitMask = catd|boundry;
            lineCut.physicsBody.node.name = @"lineCut";
            
            [self checkOnlyLineIntersection];
            
            if(self.intersectionCount>=2){
                bool ch = [self checkObjectPosition];
                
                if (ch != 0) {
                    
                    [self checkPolygon1];// get points1
                    [self checkPolygon2];// get points2
                    
                    polygon1 = [self makePolygon:polygonLowerBoundPoints flag:1];//get cgpath
                    polygon2 = [self makePolygon:polygonUpperBoundPoints flag:2];//get cgpath
                    
                    SKSpriteNode *tempNode;
                    int pf1=0,pf2=0;
                    for (tempNode in myObjects){
                        CGPoint tempCGPoint;
                        tempCGPoint = [tempNode position];
                        
                        if(CGPathContainsPoint(polygonPath1, NULL,tempCGPoint,NULL)){
                            pf1=1;
                            [polygonPoints removeAllObjects];
                            [polygonPoints addObjectsFromArray:polygonLowerBoundPoints];
                        }else{
                            pf2=1;
                            [polygonPoints removeAllObjects];
                            [polygonPoints addObjectsFromArray:polygonUpperBoundPoints];
                        }
                        
                    }
                    if(pf1==1 && pf2==1){
                        
                    }else{
                        if(pf1==1){
                            [polygonPoints removeAllObjects];
                            [polygonPoints addObjectsFromArray:polygonLowerBoundPoints];
                            
                        }else{
                            [polygonPoints removeAllObjects];
                            [polygonPoints addObjectsFromArray:polygonUpperBoundPoints];
                        }
                        
                        
                        [self changePolygon:polygonPoints];
                        [self runAction:cutmusic];
                        
                        areaOfPolygonCurrent = [self areaOfPolygon:polygonPoints];
                        areaOfPolygonPercentage = 100 - (((areaOfPolygonBefore -areaOfPolygonCurrent)/areaOfPolygonBefore)*100);
                        
                        NSLog(@"Remaining area :: %f",areaOfPolygonPercentage);
                        NSLog(@"Are of polygon :: %f",areaOfPolygonCurrent);
                        _changeScore(areaOfPolygonPercentage);
                    }
                    
                    [polygonLowerBoundPoints removeAllObjects];
                    [polygonUpperBoundPoints removeAllObjects];
                    
                }
                [self checkWonCondition];
                
                
                SKSpriteNode *ob = [[SKSpriteNode alloc]init];
                ob = [myObjects objectAtIndex:0];
                
                [lineCut removeFromParent];
                
                if(pathToDraw){
                    CGPathRelease(pathToDraw);
                }
                lineCutFirstPoint = lineCutSecondPoint;
                
                pathToDraw = CGPathCreateMutable();
                CGPathMoveToPoint(pathToDraw, NULL, lineCutFirstPoint.x, lineCutFirstPoint.y);
                lineCut = [SKShapeNode node];
                lineCut.path = pathToDraw;
                lineCut.strokeColor = [SKColor redColor];
                [self addChild:lineCut];
                
                /*
                 lineCutFirstPoint = ob.position;
                 lineCutSecondPoint = ob.position;
                 */
                self.intersectionCount = 0;
                
            }else{
                self.intersectionCount = 0;
            }
        }
    }else{
        if(lineCut)
            [lineCut removeFromParent];
        SKSpriteNode *tempNode;
        
        lineCutFirstPoint = [tempNode position];
        lineCutSecondPoint = [tempNode position];
        
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(self.drawLineCut == 1){
        [lineCut removeFromParent];
    }
    SKSpriteNode *tempNode;
    
    lineCutFirstPoint = [tempNode position];
    lineCutSecondPoint = [tempNode position];

    self.drawLineCut =0;
    self.intersectionCount = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if(lineCut){
        [lineCut removeFromParent];
    }
    SKSpriteNode *tempNode;
    
    lineCutFirstPoint = [tempNode position];
    lineCutSecondPoint = [tempNode position];

}


-(void)update:(CFTimeInterval)dt {}


/*
 *
 * This Function detects collision between [lineCut and Object]
 * Event is handled ny the system
 *
 */
- (void)didBeginContact:(SKPhysicsContact *)contact{
    
    
    SKPhysicsBody *firstBody, *secondBody;
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
    NSString * pb = [NSString stringWithFormat:@"polygonBoundry"];
    NSString * lc = [NSString stringWithFormat:@"lineCut"];
    NSString * ob = [NSString stringWithFormat:@"cat"];
    NSString * fbn = firstBody.node.name;
    NSString * sbn = secondBody.node.name;
    
    
    if(([fbn isEqualToString:pb]||[sbn isEqualToString:pb])&&([fbn isEqualToString:ob]||[sbn isEqualToString:ob]) ){
        //NSLog(@"polygonBoundry and cat collision");
    }else if(([fbn isEqualToString:ob]||[sbn isEqualToString:ob])&&([fbn isEqualToString:lc]||[sbn isEqualToString:lc])){
        NSLog(@"cat and lineCut collision");
        [self gameRestart];
    }else{
        NSLog(@"lineCut and polygon");
        
    }
}


/*
 *
 * checkObjectPosition Function checks whether objects on the screen are on one side of the linecut or both
 * side
 *
 * Parameter: Nothing
 * Return: 0 if points are on the both side of the linecut
 *         1 if points are on the one side of the line
 */
- (bool)checkObjectPosition{
    
    float tempArray[self.numberOfObjects];
    int flag=0;
    for(int i=0;i<self.numberOfObjects;i++){
        SKSpriteNode *tempOb = [myObjects objectAtIndex:i];
        CGPoint x1 = tempOb.position;
        float ch = ((lineCutSecondPoint.x - lineCutFirstPoint.x) * (x1.y - lineCutFirstPoint.y)) - ((lineCutSecondPoint.y-lineCutFirstPoint.y)*(x1.x-lineCutFirstPoint.x));
        tempArray[i] = ch;
        objectOrientationSign = [self getSign:ch];
    }
    if(tempArray[0]<0){
        flag=0;
    }else{
        flag=1;
    }
    for(int i=0;i<self.numberOfObjects;i++){
        if(tempArray[i]<0 && flag==0){
            flag=0;
        }else if(tempArray[i]>0 && flag==1){
            flag=1;
        }else{
            return false;
        }
    }
    
    return true;
}

/*
 *
 * Function spawnObjects generates random moving obejcts
 * Parameters: Number of object
 * Return: Nothing
 *
 */
- (void)spawnObjects:(int)num{
    
    NSString *plistLevel = [[NSBundle mainBundle] pathForResource:@"Object-plist" ofType:@"plist"];
    
    NSDictionary *environmentDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistLevel];
    NSDictionary *levelDictionary = [[NSDictionary alloc] initWithDictionary:[environmentDictionary objectForKey:self.environmentName]];
    NSDictionary *objectDataDictionary = [[NSDictionary alloc] initWithDictionary:[levelDictionary objectForKey:self.levelName]];
    
    NSArray *tempLevel = [[NSArray alloc] init];
    tempLevel = [NSArray arrayWithArray:[objectDataDictionary objectForKey:@"objectPosition"]];
    
    self.numberOfObjects = tempLevel.count;
    
    for(int i=0;i<tempLevel.count;i++){
        NSArray *tempPoint = [[NSArray alloc] initWithArray:[tempLevel objectAtIndex:i]];
        
        CGFloat p1,p2;
        
        p1 =[[tempPoint objectAtIndex:0] floatValue];
        p2 =[[tempPoint objectAtIndex:1] floatValue];
        
        SKSpriteNode *ob = [[SKSpriteNode alloc]init];
        
        ob =[SKSpriteNode spriteNodeWithImageNamed:@"cat"];
        CGSize obSize = CGSizeMake(ob.size.height,ob.size.width);
        
        ob.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:obSize];
        
        ob.name = [NSString stringWithFormat:@"cat"];
        ob.physicsBody.node.name = [NSString stringWithFormat:@"cat"];
        ob.physicsBody.categoryBitMask = catd;
        ob.physicsBody.contactTestBitMask = lined;
        
        
        ob.position = CGPointMake(p1,p2);
        
        ob.physicsBody.friction =0.0f;
        ob.physicsBody.linearDamping = 0.0f;
        ob.physicsBody.angularDamping = 0.0f;
        ob.physicsBody.allowsRotation= YES;
        
        [ob.physicsBody setRestitution:1.0f];
        [ob.physicsBody setVelocity:CGVectorMake((arc4random() % 350),arc4random() % 350)];
        [ob.physicsBody applyImpulse:CGVectorMake((arc4random() % 350),arc4random() % 350)];
        [myObjects addObject:ob];
        //NSLog(@"Area: %f",ob.physicsBody.area);
        [self addChild:ob];
    }
}

/*
 *
 * Function makePolygon genrates polygon
 * Parameters: Array of points
 * Return: SKShapeNode
 *
 */
- (SKShapeNode*)makePolygon:(NSMutableArray*)temppolygonPointsArray flag:(int)polygonFlag{
    
    CGMutablePathRef tempPathToDraw;
    SKShapeNode *tempPolygon;
    NSValue *tempObjectPoint;
    int c=0;
    tempPathToDraw = CGPathCreateMutable();
    tempObjectPoint = [temppolygonPointsArray objectAtIndex:0];
    CGPathMoveToPoint(tempPathToDraw, NULL,tempObjectPoint.CGPointValue.x,tempObjectPoint.CGPointValue.y);
    //NSLog(@"x:%f y:%f ",tempObjectPoint.CGPointValue.x,tempObjectPoint.CGPointValue.y);
    
    for(tempObjectPoint in temppolygonPointsArray){
        CGPathAddLineToPoint(tempPathToDraw, NULL,tempObjectPoint.CGPointValue.x,tempObjectPoint.CGPointValue.y);
        c++;
        //NSLog(@"x:%f y:%f ",tempObjectPoint.CGPointValue.x,tempObjectPoint.CGPointValue.y);
    }
    
    tempPolygon = [SKShapeNode node];
    tempPolygon.strokeColor = [SKColor redColor];
    tempPolygon.path = tempPathToDraw;
    
    if(polygonFlag==0)
        polygonPath = tempPathToDraw;
    else if(polygonFlag==1)
        polygonPath1 = tempPathToDraw;
    else
        polygonPath2 = tempPathToDraw;
    
    NSLog(@"Total point For :: %d is %d",polygonFlag,c);
    tempPolygon.physicsBody.friction=0.0f;
    tempPolygon.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:tempPathToDraw];
    tempPolygon.physicsBody.categoryBitMask = boundry;
    tempPolygon.physicsBody.contactTestBitMask = lined;
    tempPolygon.physicsBody.node.name = @"polygonBoundry";
    [tempPolygon setFillColor:[UIColor grayColor]];
    
    return tempPolygon;
}

/*
 *
 * Function areaOfPolygon calculates area of the polygon
 * Parameters: Array of points
 * Return: area(float number)
 *
 */
- (float)areaOfPolygon:(NSMutableArray*)temppolygonPointsArray{
    
    float polygonArea=0.0;
    NSValue* tempObjectPoint1;
    NSValue* tempObjectPoint2;
    
    for(int i=0;i< temppolygonPointsArray.count-1; i++){
        tempObjectPoint1 = [temppolygonPointsArray objectAtIndex:i];
        tempObjectPoint2 = [temppolygonPointsArray objectAtIndex:i+1];
        
        polygonArea += (tempObjectPoint1.CGPointValue.x * tempObjectPoint2.CGPointValue.y)
        - (tempObjectPoint1.CGPointValue.y * tempObjectPoint2.CGPointValue.x);
    }
    
    tempObjectPoint2 = [temppolygonPointsArray objectAtIndex:0];
    tempObjectPoint1 = [temppolygonPointsArray lastObject];
    
    polygonArea += (tempObjectPoint1.CGPointValue.x * tempObjectPoint2.CGPointValue.y)
    - (tempObjectPoint1.CGPointValue.y * tempObjectPoint2.CGPointValue.x);
    
    polygonArea = fabsf(polygonArea/2);
    //NSLog(@"Area of plygon: %f ",polygonArea);
    return polygonArea;
}



-(void)checkLineIntersection{
    
    float m1,m2,c1,c2,x1,y1,x2,y2;
    float tx1,tx2,ty1,ty2;
    float ttx1,ttx2,tty1,tty2;
    NSValue *tempObjectPoint1;
    NSValue *tempObjectPoint2;
    int flag=0;
    NSMutableArray* tempObjectArray;
    tempObjectArray = [[NSMutableArray alloc]init];
    
    ix1=0;iy1=0;ix2=0;iy2=0;
    
    /* Handle parallel line for lineCut*/
    if((lineCutSecondPoint.x -lineCutFirstPoint.x)==0){
        m1 = infinity;
        c1 = infinity;
    }else{
        m1 = (lineCutSecondPoint.y-lineCutFirstPoint.y)/(lineCutSecondPoint.x-lineCutFirstPoint.x);
        c1 = ((lineCutSecondPoint.y*lineCutFirstPoint.x)-(lineCutFirstPoint.y*lineCutSecondPoint.x))/(lineCutFirstPoint.x-lineCutSecondPoint.x);
    }
    
    
    /* set points [left to right] */
    if(lineCutFirstPoint.x>lineCutSecondPoint.x){
        tx1 = lineCutSecondPoint.x;
        tx2 = lineCutFirstPoint.x;
    }else{
        tx1 = lineCutFirstPoint.x;
        tx2 = lineCutSecondPoint.x;
    }
    
    /* set points [top to bottom] */
    if(lineCutFirstPoint.y>lineCutSecondPoint.y){
        ty1 = lineCutSecondPoint.y;
        ty2 = lineCutFirstPoint.y;
    }else{
        ty1 = lineCutFirstPoint.y;
        ty2 = lineCutSecondPoint.y;
    }
    
    //??
    flag=0;
    
    for(int i=0;i<polygonPoints.count-1;i++){
        
        float ax,ay;
        tempObjectPoint1 = [polygonPoints objectAtIndex:i];
        
        if(i==polygonPoints.count){
            tempObjectPoint2 = [polygonPoints objectAtIndex:0];
        }else{
            tempObjectPoint2 = [polygonPoints objectAtIndex:i+1];
        }
        
        x1 = (float)tempObjectPoint1.CGPointValue.x;
        y1 = (float)tempObjectPoint1.CGPointValue.y;
        x2 = (float)tempObjectPoint2.CGPointValue.x;
        y2 = (float)tempObjectPoint2.CGPointValue.y;
        
        
        /* Handle parallel line for Polgon line*/
        if((x2-x1)==0){
            m2 = infinity;
            c2 = infinity;
        }else{
            m2 = (y2-y1)/(x2-x1);
            c2 = ((y2*x1)-(y1*x2))/(x1-x2);
        }
        
        if((m1-m2)==0){
            ax = infinity;
            ay = infinity;
        }else{
            if(m1 >= infinity){
                ax = lineCutFirstPoint.x;
                ay = ((m2*lineCutFirstPoint.x)) + c2;
            }else{
                if(m2 >= infinity){
                    ax = x1;
                    ay = ((m1*x1)) + c1;
                }else{
                    
                    ax = ((c2-c1)/(m1-m2));
                    ay = (m1*((c2-c1)/(m1-m2)))+ c1;
                    
                }
            }
        }
        
        //handle polygon line from left to right
        if(x1>x2){
            ttx1 = x2;
            ttx2 = x1;
        }else{
            ttx1 = x1;
            ttx2 = x2;
        }
        
        //handle polygon right from top to bottom
        if(y1>y2){
            tty1 = y2;
            tty2 = y1;
        }else{
            tty1 = y1;
            tty2 = y2;
        }
        
        if((ax>=tx1 && ax<=tx2) && (ax>=ttx1 && ax<=ttx2) && (ay>=ty1 && ay<=ty2) && (ay>=tty1 && ay<=tty2)){
            
                if([self getVertexOrientationSign:[polygonPoints objectAtIndex:i]] == objectOrientationSign){
                    [tempObjectArray addObject:[polygonPoints objectAtIndex:i]];
                }
                
                [tempObjectArray addObject:[NSValue valueWithCGPoint:CGPointMake(ax,ay)]];
                self.intersectionCount++;
            }else{
                /* No intersection */
                if([self getVertexOrientationSign:[polygonPoints objectAtIndex:i]] == objectOrientationSign){
                    [tempObjectArray addObject:[polygonPoints objectAtIndex:i]];
                    
                }
            }
    }
    
    [tempObjectArray addObject:[tempObjectArray objectAtIndex:0]];
    if(self.intersectionCount >=2){
        [polygonPoints removeAllObjects];
        [polygonPoints addObjectsFromArray:tempObjectArray];
    }else{
        self.intersectionCount = 0;
    }
}

/*
 *
 * Function returns oreientation sign of given vertex
 * Input : vertex point [NSValue]
 * Output: [1 or -1]
 *
 */
-(int)getVertexOrientationSign:(NSValue *)tempVertexPoint{
    
    float ch = ((lineCutSecondPoint.x - lineCutFirstPoint.x) * ((float)tempVertexPoint.CGPointValue.y - lineCutFirstPoint.y)) - ((lineCutSecondPoint.y-lineCutFirstPoint.y)*((float)tempVertexPoint.CGPointValue.x-lineCutFirstPoint.x));
    
    return [self getSign:ch];
    
}

/*
 * Function returns sign of th efloat Number
 * Input : float Number
 * Output: [1 or -1]
 *
 */
-(int)getSign:(float) val{
    
    if(val>0)
        return 1;
    
    return -1;
}

-(void)gameRestart{
    
    self.paused = YES;
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Ooops :(" message:@"You Lost!!!" delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:@"Levels", nil, nil];
    [alertView show];
}


-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    self.paused = NO;
    
    if (buttonIndex == 1) {
        /*  Level */
        self.goBackToLevel();
        
    }else if(buttonIndex == 0){
        /* Restart */
        [self removeAllChildren];
        [polygonPoints removeAllObjects];
        [myObjects removeAllObjects];
        self.restartLevel();
    }else{
        
    }
}


-(void)changePolygon:(NSMutableArray*)temppolygonPointsArray{

    CGMutablePathRef tempPathToDraw;
    NSValue *tempObjectPoint;
    
    tempPathToDraw = CGPathCreateMutable();
    tempObjectPoint = [temppolygonPointsArray objectAtIndex:0];
    CGPathMoveToPoint(tempPathToDraw, NULL,tempObjectPoint.CGPointValue.x,tempObjectPoint.CGPointValue.y);
    
    for(tempObjectPoint in temppolygonPointsArray){
        CGPathAddLineToPoint(tempPathToDraw, NULL,tempObjectPoint.CGPointValue.x,tempObjectPoint.CGPointValue.y);
    }
    
    polygonBoundry.strokeColor = [SKColor redColor];
    polygonBoundry.path = tempPathToDraw;
    polygonPath = tempPathToDraw;
    polygonBoundry.physicsBody.friction=0.0f;
    polygonBoundry.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:tempPathToDraw];
    polygonBoundry.physicsBody.categoryBitMask = boundry;
    polygonBoundry.physicsBody.contactTestBitMask = lined;
    polygonBoundry.physicsBody.node.name = @"polygonBoundry";
    [polygonBoundry setFillColor:[UIColor grayColor]];
    
}








-(void)checkOnlyLineIntersection{
    
    float m1,m2,c1,c2,x1,y1,x2,y2;
    float tx1,tx2,ty1,ty2;
    float ttx1,ttx2,tty1,tty2;
    NSValue *tempObjectPoint1;
    NSValue *tempObjectPoint2;
    int flag=0;
    NSMutableArray* tempObjectArray;
    tempObjectArray = [[NSMutableArray alloc]init];
    
    
    ix1=0;iy1=0;ix2=0;iy2=0;
    
    /* Handle parallel line for lineCut*/
    if((lineCutSecondPoint.x -lineCutFirstPoint.x)==0){
        m1 = infinity;
        c1 = infinity;
    }else{
        m1 = (lineCutSecondPoint.y-lineCutFirstPoint.y)/(lineCutSecondPoint.x-lineCutFirstPoint.x);
        c1 = ((lineCutSecondPoint.y*lineCutFirstPoint.x)-(lineCutFirstPoint.y*lineCutSecondPoint.x))/(lineCutFirstPoint.x-lineCutSecondPoint.x);
    }
    
    
    /* set points [left to right] */
    if(lineCutFirstPoint.x>lineCutSecondPoint.x){
        tx1 = lineCutSecondPoint.x;
        tx2 = lineCutFirstPoint.x;
    }else{
        tx1 = lineCutFirstPoint.x;
        tx2 = lineCutSecondPoint.x;
    }
    
    /* set points [top to bottom] */
    if(lineCutFirstPoint.y>lineCutSecondPoint.y){
        ty1 = lineCutSecondPoint.y;
        ty2 = lineCutFirstPoint.y;
    }else{
        ty1 = lineCutFirstPoint.y;
        ty2 = lineCutSecondPoint.y;
    }
    
    //??
    flag=0;
    
    for(int i=0;i<polygonPoints.count-1;i++){
        
        float ax,ay;
        tempObjectPoint1 = [polygonPoints objectAtIndex:i];
        
        if(i==polygonPoints.count){
            tempObjectPoint2 = [polygonPoints objectAtIndex:0];
        }else{
            tempObjectPoint2 = [polygonPoints objectAtIndex:i+1];
        }
        
        x1 = (float)tempObjectPoint1.CGPointValue.x;
        y1 = (float)tempObjectPoint1.CGPointValue.y;
        x2 = (float)tempObjectPoint2.CGPointValue.x;
        y2 = (float)tempObjectPoint2.CGPointValue.y;
        
        
        /* Handle parallel line for Polgon line*/
        if((x2-x1)==0){
            m2 = infinity;
            c2 = infinity;
        }else{
            m2 = (y2-y1)/(x2-x1);
            c2 = ((y2*x1)-(y1*x2))/(x1-x2);
        }
        
        if((m1-m2)==0){
            ax = infinity;
            ay = infinity;
        }else{
            if(m1 >= infinity){
                ax = lineCutFirstPoint.x;
                ay = ((m2*lineCutFirstPoint.x)) + c2;
            }else{
                if(m2 >= infinity){
                    ax = x1;
                    ay = ((m1*x1)) + c1;
                }else{
                    
                    ax = ((c2-c1)/(m1-m2));
                    ay = (m1*((c2-c1)/(m1-m2)))+ c1;
                    
                }
            }
        }
        
        //handle polygon line from left to right
        if(x1>x2){
            ttx1 = x2;
            ttx2 = x1;
        }else{
            ttx1 = x1;
            ttx2 = x2;
        }
        
        //handle polygon right from top to bottom
        if(y1>y2){
            tty1 = y2;
            tty2 = y1;
        }else{
            tty1 = y1;
            tty2 = y2;
        }
        
        if((ax>=tx1 && ax<=tx2) && (ax>=ttx1 && ax<=ttx2) && (ay>=ty1 && ay<=ty2) && (ay>=tty1 && ay<=tty2)){
           self.intersectionCount++;
        }
    }
}


-(void)checkWonCondition{
    if(areaOfPolygonPercentage<_winningScore){
        self.paused = YES;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Wooooohhhhhoo :)" message:@"You Won!!!" delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:@"Levels", nil, nil];
        [alertView show];

    }
}





















/* Ignore points between intersection*/
-(void)checkPolygon1{
    
    float m1,m2,c1,c2,x1,y1,x2,y2;
    float tx1,tx2,ty1,ty2;
    float ttx1,ttx2,tty1,tty2;
    NSValue *tempObjectPoint1;
    NSValue *tempObjectPoint2;
    int flag=0;
    NSMutableArray* tempObjectArray;
    tempObjectArray = [[NSMutableArray alloc]init];
    int intersectionPoin1Flag=0;
    int intersectionPoin2Flag=0;
    
    ix1=0;iy1=0;ix2=0;iy2=0;
    
    /* Handle parallel line for lineCut*/
    if((lineCutSecondPoint.x -lineCutFirstPoint.x)==0){
        m1 = infinity;
        c1 = infinity;
    }else{
        m1 = (lineCutSecondPoint.y-lineCutFirstPoint.y)/(lineCutSecondPoint.x-lineCutFirstPoint.x);
        c1 = ((lineCutSecondPoint.y*lineCutFirstPoint.x)-(lineCutFirstPoint.y*lineCutSecondPoint.x))/(lineCutFirstPoint.x-lineCutSecondPoint.x);
    }
    
    
    /* set points [left to right] */
    if(lineCutFirstPoint.x>lineCutSecondPoint.x){
        tx1 = lineCutSecondPoint.x;
        tx2 = lineCutFirstPoint.x;
    }else{
        tx1 = lineCutFirstPoint.x;
        tx2 = lineCutSecondPoint.x;
    }
    
    /* set points [top to bottom] */
    if(lineCutFirstPoint.y>lineCutSecondPoint.y){
        ty1 = lineCutSecondPoint.y;
        ty2 = lineCutFirstPoint.y;
    }else{
        ty1 = lineCutFirstPoint.y;
        ty2 = lineCutSecondPoint.y;
    }
    
    //??
    flag=0;
    
    for(int i=0;i<polygonPoints.count-1;i++){
        
        float ax,ay;
        tempObjectPoint1 = [polygonPoints objectAtIndex:i];
        
        if(i==polygonPoints.count){
            tempObjectPoint2 = [polygonPoints objectAtIndex:0];
        }else{
            tempObjectPoint2 = [polygonPoints objectAtIndex:i+1];
        }
        
        x1 = (float)tempObjectPoint1.CGPointValue.x;
        y1 = (float)tempObjectPoint1.CGPointValue.y;
        x2 = (float)tempObjectPoint2.CGPointValue.x;
        y2 = (float)tempObjectPoint2.CGPointValue.y;
        
        
        /* Handle parallel line for Polgon line*/
        if((x2-x1)==0){
            m2 = infinity;
            c2 = infinity;
        }else{
            m2 = (y2-y1)/(x2-x1);
            c2 = ((y2*x1)-(y1*x2))/(x1-x2);
        }
        
        if((m1-m2)==0){
            ax = infinity;
            ay = infinity;
        }else{
            if(m1 >= infinity){
                ax = lineCutFirstPoint.x;
                ay = ((m2*lineCutFirstPoint.x)) + c2;
            }else{
                if(m2 >= infinity){
                    ax = x1;
                    ay = ((m1*x1)) + c1;
                }else{
                    
                    ax = ((c2-c1)/(m1-m2));
                    ay = (m1*((c2-c1)/(m1-m2)))+ c1;
                    
                }
            }
        }
        
        //handle polygon line from left to right
        if(x1>x2){
            ttx1 = x2;
            ttx2 = x1;
        }else{
            ttx1 = x1;
            ttx2 = x2;
        }
        
        //handle polygon right from top to bottom
        if(y1>y2){
            tty1 = y2;
            tty2 = y1;
        }else{
            tty1 = y1;
            tty2 = y2;
        }
        
        if((ax>=tx1 && ax<=tx2) && (ax>=ttx1 && ax<=ttx2) && (ay>=ty1 && ay<=ty2) && (ay>=tty1 && ay<=tty2)){
            
            if(intersectionPoin1Flag==1){
                intersectionPoin2Flag=1;
                [tempObjectArray addObject:[NSValue valueWithCGPoint:CGPointMake(ax,ay)]];
                
            }else{
                [tempObjectArray addObject:[polygonPoints objectAtIndex:i]];
                [tempObjectArray addObject:[NSValue valueWithCGPoint:CGPointMake(ax,ay)]];
                intersectionPoin1Flag=1;
            }
            
            //self.intersectionCount++;
        }else{
            /* No intersection */
            if(intersectionPoin1Flag==0){
                [tempObjectArray addObject:[polygonPoints objectAtIndex:i]];
            }else if(intersectionPoin2Flag==1){
                [tempObjectArray addObject:[polygonPoints objectAtIndex:i]];
                
            }else{
            
            }
            
        
        }
    }
    
    [tempObjectArray addObject:[tempObjectArray objectAtIndex:0]];
    [polygonLowerBoundPoints addObjectsFromArray:tempObjectArray];
}

/* Only include points between intersection */
-(void)checkPolygon2{
    
    float m1,m2,c1,c2,x1,y1,x2,y2;
    float tx1,tx2,ty1,ty2;
    float ttx1,ttx2,tty1,tty2;
    NSValue *tempObjectPoint1;
    NSValue *tempObjectPoint2;
    int flag=0;
    NSMutableArray* tempObjectArray;
    tempObjectArray = [[NSMutableArray alloc]init];
    int intersectionPoin1Flag=0;
    int intersectionPoin2Flag=0;
    
    ix1=0;iy1=0;ix2=0;iy2=0;
    
    /* Handle parallel line for lineCut*/
    if((lineCutSecondPoint.x -lineCutFirstPoint.x)==0){
        m1 = infinity;
        c1 = infinity;
    }else{
        m1 = (lineCutSecondPoint.y-lineCutFirstPoint.y)/(lineCutSecondPoint.x-lineCutFirstPoint.x);
        c1 = ((lineCutSecondPoint.y*lineCutFirstPoint.x)-(lineCutFirstPoint.y*lineCutSecondPoint.x))/(lineCutFirstPoint.x-lineCutSecondPoint.x);
    }
    
    
    /* set points [left to right] */
    if(lineCutFirstPoint.x>lineCutSecondPoint.x){
        tx1 = lineCutSecondPoint.x;
        tx2 = lineCutFirstPoint.x;
    }else{
        tx1 = lineCutFirstPoint.x;
        tx2 = lineCutSecondPoint.x;
    }
    
    /* set points [top to bottom] */
    if(lineCutFirstPoint.y>lineCutSecondPoint.y){
        ty1 = lineCutSecondPoint.y;
        ty2 = lineCutFirstPoint.y;
    }else{
        ty1 = lineCutFirstPoint.y;
        ty2 = lineCutSecondPoint.y;
    }
    
    //??
    flag=0;
    
    for(int i=0;i<polygonPoints.count-1;i++){
        
        float ax,ay;
        tempObjectPoint1 = [polygonPoints objectAtIndex:i];
        
        if(i==polygonPoints.count){
            tempObjectPoint2 = [polygonPoints objectAtIndex:0];
        }else{
            tempObjectPoint2 = [polygonPoints objectAtIndex:i+1];
        }
        
        x1 = (float)tempObjectPoint1.CGPointValue.x;
        y1 = (float)tempObjectPoint1.CGPointValue.y;
        x2 = (float)tempObjectPoint2.CGPointValue.x;
        y2 = (float)tempObjectPoint2.CGPointValue.y;
        
        
        /* Handle parallel line for Polgon line*/
        if((x2-x1)==0){
            m2 = infinity;
            c2 = infinity;
        }else{
            m2 = (y2-y1)/(x2-x1);
            c2 = ((y2*x1)-(y1*x2))/(x1-x2);
        }
        
        if((m1-m2)==0){
            ax = infinity;
            ay = infinity;
        }else{
            if(m1 >= infinity){
                ax = lineCutFirstPoint.x;
                ay = ((m2*lineCutFirstPoint.x)) + c2;
            }else{
                if(m2 >= infinity){
                    ax = x1;
                    ay = ((m1*x1)) + c1;
                }else{
                    
                    ax = ((c2-c1)/(m1-m2));
                    ay = (m1*((c2-c1)/(m1-m2)))+ c1;
                    
                }
            }
        }
        
        //handle polygon line from left to right
        if(x1>x2){
            ttx1 = x2;
            ttx2 = x1;
        }else{
            ttx1 = x1;
            ttx2 = x2;
        }
        
        //handle polygon right from top to bottom
        if(y1>y2){
            tty1 = y2;
            tty2 = y1;
        }else{
            tty1 = y1;
            tty2 = y2;
        }
        
        if((ax>=tx1 && ax<=tx2) && (ax>=ttx1 && ax<=ttx2) && (ay>=ty1 && ay<=ty2) && (ay>=tty1 && ay<=tty2)){
            
            if(intersectionPoin1Flag==1){
                intersectionPoin2Flag=1;
                [tempObjectArray addObject:[polygonPoints objectAtIndex:i]];
                [tempObjectArray addObject:[NSValue valueWithCGPoint:CGPointMake(ax,ay)]];
                
            }else{
                [tempObjectArray addObject:[NSValue valueWithCGPoint:CGPointMake(ax,ay)]];
                intersectionPoin1Flag=1;
            }
            
            //self.intersectionCount++;
        }else{
            /* No intersection */
            if(intersectionPoin1Flag==1 && intersectionPoin2Flag==0){
                [tempObjectArray addObject:[polygonPoints objectAtIndex:i]];
            }
        }
    }
    
    [tempObjectArray addObject:[tempObjectArray objectAtIndex:0]];
    [polygonUpperBoundPoints addObjectsFromArray:tempObjectArray];
}




@end
