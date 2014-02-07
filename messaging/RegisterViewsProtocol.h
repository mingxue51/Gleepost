//
//  RegisterViewsProtocol.h
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RegisterViewsProtocol <NSObject>

@required

-(void)navigateToNextView;
-(void)login;
-(void)firstAndLastName:(NSArray*)firstLastName;
-(void)emailAndPass:(NSArray*)emailPass;
-(void)pickImage:(id)sender;

@end
