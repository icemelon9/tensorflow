include(ExternalProject)

ExternalProject_Add(
  tensorflow_shared
  #TMP_DIR "/tmp"
  #STAMP_DIR "tensorflow-stamp"
  SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  BUILD_IN_SOURCE 1
  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND make -f ${CMAKE_CURRENT_SOURCE_DIR}/tensorflow/contrib/makefile/Makefile clean
            COMMAND tensorflow/contrib/makefile/download_dependencies.sh
            #COMMAND tensorflow/contrib/makefile/compile_linux_protobuf.sh
            COMMAND env CUDA_PATH=${CUDA_PATH} CUDNN_PATH=${CUDNN_PATH} cmake/build_tensorflow.sh
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)
