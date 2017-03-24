#include "grpc_android.h"

#include "src/core/lib/iomgr/port.h"

#ifdef GRPC_POSIX_SOCKET
#ifndef GRPC_LINUX_EPOLL
#include "src/core/lib/iomgr/wakeup_fd_posix.h"
grpc_wakeup_fd grpc_global_wakeup_fd;
#endif
#endif
