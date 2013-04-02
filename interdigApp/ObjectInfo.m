//
//  ObjectInfo.m
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ObjectInfo.h"

@implementation ObjectInfo
@synthesize objectID, titulo, descripcion, claveActual, claveSig, email, photoURL, address1, address2, telefono, siteURL, sms, ext, dataBase, masInfo, mapa, video, edatadb, chatOn, dataInput, inpid, security;

-(id)initWithDictionary:(NSDictionary *)dataObject
{
    self = [super init];
    if(self != nil)
    {
        self.objectID = [dataObject objectForKey:@"id"];
        self.titulo = [dataObject objectForKey:@"titulo"];
        self.descripcion = [dataObject objectForKey:@"desl"];
        self.claveActual = [dataObject objectForKey:@"clave"];
        self.claveSig = [dataObject objectForKey:@"cla"];
        self.email = [dataObject objectForKey:@"email"];
        self.photoURL = [dataObject objectForKey:@"filename"];
        self.address1 = [dataObject objectForKey:@"ad1"];
        self.address2 = [dataObject objectForKey:@"ad2"];
        self.telefono = [dataObject objectForKey:@"tel"];
        self.siteURL = [dataObject objectForKey:@"url1"];
        self.sms = [dataObject objectForKey:@"sms"];
        self.ext = [dataObject objectForKey:@"ext1"];
        self.dataBase = [dataObject objectForKey:@"db"];
        self.masInfo = [dataObject objectForKey:@"masinfo"];
        self.mapa = [dataObject objectForKey:@"mapa"];
        self.video = [dataObject objectForKey:@"video"];
        self.edatadb = [dataObject objectForKey:@"edatadb"];
        self.chatOn = [[dataObject objectForKey:@"chaton"] boolValue];
        self.dataInput = [dataObject objectForKey:@"datainput"];
        self.inpid = [[dataObject objectForKey:@"inpid"] integerValue];
        self.security = [[dataObject objectForKey:@"seg"] isEqualToString:@"1"] ? YES : NO;
        //NSLog(@"CHAT ON: %@", [dataObject objectForKey:@"chaton"]);
        //NSLog(@"BOOL CHAT ON: %d", [[dataObject objectForKey:@"chaton"] boolValue]);
    }
    
    return self;
}

-(void)dealloc
{
    [objectID release];
    [titulo release];
    [descripcion release];
    [claveActual release];
    [claveSig release];
    [email release];
    [photoURL release];
    [address1 release];
    [address2 release];
    [telefono release];
    [siteURL release];
    [sms release];
    [ext release];
    [dataBase release];
    [masInfo release];
    [mapa release];
    [video release];
    [dataInput release];
    
    [super dealloc];
}

@end
