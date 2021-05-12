#include "include/multi_window_linux/multi_window_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#include <sys/utsname.h>

#include "flutter/generated_plugin_registrant.h"

#include "event_channel_listener.cc"
#include <cstring>
#include <string>
#include <functional>

#define MULTI_WINDOW_LINUX_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), multi_window_linux_plugin_get_type(), \
                              MultiWindowLinuxPlugin))

struct _MultiWindowLinuxPlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;
};

G_DEFINE_TYPE(MultiWindowLinuxPlugin, multi_window_linux_plugin, g_object_get_type())

static FlValue* get_args(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return fl_value_new_map();
  }
  return args;
}

gint comp(gpointer pa, gpointer pb) {
  // TODO: invalid uninstantiatable type '(null)' in cast to 'GObject'
  __attribute__((unused)) GObject *a = G_OBJECT(pa), *b = G_OBJECT(pb);

  // __attribute__((unused)) gchar *a_key = (gchar *)g_object_get_data(a, "key");
  // __attribute__((unused)) gchar *b_key = (gchar *)g_object_get_data(b, "key");

  // const gchar *a_key = g_value_get_string(g_a_key); 
  // const gchar *b_key = g_value_get_string(g_b_key); 

  return 1; // strcmp(a_key, b_key);
}

static GtkWindow* get_window(MultiWindowLinuxPlugin* self, FlValue* args) {
  const gchar *key = fl_value_get_string(fl_value_get_map_value(args, 0));
  if (key == NULL || key[0] == '\0') {
    return nullptr;
  }
  
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (strcmp(key, "main") == 0) {
    return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
  }

  GtkWindow *tmp_window = GTK_WINDOW(gtk_window_new(GTK_WINDOW_TOPLEVEL));
  g_object_set_data(G_OBJECT(tmp_window), "key", (gpointer)key);

  GList* toplevels = gtk_window_list_toplevels();
  g_list_foreach(toplevels, (GFunc)g_object_ref, NULL); // TODO might not need
  
  GList* window_result = g_list_find_custom(toplevels, &tmp_window, (GCompareFunc) comp);
  g_list_foreach(toplevels, (GFunc)g_object_unref, NULL); // TODO might not need
  
  if (window_result == nullptr) {
    return nullptr;
  }
  return GTK_WINDOW(window_result->data);
  // return nullptr;
}

static void register_event_channel(MultiWindowLinuxPlugin* self, const gchar *key) {
  EventChannelListener listener = EventChannelListener(
    key, 
    [](FlEventChannel* channel, FlValue* args, gpointer user_data) -> FlMethodErrorResponse* {
      return nullptr;
    },
    [](FlEventChannel* channel, FlValue* args, gpointer user_data) -> FlMethodErrorResponse* {
      return nullptr;
    }
  );

  std::string name = "multi_window_linux/events/" + std::string(key);

  // Setup event channel.
  g_autoptr(FlEventChannel) events_channel = 
      fl_event_channel_new(fl_plugin_registrar_get_messenger(self->registrar), 
                            name.c_str(), 
                            FL_METHOD_CODEC(fl_standard_method_codec_new()));
  fl_event_channel_set_stream_handlers(events_channel, listener.on_listen,
                                        listener.on_cancel, nullptr,
                                        nullptr);
}

static FlMethodResponse* create(MultiWindowLinuxPlugin* self, FlMethodCall* method_call) {
  FlValue* args = get_args(method_call);

  // TODO: check if we already have a window with given key.
  // Check if we already have a window with given key.
  if (get_window(self, args) != nullptr) {
    return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
  }

  const gchar* key = fl_value_get_string(fl_value_get_map_value(args, 0));
  if (key == NULL || key[0] == '\0') {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("MISSING_PARAMS", "Missing 'key' parameter", nullptr));
  }
    
  // Registering a channel first, before starting a new flutter project.
  register_event_channel(self, key);

  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view != nullptr) {
    GtkWindow* current_window = GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
    GtkApplication* application = gtk_window_get_application(current_window);

    GtkWindow* new_window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
    
    g_object_set_data(G_OBJECT(new_window), "key", (gpointer)key);
    
    GtkHeaderBar* current_header_bar = (GtkHeaderBar*) gtk_window_get_titlebar(current_window);

    if (current_header_bar != nullptr) {
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

static FlMethodResponse* set_title(MultiWindowLinuxPlugin* self, FlMethodCall* method_call) {
  FlValue* args = get_args(method_call);

  GtkWindow* window = get_window(self, args);
  if (window == nullptr) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("ERROR", "Could not find the window", nullptr));
  }

  const gchar* title = fl_value_get_string(fl_value_get_map_value(args, 1));
  if (title == NULL || title[0] == '\0') {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("MISSING_PARAMS", "Missing 'title' parameter", nullptr));
  }

  GtkHeaderBar* current_header_bar = (GtkHeaderBar*) gtk_window_get_titlebar(window);
  if (current_header_bar != nullptr) {
    gtk_header_bar_set_title(current_header_bar, title);
  }else {
    gtk_window_set_title(window, title);
  }

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
}

static FlMethodResponse* get_title(MultiWindowLinuxPlugin* self, FlMethodCall* method_call) {
  FlValue* args = get_args(method_call);

  GtkWindow* window = get_window(self, args);
  if (window == nullptr) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("ERROR", "Could not find the window", nullptr));
  }

  GtkHeaderBar* current_header_bar = (GtkHeaderBar*) gtk_window_get_titlebar(window);
  const gchar* title;

  if (current_header_bar != nullptr) {
    title = gtk_header_bar_get_title(current_header_bar);
  }else {
    title = gtk_window_get_title(window);
  }

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string(title)));
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
  } else if (strcmp(method, "emit") == 0) {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
  } else if (strcmp(method, "getTitle") == 0) {
    response = get_title(self, method_call);
  } else if (strcmp(method, "setTitle") == 0) {
    response = set_title(self, method_call);
  } else if (strcmp(method, "create") == 0) {
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

  register_event_channel(plugin, "main");

  g_object_unref(plugin);
}
