cmake_minimum_required(VERSION 2.8)
project(gprc_csharp_ext C CXX)

set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -std=c99")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(PROJECT_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../..)

if(NOT ZLIB_ROOT_DIR)
  set(ZLIB_ROOT_DIR ${PROJECT_ROOT_DIR}/third_party/zlib)
endif()
set(ZLIB_INCLUDE_DIR "${ZLIB_ROOT_DIR}")
if(EXISTS "${ZLIB_ROOT_DIR}/CMakeLists.txt")
  # add_subdirectory(${ZLIB_ROOT_DIR} third_party/zlib)
  add_subdirectory(${ZLIB_ROOT_DIR} ${ZLIB_ROOT_DIR})
  if(TARGET zlibstatic)
    set(_gRPC_ZLIB_LIBRARIES zlibstatic)
  endif()
else()
  message(WARNING "gRPC_ZLIB_PROVIDER is \"module\" but ZLIB_ROOT_DIR is wrong")
endif()

if(NOT CARES_ROOT_DIR)
  set(CARES_ROOT_DIR ${PROJECT_ROOT_DIR}/src/c-ares)
endif()
string(TOLOWER ${CMAKE_SYSTEM_NAME} CARES_SYSTEM_NAME)
set(CARES_INCLUDE_DIR "${PROJECT_ROOT_DIR}/third_party/cares/cares")
set(CARES_BUILD_INCLUDE_DIR "${PROJECT_ROOT_DIR}/third_party/cares")
set(CARES_PLATFORM_INCLUDE_DIR "${PROJECT_ROOT_DIR}/third_party/cares/config_${CARES_SYSTEM_NAME}")
if(EXISTS "${CARES_ROOT_DIR}/CMakeLists.txt")
  if("${CARES_SYSTEM_NAME}" MATCHES "windows")
    add_definitions(-DCARES_STATICLIB=1)
    add_definitions(-DWIN32_LEAN_AND_MEAN=1)
  else()
    add_definitions(-DHAVE_CONFIG_H=1)
    add_definitions(-D_GNU_SOURCE=1)
  endif()
  # add_subdirectory(src/c-ares third_party/cares)
  add_subdirectory(${CARES_ROOT_DIR} ${CARES_BUILD_INCLUDE_DIR})
  if(TARGET cares)
      set(_gRPC_CARES_LIBRARIES cares)
  endif()
else()
  message(WARNING "gRPC_CARES_PROVIDER is \"module\" but CARES_ROOT_DIR is wrong")
endif()

if(NOT BORINGSSL_ROOT_DIR)
  set(BORINGSSL_ROOT_DIR ${PROJECT_ROOT_DIR}/third_party/boringssl)
endif()
if(EXISTS "${BORINGSSL_ROOT_DIR}/CMakeLists.txt")
  add_subdirectory(${BORINGSSL_ROOT_DIR} third_party/boringssl)
  if(TARGET ssl)
    set(_gRPC_SSL_LIBRARIES ssl)
  endif()
else()
  message(WARNING "gRPC_SSL_PROVIDER is \"module\" but BORINGSSL_ROOT_DIR is wrong")
endif()

include(GNUInstallDirs)
if(NOT DEFINED CMAKE_INSTALL_CMAKEDIR)
  set(CMAKE_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/gRPC")
endif()

if(_gRPC_PLATFORM_MAC)
  set(_gRPC_ALLTARGETS_LIBRARIES ${CMAKE_DL_LIBS} m pthread)
elseif(UNIX)
  set(_gRPC_ALLTARGETS_LIBRARIES ${CMAKE_DL_LIBS} rt m pthread)
endif()


if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  # Clang's integerated assembler does not support debug symbols.
  if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -Wa,-g")
  endif()
endif()


if(CMAKE_COMPILER_IS_GNUCXX)
  if ((CMAKE_C_COMPILER_VERSION VERSION_GREATER "4.8.99") OR
      CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11")
  else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")
  endif()
endif()


if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
  set(ARCH "x86_64")
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "amd64")
  set(ARCH "x86_64")
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "AMD64")
  # cmake reports AMD64 on Windows, but we might be building for 32-bit.
  if (CMAKE_CL_64)
    set(ARCH "x86_64")
  else()
    set(ARCH "x86")
  endif()
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86")
  set(ARCH "x86")
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i386")
  set(ARCH "x86")
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
  set(ARCH "x86")
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "arm")
  set(ARCH "arm")
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "armv6")
  set(ARCH "arm")
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "armv7-a")
  set(ARCH "arm")
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "aarch64")
  set(ARCH "aarch64")
