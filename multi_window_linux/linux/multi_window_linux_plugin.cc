#include "include/multi_window_linux/multi_window_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#include <sys/utsname.h>

#include "flutter/generated_plugin_registrant.h"

#include <cstring>

#define MULTI_WINDOW_LINUX_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), multi_window_linux_plugin_get_type(), \
                              MultiWindowLinuxPlugin))

struct _MultiWindowLinuxPlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;
};

G_DEFINE_TYPE(MultiWindowLinuxPlugin, multi_window_linux_plugin, g_object_get_type())

static FlMethodResponse* create(MultiWindowLinuxPlugin* self, FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("MISSING_PARAMS", "Expected map", nullptr));
  }

  const gchar* key = fl_value_get_string(fl_value_get_map_value(args, 0));
  if (key == NULL || key[0] == '\0') {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("MISSING_PARAMS", "Missing 'key' parameter", nullptr));
  }

  // TODO: check if we already have a window with given key.

  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view != nullptr) {
    /// TODO: read out key and use it to check if a window already exists.
    /// - `GtkWindow` is a indirect subclass of `GObject`, so `g_object_set` and `g_object_get` methods are applyable:
    ///   ```cpp
    ///   int pid = 12345;
    ///   GValue val = G_VALUE_INIT;
    ///   g_value_init (&val, G_TYPE_INT);
    ///   g_value_set_int (&val, pid);
    ///   g_object_set (G_OBJECT(window), "pID", &val, NULL); //add to GTKWindow
    ///   ```
    ///
    ///   ```cpp
    ///   GValue _pid;
    ///   g_object_get_property(G_OBJECT(window), "pID", &_pid);
    ///   ```
    
    GtkWindow* current_window = GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
    GtkApplication* application = gtk_window_get_application(current_window);

    GtkWindow* new_window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
    
    GValue g_key = G_VALUE_INIT;
    g_value_init(&g_key, G_TYPE_STRING);
    g_value_set_string(&g_key, key);
    g_object_set_data(G_OBJECT(new_window), "key", &g_key);
    
    // Use a header bar when running in GNOME as this is the common style used
    // by applications and is the setup most users will be using (e.g. Ubuntu
    // desktop).
    // If running on X and not using GNOME then just use a traditional title bar
    // in case the window manager does more exotic layout, e.g. tiling.
    // If running on Wayland assume the header bar will work (may need changing
    // if future cases occur).
    gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
    GdkScreen *screen = gtk_window_get_screen(new_window);
    if (GDK_IS_X11_SCREEN(screen)) {
      const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
      if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
        use_header_bar = FALSE;
      }
    }
#endif
    if (use_header_bar) {
      GtkHeaderBar* current_header_bar = (GtkHeaderBar*) gtk_window_get_titlebar(current_window);
      
      GtkHeaderBar *header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
      gtk_widget_show(GTK_WIDGET(header_bar));
      gtk_header_bar_set_title(header_bar, gtk_header_bar_get_title(current_header_bar));
      gtk_header_bar_set_show_close_button(header_bar, gtk_header_bar_get_show_close_button(current_header_bar));
      gtk_window_set_titlebar(new_window, GTK_WIDGET(header_bar));
    }else {
      gtk_window_set_title(new_window, gtk_window_get_title(current_window));
    }

    gtk_window_set_default_size(new_window, 1280, 720);
    gtk_widget_show(GTK_WIDGET(new_window));  

    char *args[] = { (char*)key, NULL };
    g_autoptr(FlDartProject) project = fl_dart_project_new();
    fl_dart_project_set_dart_entrypoint_arguments(project, args);

    FlView* view = fl_view_new(project);
    gtk_widget_show(GTK_WIDGET(view));
    gtk_container_add(GTK_CONTAINER(new_window), GTK_WIDGET(view));

    fl_register_plugins(FL_PLUGIN_REGISTRY(view));

    gtk_widget_grab_focus(GTK_WIDGET(view));

    return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
  } else {
    return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string("error?")));
  }
}

// Called when a method call is received from Flutter.
static void multi_window_linux_plugin_handle_method_call(MultiWindowLinuxPlugin* self, FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "count") == 0) {
    response = FL_METHOD_RESPONSE(
      fl_method_success_response_new(
        fl_value_new_int(g_list_length(gtk_window_list_toplevels()))
      )
    );
  } else if (strcmp(method, "create")== 0) {
    response = create(self, method_call);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void multi_window_linux_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(multi_window_linux_plugin_parent_class)->dispose(object);
}

static void multi_window_linux_plugin_class_init(MultiWindowLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = multi_window_linux_plugin_dispose;
}

static void multi_window_linux_plugin_init(MultiWindowLinuxPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  MultiWindowLinuxPlugin* plugin = MULTI_WINDOW_LINUX_PLUGIN(user_data);
  multi_window_linux_plugin_handle_method_call(plugin, method_call);
}

FlMethodErrorResponse* event_listen_cb(FlEventChannel* channel, FlValue* args, gpointer user_data) {
  // fl_event_channel_send(channel, )
  return nullptr;
}

FlMethodErrorResponse* event_cancel_cb(FlEventChannel* channel, FlValue* args, gpointer user_data) {
  return nullptr;
}

void multi_window_linux_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  MultiWindowLinuxPlugin* plugin = MULTI_WINDOW_LINUX_PLUGIN(
      g_object_new(multi_window_linux_plugin_get_type(), nullptr));

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));
  
  g_autoptr(FlBinaryMessenger) messenger = fl_plugin_registrar_get_messenger(registrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();

  // Setup method channel.
  g_autoptr(FlMethodChannel) method_channel =
      fl_method_channel_new(messenger,
                            "multi_window_linux",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(method_channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  // Setup event channel.
  g_autoptr(FlEventChannel) events_channel = 
      fl_event_channel_new(messenger, 
                            "multi_window_linux/events", 
                            FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(events_channel, event_listen_cb,
                                        event_cancel_cb, nullptr,
                                        nullptr);

  g_object_unref(plugin);
}
