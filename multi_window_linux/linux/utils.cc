#include <stdarg.h>
#include <string>

static void log(std::string format, ...) {
  std::string log_line = "native: " + std::string(format) + "\n";

  va_list argptr;
  va_start(argptr, format);
  vprintf(log_line.c_str(), argptr);
  va_end(argptr);
}