extern "C" {

#ifdef WIN32
#define EXPORT_FUNC __declspec(dllexport)
#else
#define EXPORT_FUNC
#endif

#include "luajit.h"
#include "lauxlib.h"
#include "lualib.h"

#define TYPE_INVALID 0
#define TYPE_DOUBLE 1
#define TYPE_STRING 2

union Data {
  double f64;
  const char* str;
};

struct DataWithType {
  long long type;
  union Data data;
};

EXPORT_FUNC const char* GetError();
EXPORT_FUNC int Init(const char* rootdir, int max_result_size);
EXPORT_FUNC int StartInvoke(const char* name);
EXPORT_FUNC void FeedFloatArg(double f64);
EXPORT_FUNC void FeedStringArg(const char* str);
EXPORT_FUNC int Invoke(DataWithType* result);

}

#include <string>

class LuaInterface {
 public:
  static LuaInterface* Instance() {
    static LuaInterface instance;
    return &instance;
  }
  lua_State* State() { return L; }

  int init(const char* rootdir, int max_result_size) {
    max_result_size_ = max_result_size;
    std::string path = rootdir;
    path.append("/?.lua");
    std::string file = rootdir;
    file.append("/main.lua");
    L = luaL_newstate();
    luaopen_jit(L);
    luaJIT_setmode(L, 0, LUAJIT_MODE_ENGINE | LUAJIT_MODE_ON);
    luaL_openlibs(L);
    set_lua_path(path.c_str());
    if (luaL_loadfile(L, file.c_str()) != 0) {
      error_message_ = lua_tostring(L, -1);
      lua_pop(L, 1);
      return -1;
    }
    if (lua_pcall(L, 0, 0, 0) != 0) {
      error_message_ = lua_tostring(L, -1);
      lua_pop(L, 1);
      return -1;
    }
    lua_pushstring(L, "placeholder");
    return 0;
  }

  int set_lua_path(const char* path) {
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "path");
    std::string cur_path = lua_tostring(L, -1);
    cur_path.append(";");
    cur_path.append(path);
    lua_pop(L, 1);
    lua_pushstring(L, cur_path.c_str());
    lua_setfield(L, -2, "path");
    lua_pop(L, 1);
    return 0;
  }

  const char* error_message() {
    return error_message_.c_str();
  }

  void push_double(double f64) {
    lua_pushnumber(L, f64);
    arg_size_++;
  }

  void push_string(const char* str) {
    lua_pushstring(L, str);
    arg_size_++;
  }

  void start_run_func(const char* name) {
    lua_pop(L, 1);
    lua_getglobal(L, name);
  }

  int run_non_result_func() {
    if (lua_pcall(L, arg_size_, 1, 0) != 0) {
      error_message_ = lua_tostring(L, -1);
      lua_pop(L, 1);
      return -1;
    }
    return 0;
  }

  int run_func(DataWithType* result) {
    if (lua_pcall(L, arg_size_, 1, 0) != 0) {
      error_message_ = lua_tostring(L, -1);
      return -1;
    }
    return parse_result(result);
  }

  struct LuaStackHolder {
    LuaStackHolder(lua_State* L) : L_(L) {}
    ~LuaStackHolder() {
      lua_pop(L_, 1);
    }
    lua_State* L_;
  };

  DataWithType parse() {
    LuaStackHolder lsh(L);
    if (lua_isnumber(L, -1)) {
      return {.type = TYPE_DOUBLE, .data = {.f64 = lua_tonumber(L, -1)}};
    } else if (lua_isstring(L, -1)) {
      return {.type = TYPE_STRING, .data = {.str = lua_tostring(L, -1)}};
    } else {
      return {.type = TYPE_INVALID};
    }
  }

  int parse_result(DataWithType* result) {
    if (!lua_istable(L, -1)) {
      error_message_ = "error on parse: result is not table.";
      return -1;
    }
    int size = 0;
    lua_getfield(L, -1, "size");
    DataWithType parsed_size = parse();
    if (parsed_size.type != TYPE_DOUBLE) {
      error_message_ = "error on parse: size is not a number.";
      return -1;
    }
    size = parsed_size.data.f64;
    if (size > max_result_size_) {
      error_message_ = "max result size exceed.";
      return -1;
    }
    lua_getfield(L, -1, "vec");
    LuaStackHolder lsh(L);
    if (!lua_istable(L, -1)) {
      error_message_ = "error on parse: vec is not a table.";
      return -1;
    }
    lua_pushnil(L);
    while (lua_next(L, -2)) {
      if (lua_isnumber(L, -2)) {
        int id = lua_tonumber(L, -2);
        if (id <= size && id >= 1) {
          DataWithType parsed_value = parse();
          if (parsed_value.type != TYPE_INVALID) {
            result[id - 1] = parsed_value;
          } else {
            error_message_ = "error on parse: result type is invalid.";
            return -1;
          }
        } else {
          lua_pop(L, 1);
        }
      } else {
        lua_pop(L, 1);
      }
    }
    return size;
  }

 private:
  std::string error_message_;
  lua_State* L;
  int arg_size_;
  int max_result_size_;
};

const char* GetError() {
  return LuaInterface::Instance()->error_message();
}

int Init(const char* rootdir, int max_result_size) {
  return LuaInterface::Instance()->init(rootdir, max_result_size);
}

int StartInvoke(const char* name) {
  LuaInterface::Instance()->start_run_func("StartInvoke");
  int result = LuaInterface::Instance()->run_non_result_func();
  if (result != 0) {
    return result;
  }
  LuaInterface::Instance()->start_run_func("Invoke");
  LuaInterface::Instance()->push_string(name);
  return 0;
}

EXPORT_FUNC void FeedFloatArg(double f64) {
  LuaInterface::Instance()->push_double(f64);
}

EXPORT_FUNC void FeedStringArg(const char* str) {
  LuaInterface::Instance()->push_string(str);
}

EXPORT_FUNC int Invoke(DataWithType* result) {
  return LuaInterface::Instance()->run_func(result);
}

#ifdef TEST

#include <iostream>

int main() {
  DataWithType* result = new DataWithType[1 << 20];
  std::cout << Init("./script", 1 << 20) << std::endl;
  std::cout << StartInvoke("game.get_prototype") << std::endl;
  FeedFloatArg(16);
  std::cout << Invoke(result) << std::endl;
  std::cout << GetError() << std::endl;
  std::cout << result[0].data.str << std::endl;
}

#endif
