#include "include/multi_window_windows/multi_window_windows_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

namespace {

class MultiWindowWindowsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);
 
  MultiWindowWindowsPlugin(flutter::PluginRegistrarWindows& registrar) : registrar(registrar);

  virtual ~MultiWindowWindowsPlugin();

  flutter::PluginRegistrarWindows *registrar;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

static void register_event_channel(MultiWindowWindowsPlugin* self, std::string key) {
  // log("Creating an EventChannel for %s", key.c_str());
  // if (multi_event_channels.find(key + "/" + key) == multi_event_channels.end()) {
  //   multi_event_channels[key] = nullptr;
  // }

  std::string name = "multi_window_windows/events/" + key;

  // Setup event channel.
  auto event_channel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
    self.registrar->messenger(), 
    name,
    &flutter::StandardMethodCodec::GetInstance()
  );
  
  // event_channel.
  // g_autoptr(FlEventChannel) events_channel = 
  //     fl_event_channel_new(fl_plugin_registrar_get_messenger(self->registrar), 
  //                           name.c_str(), 
  //                           FL_METHOD_CODEC(fl_standard_method_codec_new()));
  // fl_event_channel_set_stream_handlers(events_channel, on_listen,
  //                                       on_cancel, nullptr,
  //                                       nullptr);
}


// static
void MultiWindowWindowsPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<MultiWindowWindowsPlugin>(registrar);

  // Setup method channel
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "multi_window_windows",
          &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });
      
  register_event_channel(plugin.get(), "main");

  registrar->AddPlugin(std::move(plugin));
}

MultiWindowWindowsPlugin::MultiWindowWindowsPlugin() {}

MultiWindowWindowsPlugin::~MultiWindowWindowsPlugin() {}

void MultiWindowWindowsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method.compare("count")) {
    result->Success(flutter::EncodableValue(1));
  } else if (method.compare("emit")) {
    // result->Success(emit(self, method_call));
    result->NotImplemented();
  } else if (method.compare("getTitle")) {
    // result->Success(get_title(self, method_call));
    result->NotImplemented();
  } else if (method.compare("setTitle")) {
    // result->Success(set_title(self, method_call));
    result->NotImplemented();
  } else if (method.compare("create")) {
    // result->Success(create(self, method_call));
    result->NotImplemented();
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void MultiWindowWindowsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  MultiWindowWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
