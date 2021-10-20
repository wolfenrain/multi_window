#include "include/multi_window_linux/multi_window_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#include <sys/utsname.h>

#include "flutter/generated_plugin_registrant.h"

#include "utils.cc"
#include <functional>
#include <iostream>
#include <list>
#include <map>
#include <algorithm>
#include <utility>

#define MULTI_WINDOW_LINUX_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), multi_window_linux_plugin_get_type(), \
                              MultiWindowLinuxPlugin))

struct _MultiWindowLinuxPlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;
};

std::map<std::string, GtkWindow*> windows = {};
std::map<std::string, FlEventChannel*> multi_event_channels = {};

G_DEFINE_TYPE(MultiWindowLinuxPlugin, multi_window_linux_plugin, g_object_get_type())

static void emitEvent(std::string key, std::string from, std::string type, FlValue* data) {
  log("Emitting event for %s", key.c_str());
  for(auto pair : multi_event_channels) {
    std::string eventKey = pair.first;
    FlEventChannel* eventChannel = pair.second;
    if (hasSuffix(eventKey, key) && eventChannel != nullptr) {
      FlValue* eventData = fl_value_new_map();
      fl_value_set_string(eventData, "to", fl_value_new_string(key.c_str()));
      fl_value_set_string(eventData, "from", fl_value_new_string(from.c_str()));
      fl_value_set_string(eventData, "type", fl_value_new_string(type.c_str()));
      fl_value_set_string(eventData, "data", data);
      fl_event_channel_send(eventChannel, eventData, NULL, NULL);
    }
  }
}

static gboolean on_window_quit(GtkWidget* widget, GdkEvent* event, gpointer user_data) {
  std::string key = std::find_if(std::begin(windows), std::end(windows), [&](const std::pair<std::string, GtkWindow*> &pair) {
    return GTK_WIDGET(pair.second) == widget;
  })->first;
  log("Closing window, %s", key.c_str());

  for(auto pair : multi_event_channels) {
    std::string eventKey = pair.first;
    if (eventKey.rfind(key + "/", 0) == 0) {
      multi_event_channels.erase(eventKey);
    }
  }

  windows.erase(key);

  FlValue* eventData = fl_value_new_map();
  fl_value_set_string(eventData, "event", fl_value_new_string("windowClose"));
  emitEvent(std::string(key), std::string(key), "system", eventData);
  return FALSE;
}

static FlValue* get_args(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return fl_value_new_map();
  }
  return args;
}

static GtkWindow* get_window(MultiWindowLinuxPlugin* self, FlValue* args) {
  const gchar* key = fl_value_get_string(fl_value_get_map_value(args, 0));
  if (key == NULL || key[0] == '\0') {
    return nullptr;
  }

  if (strcmp(key, "main") == 0) {
    return windows["main"];
  }

  if (windows.find(std::string(key)) != windows.end()) {
    return windows[std::string(key)];
  }

  return nullptr;
}

static FlMethodErrorResponse* on_listen(FlEventChannel* eventChannel, FlValue* args, gpointer user_data) {
  const gchar* key = fl_value_get_string(args);
  if (key == NULL || key[0] == '\0') {
    return fl_method_error_response_new("MISSING_PARAMS", "Missing 'key' parameter", nullptr);
  }
  log("EventChannelListener.on_listen => eventChannel for %s attached", key);

  multi_event_channels[key] = eventChannel;
  return nullptr;
}

static FlMethodErrorResponse* on_cancel(FlEventChannel* eventChannel, FlValue* args, gpointer user_data) {
  const gchar* key = fl_value_get_string(args);
  if (key == NULL || key[0] == '\0') {
    return fl_method_error_response_new("MISSING_PARAMS", "Missing 'key' parameter", nullptr);
  }
  log("EventChannelListener.on_listen => eventChannel for %s attached", key);

  multi_event_channels.erase(key);
  return nullptr;
}

