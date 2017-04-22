#ifndef GRPC_CORE_LIB_SURFACE_CHANNEL_GOAWAY_H
#define GRPC_CORE_LIB_SURFACE_CHANNEL_GOAWAY_H

#include <grpc/grpc.h>

#ifdef __cplusplus
extern "C" {
#endif

	void grpc_channel_goaway(grpc_channel *channel);

#ifdef __cplusplus
}
#endif

#endif /* GRPC_CORE_LIB_SURFACE_CHANNEL_GOAWAY_H */
