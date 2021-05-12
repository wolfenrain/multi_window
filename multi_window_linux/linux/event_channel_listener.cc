#include "include/multi_window_linux/multi_window_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <functional>
#include <utility>

struct EventChannelListener {
    const gchar *key;

    EventChannelListener(
        const gchar *key, 
        FlEventChannelHandler onListen,
        FlEventChannelHandler onCancel
    ) : key(key), on_listen {std::move(onListen)}, on_cancel {std::move(onCancel)} {}

    FlEventChannelHandler on_listen;
    FlEventChannelHandler on_cancel;
};