static void register_event_channel(MultiWindowLinuxPlugin* self, std::string key) {
  log("Creating an EventChannel for %s", key.c_str());
  if (multi_event_channels.find(key + "/" + key) == multi_event_channels.end()) {
    multi_event_channels[key] = nullptr;
  }

  std::string name = "multi_window_linux/events/" + key;

  // Setup event channel.
  g_autoptr(FlEventChannel) events_channel = 
      fl_event_channel_new(fl_plugin_registrar_get_messenger(self->registrar), 
                            name.c_str(), 
                            FL_METHOD_CODEC(fl_standard_method_codec_new()));
  fl_event_channel_set_stream_handlers(events_channel, on_listen,
                                        on_cancel, nullptr,
                                        nullptr);
}

static FlMethodResponse* create(MultiWindowLinuxPlugin* self, FlMethodCall* method_call) {
  FlValue* args = get_args(method_call);

  if (get_window(self, args) != nullptr) {
    return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
  }
  
  const char* key = fl_value_get_string(fl_value_get_map_value(args, 0));
  if (key == NULL || key[0] == '\0') {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("MISSING_PARAMS", "Missing 'key' parameter", nullptr));
  }
  log("Creating new window %s", key);
    
  // Registering a channel first, before starting a new flutter project.
  register_event_channel(self, key);

  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view != nullptr) {
    GtkWindow* current_window = GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
    // Retrieve current window data
    gint current_window_x;
    gint current_window_y;
    gint current_window_width;
    gint current_window_height;
    
    gtk_window_get_position(current_window, &current_window_x, &current_window_y);
    gtk_window_get_size(current_window, &current_window_width, &current_window_height);

    GtkApplication* application = gtk_window_get_application(current_window);

    GtkWindow* new_window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

    // Listen to events on the new window.
    g_signal_connect(new_window, "delete-event", G_CALLBACK(on_window_quit), NULL);

    // Setup title.
    GtkHeaderBar* current_header_bar = (GtkHeaderBar*) gtk_window_get_titlebar(current_window);
    const char* title = fl_value_get_string(fl_value_get_map_value(args, 2));
    if (title == NULL || title[0] == '\0') {
      if (current_header_bar != nullptr) {
        title = gtk_header_bar_get_title(current_header_bar);
      } else {
        title = gtk_window_get_title(current_window);
      }
    }
    
    if (current_header_bar != nullptr) {
      GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
      gtk_widget_show(GTK_WIDGET(header_bar));
      gtk_header_bar_set_title(header_bar, title);
      gtk_header_bar_set_show_close_button(header_bar, gtk_header_bar_get_show_close_button(current_header_bar));
      gtk_window_set_titlebar(new_window, GTK_WIDGET(header_bar));
    } else {
      gtk_window_set_title(new_window, title);
    }

    // Setup size.
    gint width;
    gint height;
    FlValue* size = fl_value_get_map_value(args, 1);
    if (fl_value_get_type(size) == FL_VALUE_TYPE_MAP) {
      width = fl_value_get_int(fl_value_get_map_value(size, 0));
      height = fl_value_get_int(fl_value_get_map_value(size, 1));
    } else {
      gtk_window_get_size(current_window, &width, &height);
    }
    gtk_window_set_default_size(new_window, width, height);

    // Setup alignment.
    gint position_x = current_window_x + (current_window_width - width) / 2;
    gint position_y = current_window_y + (current_window_height - height) / 2;
    
    FlValue* alignment = fl_value_get_map_value(args, 3);
    if (fl_value_get_type(alignment) == FL_VALUE_TYPE_MAP) {
      gint alignment_x = fl_value_get_int(fl_value_get_map_value(alignment, 0));
      gint alignment_y = fl_value_get_int(fl_value_get_map_value(alignment, 1));
      
      GdkWindow* gdk_current_window = gtk_widget_get_window(GTK_WIDGET(current_window));
      GdkMonitor* monitor = gdk_display_get_monitor_at_window(gdk_window_get_display(gdk_current_window), gdk_current_window);
      GdkRectangle monitor_frame;
      gdk_monitor_get_geometry(monitor, &monitor_frame);

      if (alignment_x == 0) {
        // center
        position_x = monitor_frame.x + (monitor_frame.width - width) / 2;
      } else if (alignment_x == 1){
        // right
        position_x = monitor_frame.x +  monitor_frame.width - width;
      } else {
        // left
        position_x = monitor_frame.x;
      }

      if (alignment_y == 0) {
        // center
        position_y = monitor_frame.y + (monitor_frame.height - height) / 2;
      } else if (alignment_y == 1){
        // bottom
        position_y = monitor_frame.y +  monitor_frame.height - height;
      } else {
        // top
        position_y = monitor_frame.y;
      }
    }
    gtk_window_set_gravity(new_window, GDK_GRAVITY_NORTH_WEST);
    gtk_window_move(new_window, position_x, position_y);

    gtk_widget_show(GTK_WIDGET(new_window));  

    char* args[] = { (char*)key, NULL };
    g_autoptr(FlDartProject) project = fl_dart_project_new();
    fl_dart_project_set_dart_entrypoint_arguments(project, args);

    FlView* view = fl_view_new(project);
    gtk_widget_show(GTK_WIDGET(view));
    gtk_container_add(GTK_CONTAINER(new_window), GTK_WIDGET(view));

    fl_register_plugins(FL_PLUGIN_REGISTRY(view));

    gtk_widget_grab_focus(GTK_WIDGET(view));
    
    windows[std::string(key)] = new_window;

    return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
  } else {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("ERROR", "Could not setup FlView", nullptr));
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
  } else {
    title = gtk_window_get_title(window);
  }

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string(title)));
}

