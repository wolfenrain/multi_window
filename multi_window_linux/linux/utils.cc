#include <stdarg.h>
#include <string>
#include <vector>

using namespace std;

static void log(string format, ...) {
  string log_line = "native: " + std::string(format) + "\n";

  va_list argptr;
  va_start(argptr, format);
  vprintf(log_line.c_str(), argptr);
  va_end(argptr);
}

bool hasSuffix(string const &fullString, string const &ending) {
    if (fullString.length() >= ending.length()) {
        return (0 == fullString.compare (fullString.length() - ending.length(), ending.length(), ending));
    } else {
        return false;
    }
}

vector<string> split (string s, string delimiter) {
    size_t pos_start = 0, pos_end, delim_len = delimiter.length();
    string token;
    vector<string> res;

    while ((pos_end = s.find (delimiter, pos_start)) != string::npos) {
        token = s.substr (pos_start, pos_end - pos_start);
        pos_start = pos_end + delim_len;
        res.push_back (token);
    }

    res.push_back (s.substr (pos_start));
    return res;
}