/*
 * Assert.cpp
 *
 *  make sure that your code will terminate whenever an error occurs
 *  author: MHB, 2015
 */

#include "Assert.h"
#include<stdio.h>
#include<stdlib.h>
#include<iostream>
#include<string>
using namespace std;

void Assert( bool cond, string str){
	char c;
	if( !cond){
		cout << str << endl;
		//getchar();
		exit(-1);
	}
}