static FlMethodResponse* emit(MultiWindowLinuxPlugin* self, FlMethodCall* method_call) {
  FlValue* args = get_args(method_call);
  const gchar* key = fl_value_get_string(fl_value_get_map_value(args, 0));
  if (key == NULL || key[0] == '\0') {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("MISSING_PARAMS", "Missing 'key' parameter", nullptr));
  }
  const gchar* from = fl_value_get_string(fl_value_get_map_value(args, 1));
  if (from == NULL || from[0] == '\0') {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("MISSING_PARAMS", "Missing 'from' parameter", nullptr));
  }

  emitEvent(std::string(key), std::string(from), "user", fl_value_get_map_value(args, 2));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
}

static FlMethodResponse* close(MultiWindowLinuxPlugin* self, FlMethodCall* method_call) {
  FlValue* args = get_args(method_call);

  GtkWindow* window = get_window(self, args);
  if (window == nullptr) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("ERROR", "Could not find the window", nullptr));
  }

  gtk_window_close(window);

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
}

// Called when a method call is received from Flutter.
static void multi_window_linux_plugin_handle_method_call(MultiWindowLinuxPlugin* self, FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "count") == 0) {
    response = FL_METHOD_RESPONSE(
      fl_method_success_response_new(
        fl_value_new_int(windows.size())
      )
    );
  } else if (strcmp(method, "emit") == 0) {
    response = emit(self, method_call);
  } else if (strcmp(method, "close") == 0) {
    response = close(self, method_call);
  } else if (strcmp(method, "getTitle") == 0) {
    response = get_title(self, method_call);
  } else if (strcmp(method, "setTitle") == 0) {
    response = set_title(self, method_call);
  } else if (strcmp(method, "create") == 0) {
    response = create(self, method_call);
  } else if (strcmp(method, "close") == 0) {
    response = close(self, method_call);
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

  // Register main window to list.
  FlView* view = fl_plugin_registrar_get_view(plugin->registrar);

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

  if (multi_event_channels.size() == 0) {
    GtkWindow* main_window = GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
    windows["main"] = main_window;
    register_event_channel(plugin, "main");

    g_signal_connect(main_window, "delete-event", G_CALLBACK(on_window_quit), NULL);
  } else {
    for(auto pair : multi_event_channels) {
      std::string key = split(pair.first, std::string("/")).front();
      register_event_channel(plugin, key);
    }
  }

  g_object_unref(plugin);
}
