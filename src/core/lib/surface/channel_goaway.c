#include "src/core/lib/surface/channel.h"

#include <string.h>

#include <grpc/support/alloc.h>
#include <grpc/support/log.h>

#include "src/core/lib/slice/slice_internal.h"
#include "src/core/lib/surface/api_trace.h"

struct goaway_cleanup_args {
	grpc_closure closure;
	grpc_slice slice;
};

static void goaway_cleanup(grpc_exec_ctx *exec_ctx, void *arg,
	grpc_error *error) {
	struct goaway_cleanup_args *a = arg;
	grpc_slice_unref_internal(exec_ctx, a->slice);
	gpr_free(a);
}

void grpc_channel_goaway(grpc_channel *channel) {
	GRPC_API_TRACE("grpc_channel_goaway(channel=%p)", 1, (channel));

	grpc_exec_ctx exec_ctx = GRPC_EXEC_CTX_INIT;

	struct goaway_cleanup_args *gc = gpr_malloc(sizeof(*gc));
	grpc_closure_init(&gc->closure, goaway_cleanup, gc,
		grpc_schedule_on_exec_ctx);
	grpc_transport_op *op = grpc_make_transport_op(&gc->closure);
	grpc_channel_element *elem;

	op->goaway_error = grpc_error_set_int(GRPC_ERROR_CREATE("Server send GOAWAY"), GRPC_ERROR_INT_GRPC_STATUS, GRPC_STATUS_OK);
	op->set_accept_stream = true;
	gc->slice = grpc_slice_from_copied_string("Server send GOAWAY");
	op->disconnect_with_error = GRPC_ERROR_NONE;

	elem = grpc_channel_stack_element(grpc_channel_get_channel_stack(channel), 0);
	elem->filter->start_transport_op(&exec_ctx, elem, op);

	grpc_exec_ctx_finish(&exec_ctx);
}
