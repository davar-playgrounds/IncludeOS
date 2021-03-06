
#include <common.cxx>
#include <net/http/time.hpp>

using namespace std::string_literals;

CASE("from_time_t() returns time as string")
{
  time_t epoch {0};
  std::string str {http::time::from_time_t(epoch)};
  EXPECT(str != "");
  EXPECT(str.find("1970") != std::string::npos);
}

CASE("to_time_t() returns time_t from string")
{
  auto str1 = "Tue, 01 Jan 1980 00:00:00 GMT"s;
  time_t time1 {http::time::to_time_t(str1)};
  EXPECT(time1 != std::time_t{});

  auto str2 = "Tuesday, 01-Jan-80 00:00:00 GMT"s;
  time_t time2 {http::time::to_time_t(str2)};
  EXPECT(time2 != std::time_t{});

  auto str3 = "Tue Jan  1 00:00:00 1980"s;
  time_t time3 {http::time::to_time_t(str3)};
  EXPECT(time3 != std::time_t{});

  // invalid
  auto str4 = "Zxe Jyn 32 23:59:99 1930"s;
  time_t time4 {http::time::to_time_t(str4)};
  EXPECT(time4 == std::time_t{});
}

CASE("now() returns current time")
{
  auto str = http::time::now();
  EXPECT(str.size() > 0ul);
}