else()
  message(FATAL_ERROR "Unknown processor:" ${CMAKE_SYSTEM_PROCESSOR})
endif()

if (ANDROID AND ${ARCH} STREQUAL "arm")
  # The Android-NDK CMake files somehow fail to set the -march flag for
  # assembly files. Without this flag, the compiler believes that it's
  # building for ARMv5.
  set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -march=${CMAKE_SYSTEM_PROCESSOR}")
endif()

  
add_library(gpr STATIC
  ${PROJECT_ROOT_DIR}/src/core/lib/profiling/basic_timers.c
  ${PROJECT_ROOT_DIR}/src/core/lib/profiling/stap_timers.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/alloc.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/arena.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/atm.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/avl.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/backoff.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/cmdline.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/cpu_iphone.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/cpu_linux.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/cpu_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/cpu_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/env_linux.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/env_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/env_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/histogram.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/host_port.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/log.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/log_android.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/log_linux.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/log_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/log_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/mpscq.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/murmur_hash.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/stack_lockfree.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/string.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/string_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/string_util_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/string_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/subprocess_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/subprocess_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/sync.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/sync_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/sync_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/thd.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/thd_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/thd_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/time.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/time_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/time_precise.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/time_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/tls_pthread.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/tmpfile_msys.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/tmpfile_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/tmpfile_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/support/wrap_memcpy.c
)

target_include_directories(gpr
  PRIVATE ${PROJECT_ROOT_DIR}
  PRIVATE ${PROJECT_ROOT_DIR}/include
  PRIVATE ${BORINGSSL_ROOT_DIR}/include
  PRIVATE ${PROTOBUF_ROOT_DIR}/src
  PRIVATE ${ZLIB_INCLUDE_DIR}
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/third_party/zlib
  PRIVATE ${CARES_BUILD_INCLUDE_DIR}
  PRIVATE ${CARES_INCLUDE_DIR}
  PRIVATE ${CARES_PLATFORM_INCLUDE_DIR}
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/third_party/cares/cares
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/third_party/gflags/include
)

target_link_libraries(gpr
  ${_gRPC_ALLTARGETS_LIBRARIES}
)


foreach(_hdr
  ${PROJECT_ROOT_DIR}/include/grpc/support/alloc.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/atm.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/atm_gcc_atomic.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/atm_gcc_sync.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/atm_windows.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/avl.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/cmdline.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/cpu.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/histogram.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/host_port.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/log.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/log_windows.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/port_platform.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/string_util.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/subprocess.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/sync.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/sync_generic.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/sync_posix.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/sync_windows.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/thd.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/time.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/tls.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/tls_gcc.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/tls_msvc.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/tls_pthread.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/useful.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/atm.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/atm_gcc_atomic.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/atm_gcc_sync.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/atm_windows.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/gpr_slice.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/gpr_types.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/port_platform.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/sync.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/sync_generic.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/sync_posix.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/sync_windows.h
)
  string(REPLACE "include/" "" _path ${_hdr})
  get_filename_component(_path ${_path} PATH)
  install(FILES ${_hdr}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${_path}"
  )
