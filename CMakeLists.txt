cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
project(
  "tensorflow_cc"
  VERSION 0.2
)

# -------------
# CMake Options
# -------------

set(TENSORFLOW_VERSION "1.7" CACHE STRING "TensorFlow version")
set(CUDA_PATH "/usr/local/cuda" CACHE PATH "CUDA install path")
set(CUDNN_PATH "/usr/local/cuda" CACHE PATH "CUDNN install path")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
include(CMakePackageConfigHelpers)
set(CMAKECFG_INSTALL_DIR lib/cmake/TensorflowCC)
set(PKGCONFIG_INSTALL_DIR lib/pkgconfig)

# --------------------------------------------------------
# Include External Projects for Shared Tensorflow
# --------------------------------------------------------

include(TensorflowShared)

# ----------------------------------
# Define Shared Tensorflow Interface
# ----------------------------------

add_library(tensorflow_cc_shared INTERFACE)
target_compile_options(
  tensorflow_cc_shared INTERFACE
  "-std=c++11"
)
add_dependencies(
  tensorflow_cc_shared
  tensorflow_shared
)
target_include_directories(
  tensorflow_cc_shared INTERFACE
  "${CMAKE_INSTALL_PREFIX}/include/tensorflow"
  "${CMAKE_INSTALL_PREFIX}/include/tensorflow/bazel-genfiles"
  "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads"
  "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/eigen"
  "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/gemmlowp"
  "${CMAKE_INSTALL_PREFIX}/include/tensorflow/tensorflow/contrib/makefile/downloads/nsync/public"
)
target_link_libraries(
  tensorflow_cc_shared INTERFACE
  "${CMAKE_INSTALL_PREFIX}/lib/tensorflow/libtensorflow_cc.so"
  # static protobuf is used from the contrib/makefile
  #"${CMAKE_INSTALL_PREFIX}/lib/tensorflow/libprotobuf.a"
  dl pthread
)

# ----------------------------------------
# Configure CMake Config and Version Files
# ----------------------------------------

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/TensorflowCCConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/TensorflowCCConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/TensorflowCCConfig.cmake"
  INSTALL_DESTINATION "${CMAKECFG_INSTALL_DIR}"
  NO_SET_AND_CHECK_MACRO # TensorflowCC only uses interface libraries
  NO_CHECK_REQUIRED_COMPONENTS_MACRO # TensorflowCC does not have components
)
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/tensorflow.pc.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/tensorflow.pc" @ONLY
)

# -------
# Install
# -------

# install all header files
install(
  DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tensorflow"
  DESTINATION include/tensorflow
  FILES_MATCHING PATTERN "*.h"
)
install(
  DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bazel-genfiles/tensorflow"
            "${CMAKE_CURRENT_SOURCE_DIR}/bazel-genfiles/external"
  DESTINATION include/tensorflow
  FILES_MATCHING PATTERN "*.h"
)
# install all files downloaded by contrib/makefile as dependencies
install(
  DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tensorflow/contrib/makefile/downloads/"
  DESTINATION include/tensorflow/tensorflow/contrib/makefile/downloads
)
# install all files from third_party folder (e.g., Eigen/Tensor)
install(
  DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/third_party/"
  DESTINATION include/tensorflow/third_party
)
# install static libprotobuf from contrib/makefile
# install(
#   FILES "${CMAKE_CURRENT_SOURCE_DIR}/tensorflow/contrib/makefile/gen/protobuf-host/lib/libprotobuf.a"
#   DESTINATION lib/tensorflow_cc
# )
# shared library specific
install(
  FILES "${CMAKE_CURRENT_SOURCE_DIR}/bazel-bin/tensorflow/libtensorflow_cc.so"
  DESTINATION lib/tensorflow
)

# --------------------------
# Install CMake targets file
# --------------------------

set_target_properties(
  tensorflow_cc_shared PROPERTIES EXPORT_NAME Shared
)
install(
  TARGETS tensorflow_cc_shared
  EXPORT TensorflowCCSharedTargets
)
install(
  EXPORT TensorflowCCSharedTargets
  FILE TensorflowCCSharedTargets.cmake
  NAMESPACE TensorflowCC::
  DESTINATION "${CMAKECFG_INSTALL_DIR}"
)
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/tensorflow.pc"
  DESTINATION "${PKGCONFIG_INSTALL_DIR}"
)

# install config and version files
install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/TensorflowCCConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/TensorflowCCConfigVersion.cmake"
  DESTINATION "${CMAKECFG_INSTALL_DIR}"
)
