//
//  TestCppClass.cpp
//  CppWrapper
//
//  Created by Student on 08.01.17.
//  Copyright © 2017 Tony Lattke. All rights reserved.
//

#include "TestCppClass.hpp"

TestCppClass::TestCppClass() {}
TestCppClass::TestCppClass(const std::string &title): m_title(title) {}
TestCppClass::~TestCppClass() {}
void TestCppClass::setTitle(const std::string &title)
{
    m_title = title;
}
const std::string &TestCppClass::getTtile()
{
    std::printf("test");
    return m_title;
}
