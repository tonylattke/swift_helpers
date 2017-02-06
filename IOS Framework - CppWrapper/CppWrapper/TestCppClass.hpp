//
//  TestCppClass.hpp
//  CppWrapper
//
//  Created by Student on 08.01.17.
//  Copyright © 2017 Tony Lattke. All rights reserved.
//

#ifndef TestCppClass_hpp
#define TestCppClass_hpp

#include <stdio.h>
#include <string>

class TestCppClass {
    public:
        TestCppClass();
        TestCppClass(const std::string &title);
        ~TestCppClass();
    
    public:
        void setTitle(const std::string &title);
        const std::string &getTtile();
    
    private:
        std::string m_title;
};

#endif /* TestCppClass_hpp */