endforeach()

  
install(TARGETS gpr
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

  
add_library(grpc STATIC
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/init.c
  ${PROJECT_ROOT_DIR}/src/core/lib/channel/channel_args.c
  ${PROJECT_ROOT_DIR}/src/core/lib/channel/channel_stack.c
  ${PROJECT_ROOT_DIR}/src/core/lib/channel/channel_stack_builder.c
  ${PROJECT_ROOT_DIR}/src/core/lib/channel/connected_channel.c
  ${PROJECT_ROOT_DIR}/src/core/lib/channel/handshaker.c
  ${PROJECT_ROOT_DIR}/src/core/lib/channel/handshaker_factory.c
  ${PROJECT_ROOT_DIR}/src/core/lib/channel/handshaker_registry.c
  ${PROJECT_ROOT_DIR}/src/core/lib/compression/compression.c
  ${PROJECT_ROOT_DIR}/src/core/lib/compression/message_compress.c
  ${PROJECT_ROOT_DIR}/src/core/lib/http/format_request.c
  ${PROJECT_ROOT_DIR}/src/core/lib/http/httpcli.c
  ${PROJECT_ROOT_DIR}/src/core/lib/http/parser.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/closure.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/combiner.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/endpoint.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/endpoint_pair_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/endpoint_pair_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/endpoint_pair_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/error.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/ev_epoll1_linux.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/ev_epoll_limited_pollers_linux.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/ev_epoll_thread_pool_linux.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/ev_epollex_linux.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/ev_epollsig_linux.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/ev_poll_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/ev_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/ev_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/exec_ctx.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/executor.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/iocp_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/iomgr.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/iomgr_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/iomgr_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/iomgr_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/is_epollexclusive_available.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/load_file.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/lockfree_event.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/network_status_tracker.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/polling_entity.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/pollset_set_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/pollset_set_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/pollset_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/pollset_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/resolve_address_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/resolve_address_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/resolve_address_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/resource_quota.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/sockaddr_utils.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/socket_factory_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/socket_mutator.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/socket_utils_common_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/socket_utils_linux.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/socket_utils_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/socket_utils_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/socket_utils_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/socket_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_client_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_client_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_client_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_server_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_server_utils_posix_common.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_server_utils_posix_ifaddrs.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_server_utils_posix_noifaddrs.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_server_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_server_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/tcp_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/time_averaged_stats.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/timer_generic.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/timer_heap.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/timer_manager.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/timer_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/udp_server.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/unix_sockets_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/unix_sockets_posix_noop.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/wakeup_fd_cv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/wakeup_fd_eventfd.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/wakeup_fd_nospecial.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/wakeup_fd_pipe.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/wakeup_fd_posix.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/workqueue_uv.c
  ${PROJECT_ROOT_DIR}/src/core/lib/iomgr/workqueue_windows.c
  ${PROJECT_ROOT_DIR}/src/core/lib/json/json.c
  ${PROJECT_ROOT_DIR}/src/core/lib/json/json_reader.c
  ${PROJECT_ROOT_DIR}/src/core/lib/json/json_string.c
  ${PROJECT_ROOT_DIR}/src/core/lib/json/json_writer.c
  ${PROJECT_ROOT_DIR}/src/core/lib/slice/b64.c
  ${PROJECT_ROOT_DIR}/src/core/lib/slice/percent_encoding.c
  ${PROJECT_ROOT_DIR}/src/core/lib/slice/slice.c
  ${PROJECT_ROOT_DIR}/src/core/lib/slice/slice_buffer.c
  ${PROJECT_ROOT_DIR}/src/core/lib/slice/slice_hash_table.c
  ${PROJECT_ROOT_DIR}/src/core/lib/slice/slice_intern.c
  ${PROJECT_ROOT_DIR}/src/core/lib/slice/slice_string_helpers.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/alarm.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/api_trace.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/byte_buffer.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/byte_buffer_reader.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/call.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/call_details.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/call_log_batch.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/channel.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/channel_init.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/channel_ping.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/channel_stack_type.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/completion_queue.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/completion_queue_factory.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/event_string.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/lame_client.cc
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/metadata_array.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/server.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/validate_metadata.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/version.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/bdp_estimator.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/byte_stream.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/connectivity_state.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/error_utils.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/metadata.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/metadata_batch.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/pid_controller.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/service_config.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/static_metadata.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/status_conversion.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/timeout_encoding.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/transport.c
  ${PROJECT_ROOT_DIR}/src/core/lib/transport/transport_op_string.c
  ${PROJECT_ROOT_DIR}/src/core/lib/debug/trace.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/server/secure/server_secure_chttp2.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/bin_decoder.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/bin_encoder.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/chttp2_plugin.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/chttp2_transport.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/frame_data.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/frame_goaway.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/frame_ping.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/frame_rst_stream.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/frame_settings.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/frame_window_update.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/hpack_encoder.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/hpack_parser.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/hpack_table.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/http2_settings.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/huffsyms.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/incoming_metadata.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/parsing.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/stream_lists.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/stream_map.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/varint.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/transport/writing.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/alpn/alpn.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/http/client/http_client_filter.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/http/http_filters_plugin.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/http/message_compress/message_compress_filter.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/http/server/http_server_filter.c
  ${PROJECT_ROOT_DIR}/src/core/lib/http/httpcli_security_connector.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/context/security_context.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/composite/composite_credentials.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/credentials.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/credentials_metadata.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/fake/fake_credentials.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/google_default/credentials_generic.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/google_default/google_default_credentials.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/iam/iam_credentials.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/jwt/json_token.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/jwt/jwt_credentials.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/jwt/jwt_verifier.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/oauth2/oauth2_credentials.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/plugin/plugin_credentials.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/credentials/ssl/ssl_credentials.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/transport/client_auth_filter.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/transport/lb_targets_info.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/transport/secure_endpoint.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/transport/security_connector.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/transport/security_handshaker.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/transport/server_auth_filter.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/transport/tsi_error.c
  ${PROJECT_ROOT_DIR}/src/core/lib/security/util/json_util.c
  ${PROJECT_ROOT_DIR}/src/core/lib/surface/init_secure.c
  ${PROJECT_ROOT_DIR}/src/core/tsi/fake_transport_security.c
  ${PROJECT_ROOT_DIR}/src/core/tsi/ssl_transport_security.c
  ${PROJECT_ROOT_DIR}/src/core/tsi/transport_security.c
  ${PROJECT_ROOT_DIR}/src/core/tsi/transport_security_adapter.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/server/chttp2_server.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/client/secure/secure_channel_create.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/channel_connectivity.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/client_channel.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/client_channel_factory.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/client_channel_plugin.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/connector.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/http_connect_handshaker.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/http_proxy.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy_factory.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy_registry.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/parse_address.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/proxy_mapper.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/proxy_mapper_registry.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/resolver.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/resolver_factory.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/resolver_registry.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/retry_throttle.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/subchannel.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/subchannel_index.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/uri_parser.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/deadline/deadline_filter.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/client/chttp2_connector.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/server/insecure/server_chttp2.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/server/insecure/server_chttp2_posix.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/client/insecure/channel_create.c
  ${PROJECT_ROOT_DIR}/src/core/ext/transport/chttp2/client/insecure/channel_create_posix.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy/grpclb/client_load_reporting_filter.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy/grpclb/grpclb.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy/grpclb/grpclb_channel_secure.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy/grpclb/grpclb_client_stats.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy/grpclb/load_balancer_api.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy/grpclb/proto/grpc/lb/v1/load_balancer.pb.c
  ${PROJECT_ROOT_DIR}/third_party/nanopb/pb_common.c
  ${PROJECT_ROOT_DIR}/third_party/nanopb/pb_decode.c
  ${PROJECT_ROOT_DIR}/third_party/nanopb/pb_encode.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy/pick_first/pick_first.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/lb_policy/round_robin/round_robin.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/resolver/dns/c_ares/dns_resolver_ares.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/resolver/dns/c_ares/grpc_ares_ev_driver_posix.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/resolver/dns/c_ares/grpc_ares_wrapper.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/resolver/dns/native/dns_resolver.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/client_channel/resolver/sockaddr/sockaddr_resolver.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/load_reporting/load_reporting.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/load_reporting/load_reporting_filter.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/base_resources.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/context.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/gen/census.pb.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/gen/trace_context.pb.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/grpc_context.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/grpc_filter.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/grpc_plugin.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/initialize.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/intrusive_hash_map.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/mlog.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/operation.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/placeholders.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/resource.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/trace_context.c
  ${PROJECT_ROOT_DIR}/src/core/ext/census/tracing.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/max_age/max_age_filter.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/message_size/message_size_filter.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/workarounds/workaround_cronet_compression_filter.c
  ${PROJECT_ROOT_DIR}/src/core/ext/filters/workarounds/workaround_utils.c
  ${PROJECT_ROOT_DIR}/src/core/plugin_registry/grpc_plugin_registry.c
)

target_include_directories(grpc
  PRIVATE ${PROJECT_ROOT_DIR}
  PRIVATE ${PROJECT_ROOT_DIR}/include
  PRIVATE ${BORINGSSL_ROOT_DIR}/include
  PRIVATE ${PROTOBUF_ROOT_DIR}/src
  PRIVATE ${ZLIB_INCLUDE_DIR}
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/third_party/zlib
  PRIVATE ${CARES_BUILD_INCLUDE_DIR}
  PRIVATE ${CARES_INCLUDE_DIR}
  PRIVATE ${CARES_PLATFORM_INCLUDE_DIR}
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/third_party/cares/cares
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/third_party/gflags/include
)

target_link_libraries(grpc
  ${_gRPC_BASELIB_LIBRARIES}
  ${_gRPC_SSL_LIBRARIES}
  ${_gRPC_ZLIB_LIBRARIES}
  ${_gRPC_CARES_LIBRARIES}
  ${_gRPC_ALLTARGETS_LIBRARIES}
  gpr
)

foreach(_hdr
  ${PROJECT_ROOT_DIR}/include/grpc/grpc.h
  ${PROJECT_ROOT_DIR}/include/grpc/grpc_posix.h
  ${PROJECT_ROOT_DIR}/include/grpc/grpc_security_constants.h
  ${PROJECT_ROOT_DIR}/include/grpc/load_reporting.h
  ${PROJECT_ROOT_DIR}/include/grpc/slice.h
  ${PROJECT_ROOT_DIR}/include/grpc/slice_buffer.h
  ${PROJECT_ROOT_DIR}/include/grpc/status.h
  ${PROJECT_ROOT_DIR}/include/grpc/support/workaround_list.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/byte_buffer_reader.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/compression_types.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/connectivity_state.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/exec_ctx_fwd.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/grpc_types.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/propagation_bits.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/slice.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/status.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/atm.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/atm_gcc_atomic.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/atm_gcc_sync.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/atm_windows.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/gpr_slice.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/gpr_types.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/port_platform.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/sync.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/sync_generic.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/sync_posix.h
  ${PROJECT_ROOT_DIR}/include/grpc/impl/codegen/sync_windows.h
  ${PROJECT_ROOT_DIR}/include/grpc/grpc_security.h
  ${PROJECT_ROOT_DIR}/include/grpc/census.h
)
  string(REPLACE "include/" "" _path ${_hdr})
  get_filename_component(_path ${_path} PATH)
  install(FILES ${_hdr}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${_path}"
  )
endforeach()

  
install(TARGETS grpc
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

  
add_library(grpc_csharp_ext SHARED
#  ${PROJECT_ROOT_DIR}/src/csharp/ext/grpc_csharp_ext.c
  src/csharp/ext/grpc_csharp_ext.c
)

target_include_directories(grpc_csharp_ext
  PRIVATE ${PROJECT_ROOT_DIR}
  PRIVATE ${PROJECT_ROOT_DIR}/include
  PRIVATE ${BORINGSSL_ROOT_DIR}/include
  PRIVATE ${PROTOBUF_ROOT_DIR}/src
  PRIVATE ${ZLIB_INCLUDE_DIR}
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/third_party/zlib
  PRIVATE ${CARES_BUILD_INCLUDE_DIR}
  PRIVATE ${CARES_INCLUDE_DIR}
  PRIVATE ${CARES_PLATFORM_INCLUDE_DIR}
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/third_party/cares/cares
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/third_party/gflags/include
)

find_library(log-lib log)

target_link_libraries(grpc_csharp_ext
  ${_gRPC_ALLTARGETS_LIBRARIES}
  grpc
  gpr
  ${log-lib}
)

install(TARGETS grpc_csharp_ext
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
