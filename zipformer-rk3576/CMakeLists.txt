cmake_minimum_required(VERSION 3.10)

project(rknn_zipformer_demo)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(TARGET_LIB_ARCH aarch64)
else()
    set(TARGET_LIB_ARCH armhf)
endif()

message(STATUS "TARGET_LIB_ARCH: ${TARGET_LIB_ARCH}")

set(RKNN_PATH ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/rknpu2)
set(LIBRKNNRT ${RKNN_PATH}/Linux/${TARGET_LIB_ARCH}/librknnrt.so)
set(LIBRKNNRT_INCLUDES ${RKNN_PATH}/include)

set(KALDI_FBANK_PATH ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/kaldi_native_fbank)
set(LIBKALDI_NATIVE_FBANK_INCLUDES ${KALDI_FBANK_PATH}/include)
set(LIBKALDI_NATIVE_FBANK ${KALDI_FBANK_PATH}/Linux/${TARGET_LIB_ARCH}/libkaldi-native-fbank-core.a)

set(KISSFFT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/kissfft)
set(LIBKISSFFT_INCLUDES ${KISSFFT_PATH}/include)
set(LIBKISSFFT ${KISSFFT_PATH}/Linux/${TARGET_LIB_ARCH}/libkissfft-float.a)

set(TIMER_PATH ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/timer)
set(LIBTIMER_INCLUDES ${TIMER_PATH})

set(FFTW_PATH ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/fftw)
set(LIBFFTW_INCLUDES ${FFTW_PATH}/include)
set(LIBFFTW ${FFTW_PATH}/Linux/${TARGET_LIB_ARCH}/libfftw3f.a)

set(SNDFILE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/libsndfile)
set(LIBSNDFILE_INCLUDES ${SNDFILE_PATH}/include)
set(LIBSNDFILE ${SNDFILE_PATH}/Linux/${TARGET_LIB_ARCH}/libsndfile.a)

set(STB_PATH ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/stb_image)
set(STB_INCLUDES ${STB_PATH})

set(UTILS_PATH ${CMAKE_CURRENT_SOURCE_DIR}/utils)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

add_library(fileutils STATIC
    ${UTILS_PATH}/file_utils.c
)
target_include_directories(fileutils PUBLIC ${UTILS_PATH})

add_library(audioutils STATIC
    ${UTILS_PATH}/audio_utils.c
)
target_include_directories(audioutils PUBLIC ${UTILS_PATH} ${LIBSNDFILE_INCLUDES})
target_link_libraries(audioutils ${LIBSNDFILE})

add_executable(${PROJECT_NAME}
    src/main.cc
    src/process.cc
    src/zipformer.cc
)

target_link_libraries(${PROJECT_NAME}
    fileutils
    audioutils
    ${LIBRKNNRT}
    ${LIBKALDI_NATIVE_FBANK}
    ${LIBKISSFFT}
    ${LIBFFTW}
    ${LIBSNDFILE}
)

if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    find_package(OpenMP REQUIRED)
    target_link_libraries(${PROJECT_NAME} OpenMP::OpenMP_CXX)
    
    set(THREADS_PREFER_PTHREAD_FLAG ON)
    find_package(Threads REQUIRED)
    target_link_libraries(${PROJECT_NAME} Threads::Threads)
endif()

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${LIBRKNNRT_INCLUDES}
    ${LIBKALDI_NATIVE_FBANK_INCLUDES}
    ${LIBKISSFFT_INCLUDES}
    ${LIBTIMER_INCLUDES}
    ${LIBFFTW_INCLUDES}
    ${LIBSNDFILE_INCLUDES}
    ${STB_INCLUDES}
    ${UTILS_PATH}
)

install(TARGETS ${PROJECT_NAME} DESTINATION .)
install(PROGRAMS ${LIBRKNNRT} DESTINATION lib)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/run.sh DESTINATION .)
