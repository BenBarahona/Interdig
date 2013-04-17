//
//  ObjectInfo.h
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectInfo : NSObject
{
}

-(id)initWithDictionary:(NSDictionary *)dataObject;

@property (nonatomic, retain) NSString *objectID;
@property (nonatomic, retain) NSString *titulo;
@property (nonatomic, retain) NSString *descripcion;
@property (nonatomic, retain) NSString *claveActual;
@property (nonatomic, retain) NSString *claveSig;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *photoURL;
@property (nonatomic, retain) NSString *address1;
@property (nonatomic, retain) NSString *address2;
@property (nonatomic, retain) NSString *telefono;
@property (nonatomic, retain) NSString *siteURL;
@property (nonatomic, retain) NSString *sms;
@property (nonatomic, retain) NSString *ext;
@property (nonatomic, retain) NSString *dataBase;
@property (nonatomic, retain) NSArray *masInfo;
@property (nonatomic, retain) NSString *mapa;
@property (nonatomic, retain) NSString *video;
@property (nonatomic, retain) NSString *edatadb;
@property (nonatomic, assign) BOOL chatOn;
@property (nonatomic, assign) NSInteger inpid;
@property (nonatomic, retain) NSArray *dataInput;
@property (nonatomic, assign) BOOL security;
@property (nonatomic, retain) NSString *sipServer;
@property (nonatomic, retain) NSString *sipUser;
@property (nonatomic, retain) NSString *sipPswd;
@end
