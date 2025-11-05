# CMakeLists.txt pour compiler la partie C++ du client SCP

cmake_minimum_required(VERSION 3.20)
project(SCPClient VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Trouver libssh2
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBSSH2 REQUIRED libssh2)

# Sources C++
set(SOURCES
    SCPClient/Sources/Services/SCPSession.cpp
)

set(HEADERS
    SCPClient/Sources/Services/SCPSession.h
)

# Créer une bibliothèque statique
add_library(SCPClientCore STATIC ${SOURCES} ${HEADERS})

target_include_directories(SCPClientCore PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/SCPClient/Sources/Services
    ${LIBSSH2_INCLUDE_DIRS}
)

target_link_libraries(SCPClientCore PUBLIC
    ${LIBSSH2_LIBRARIES}
)

# Compiler pour macOS avec support universal (Intel + Apple Silicon)
if(APPLE)
    set_target_properties(SCPClientCore PROPERTIES
        OSX_ARCHITECTURES "x86_64;arm64"
    )
endif()

# Installation
install(TARGETS SCPClientCore
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES ${HEADERS} DESTINATION include/SCPClient)
