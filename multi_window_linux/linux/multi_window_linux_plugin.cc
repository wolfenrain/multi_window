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

// Called when a method call is received from Flutter.
static void multi_window_linux_plugin_handle_method_call(
    MultiWindowLinuxPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "create")== 0) {
    FlView* view = fl_plugin_registrar_get_view(self->registrar);
    if (view != nullptr) {
      GtkWindow* current_window = GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
      GtkApplication* application = gtk_window_get_application(current_window);

      // Stolen
      GtkWindow* new_window =
          GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

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
        GtkHeaderBar *header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
        gtk_widget_show(GTK_WIDGET(header_bar));
        gtk_header_bar_set_title(header_bar, "example");
        gtk_header_bar_set_show_close_button(header_bar, TRUE);
        gtk_window_set_titlebar(new_window, GTK_WIDGET(header_bar));
      }
      else {
        gtk_window_set_title(new_window, "example");
      }

      gtk_window_set_default_size(new_window, 1280, 720);
      gtk_widget_show(GTK_WIDGET(new_window));

      g_autoptr(FlDartProject) project = fl_dart_project_new();
      // fl_dart_project_set_dart_entrypoint_arguments(project, application->dart_entrypoint_arguments);

      FlView* view = fl_view_new(project);
      gtk_widget_show(GTK_WIDGET(view));
      gtk_container_add(GTK_CONTAINER(new_window), GTK_WIDGET(view));

      fl_register_plugins(FL_PLUGIN_REGISTRY(view));

      gtk_widget_grab_focus(GTK_WIDGET(view));

      response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string("hi")));
    } else {
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string("fuck")));
    }
  } else if (strcmp(method, "destroy") == 0) {
    // gtk_application_remove_window();
  } else  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
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

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "multi_window_linux",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
