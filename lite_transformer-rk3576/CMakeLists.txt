cmake_minimum_required(VERSION 3.10)

project(rknn_lite_transformer_demo)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wl,--allow-shlib-undefined")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wl,--allow-shlib-undefined")

if(${CMAKE_VERSION} VERSION_GREATER "3.15.0" AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
  add_link_options("-Wl,-Bsymbolic")
endif()

if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    set (TARGET_LIB_ARCH ${CMAKE_ANDROID_ARCH_ABI})
else()
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set (TARGET_LIB_ARCH aarch64)
    else()
        set (TARGET_LIB_ARCH armhf)
    endif()
    if (CMAKE_C_COMPILER MATCHES "uclibc")
        set (TARGET_LIB_ARCH ${TARGET_LIB_ARCH}_uclibc)
    endif()
endif()

set(RKNN_PATH ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/librknnrt)
set(LIBRKNNRT ${RKNN_PATH}/${CMAKE_SYSTEM_NAME}/librknn_api/${TARGET_LIB_ARCH}/librknnrt.so)
set(LIBRKNNRT_INCLUDES ${RKNN_PATH}/${CMAKE_SYSTEM_NAME}/librknn_api/include)

set(LIBTIMER_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/timer)

find_package(OpenMP)

include_directories(${LIBRKNNRT_INCLUDES})
include_directories(${LIBTIMER_INCLUDES})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/utils)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/utils/bpe_tools)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/rknpu2/rkdemo_utils)

add_executable(${PROJECT_NAME}
    src/main.cc
    src/rknpu2/lite_transformer.cc
    src/rknpu2/rkdemo_utils/rknn_demo_utils.cc
    src/utils/bpe_tools/bpe_tools.cc
    src/utils/file_utils.c
)

target_link_libraries(${PROJECT_NAME}
    ${LIBRKNNRT}
    dl
)

if(OpenMP_FOUND)
    target_link_libraries(${PROJECT_NAME} OpenMP::OpenMP_CXX)
endif()

if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    target_link_libraries(${PROJECT_NAME} log)
endif()

if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_link_libraries(${PROJECT_NAME} pthread)
endif()

set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/install)
install(TARGETS ${PROJECT_NAME} DESTINATION .)
install(PROGRAMS ${LIBRKNNRT} DESTINATION lib)
install(FILES ${CMAKE_SOURCE_DIR}/run.sh DESTINATION .)
install(FILES ${CMAKE_SOURCE_DIR}/model/bpe_order.txt DESTINATION model)
install(FILES ${CMAKE_SOURCE_DIR}/model/dict_order.txt DESTINATION model)
install(FILES ${CMAKE_SOURCE_DIR}/model/cw_token_map_order.txt DESTINATION model)
install(FILES ${CMAKE_SOURCE_DIR}/model/position_embed.bin DESTINATION model)
install(FILES ${CMAKE_SOURCE_DIR}/model/token_embed.bin DESTINATION model)
file(GLOB RKNN_FILES "${CMAKE_SOURCE_DIR}/model/*.rknn")
install(FILES ${RKNN_FILES} DESTINATION model)
