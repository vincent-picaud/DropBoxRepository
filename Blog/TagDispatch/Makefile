CXX	:= g++

all:  sfinae_fix tag_usual priority_raw priority static_if sfinae

sfinae: sfinae.cpp
	$(CXX) -std=c++11 sfinae.cpp -o sfinae

sfinae_fix: sfinae_fix.cpp
	$(CXX) -std=c++11 sfinae_fix.cpp -o sfinae_fix

tag_usual: tag_usual.cpp
	$(CXX) -std=c++11 tag_usual.cpp -o tag_usual

priority_raw: priority_raw.cpp
	$(CXX) -std=c++11 priority_raw.cpp -o priority_raw

priority: priority.cpp
	$(CXX) -std=c++14 priority.cpp -o priority

static_if: static_if.cpp
	$(CXX) -std=c++14 static_if.cpp -o static_if
